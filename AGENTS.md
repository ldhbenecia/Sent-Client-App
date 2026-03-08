# AGENTS.md

이 파일은 이 저장소에서 Codex가 작업할 때의 기본 규칙이다.

## 목적

- 빠르게 변경하고, 반드시 검증하고, 변경 범위를 작게 유지한다.
- 기능 코드와 포맷/리네임/대규모 이동을 한 커밋에 섞지 않는다.

## 작업 순서

1. 영향 범위를 먼저 찾는다 (`rg`, `git grep` 우선).
2. 최소 변경으로 수정한다.
3. 아래 검증을 실행한다.
4. 변경 이유가 드러나는 커밋 메시지로 커밋한다.

## 실행/검증 명령

```bash
./run.dev.sh
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

## 코드/구조 원칙

- 상태 관리는 Riverpod(`@riverpod`) 기준을 따른다.
- 비동기/비즈니스 로직은 UI(`*_page.dart`)에 두지 않는다.
- 공통 UI는 `lib/shared/`, 기능 전용 UI는 해당 feature 내부에 둔다.
- 사용자 노출 문자열은 `lib/l10n/*.arb` 및 `AppLocalizations`로 관리한다.

## 생성 파일 규칙

- 생성 파일(`*.g.dart`, 사용 시 `*.freezed.dart`)은 소스와 함께 커밋한다.
- ARB 변경 후 `flutter gen-l10n`을 반드시 실행한다.
- `@riverpod` 변경 후 `build_runner`를 반드시 실행한다.

## 커밋 규칙

- 형식: `type(scope): 한글 설명`
- type: `feat`, `fix`, `refactor`, `chore`, `docs`
- scope 예시: `core`, `router`, `auth`, `home`, `todo`, `ledger`, `social`, `memo`, `settings`, `ui`, `l10n`, `deps`
- 서로 다른 도메인 변경은 가능한 분리 커밋한다.

## 주의사항

- API 기본 URL은 `http://localhost:8080`
- 환경 파일은 `.env`, `.env.prod`를 사용한다.
- 민감정보는 커밋하지 않는다.
