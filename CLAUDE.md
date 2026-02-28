# Sent Client App — CLAUDE.md

Flutter iOS 앱. 백엔드: `sent-server` (Kotlin/Spring Boot, localhost:8080).

---

## 실행

```bash
./run.sh                                                      # 앱 실행 (권장)
dart run build_runner build --delete-conflicting-outputs      # 코드 생성
flutter build ios --no-codesign                               # 빌드 에러 확인
```

- `flutter run` 전에 시뮬레이터 **Booted 상태** 확인
- 실행 중: `r` = hot reload / `R` = restart / `q` = 종료

---

## 커밋 컨벤션

```
type(scope): 한글 설명
```

**type**: `feat` / `fix` / `refactor` / `chore` / `docs`

**scope**:

| scope | 대상 |
|-------|------|
| `deps` | pubspec.yaml, pubspec.lock |
| `core` | lib/core/ |
| `router` | lib/core/router/ |
| `auth` | lib/features/auth/ |
| `todo` | lib/features/todo/ |
| `memo` | lib/features/memo/ |
| `social` | lib/features/social/ |
| `ledger` | lib/features/ledger/ |
| `ui` | lib/shared/ |
| `env` | 환경설정, run.sh |

예시:
```
feat(ledger): 카테고리 편집 페이지 추가
fix(core): 토큰 갱신 무한 루프 수정
chore(deps): table_calendar 패키지 추가
refactor(router): StatefulShellRoute 전환
```

역할이 다른 파일(예: 도메인/데이터/프레젠테이션 레이어)은 커밋을 분리한다.

---

## 코드 스타일

**파일 분리**:
- 페이지 파일(`_page.dart`)에는 해당 페이지의 주요 위젯만
- 재사용 가능한 위젯은 `shared/widgets/` 또는 feature 내 `widgets/` 폴더로 분리
- Provider는 `presentation/providers/` 에 모아서 관리
- 작은 private 위젯(`_XxxWidget`)은 같은 파일 하단에 위치, 200줄 넘으면 분리 검토

**상태 관리**:
- `@riverpod` 어노테이션 사용, 파일마다 `part '*.g.dart'` 선언
- UI에서 직접 비동기 로직 금지 — Provider/Notifier로 위임
- AsyncValue는 `.when()` 또는 `.valueOrNull ?? []` 패턴 사용
- 목록 변경은 `AsyncNotifier` + 낙관적 업데이트 패턴 적용
- `StateProvider`는 단순 UI 상태(선택 월, 선택 날짜 등)에만 사용

**UI/UX 규칙**:
- 다크 테마 전용; 색상은 항상 `AppColors.*` 참조
- `withOpacity()` 대신 `withValues(alpha:)` 사용
- 삭제 등 비가역적 동작은 반드시 확인 바텀시트 표시

**네이밍**:
- 파일명: `snake_case`
- 클래스: `PascalCase`
- private 위젯·함수: `_camelCase`
- Provider: `<기능>Provider` / Notifier: `<기능>Notifier`
- DTO: `<모델>Dto`

---

## 주의사항

- `.g.dart`, `.freezed.dart` 파일도 커밋한다
- API URL 기본값: `http://localhost:8080`
- GoRouter `extra`는 `StatefulShellBranch` 간 이동 시 유실될 수 있음 → Riverpod `StateProvider` 사용
