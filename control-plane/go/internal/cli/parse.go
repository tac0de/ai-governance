package cli

import (
	"errors"
	"fmt"
)

type CommandName string

const (
	CmdValidate CommandName = "validate"
	CmdRun      CommandName = "run"
	CmdAudit    CommandName = "audit"
)

type Command struct {
	Name     CommandName
	PlanPath string
	OutDir   string
	Result   string
	Evidence string
	Out      string
}

func Parse(args []string) (Command, error) {
	if len(args) == 0 {
		return Command{}, errors.New("missing command")
	}

	switch args[0] {
	case string(CmdValidate):
		return parseValidate(args[1:])
	case string(CmdRun):
		return parseRun(args[1:])
	case string(CmdAudit):
		return parseAudit(args[1:])
	default:
		return Command{}, fmt.Errorf("unknown command: %s", args[0])
	}
}

func parseValidate(args []string) (Command, error) {
	plan, err := requireFlagValue(args, "--plan")
	if err != nil {
		return Command{}, err
	}
	if hasUnknownFlags(args, map[string]bool{"--plan": true}) {
		return Command{}, errors.New("unknown flag")
	}
	return Command{Name: CmdValidate, PlanPath: plan}, nil
}

func parseRun(args []string) (Command, error) {
	plan, err := requireFlagValue(args, "--plan")
	if err != nil {
		return Command{}, err
	}
	outdir, err := requireFlagValue(args, "--outdir")
	if err != nil {
		return Command{}, err
	}
	if hasUnknownFlags(args, map[string]bool{"--plan": true, "--outdir": true}) {
		return Command{}, errors.New("unknown flag")
	}
	return Command{Name: CmdRun, PlanPath: plan, OutDir: outdir}, nil
}

func parseAudit(args []string) (Command, error) {
	plan, err := requireFlagValue(args, "--plan")
	if err != nil {
		return Command{}, err
	}
	result, err := requireFlagValue(args, "--result")
	if err != nil {
		return Command{}, err
	}
	evidence, err := requireFlagValue(args, "--evidence")
	if err != nil {
		return Command{}, err
	}
	out, err := requireFlagValue(args, "--out")
	if err != nil {
		return Command{}, err
	}
	if hasUnknownFlags(args, map[string]bool{"--plan": true, "--result": true, "--evidence": true, "--out": true}) {
		return Command{}, errors.New("unknown flag")
	}
	return Command{Name: CmdAudit, PlanPath: plan, Result: result, Evidence: evidence, Out: out}, nil
}

func requireFlagValue(args []string, flag string) (string, error) {
	for i := 0; i < len(args); i++ {
		if args[i] == flag {
			if i+1 >= len(args) {
				return "", fmt.Errorf("missing value for %s", flag)
			}
			if len(args[i+1]) > 0 && args[i+1][0] == '-' {
				return "", fmt.Errorf("missing value for %s", flag)
			}
			return args[i+1], nil
		}
	}
	return "", fmt.Errorf("missing required flag %s", flag)
}

func hasUnknownFlags(args []string, allowed map[string]bool) bool {
	for i := 0; i < len(args); i++ {
		if len(args[i]) > 0 && args[i][0] == '-' {
			if !allowed[args[i]] {
				return true
			}
			i++
		}
	}
	return false
}
