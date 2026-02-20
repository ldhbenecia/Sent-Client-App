# Sent Client App — CLAUDE.md

Flutter iOS 앱. 백엔드: `sent-server` (Kotlin/Spring Boot, localhost:8080).

---

## Tech Stack

| 역할 | 패키지 |
|------|--------|
| 상태 관리 | `flutter_riverpod` + `riverpod_annotation` |
| 네트워크 | `dio` + `pretty_dio_logger` |
| 라우팅 | `go_router` |
| OAuth 로그인 | `flutter_web_auth_2` |
| 토큰 저장 | `flutter_secure_storage` |
| 모델 직렬화 | `freezed` + `json_serializable` |
| 코드 생성 | `build_runner` |

---

## 폴더 구조

```
lib/
├── main.dart
├── core/
│   ├── config/        # AppConfig (API URL, OAuth 콜백 스킴)
│   ├── network/       # Dio + JWT 인터셉터
│   ├── storage/       # TokenStorage
│   ├── router/        # go_router
│   └── error/         # AppException
├── features/
│   ├── auth/
│   │   ├── data/services/      # OAuthService
│   │   └── presentation/pages/ # LoginPage
│   ├── todo/
│   ├── memo/
│   └── social/
└── shared/
    ├── theme/         # AppColors, AppTheme
    └── widgets/       # SentLogo, MainShell, GlassContainer
```

---

## 실행 명령어

### DEV (개발 환경)
```bash
# .env: API_BASE_URL=http://localhost:8080, DEV_MODE=true
./run.dev.sh   # DEV_MODE=true → 앱 내 "DEV — 로그인 건너뛰기" 버튼 표시
               # 로그인 스킵: 로그인 카드 하단 DEV 버튼
               # 로그인 화면 복귀: 메인에서 우상단 프로필 아이콘 탭
```

### PROD (프로덕션 환경)
```bash
# 1. .env.prod 파일 준비 (.env.prod.example 참고)
cp .env.prod.example .env.prod
# API_BASE_URL=https://api.sent.com, DEV_MODE=false 로 수정

# 2. 실행
./run.prod.sh  # DEV_MODE=false → DEV 버튼 숨김
               # 실제 기기 배포: flutter build ipa
```

### 기타
```bash
# 실행 중 단축키: r = hot reload / R = restart / q = 종료

# 코드 생성 (.g.dart 재생성)
dart run build_runner build --delete-conflicting-outputs

# 빌드 에러 확인
flutter build ios --no-codesign
```

---

## 라우팅

```
/auth/login  → LoginPage
/todo        → TodoPage   (ShellRoute 탭 1)
/memo        → MemoPage   (ShellRoute 탭 2)
/social      → SocialPage (ShellRoute 탭 3)
```

토큰 없으면 `/auth/login`, 토큰 있으면 `/todo` 자동 리다이렉트.

---

## Provider 패턴

```dart
// @riverpod 어노테이션 사용, 파일마다 part 선언 필요
part 'todo_list.g.dart';

@riverpod
Future<List<Todo>> todoList(Ref ref) async {
  return ref.watch(todoRepositoryProvider).fetchAll();
}
```

코드 생성 후 `.g.dart` 파일도 커밋한다.

---

## 모델 패턴

```dart
@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    required bool isDone,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
```

---

## 디자인 시스템

- 다크 테마 전용, 폰트: Pretendard
- 색상: `lib/shared/theme/app_colors.dart`
  - background `#000000` / card `#0F0F0F` / border `#262626`
- 글래스모피즘: `GlassContainer` 위젯 사용

---

## 커밋 컨벤션

```
feat / fix / refactor / chore / docs
```

관련 파일은 묶어서, 역할 다른 파일은 분리해서 커밋.

---

## 주의사항

- `flutter run` 전에 시뮬레이터 **Booted 상태** 확인 (`open -a Simulator`)
- `.g.dart`, `.freezed.dart` 파일 커밋 대상
- API URL 기본값: `http://localhost:8080` (`AppConfig.apiBaseUrl`)
