# AI-GOVERNANCE 스킬 사용법 (아주 쉬운 버전)

## 1) 가장 중요한 한 줄
- VSCode Codex 채팅창의 `/`는 스킬 실행 명령이 아닙니다.
- 스킬은 채팅에 `[$스킬이름]` 또는 `$스킬이름`으로 호출합니다.

예시:
```text
[$global-governance-closure] 역할/정책/스키마 정합화 해줘
```

## 2) 스킬이 안 보일 때
터미널에서 순서대로 실행:

```bash
source ~/.zshrc
hash -r
codex-skill-list
```

- 여기서 목록이 나오면 설치는 정상입니다.
- Codex/VSCode 창을 다시 열면 인식되는 경우가 많습니다.

## 3) ai-governance에 지금 필요한 스킬 4개

### A. `global-governance-closure` (필수)
- 용도: 역할/정책/스키마를 한 번에 잠그기
- 언제: 역할이 늘어나거나 문서-스키마가 어긋날 때

### B. `governance-doc-diet` (추천)
- 용도: 불필요 문서 정리, 핵심 읽기 순서 고정
- 언제: 문서가 많아져서 사람이 헷갈릴 때

### C. `schema-gate-check` (추천)
- 용도: `plan/result/evidence/audit` 필수 필드 누락 검사
- 언제: PR 전에 정합성 빠르게 확인할 때

### D. `release-proof-pack` (추천)
- 용도: PR에 넣을 근거 묶음(결정/검증/증거 링크) 생성
- 언제: 릴리즈 게이트 통과용 자료 만들 때

## 4) 바로 복붙해서 쓰는 요청 문장

```text
[$global-governance-closure] 역할/정책/스키마 정합화 해줘
```

```text
[$governance-doc-diet] 사람이 보는 문서만 남기고 읽기 순서 재정렬해줘
```

```text
[$schema-gate-check] 현재 변경분 기준으로 v1.1 스키마 게이트 실패 항목만 알려줘
```

```text
[$release-proof-pack] 이번 PR용 거버넌스 증거 묶음 문서 만들어줘
```

## 5) 새 스킬 1분 생성

```bash
cd ~/.codex/skills
codex-skill-init governance-doc-diet references
codex-skill-init schema-gate-check scripts
codex-skill-init release-proof-pack templates
codex-skill-list
```

생성 후 각 폴더의 `SKILL.md`에 목적/입력/출력 포맷만 짧게 채우면 됩니다.
