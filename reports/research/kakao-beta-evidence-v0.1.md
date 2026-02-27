# Kakao Beta Evidence v0.1

## Objective
- 카카오 챗봇 베타(그룹 시나리오) 설계의 공개 근거와 미확정 항목을 분리한다.

## Confirmed Public Evidence
- Kakao Business 챗봇 설정 문서: 스킬 응답 시간 5초, 장기 처리 시 `useCallback` 사용.
- Kakao Business AI callback 문서: callback token 유효시간 1분.
- Kakao Developers quota/webhook/utility 문서: API 쿼터와 운영 연계 API 기준.
- OpenAI 공식 문서: Responses API, Prompt Caching, Batch, Latency optimization, Rate limits.

## Assumptions (Pending Private Beta Docs)
- 채널 1:1과 구분되는 베타 그룹 상호작용 제약은 비공개 문서 확인 전까지 가정 상태다.
- 중앙 저장소는 계약/증빙/검증만 담당하고 런타임 구현은 외부 저장소에서 수행한다.
- 신규 Core MCP(`core-study-session-governor-mcp`)는 high-tier 경계로 유지한다.

## Risk Notes
- 비공개 베타 제약이 공개 가정과 다를 가능성이 있다.
- private evidence 수신 시 이 문서와 관련 서비스 계약 문서를 즉시 갱신해야 한다.

## Source Links
- https://kakaobusiness.gitbook.io/main/tool/chatbot/bot-setting
- https://kakaobusiness.gitbook.io/main/tool/chatbot/skill_guide/aicallback
- https://developers.kakao.com/docs/latest/en/getting-started/quota
- https://developers.kakao.com/docs/latest/en/kakaologin/webhook
- https://developers.kakao.com/docs/latest/en/reference/utility#api-status-get
- https://platform.openai.com/docs/guides/migrate-to-responses?api-mode=responses
- https://platform.openai.com/docs/guides/prompt-caching
- https://platform.openai.com/docs/guides/batch
- https://platform.openai.com/docs/guides/latency-optimization
- https://platform.openai.com/docs/guides/rate-limits
- https://tech.kakao.com/posts/115
