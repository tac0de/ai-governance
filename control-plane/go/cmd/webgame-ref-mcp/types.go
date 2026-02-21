package main

import "encoding/json"

const (
	protocolVersion = "2024-11-05"
	serverName      = "webgame-reference-mcp"
	serverVersion   = "0.1.0"
)

type rpcRequest struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      json.RawMessage `json:"id,omitempty"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params,omitempty"`
}

type rpcResponse struct {
	JSONRPC string    `json:"jsonrpc"`
	ID      any       `json:"id,omitempty"`
	Result  any       `json:"result,omitempty"`
	Error   *rpcError `json:"error,omitempty"`
}

type rpcError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

type toolSpec struct {
	Name        string         `json:"name"`
	Description string         `json:"description"`
	InputSchema map[string]any `json:"inputSchema"`
}

type toolCallParams struct {
	Name      string         `json:"name"`
	Arguments map[string]any `json:"arguments"`
}

type searchArgs struct {
	Query         string
	Platform      string
	Limit         int
	IncludeImages bool
	Language      string
}

type benchmarkArgs struct {
	URLs []string
}

type scoreArgs struct {
	Items   []referenceItem
	Weights scoreWeights
}

type visionReviewArgs struct {
	ImageURLs []string
	Context   string
	Model     string
}

type modelPolicyAuditArgs struct {
	RootPath        string
	BaselineModel   string
	ForbiddenModels []string
}

type marketLaunchAuditArgs struct {
	ProjectRoot string
}

type scoreWeights struct {
	Hook         float64
	Interaction  float64
	Mobile       float64
	Monetization float64
	Novelty      float64
}

type referenceItem struct {
	Title       string `json:"title"`
	URL         string `json:"url"`
	Domain      string `json:"domain"`
	Snippet     string `json:"snippet"`
	PlatformTag string `json:"platform_tag"`
	OGImage     string `json:"og_image,omitempty"`
}

type benchmarkItem struct {
	URL                  string `json:"url"`
	Title                string `json:"title"`
	Description          string `json:"description"`
	OGImage              string `json:"og_image,omitempty"`
	CoreLoopGuess        string `json:"core_loop_guess"`
	FTUEComplexity       string `json:"ftue_complexity"`
	InteractionDensity   string `json:"interaction_density"`
	MobileTouchReadiness string `json:"mobile_touch_readiness"`
}

type scoredReference struct {
	Title              string          `json:"title"`
	URL                string          `json:"url"`
	Domain             string          `json:"domain"`
	PlatformTag        string          `json:"platform_tag"`
	OGImage            string          `json:"og_image,omitempty"`
	CompositeScore     int             `json:"composite_score"`
	ScoreBreakdown     map[string]int  `json:"score_breakdown"`
	Why                []string        `json:"why"`
	Provenance         scoreProvenance `json:"provenance"`
	RecommendedForStep map[string]bool `json:"recommended_for_step"`
}

type scoreProvenance struct {
	SourceURL      string `json:"source_url"`
	AnalyzedAtUTC  string `json:"analyzed_at_utc"`
	ReferenceNotes string `json:"reference_notes"`
}

type visionReviewRow struct {
	ImageURL          string   `json:"image_url"`
	SilhouetteScore   int      `json:"silhouette_score"`
	ReadabilityScore  int      `json:"readability_score"`
	MotionScore       int      `json:"motion_score"`
	MoodCoherence     int      `json:"mood_coherence_score"`
	OverallScore      int      `json:"overall_score"`
	Findings          []string `json:"findings"`
	HighPriorityFixes []string `json:"high_priority_fixes"`
}

type modelPolicyViolation struct {
	FilePath string `json:"file_path"`
	Line     int    `json:"line"`
	Model    string `json:"model"`
	Excerpt  string `json:"excerpt"`
}

type marketLaunchCriterion struct {
	Key       string `json:"key"`
	Title     string `json:"title"`
	Status    string `json:"status"`
	Score     int    `json:"score"`
	Evidence  string `json:"evidence"`
	Impact    string `json:"impact"`
	NextCheck string `json:"next_check"`
}

type marketLaunchAuditReport struct {
	ProjectRoot     string                  `json:"project_root"`
	GeneratedAtUTC  string                  `json:"generated_at_utc"`
	OverallScore    int                     `json:"overall_score"`
	LaunchDecision  string                  `json:"launch_decision"`
	Criteria        []marketLaunchCriterion `json:"criteria"`
	CriticalBlocker []string                `json:"critical_blockers"`
}

type pageMeta struct {
	Title       string
	Description string
	OGImage     string
}
