package main

import (
	"fmt"
	"os"

	"ai-governance/hub-go/internal/cli"
)

func main() {
	cmd, err := cli.Parse(os.Args[1:])
	if err != nil {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(2)
	}

	code := cli.Execute(cmd)
	os.Exit(code)
}
