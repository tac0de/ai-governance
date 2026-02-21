# Codex 글로벌 세팅 사용법 (간단)

## 1) 적용된 것
- 전역 스킬: `~/.codex/skills/global-governance-closure/SKILL.md`
- 전역 프롬프트 템플릿: `~/.codex/prompts/governance_lock_prompt_en.md`
- 전역 커스텀 명령: `~/.zsh_codex_shortcuts`

## 2) 터미널에서 바로 쓰는 명령
- `cdx-aigov` : `ai-governance` 폴더로 이동
- `cdx-tdp` : `thedivineparadox` 폴더로 이동
- `cdx-skills` : Codex 스킬 폴더로 이동
- `cdx-prompt` : 거버넌스 잠금용 프롬프트 출력
- `cdx-prompt-copy` : 프롬프트를 클립보드로 복사
- `cdx-help` : 이 문서 열람
- `codex-help` : 이 문서 열람 (동일 기능)
- `codex-skill-list` : 설치된 스킬 목록 확인
- `codex-skill-init <name> [resources]` : 스킬 자동 생성
- `codex-skill-validate <folder>` : 스킬 검증

## 3) 처음 1회 또는 설정 변경 후
아래 명령으로 셸을 다시 로드:

```bash
source ~/.zshrc
```

## 4) 스킬/사전 프롬프트 개념 (짧게)
- 스킬: 작업 절차를 고정한 로컬 가이드 파일입니다.
- 사전 프롬프트: 작업 시작 전에 붙이는 템플릿 문장입니다.
- 권장 순서: 스킬로 구조를 고정하고, 사전 프롬프트로 그때그때 목적을 넣습니다.

## 5) VSCode에서 클릭 실행 (터미널 명령 대체)
- `Cmd+Shift+P` -> `Tasks: Run Task`
- 실행할 작업 선택:
  - `Codex: Help`
  - `TDP: Dev (Backend+Frontend)`
  - `TDP: Backend Only`
  - `TDP: Frontend Only`

## 6) UI 없이 스킬 만드는 순서 (자동)
```bash
codex-skill-init my-skill scripts,references
codex-skill-validate my-skill
```
- 생성 위치: `~/.codex/skills/my-skill`
- 마지막: Codex 재시작
