package cli

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"time"

	"github.com/santhosh-tekuri/jsonschema/v5"
)

var safeEnvKeyRegex = regexp.MustCompile(`^SAFE_[A-Z0-9_]+$`)

const (
	reasonPlanSchemaInvalid = "HUNBUP_PLAN_SCHEMA_INVALID"
	reasonActionTypeInvalid = "HUNBUP_ACTION_TYPE_NOT_ALLOWED"
	reasonCommandNotAllowed = "HUNBUP_COMMAND_ID_NOT_ALLOWED"
	reasonEnvKeyNotAllowed  = "HUNBUP_ENV_KEY_NOT_ALLOWED"
)

type planLocalExecAction struct {
	ID         string            `json:"id"`
	Type       string            `json:"type"`
	CommandID  string            `json:"command_id"`
	Args       []string          `json:"args"`
	TimeoutSec int               `json:"timeout_sec"`
	Env        map[string]string `json:"env"`
}

type planFile struct {
	Version   string                `json:"version"`
	RequestID string                `json:"request_id"`
	Actions   []planLocalExecAction `json:"actions"`
}

type resultArtifact struct {
	Path   string `json:"path"`
	SHA256 string `json:"sha256"`
}

type resultAction struct {
	ID            string           `json:"id"`
	Status        string           `json:"status"`
	Artifacts     []resultArtifact `json:"artifacts"`
	StdoutSummary string           `json:"stdout_summary"`
	StderrSummary string           `json:"stderr_summary"`
}

type resultFile struct {
	Version   string         `json:"version"`
	RequestID string         `json:"request_id"`
	Actions   []resultAction `json:"actions"`
}

type evidenceAction struct {
	ID           string            `json:"id"`
	ExecutedAt   string            `json:"executed_at"`
	Runner       string            `json:"runner"`
	Command      []string          `json:"command"`
	CWD          string            `json:"cwd"`
	UID          int               `json:"uid"`
	GID          int               `json:"gid"`
	SanitizedEnv map[string]string `json:"sanitized_env"`
	TimeoutSec   int               `json:"timeout_sec"`
	ExitCode     int               `json:"exit_code"`
	StdoutPath   string            `json:"stdout_path"`
	StderrPath   string            `json:"stderr_path"`
	StdoutHash   string            `json:"stdout_hash"`
	StderrHash   string            `json:"stderr_hash"`
	InputsHash   string            `json:"inputs_hash"`
	OutputsHash  string            `json:"outputs_hash"`
}

type evidencePlatform struct {
	Node string `json:"node"`
	OS   string `json:"os"`
	Arch string `json:"arch"`
}

type evidenceFile struct {
	Version   string           `json:"version"`
	RequestID string           `json:"request_id"`
	Actions   []evidenceAction `json:"actions"`
	Platform  evidencePlatform `json:"platform"`
}

func Execute(cmd Command) int {
	switch cmd.Name {
	case CmdValidate:
		return handleValidate(cmd)
	case CmdRun:
		return handleRun(cmd)
	case CmdAudit:
		return notImplemented("audit")
	default:
		fmt.Fprintln(os.Stderr, "unknown command")
		return 2
	}
}

