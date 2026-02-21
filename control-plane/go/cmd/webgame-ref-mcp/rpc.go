package main

import (
	"bytes"
	"context"
	"encoding/json"
	"os"
)

func handleRequest(req rpcRequest) *rpcResponse {
	parsedID, hasID := parseID(req.ID)

	switch req.Method {
	case "initialize":
		return &rpcResponse{
			JSONRPC: "2.0",
			ID:      parsedID,
			Result: map[string]any{
				"protocolVersion": protocolVersion,
				"serverInfo": map[string]any{
					"name":    serverName,
					"version": serverVersion,
				},
				"capabilities": map[string]any{
					"tools": map[string]any{
						"listChanged": false,
					},
				},
			},
		}
	case "notifications/initialized":
		return nil
	case "ping":
		if !hasID {
			return nil
		}
		return &rpcResponse{
			JSONRPC: "2.0",
			ID:      parsedID,
			Result:  map[string]any{},
		}
	case "tools/list":
		if !hasID {
			return nil
		}
		return &rpcResponse{
			JSONRPC: "2.0",
			ID:      parsedID,
			Result: map[string]any{
				"tools": listTools(),
			},
		}
	case "tools/call":
		if !hasID {
			return nil
		}
		var params toolCallParams
		if err := json.Unmarshal(req.Params, &params); err != nil {
			return rpcErr(parsedID, -32602, "invalid tool call params")
		}

		switch params.Name {
		case "search_webgame_references":
			args, err := parseSearchArgs(params.Arguments)
			if err != nil {
				return rpcErr(parsedID, -32602, err.Error())
			}
			items, err := searchReferences(context.Background(), args)
			if err != nil {
				return rpcErr(parsedID, -32001, err.Error())
			}
			payload := map[string]any{
				"query":    args.Query,
				"platform": args.Platform,
				"count":    len(items),
				"items":    items,
			}
			return toolResult(parsedID, payload)
		case "build_webgame_benchmark_sheet":
			args, err := parseBenchmarkArgs(params.Arguments)
			if err != nil {
				return rpcErr(parsedID, -32602, err.Error())
			}
			sheet, err := buildBenchmark(context.Background(), args)
			if err != nil {
				return rpcErr(parsedID, -32001, err.Error())
			}
			payload := map[string]any{
				"count": len(sheet),
				"rows":  sheet,
			}
			return toolResult(parsedID, payload)
		case "score_webgame_references":
			args, err := parseScoreArgs(params.Arguments)
			if err != nil {
				return rpcErr(parsedID, -32602, err.Error())
			}
			rows := scoreReferences(args)
			payload := map[string]any{
				"count": len(rows),
				"rows":  rows,
			}
			return toolResult(parsedID, payload)
		case "vision_review_webgame_images":
			args, err := parseVisionReviewArgs(params.Arguments)
			if err != nil {
				return rpcErr(parsedID, -32602, err.Error())
			}
			rows, err := visionReviewImages(context.Background(), args)
			if err != nil {
				return rpcErr(parsedID, -32001, err.Error())
			}
			payload := map[string]any{
				"count": len(rows),
				"rows":  rows,
			}
			return toolResult(parsedID, payload)
		case "audit_model_policy_drift":
			args, err := parseModelPolicyAuditArgs(params.Arguments)
			if err != nil {
				return rpcErr(parsedID, -32602, err.Error())
			}
			rows, err := auditModelPolicyDrift(args)
			if err != nil {
				return rpcErr(parsedID, -32001, err.Error())
			}
			payload := map[string]any{
				"baseline_model":   args.BaselineModel,
				"forbidden_models": args.ForbiddenModels,
				"count":            len(rows),
				"violations":       rows,
			}
			return toolResult(parsedID, payload)
		case "audit_market_launch_readiness":
			args, err := parseMarketLaunchAuditArgs(params.Arguments)
			if err != nil {
				return rpcErr(parsedID, -32602, err.Error())
			}
			report, err := auditMarketLaunchReadiness(args)
			if err != nil {
				return rpcErr(parsedID, -32001, err.Error())
			}
			return toolResult(parsedID, report)
		default:
			return rpcErr(parsedID, -32601, "unknown tool")
		}
	default:
		if !hasID {
			return nil
		}
		return rpcErr(parsedID, -32601, "method not found")
	}
}

