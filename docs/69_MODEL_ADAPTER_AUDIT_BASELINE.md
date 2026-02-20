# 69. Model Adapter Audit Baseline

## 목적
로그 감사자 의견(모델별 차이 흡수)을 계약으로 고정한다.

## 감사 요구사항 매핑
1. 모델 특화 프롬프트가 코어 로직에 박혀 있지 않을 것  
   - 코어는 `PromptSpec` 구조만 전달.
   - 모델별 포맷팅은 어댑터 구현 내부에서만 처리.

2. 모델별 출력 포맷 차이를 흡수하는 어댑터 레이어가 있을 것  
   - 표준 인터페이스: `ProviderAdapter`.
   - 표준 결과 타입: `NormalizedResult`.

3. 토큰/컨텍스트/스트리밍 차이를 인터페이스에서 정규화할 것  
   - `NormalizedRequest.limits`로 토큰/타임아웃 정규화.
   - `NormalizedUsage`로 usage 필드 통일.
   - `NormalizedStreamChunk`로 스트리밍 청크 통일.

4. 실패 모드가 모델마다 달라도 상위 레이어는 동일하게 처리할 것  
   - 표준 실패 코드: `NormalizedFailureCode`.
   - 상위 레이어는 provider raw error를 직접 파싱하지 않음.

## 계약 파일
- `contracts/provider.adapter.interface.v1.ts`

## 테스트 게이트(최소)
- 코어 레이어에서 모델별 raw 응답 스키마 참조 금지.
- 코어 레이어에서 모델별 프롬프트 문자열 템플릿 참조 금지.
- 상위 레이어는 `NormalizedResult.ok`만 기준으로 분기.