func handleValidate(cmd Command) int {
	schemaPath := resolvePlanSchemaPath()
	if schemaPath == "" {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	schemaCompiler := jsonschema.NewCompiler()
	schema, err := schemaCompiler.Compile(schemaPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	data, err := os.ReadFile(cmd.PlanPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	var v any
	if err := json.Unmarshal(data, &v); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	if err := schema.Validate(v); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	return 0
}

func handleRun(cmd Command) int {
	plan, planBytes, ok := loadAndValidatePlan(cmd.PlanPath)
	if !ok {
		return 1
	}

	if len(plan.Actions) != 1 {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	action := plan.Actions[0]
	if action.Type != "local_exec" {
		fmt.Fprintln(os.Stderr, reasonActionTypeInvalid)
		return 1
	}

	resolvedCmd, resolveOK := resolveLocalCommand(action.CommandID, action.Args)
	if !resolveOK {
		fmt.Fprintln(os.Stderr, reasonCommandNotAllowed)
		return 1
	}

	if !isSafeEnv(action.Env) {
		fmt.Fprintln(os.Stderr, reasonEnvKeyNotAllowed)
		return 1
	}

	logsDir := filepath.Join(cmd.OutDir, "logs")
	if err := os.MkdirAll(logsDir, 0o755); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	stdoutPath := filepath.Join(logsDir, action.ID+".stdout.log")
	stderrPath := filepath.Join(logsDir, action.ID+".stderr.log")

	exitCode, stdoutText, stderrText, runErr := runLocalExec(resolvedCmd, action.Env, action.TimeoutSec)
	if runErr != nil {
		fmt.Fprintln(os.Stderr, runErr.Error())
		return 1
	}

	if err := os.WriteFile(stdoutPath, []byte(stdoutText), 0o644); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}
	if err := os.WriteFile(stderrPath, []byte(stderrText), 0o644); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	stdoutHash := sha256HexBytes([]byte(stdoutText))
	stderrHash := sha256HexBytes([]byte(stderrText))

	artifacts := []resultArtifact{
		{Path: stdoutPath, SHA256: stdoutHash},
		{Path: stderrPath, SHA256: stderrHash},
	}

	status := "ok"
	if exitCode != 0 {
		status = "error"
	}

	resultActionData := resultAction{
		ID:            action.ID,
		Status:        status,
		Artifacts:     artifacts,
		StdoutSummary: summarizeOutput(stdoutText),
		StderrSummary: summarizeOutput(stderrText),
	}

	result := resultFile{
		Version:   "1.0",
		RequestID: plan.RequestID,
		Actions:   []resultAction{resultActionData},
	}

	outputsHashPayload := struct {
		ID        string           `json:"id"`
		Status    string           `json:"status"`
		Artifacts []resultArtifact `json:"artifacts"`
	}{
		ID:        resultActionData.ID,
		Status:    resultActionData.Status,
		Artifacts: resultActionData.Artifacts,
	}

	outputsBytes, err := json.Marshal(outputsHashPayload)
	if err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	cwd, _ := os.Getwd()
	evidence := evidenceFile{
		Version:   "1.0",
		RequestID: plan.RequestID,
		Actions: []evidenceAction{
			{
				ID:           action.ID,
				ExecutedAt:   time.Now().UTC().Format(time.RFC3339Nano),
				Runner:       "hub-go@v0",
				Command:      resolvedCmd,
				CWD:          cwd,
				UID:          os.Getuid(),
				GID:          os.Getgid(),
				SanitizedEnv: action.Env,
				TimeoutSec:   action.TimeoutSec,
				ExitCode:     exitCode,
				StdoutPath:   stdoutPath,
				StderrPath:   stderrPath,
				StdoutHash:   stdoutHash,
				StderrHash:   stderrHash,
				InputsHash:   sha256HexBytes(planBytes),
				OutputsHash:  sha256HexBytes(outputsBytes),
			},
		},
		Platform: evidencePlatform{
			Node: "go:" + runtime.Version(),
			OS:   runtime.GOOS,
			Arch: runtime.GOARCH,
		},
	}

	if err := writeJSON(filepath.Join(cmd.OutDir, "result.json"), result); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}
	if err := writeJSON(filepath.Join(cmd.OutDir, "evidence.json"), evidence); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}

	if exitCode == 0 {
		return 0
	}
	return 1
}

func resolvePlanSchemaPath() string {
	candidates := []string{
		"constitution/schemas/plan.schema.json",
		filepath.Join("..", "constitution", "schemas", "plan.schema.json"),
	}
	for _, p := range candidates {
		if _, err := os.Stat(p); err == nil {
			return p
		}
	}
	return ""
}

func loadAndValidatePlan(planPath string) (planFile, []byte, bool) {
	schemaPath := resolvePlanSchemaPath()
	if schemaPath == "" {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return planFile{}, nil, false
	}

	schemaCompiler := jsonschema.NewCompiler()
	schema, err := schemaCompiler.Compile(schemaPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return planFile{}, nil, false
	}

	data, err := os.ReadFile(planPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return planFile{}, nil, false
	}

	var raw any
	if err := json.Unmarshal(data, &raw); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return planFile{}, nil, false
	}
	if err := schema.Validate(raw); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return planFile{}, nil, false
	}

	var plan planFile
	if err := json.Unmarshal(data, &plan); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return planFile{}, nil, false
	}

	return plan, data, true
}

func resolveLocalCommand(commandID string, args []string) ([]string, bool) {
	switch commandID {
	case "ECHO":
		return append([]string{"/bin/echo"}, args...), true
	case "RUN_NODE_VERSION":
		return append([]string{"node", "--version"}, args...), true
	default:
		return nil, false
	}
}

func isSafeEnv(env map[string]string) bool {
	for k := range env {
		if !safeEnvKeyRegex.MatchString(k) {
			return false
		}
	}
	return true
}

func runLocalExec(command []string, env map[string]string, timeoutSec int) (int, string, string, error) {
	if len(command) == 0 {
		return 1, "", "", fmt.Errorf(reasonCommandNotAllowed)
	}
	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(timeoutSec)*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, command[0], command[1:]...)

	baseEnv := []string{"PATH=/usr/bin:/bin:/usr/sbin:/sbin"}
	for k, v := range env {
		baseEnv = append(baseEnv, k+"="+v)
	}
	cmd.Env = baseEnv

	stdout, err := cmd.Output()
	stderr := []byte{}
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			stderr = exitErr.Stderr
			if ctx.Err() == context.DeadlineExceeded {
				return 124, string(stdout), string(stderr), nil
			}
			return exitErr.ExitCode(), string(stdout), string(stderr), nil
		}
		if ctx.Err() == context.DeadlineExceeded {
			return 124, string(stdout), string(stderr), nil
		}
		return 1, string(stdout), string(stderr), nil
	}
	return 0, string(stdout), string(stderr), nil
}

func summarizeOutput(text string) string {
	clean := strings.TrimSpace(strings.ReplaceAll(text, "\r\n", "\n"))
	if len(clean) > 240 {
		return clean[:240] + "..."
	}
	return clean
}

func writeJSON(path string, v any) error {
	data, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return err
	}
	data = append(data, '\n')
	return os.WriteFile(path, data, 0o644)
}

func sha256HexBytes(input []byte) string {
	h := sha256.Sum256(input)
	return hex.EncodeToString(h[:])
}

func notImplemented(name string) int {
	fmt.Fprintln(os.Stderr, name+": not implemented")
	return 1
}
