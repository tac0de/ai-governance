package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"html"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"
)

var errNoReferences = errors.New("no references found from search provider")

func fetchDuckDuckGoHTML(ctx context.Context, query string, lang string) (string, error) {
	u := "https://duckduckgo.com/html/?q=" + url.QueryEscape(query)
	if strings.TrimSpace(lang) != "" {
		u += "&kl=" + url.QueryEscape(lang+"-en")
	}
	return httpGet(ctx, u, 8*time.Second)
}

func parseDuckDuckGoResults(body string) []referenceItem {
	linkRe := regexp.MustCompile(`(?s)<a[^>]*class="result__a"[^>]*href="([^"]+)"[^>]*>(.*?)</a>`)
	snippetRe := regexp.MustCompile(`(?s)<a[^>]*class="result__snippet"[^>]*>(.*?)</a>`)
	tagRe := regexp.MustCompile(`<[^>]+>`)

	linkMatches := linkRe.FindAllStringSubmatch(body, -1)
	snippetMatches := snippetRe.FindAllStringSubmatch(body, -1)
	items := make([]referenceItem, 0, len(linkMatches))

	for i, m := range linkMatches {
		if len(m) < 3 {
			continue
		}
		href := strings.TrimSpace(html.UnescapeString(m[1]))
		if href == "" {
			continue
		}
		if strings.HasPrefix(href, "//duckduckgo.com/l/?uddg=") {
			parsed, err := url.Parse("https:" + href)
			if err == nil {
				target := parsed.Query().Get("uddg")
				if target != "" {
					href = target
				}
			}
		}
		if !strings.HasPrefix(href, "http://") && !strings.HasPrefix(href, "https://") {
			continue
		}

		title := html.UnescapeString(strings.TrimSpace(tagRe.ReplaceAllString(m[2], "")))
		snippet := ""
		if i < len(snippetMatches) && len(snippetMatches[i]) >= 2 {
			snippet = html.UnescapeString(strings.TrimSpace(tagRe.ReplaceAllString(snippetMatches[i][1], "")))
		}
		domain := ""
		if parsed, err := url.Parse(href); err == nil {
			domain = parsed.Hostname()
		}

		items = append(items, referenceItem{
			Title:   title,
			URL:     href,
			Domain:  domain,
			Snippet: snippet,
		})
	}

	return items
}

func fetchPageMeta(ctx context.Context, pageURL string) pageMeta {
	body, err := httpGet(ctx, pageURL, 6*time.Second)
	if err != nil {
		return pageMeta{}
	}

	title := extractTitle(body)
	desc := extractMetaContent(body, "description")
	if desc == "" {
		desc = extractMetaProperty(body, "og:description")
	}
	og := extractMetaProperty(body, "og:image")
	if og != "" {
		og = resolveURL(pageURL, og)
	}

	return pageMeta{Title: title, Description: desc, OGImage: og}
}

func fetchOGImage(ctx context.Context, pageURL string) string {
	meta := fetchPageMeta(ctx, pageURL)
	return meta.OGImage
}

func extractTitle(body string) string {
	re := regexp.MustCompile(`(?is)<title[^>]*>(.*?)</title>`)
	m := re.FindStringSubmatch(body)
	if len(m) < 2 {
		return ""
	}
	return strings.TrimSpace(html.UnescapeString(stripTags(m[1])))
}

func extractMetaContent(body string, name string) string {
	re := regexp.MustCompile(`(?is)<meta[^>]*name=["']` + regexp.QuoteMeta(name) + `["'][^>]*content=["'](.*?)["'][^>]*>`)
	m := re.FindStringSubmatch(body)
	if len(m) < 2 {
		return ""
	}
	return strings.TrimSpace(html.UnescapeString(stripTags(m[1])))
}

func extractMetaProperty(body string, prop string) string {
	re := regexp.MustCompile(`(?is)<meta[^>]*property=["']` + regexp.QuoteMeta(prop) + `["'][^>]*content=["'](.*?)["'][^>]*>`)
	m := re.FindStringSubmatch(body)
	if len(m) < 2 {
		return ""
	}
	return strings.TrimSpace(html.UnescapeString(stripTags(m[1])))
}