func listTools() []toolSpec {
	return []toolSpec{
		{
			Name:        "search_webgame_references",
			Description: "Search web/mobile-web game references and return enriched candidates for UX benchmarking.",
			InputSchema: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"query": map[string]any{
						"type":        "string",
						"description": "Search query, e.g. 'browser strategy game UI'.",
					},
					"platform": map[string]any{
						"type":        "string",
						"enum":        []string{"web", "mobile-web", "both"},
						"default":     "both",
						"description": "Target platform slice.",
					},
					"limit": map[string]any{
						"type":        "integer",
						"minimum":     1,
						"maximum":     20,
						"default":     8,
						"description": "Max number of references.",
					},
					"include_images": map[string]any{
						"type":        "boolean",
						"default":     true,
						"description": "Include Open Graph image candidates.",
					},
					"language": map[string]any{
						"type":        "string",
						"default":     "en",
						"description": "Language hint for search engine.",
					},
				},
				"required": []string{"query"},
			},
		},
		{
			Name:        "build_webgame_benchmark_sheet",
			Description: "Generate a compact benchmark sheet from reference URLs for web/mobile-web UX review.",
			InputSchema: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"urls": map[string]any{
						"type":        "array",
						"description": "Reference page URLs.",
						"items":       map[string]any{"type": "string"},
						"minItems":    1,
						"maxItems":    20,
					},
				},
				"required": []string{"urls"},
			},
		},
		{
			Name:        "score_webgame_references",
			Description: "Score references for onboarding hook, interaction depth, mobile readiness, and monetization potential.",
			InputSchema: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"items": map[string]any{
						"type":        "array",
						"description": "Reference items from search_webgame_references.",
						"minItems":    1,
						"maxItems":    50,
						"items": map[string]any{
							"type": "object",
							"properties": map[string]any{
								"title":        map[string]any{"type": "string"},
								"url":          map[string]any{"type": "string"},
								"domain":       map[string]any{"type": "string"},
								"snippet":      map[string]any{"type": "string"},
								"platform_tag": map[string]any{"type": "string"},
								"og_image":     map[string]any{"type": "string"},
							},
							"required": []string{"title", "url"},
						},
					},
					"weights": map[string]any{
						"type": "object",
						"properties": map[string]any{
							"hook":         map[string]any{"type": "number"},
							"interaction":  map[string]any{"type": "number"},
							"mobile":       map[string]any{"type": "number"},
							"monetization": map[string]any{"type": "number"},
							"novelty":      map[string]any{"type": "number"},
						},
					},
				},
				"required": []string{"items"},
			},
		},
		{
			Name:        "vision_review_webgame_images",
			Description: "Run vision-model review on game UI images and return quality scores plus fix suggestions.",
			InputSchema: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"image_urls": map[string]any{
						"type":        "array",
						"description": "Publicly reachable image URLs (screenshots or mockups).",
						"minItems":    1,
						"maxItems":    8,
						"items":       map[string]any{"type": "string"},
					},
					"context": map[string]any{
						"type":        "string",
						"description": "Optional product context to guide review.",
					},
					"model": map[string]any{
						"type":        "string",
						"description": "Optional OpenAI multimodal model override.",
					},
				},
				"required": []string{"image_urls"},
			},
		},
		{
			Name:        "audit_model_policy_drift",
			Description: "Scan code/docs and detect model-policy drift (forbidden model mentions).",
			InputSchema: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"root_path": map[string]any{
						"type":        "string",
						"description": "Root path to scan. Default: current directory.",
					},
					"baseline_model": map[string]any{
						"type":        "string",
						"description": "Expected baseline model. Default: gpt-5-nano.",
					},
					"forbidden_models": map[string]any{
						"type":        "array",
						"description": "Model names that should not appear in operational docs/code.",
						"items":       map[string]any{"type": "string"},
					},
				},
			},
		},
		{
			Name:        "audit_market_launch_readiness",
			Description: "Audit web game MVP against monetization launch requirements and return critical blockers.",
			InputSchema: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"project_root": map[string]any{
						"type":        "string",
						"description": "Absolute or relative target project root path.",
						"default":     ".",
					},
				},
			},
		},
	}
}

func parseID(raw json.RawMessage) (any, bool) {
	if len(raw) == 0 {
		return nil, false
	}

	var asAny any
	if err := json.Unmarshal(raw, &asAny); err != nil {
		return nil, false
	}
	return asAny, true
}

func toolResult(id any, payload any) *rpcResponse {
	out, _ := json.Marshal(payload)
	return &rpcResponse{
		JSONRPC: "2.0",
		ID:      id,
		Result: map[string]any{
			"content": []map[string]string{{
				"type": "text",
				"text": string(out),
			}},
			"isError": false,
		},
	}
}

func rpcErr(id any, code int, message string) *rpcResponse {
	return &rpcResponse{
		JSONRPC: "2.0",
		ID:      id,
		Error: &rpcError{
			Code:    code,
			Message: message,
		},
	}
}

func writeResponse(resp rpcResponse) error {
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetEscapeHTML(false)
	if err := enc.Encode(resp); err != nil {
		return err
	}
	_, err := os.Stdout.Write(buf.Bytes())
	return err
}
