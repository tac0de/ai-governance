package cli

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"runtime"
	"sort"
	"strings"
	"time"

	"github.com/santhosh-tekuri/jsonschema/v5"
)

var safeEnvKeyRegex = regexp.MustCompile(`^SAFE_[A-Z0-9_]+$`)

const (
	reasonPlanSchemaInvalid = "HUNBUP_PLAN_SCHEMA_INVALID"
	reasonResultSchemaError = "HUNBUP_RESULT_SCHEMA_INVALID"
	reasonEvidenceSchemaErr = "HUNBUP_EVIDENCE_SCHEMA_INVALID"
	reasonActionTypeInvalid = "HUNBUP_ACTION_TYPE_NOT_ALLOWED"
	reasonCommandNotAllowed = "HUNBUP_COMMAND_ID_NOT_ALLOWED"
	reasonEnvKeyNotAllowed  = "HUNBUP_ENV_KEY_NOT_ALLOWED"
	reasonTimeoutExceeded   = "HUNBUP_TIMEOUT_EXCEEDED"
	reasonEvidenceMissing   = "HUNBUP_EVIDENCE_MISSING_REQUIRED_FIELD"
	reasonHashMismatch      = "HUNBUP_HASH_MISMATCH"
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

type auditViolation struct {
	Code    string `json:"code"`
	Path    string `json:"path"`
	Message string `json:"message"`
}

type auditChecksums struct {
	Plan     string `json:"plan"`
	Result   string `json:"result"`
	Evidence string `json:"evidence"`
}

type auditFile struct {
	Version    string           `json:"version"`
	RequestID  string           `json:"request_id"`
	Status     string           `json:"status"`
	ReasonCode *string          `json:"reason_code"`
	Violations []auditViolation `json:"violations"`
	Checksums  auditChecksums   `json:"checksums"`
}

func Execute(cmd Command) int {
	switch cmd.Name {
	case CmdValidate:
		return handleValidate(cmd)
	case CmdRun:
		return handleRun(cmd)
	case CmdAudit:
		return handleAudit(cmd)
	default:
		fmt.Fprintln(os.Stderr, "unknown command")
		return 2
	}
}

func handleValidate(cmd Command) int {
	schemaPath := resolveSchemaPath("plan.schema.json")
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

	expectedOutputsHash, err := deriveOutputsHash(resultActionData)
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
				Runner:       "control-plane-go@v0",
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
				OutputsHash:  expectedOutputsHash,
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

func handleAudit(cmd Command) int {
	planBytes, err := os.ReadFile(cmd.PlanPath)
	if err != nil {
		return writeSingleRejectAudit(cmd.Out, "unknown", auditChecksums{}, reasonPlanSchemaInvalid, "/", "plan read failed")
	}
	resultBytes, err := os.ReadFile(cmd.Result)
	if err != nil {
		return writeSingleRejectAudit(cmd.Out, "unknown", auditChecksums{}, reasonResultSchemaError, "/", "result read failed")
	}
	evidenceBytes, err := os.ReadFile(cmd.Evidence)
	if err != nil {
		return writeSingleRejectAudit(cmd.Out, "unknown", auditChecksums{}, reasonEvidenceSchemaErr, "/", "evidence read failed")
	}

	checksums := auditChecksums{
		Plan:     sha256HexBytes(planBytes),
		Result:   sha256HexBytes(resultBytes),
		Evidence: sha256HexBytes(evidenceBytes),
	}

	planRaw, err := unmarshalRaw(planBytes)
	if err != nil {
		return writeSingleRejectAudit(cmd.Out, "unknown", checksums, reasonPlanSchemaInvalid, "/", "plan json parse failed")
	}
	if err := validateAgainstSchema("plan.schema.json", planRaw); err != nil {
		return writeSingleRejectAudit(cmd.Out, requestIDFromRaw(planRaw), checksums, reasonPlanSchemaInvalid, "/", "plan schema validation failed")
	}

	resultRaw, err := unmarshalRaw(resultBytes)
	if err != nil {
		return writeSingleRejectAudit(cmd.Out, requestIDFromRaw(planRaw), checksums, reasonResultSchemaError, "/", "result json parse failed")
	}
	if err := validateAgainstSchema("result.schema.json", resultRaw); err != nil {
		return writeSingleRejectAudit(cmd.Out, requestIDFromRaw(planRaw), checksums, reasonResultSchemaError, "/", "result schema validation failed")
	}

	evidenceRaw, err := unmarshalRaw(evidenceBytes)
	if err != nil {
		return writeSingleRejectAudit(cmd.Out, requestIDFromRaw(planRaw), checksums, reasonEvidenceSchemaErr, "/", "evidence json parse failed")
	}
	if err := validateAgainstSchema("evidence.schema.json", evidenceRaw); err != nil {
		return writeSingleRejectAudit(cmd.Out, requestIDFromRaw(planRaw), checksums, reasonEvidenceSchemaErr, "/", "evidence schema validation failed")
	}

	var plan planFile
	if err := json.Unmarshal(planBytes, &plan); err != nil {
		return writeSingleRejectAudit(cmd.Out, requestIDFromRaw(planRaw), checksums, reasonPlanSchemaInvalid, "/", "plan decode failed")
	}
	var result resultFile
	if err := json.Unmarshal(resultBytes, &result); err != nil {
		return writeSingleRejectAudit(cmd.Out, plan.RequestID, checksums, reasonResultSchemaError, "/", "result decode failed")
	}
	var evidence evidenceFile
	if err := json.Unmarshal(evidenceBytes, &evidence); err != nil {
		return writeSingleRejectAudit(cmd.Out, plan.RequestID, checksums, reasonEvidenceSchemaErr, "/", "evidence decode failed")
	}

	violations := make([]auditViolation, 0)
	if plan.RequestID != result.RequestID || plan.RequestID != evidence.RequestID {
		violations = append(violations, auditViolation{Code: reasonHashMismatch, Path: "/request_id", Message: "request_id mismatch between plan/result/evidence"})
	}

	action := plan.Actions[0]
	resultActionData := result.Actions[0]
	evidenceActionData := evidence.Actions[0]

	if action.Type != "local_exec" {
		violations = append(violations, auditViolation{Code: reasonActionTypeInvalid, Path: "/actions/0/type", Message: "action type is not allowed in v0 runtime"})
	}
	if _, ok := resolveLocalCommand(action.CommandID, action.Args); !ok {
		violations = append(violations, auditViolation{Code: reasonCommandNotAllowed, Path: "/actions/0/command_id", Message: "command_id is not allowlisted"})
	}

	envKeys := make([]string, 0, len(action.Env))
	for k := range action.Env {
		envKeys = append(envKeys, k)
	}
	sort.Strings(envKeys)
	for _, k := range envKeys {
		if !safeEnvKeyRegex.MatchString(k) {
			violations = append(violations, auditViolation{Code: reasonEnvKeyNotAllowed, Path: "/actions/0/env/" + k, Message: "environment key is not allowlisted"})
		}
	}

	if resultActionData.ID != action.ID || evidenceActionData.ID != action.ID {
		violations = append(violations, auditViolation{Code: reasonEvidenceMissing, Path: "/actions/0/id", Message: "action id mismatch across plan/result/evidence"})
	}
	if evidenceActionData.ExitCode == 124 {
		violations = append(violations, auditViolation{Code: reasonTimeoutExceeded, Path: "/actions/0/exit_code", Message: "execution timeout exceeded"})
	}
	if evidenceActionData.InputsHash != checksums.Plan {
		violations = append(violations, auditViolation{Code: reasonHashMismatch, Path: "/actions/0/inputs_hash", Message: "inputs_hash does not match plan checksum"})
	}

	expectedOutputsHash, err := deriveOutputsHash(resultActionData)
	if err != nil {
		return writeSingleRejectAudit(cmd.Out, plan.RequestID, checksums, reasonHashMismatch, "/actions/0/outputs_hash", "failed to compute outputs hash")
	}
	if evidenceActionData.OutputsHash != expectedOutputsHash {
		violations = append(violations, auditViolation{Code: reasonHashMismatch, Path: "/actions/0/outputs_hash", Message: "outputs_hash does not match derived result hash"})
	}

	stdoutBytes, err1 := os.ReadFile(evidenceActionData.StdoutPath)
	stderrBytes, err2 := os.ReadFile(evidenceActionData.StderrPath)
	if err1 != nil || err2 != nil {
		violations = append(violations, auditViolation{Code: reasonHashMismatch, Path: "/actions/0/stdout_path", Message: "stdout/stderr log files not readable"})
	} else {
		actualStdoutHash := sha256HexBytes(stdoutBytes)
		actualStderrHash := sha256HexBytes(stderrBytes)
		if actualStdoutHash != evidenceActionData.StdoutHash || actualStderrHash != evidenceActionData.StderrHash {
			violations = append(violations, auditViolation{Code: reasonHashMismatch, Path: "/actions/0/stdout_hash", Message: "stdout/stderr hash mismatch against file content"})
		}
	}

	if len(violations) > 0 {
		reason := violations[0].Code
		audit := auditFile{
			Version:    "1.0",
			RequestID:  plan.RequestID,
			Status:     "REJECT",
			ReasonCode: &reason,
			Violations: violations,
			Checksums:  checksums,
		}
		if err := writeJSON(cmd.Out, audit); err != nil {
			fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
			return 1
		}
		fmt.Fprintln(os.Stderr, "REJECT", reason)
		return 1
	}

	audit := auditFile{
		Version:    "1.0",
		RequestID:  plan.RequestID,
		Status:     "PASS",
		ReasonCode: nil,
		Violations: []auditViolation{},
		Checksums:  checksums,
	}
	if err := writeJSON(cmd.Out, audit); err != nil {
		fmt.Fprintln(os.Stderr, reasonPlanSchemaInvalid)
		return 1
	}
	fmt.Fprintln(os.Stdout, "PASS")
	return 0
}

func resolveSchemaPath(schemaFile string) string {
	candidates := []string{
		filepath.Join("schemas", "jsonschema", schemaFile),
		filepath.Join("..", "schemas", "jsonschema", schemaFile),
		filepath.Join("..", "..", "schemas", "jsonschema", schemaFile),
	}
	for _, p := range candidates {
		if _, err := os.Stat(p); err == nil {
			return p
		}
	}
	return ""
}

func loadAndValidatePlan(planPath string) (planFile, []byte, bool) {
	schemaPath := resolveSchemaPath("plan.schema.json")
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

func unmarshalRaw(data []byte) (any, error) {
	var raw any
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, err
	}
	return raw, nil
}

func validateAgainstSchema(schemaFile string, raw any) error {
	schemaPath := resolveSchemaPath(schemaFile)
	if schemaPath == "" {
		return errors.New("schema path not found")
	}
	compiler := jsonschema.NewCompiler()
	schema, err := compiler.Compile(schemaPath)
	if err != nil {
		return err
	}
	return schema.Validate(raw)
}

func requestIDFromRaw(raw any) string {
	m, ok := raw.(map[string]any)
	if !ok {
		return "unknown"
	}
	v, ok := m["request_id"].(string)
	if !ok || v == "" {
		return "unknown"
	}
	return v
}

func writeSingleRejectAudit(outPath, requestID string, checksums auditChecksums, code, path, message string) int {
	audit := auditFile{
		Version:    "1.0",
		RequestID:  requestID,
		Status:     "REJECT",
		ReasonCode: &code,
		Violations: []auditViolation{{Code: code, Path: path, Message: message}},
		Checksums:  checksums,
	}
	if err := writeJSON(outPath, audit); err != nil {
		fmt.Fprintln(os.Stderr, code)
		return 1
	}
	fmt.Fprintln(os.Stderr, "REJECT", code)
	return 1
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
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
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

func deriveOutputsHash(a resultAction) (string, error) {
	payload := struct {
		ID        string           `json:"id"`
		Status    string           `json:"status"`
		Artifacts []resultArtifact `json:"artifacts"`
	}{
		ID:        a.ID,
		Status:    a.Status,
		Artifacts: a.Artifacts,
	}
	b, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}
	return sha256HexBytes(b), nil
}

func notImplemented(name string) int {
	fmt.Fprintln(os.Stderr, name+": not implemented")
	return 1
}
