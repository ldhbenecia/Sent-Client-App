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
| `chat` | lib/features/chat/ + social/chat 관련 |
| `ledger` | lib/features/ledger/ |
| `ui` | lib/shared/ |
| `l10n` | lib/l10n/ ARB + generated |
| `env` | 환경설정, run.sh |

예시:
```
feat(todo): 시간 선택 인라인 드럼롤 피커 구현
feat(chat): 채팅방 메시지 그룹 간격 개선
feat(social): 보낸 친구 요청 전체 상태 표시
feat(l10n): 알림 옵션 문자열 추가 (ko/en/ja)
fix(core): 토큰 갱신 무한 루프 수정
chore(deps): table_calendar 패키지 추가
```

**커밋 분리 원칙** (중요):
- **도메인별로 반드시 분리** — todo, chat, social, ledger 변경은 각각 별도 커밋
- **레이어별로 분리** — 같은 도메인이라도 `domain/data/presentation` 레이어가 다르면 분리
- **l10n은 별도 커밋** — ARB + generated 파일은 항상 따로
- 한 커밋에 여러 도메인·레이어를 묶지 않는다

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
- 색상은 항상 `context.colors.*` 참조 (`AppColors.*` 직접 참조 금지; 카테고리 프리셋·로고 primary 스케일은 예외)
- `withOpacity()` 대신 `withValues(alpha:)` 사용
- 삭제 등 비가역적 동작은 반드시 확인 바텀시트 표시
- **터치 타겟**: 손가락으로 탭하는 모든 버튼은 최소 44×44px 확보. 아이콘이 작더라도 GestureDetector/InkWell 영역은 넉넉하게. 행(row) 전체를 탭 타겟으로 쓰고, 행 안에 작은 X 같은 보조 버튼을 중첩 배치하지 않는다
- 인라인 피커(드럼롤·옵션 목록)는 행을 탭해 펼치고, 피커 내부에 초기화/확인 버튼을 둔다 — 행 trailing에 별도 제거 버튼 금지

**다국어(i18n) 규칙**:
- 사용자에게 노출되는 모든 문자열은 `AppLocalizations.of(context)!.<key>` 로 참조
- 새 기능 구현 시 반드시 `lib/l10n/app_ko.arb`, `app_en.arb`, `app_ja.arb` 3개 파일 모두 업데이트
- ARB key는 `camelCase`, 화면/기능 단위 prefix 권장 (예: `ledgerNewEntry`, `todoDeleteConfirm`)
- ARB 수정 후 반드시 `flutter gen-l10n` 실행 (build_runner 아님)
- 날짜·요일 포맷: `intl` 패키지 `DateFormat` 사용 — `DateFormat.yMMMM(locale)`, `DateFormat.MMMd(locale)`, `DateFormat.E(locale)` 등
  - locale은 `Localizations.localeOf(context).toString()` 으로 획득
- 통화 기호: `l10n.currencySymbol` 참조 (한국어 "원", 영어/일본어 "₩")

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