func stripTags(s string) string {
	re := regexp.MustCompile(`<[^>]+>`)
	return re.ReplaceAllString(s, "")
}

func resolveURL(baseURL, rel string) string {
	u, err := url.Parse(rel)
	if err != nil {
		return rel
	}
	if u.IsAbs() {
		return rel
	}
	base, err := url.Parse(baseURL)
	if err != nil {
		return rel
	}
	return base.ResolveReference(u).String()
}

func httpGet(ctx context.Context, target string, timeout time.Duration) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, target, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("User-Agent", "webgame-reference-mcp/0.1 (+https://example.local)")
	req.Header.Set("Accept-Language", "en-US,en;q=0.8")

	client := &http.Client{Timeout: timeout}
	res, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer res.Body.Close()

	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return "", fmt.Errorf("http status %d for %s", res.StatusCode, target)
	}

	body, err := io.ReadAll(io.LimitReader(res.Body, 1_500_000))
	if err != nil {
		return "", err
	}
	return string(body), nil
}

func requestVisionReview(ctx context.Context, apiKey, model, imageURL, contextText string) (visionReviewRow, error) {
	if strings.TrimSpace(model) == "" {
		model = "gpt-5-nano"
	}

	rubric := "Score 0-100 for silhouette clarity, readability, motion continuity, and mood coherence."
	if strings.TrimSpace(contextText) != "" {
		rubric += " Context: " + strings.TrimSpace(contextText)
	}

	requestBody := map[string]any{
		"model": model,
		"input": []map[string]any{
			{
				"role": "user",
				"content": []map[string]any{
					{
						"type": "input_text",
						"text": strings.Join([]string{
							"You are a strict UI art director for web/mobile game UX.",
							rubric,
							"Return JSON only with fields:",
							"silhouette_score, readability_score, motion_score, mood_coherence_score, overall_score, findings(array), high_priority_fixes(array).",
							"Do not include markdown.",
						}, "\n"),
					},
					{
						"type":      "input_image",
						"image_url": imageURL,
					},
				},
			},
		},
	}

	b, err := json.Marshal(requestBody)
	if err != nil {
		return visionReviewRow{}, err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, "https://api.openai.com/v1/responses", bytes.NewReader(b))
	if err != nil {
		return visionReviewRow{}, err
	}
	req.Header.Set("Authorization", "Bearer "+apiKey)
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 35 * time.Second}
	res, err := client.Do(req)
	if err != nil {
		return visionReviewRow{}, err
	}
	defer res.Body.Close()

	respBody, err := io.ReadAll(io.LimitReader(res.Body, 3_000_000))
	if err != nil {
		return visionReviewRow{}, err
	}
	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return visionReviewRow{}, fmt.Errorf("openai status %d: %s", res.StatusCode, string(respBody))
	}

	var parsed struct {
		OutputText string `json:"output_text"`
	}
	if err := json.Unmarshal(respBody, &parsed); err != nil {
		return visionReviewRow{}, err
	}
	if strings.TrimSpace(parsed.OutputText) == "" {
		return visionReviewRow{}, errors.New("openai output_text is empty")
	}

	var score struct {
		SilhouetteScore   int      `json:"silhouette_score"`
		ReadabilityScore  int      `json:"readability_score"`
		MotionScore       int      `json:"motion_score"`
		MoodCoherence     int      `json:"mood_coherence_score"`
		OverallScore      int      `json:"overall_score"`
		Findings          []string `json:"findings"`
		HighPriorityFixes []string `json:"high_priority_fixes"`
	}
	if err := json.Unmarshal([]byte(parsed.OutputText), &score); err != nil {
		return visionReviewRow{}, fmt.Errorf("invalid json from model: %w", err)
	}

	return visionReviewRow{
		ImageURL:          imageURL,
		SilhouetteScore:   clampScore(score.SilhouetteScore),
		ReadabilityScore:  clampScore(score.ReadabilityScore),
		MotionScore:       clampScore(score.MotionScore),
		MoodCoherence:     clampScore(score.MoodCoherence),
		OverallScore:      clampScore(score.OverallScore),
		Findings:          score.Findings,
		HighPriorityFixes: score.HighPriorityFixes,
	}, nil
}
