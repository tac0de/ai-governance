package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strings"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		var req rpcRequest
		if err := json.Unmarshal([]byte(line), &req); err != nil {
			_ = writeResponse(rpcResponse{
				JSONRPC: "2.0",
				Error: &rpcError{
					Code:    -32700,
					Message: "parse error",
				},
			})
			continue
		}

		resp := handleRequest(req)
		if resp == nil {
			continue
		}

		if err := writeResponse(*resp); err != nil {
			fmt.Fprintln(os.Stderr, "failed to write response:", err.Error())
			return
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "stdin error:", err.Error())
	}
}
