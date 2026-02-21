package main

import (
	"errors"
	"net/url"
	"os"
	"strconv"
	"strings"
)

func parseSearchArgs(args map[string]any) (searchArgs, error) {
	query, ok := args["query"].(string)
	if !ok || strings.TrimSpace(query) == "" {
		return searchArgs{}, errors.New("query is required")
	}

	platform := "both"
	if raw, ok := args["platform"]; ok {
		platform, ok = raw.(string)
		if !ok {
			return searchArgs{}, errors.New("platform must be string")
		}
	}
	if platform != "web" && platform != "mobile-web" && platform != "both" {
		return searchArgs{}, errors.New("platform must be one of: web, mobile-web, both")
	}

	limit := 8
	if raw, ok := args["limit"]; ok {
		switch v := raw.(type) {
		case float64:
			limit = int(v)
		case string:
			n, err := strconv.Atoi(v)
			if err != nil {
				return searchArgs{}, errors.New("limit must be integer")
			}
			limit = n
		default:
			return searchArgs{}, errors.New("limit must be integer")
		}
	}
	if limit < 1 || limit > 20 {
		return searchArgs{}, errors.New("limit out of range: 1..20")
	}

	includeImages := true
	if raw, ok := args["include_images"]; ok {
		v, ok := raw.(bool)
		if !ok {
			return searchArgs{}, errors.New("include_images must be boolean")
		}
		includeImages = v
	}

	language := "en"
	if raw, ok := args["language"]; ok {
		v, ok := raw.(string)
		if !ok {
			return searchArgs{}, errors.New("language must be string")
		}
		if strings.TrimSpace(v) != "" {
			language = strings.TrimSpace(v)
		}
	}

	return searchArgs{
		Query:         strings.TrimSpace(query),
		Platform:      platform,
		Limit:         limit,
		IncludeImages: includeImages,
		Language:      language,
	}, nil
}

func parseBenchmarkArgs(args map[string]any) (benchmarkArgs, error) {
	rawURLs, ok := args["urls"].([]any)
	if !ok || len(rawURLs) == 0 {
		return benchmarkArgs{}, errors.New("urls is required and must be non-empty array")
	}
	if len(rawURLs) > 20 {
		return benchmarkArgs{}, errors.New("urls max length is 20")
	}

	out := make([]string, 0, len(rawURLs))
	for _, r := range rawURLs {
		s, ok := r.(string)
		if !ok || strings.TrimSpace(s) == "" {
			return benchmarkArgs{}, errors.New("each url must be non-empty string")
		}
		if !strings.HasPrefix(s, "http://") && !strings.HasPrefix(s, "https://") {
			return benchmarkArgs{}, errors.New("url must start with http:// or https://")
		}
		out = append(out, strings.TrimSpace(s))
	}
	return benchmarkArgs{URLs: out}, nil
}

func parseScoreArgs(args map[string]any) (scoreArgs, error) {
	rawItems, ok := args["items"].([]any)
	if !ok || len(rawItems) == 0 {
		return scoreArgs{}, errors.New("items is required and must be non-empty array")
	}
	if len(rawItems) > 50 {
		return scoreArgs{}, errors.New("items max length is 50")
	}

	items := make([]referenceItem, 0, len(rawItems))
	for _, raw := range rawItems {
		obj, ok := raw.(map[string]any)
		if !ok {
			return scoreArgs{}, errors.New("each item must be object")
		}
		title, _ := obj["title"].(string)
		refURL, _ := obj["url"].(string)
		if strings.TrimSpace(title) == "" || strings.TrimSpace(refURL) == "" {
			return scoreArgs{}, errors.New("each item requires non-empty title and url")
		}
		if !strings.HasPrefix(refURL, "http://") && !strings.HasPrefix(refURL, "https://") {
			return scoreArgs{}, errors.New("item.url must start with http:// or https://")
		}
		item := referenceItem{
			Title:       strings.TrimSpace(title),
			URL:         strings.TrimSpace(refURL),
			Domain:      strings.TrimSpace(asString(obj["domain"])),
			Snippet:     strings.TrimSpace(asString(obj["snippet"])),
			PlatformTag: strings.TrimSpace(asString(obj["platform_tag"])),
			OGImage:     strings.TrimSpace(asString(obj["og_image"])),
		}
		if item.Domain == "" {
			if parsed, err := url.Parse(item.URL); err == nil {
				item.Domain = parsed.Hostname()
			}
		}
		if item.PlatformTag == "" {
			item.PlatformTag = "both"
		}
		items = append(items, item)
	}

	weights := scoreWeights{
		Hook:         0.24,
		Interaction:  0.24,
		Mobile:       0.20,
		Monetization: 0.20,
		Novelty:      0.12,
	}

	if rawW, ok := args["weights"].(map[string]any); ok {
		weights.Hook = asFloatDefault(rawW["hook"], weights.Hook)
		weights.Interaction = asFloatDefault(rawW["interaction"], weights.Interaction)
		weights.Mobile = asFloatDefault(rawW["mobile"], weights.Mobile)
		weights.Monetization = asFloatDefault(rawW["monetization"], weights.Monetization)
		weights.Novelty = asFloatDefault(rawW["novelty"], weights.Novelty)
	}

	total := weights.Hook + weights.Interaction + weights.Mobile + weights.Monetization + weights.Novelty
	if total <= 0 {
		return scoreArgs{}, errors.New("weights sum must be > 0")
	}
	weights.Hook /= total
	weights.Interaction /= total
	weights.Mobile /= total
	weights.Monetization /= total
	weights.Novelty /= total

	return scoreArgs{Items: items, Weights: weights}, nil
}

