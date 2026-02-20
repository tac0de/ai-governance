package cli

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/santhosh-tekuri/jsonschema/v5"
)

func Execute(cmd Command) int {
	switch cmd.Name {
	case CmdValidate:
		return handleValidate(cmd)
	case CmdRun:
		return notImplemented("run")
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
		fmt.Fprintln(os.Stderr, "HUNBUP_PLAN_SCHEMA_INVALID")
		return 1
	}

	schemaCompiler := jsonschema.NewCompiler()
	schema, err := schemaCompiler.Compile(schemaPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, "HUNBUP_PLAN_SCHEMA_INVALID")
		return 1
	}

	data, err := os.ReadFile(cmd.PlanPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, "HUNBUP_PLAN_SCHEMA_INVALID")
		return 1
	}

	var v any
	if err := json.Unmarshal(data, &v); err != nil {
		fmt.Fprintln(os.Stderr, "HUNBUP_PLAN_SCHEMA_INVALID")
		return 1
	}

	if err := schema.Validate(v); err != nil {
		fmt.Fprintln(os.Stderr, "HUNBUP_PLAN_SCHEMA_INVALID")
		return 1
	}

	return 0
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

func notImplemented(name string) int {
	fmt.Fprintln(os.Stderr, name+": not implemented")
	return 1
}
