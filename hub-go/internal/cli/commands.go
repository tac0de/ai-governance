package cli

import (
	"fmt"
	"os"
)

func Execute(cmd Command) int {
	switch cmd.Name {
	case CmdValidate:
		return notImplemented("validate")
	case CmdRun:
		return notImplemented("run")
	case CmdAudit:
		return notImplemented("audit")
	default:
		fmt.Fprintln(os.Stderr, "unknown command")
		return 2
	}
}

func notImplemented(name string) int {
	fmt.Fprintln(os.Stderr, name+": not implemented")
	return 1
}