func parseVisionReviewArgs(args map[string]any) (visionReviewArgs, error) {
	rawImages, ok := args["image_urls"].([]any)
	if !ok || len(rawImages) == 0 {
		return visionReviewArgs{}, errors.New("image_urls is required and must be non-empty array")
	}
	if len(rawImages) > 8 {
		return visionReviewArgs{}, errors.New("image_urls max length is 8")
	}

	imageURLs := make([]string, 0, len(rawImages))
	for _, raw := range rawImages {
		s, ok := raw.(string)
		if !ok || strings.TrimSpace(s) == "" {
			return visionReviewArgs{}, errors.New("each image_urls item must be non-empty string")
		}
		s = strings.TrimSpace(s)
		if !strings.HasPrefix(s, "http://") && !strings.HasPrefix(s, "https://") {
			return visionReviewArgs{}, errors.New("image url must start with http:// or https://")
		}
		imageURLs = append(imageURLs, s)
	}

	contextText := ""
	if raw, ok := args["context"]; ok {
		s, ok := raw.(string)
		if !ok {
			return visionReviewArgs{}, errors.New("context must be string")
		}
		contextText = strings.TrimSpace(s)
	}

	model := strings.TrimSpace(asString(args["model"]))
	if model == "" {
		model = strings.TrimSpace(os.Getenv("OPENAI_VISION_MODEL"))
	}
	if model == "" {
		model = "gpt-5-nano"
	}
	// Keep baseline to gpt-5-nano, but do not block explicit upgrades.
	// Operators can pass a higher model in `model` or OPENAI_VISION_MODEL.

	return visionReviewArgs{
		ImageURLs: imageURLs,
		Context:   contextText,
		Model:     model,
	}, nil
}

func parseModelPolicyAuditArgs(args map[string]any) (modelPolicyAuditArgs, error) {
	rootPath := strings.TrimSpace(asString(args["root_path"]))
	if rootPath == "" {
		rootPath = "."
	}

	baselineModel := strings.TrimSpace(asString(args["baseline_model"]))
	if baselineModel == "" {
		baselineModel = "gpt-5-nano"
	}

	forbidden := []string{"gpt-4.1-mini"}
	if raw, ok := args["forbidden_models"].([]any); ok && len(raw) > 0 {
		custom := make([]string, 0, len(raw))
		for _, r := range raw {
			s, ok := r.(string)
			if !ok || strings.TrimSpace(s) == "" {
				return modelPolicyAuditArgs{}, errors.New("forbidden_models must contain non-empty strings")
			}
			custom = append(custom, strings.TrimSpace(s))
		}
		forbidden = custom
	}

	return modelPolicyAuditArgs{
		RootPath:        rootPath,
		BaselineModel:   baselineModel,
		ForbiddenModels: forbidden,
	}, nil
}

func parseMarketLaunchAuditArgs(args map[string]any) (marketLaunchAuditArgs, error) {
	projectRoot := strings.TrimSpace(asString(args["project_root"]))
	if projectRoot == "" {
		projectRoot = "."
	}
	return marketLaunchAuditArgs{ProjectRoot: projectRoot}, nil
}

func asString(v any) string {
	s, _ := v.(string)
	return s
}

func asFloatDefault(v any, fallback float64) float64 {
	switch n := v.(type) {
	case float64:
		return n
	case int:
		return float64(n)
	case string:
		parsed, err := strconv.ParseFloat(strings.TrimSpace(n), 64)
		if err != nil {
			return fallback
		}
		return parsed
	default:
		return fallback
	}
}
