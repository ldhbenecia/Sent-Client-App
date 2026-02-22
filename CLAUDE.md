# Sent Client App — CLAUDE.md

Flutter iOS 앱. 백엔드: `sent-server` (Kotlin/Spring Boot, localhost:8080).

---

## 실행

```bash
./run.dev.sh    # DEV_MODE=true, localhost:8080
./run.prod.sh   # DEV_MODE=false, 프로덕션 URL

dart run build_runner build --delete-conflicting-outputs  # 코드 생성
flutter build ios --no-codesign                           # 빌드 에러 확인
```

---

## 커밋 컨벤션

```
type(scope): 설명
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
| `ui` | lib/shared/ |
| `env` | 환경설정, run.sh |

```
feat(todo): 카테고리 편집 페이지 추가
fix(core): 토큰 갱신 무한 루프 수정
chore(deps): table_calendar 패키지 추가
refactor(router): StatefulShellRoute 전환
```

역할이 다른 파일은 커밋을 분리한다.

---

## 코드 스타일

**파일 분리**: 한 파일에 너무 많은 클래스/위젯을 넣지 않는다.
- 페이지 파일(`_page.dart`)에는 해당 페이지의 주요 위젯만
- 재사용 가능한 위젯은 `shared/widgets/` 또는 feature 내 `widgets/` 폴더로 분리
- Provider는 `presentation/providers/` 에 모아서 관리

**위젯 구성**:
- 작은 private 위젯(`_XxxWidget`)은 같은 파일 하단에 위치
- 200줄 이상 넘어가면 분리를 검토한다

**상태관리**:
- `@riverpod` 어노테이션 사용, 파일마다 `part '*.g.dart'` 선언
- UI에서 직접 비동기 로직 쓰지 않고 Provider/Notifier로 위임
- AsyncValue는 `.when()` 또는 `.valueOrNull ?? []` 패턴 사용

**네이밍**:
- 파일명: `snake_case`
- 클래스: `PascalCase`
- private 위젯/함수: `_camelCase`

---

## 주의사항

- `flutter run` 전에 시뮬레이터 **Booted 상태** 확인
- `.g.dart`, `.freezed.dart` 파일도 커밋한다
- DEV 모드: `dart-define=DEV_MODE=true` 없이 빌드하면 dev 버튼 안 뜸 → `flutter clean` 후 재빌드
