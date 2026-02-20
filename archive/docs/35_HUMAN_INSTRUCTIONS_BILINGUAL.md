# Human Instructions (KR/EN)

## 1) Purpose / 목적
- EN: Operator quick guide for safe daily governance operations in `ai-governance`.
- KO: `ai-governance`에서 매일 안전하게 운영 점검할 때 쓰는 빠른 안내서입니다.

## 2) Safety Boundary / 안전 경계
- EN: High-risk actions require explicit human approval.
- KO: 고위험 작업은 사람의 명시적 승인이 필요합니다.
- EN: `ai-governance` is governance/routing only; runtime execution belongs to `engine`.
- KO: `ai-governance`는 통제/라우팅 전용이며 실행 로직은 `engine`에 둡니다.

## 3) Daily Run Steps / 일일 실행 절차
1. EN: Run governance checks.
1. KO: 거버넌스 점검을 실행합니다.
2. EN: Review workflow/audit outputs.
2. KO: 워크플로우/감사 결과를 확인합니다.
3. EN: Record decisions if escalation occurred.
3. KO: 에스컬레이션이 있었다면 결정 기록을 남깁니다.

## 4) Core Commands / 핵심 명령어
- EN: `bash tools/repo_sweep.sh --strict`
- KO: `bash tools/repo_sweep.sh --strict`
- EN: `bash tools/main_hub_final_check.sh`
- KO: `bash tools/main_hub_final_check.sh`
- EN: `node tools/repo_parser.js --repo tac0de/ai-governance --branch main`
- KO: `node tools/repo_parser.js --repo tac0de/ai-governance --branch main`
- EN: `node tools/validate_run_contract.js` (if `.ops/run_contract.json` exists)
- KO: `.ops/run_contract.json`이 있을 때 `node tools/validate_run_contract.js`

## 5) Incident Rule / 장애 대응 규칙
- EN: On repeated failure, stop automation and escalate with evidence (`run_contract`, workflow run, report).
- KO: 반복 실패 시 자동화를 중단하고 증적(`run_contract`, 워크플로우 실행, 리포트)과 함께 에스컬레이션합니다.

## 6) Non-overridable Boundaries / 강제 불가 경계
- EN: System/developer safety instructions override direct user command.
- KO: 시스템/개발자 안전 지침이 사용자 직접 명령보다 우선합니다.
- EN: No support for credential theft, malware, or illegal abuse.
- KO: 자격증명 탈취, 악성행위, 불법 목적 요청은 처리하지 않습니다.
- EN: Login/2FA/payment approvals must be completed by the account owner.
- KO: 로그인/2FA/결제 승인 단계는 계정 소유자가 직접 수행해야 합니다.
