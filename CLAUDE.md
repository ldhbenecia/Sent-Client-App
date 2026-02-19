# Sent Client App — CLAUDE.md

Flutter 기반 All-in-One 생산성 앱 (iOS 우선).
백엔드: Kotlin/Spring Boot (`sent-server`), JWT 인증, REST API + WebSocket.

---

## Tech Stack

| 역할 | 패키지 |
|------|--------|
| 상태 관리 | `flutter_riverpod` + `riverpod_annotation` |
| 네트워크 | `dio` + `pretty_dio_logger` |
| 라우팅 | `go_router` |
| 토큰 저장 | `flutter_secure_storage` |
| 로컬 저장 | `shared_preferences` |
| 모델 직렬화 | `freezed` + `json_serializable` |
| 코드 생성 | `build_runner` |

---

## 폴더 구조

```
lib/
├── main.dart                  # 앱 진입점 (ProviderScope + MaterialApp.router)
├── core/
│   ├── network/               # Dio 클라이언트, 인터셉터
│   ├── storage/               # 토큰 저장소
│   ├── router/                # go_router 라우트 정의
│   └── error/                 # AppException sealed class
├── features/
│   ├── auth/                  # 로그인, 회원가입
│   │   ├── data/              # Repository 구현체, API 호출
│   │   ├── domain/            # Model, Repository 인터페이스
│   │   └── presentation/      # Page, Widget, Provider
│   ├── todo/                  # Todo 기능
│   └── chat/                  # Chat + WebSocket
└── shared/
    ├── theme/                 # AppTheme (색상, 폰트, 컴포넌트 스타일)
    └── widgets/               # 공통 위젯 (MainShell 등)
```

각 feature는 `data / domain / presentation` 3계층으로 구성한다.

---

## 아키텍처 규칙

### 레이어 의존성 방향
```
presentation → domain ← data
```
- `presentation`은 `domain`의 인터페이스만 참조한다
- `data`는 `domain`의 인터페이스를 구현한다
- 레이어를 건너뛰는 직접 참조는 금지한다

### Provider 작성 규칙
- `@riverpod` 어노테이션을 사용한다 (riverpod_generator)
- Provider 파일마다 `part '파일명.g.dart';` 선언 필요
- 코드 생성은 `dart run build_runner build --delete-conflicting-outputs`

```dart
// 올바른 예시
@riverpod
Future<List<Todo>> todoList(Ref ref) async {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.fetchAll();
}
```

### 모델 작성 규칙
- 모든 모델은 `freezed` + `json_serializable`을 사용한다

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

### 에러 처리 규칙
- API 에러는 `AppException` sealed class로 변환한다 (`core/error/app_exception.dart`)
- DioException → `mapDioException()` 함수로 변환
- Provider에서 예외를 직접 throw하지 않고 `AsyncValue`의 error state로 처리한다

---

## 네트워크

- Base URL: `core/network/api_client.dart`의 `_baseUrl` 상수
- 모든 요청에 `Authorization: Bearer {accessToken}` 자동 첨부
- 401 응답 시 Refresh Token으로 자동 재발급 후 원래 요청 재시도
- 재발급 실패 시 토큰 삭제 → 로그인 화면으로 리다이렉트

---

## 라우팅

- 토큰 없으면 `/auth/login`으로 자동 리다이렉트
- 토큰 있으면 `/auth/*` 접근 시 `/todo`로 리다이렉트
- 메인 화면은 `ShellRoute` 안에서 바텀 네비게이션 공유

```
/auth/login     → LoginPage
/auth/sign-up   → SignUpPage
/todo           → TodoPage        (ShellRoute)
/chat           → ChatListPage    (ShellRoute)
```

---

## 커밋 컨벤션

```
feat:     새로운 기능
fix:      버그 수정
refactor: 동작 변경 없는 코드 개선
chore:    빌드, 설정, 패키지 관련
test:     테스트 코드
docs:     문서
```

- 관련 파일은 하나의 커밋으로 묶는다
- 역할이 다른 파일은 커밋을 분리한다
- 커밋 메시지는 한국어로 작성한다

---

## 주요 명령어

```bash
# 앱 실행 (iOS 시뮬레이터)
flutter run

# 코드 생성 (freezed, riverpod .g.dart)
dart run build_runner build --delete-conflicting-outputs

# 코드 생성 감지 모드 (개발 중)
dart run build_runner watch --delete-conflicting-outputs

# 정적 분석
flutter analyze

# 테스트
flutter test

# 패키지 설치
flutter pub get
```

---

## 주의사항

- `.g.dart`, `.freezed.dart` 파일은 **커밋 대상**이다 (빌드 필수)
- `flutter_secure_storage`는 iOS Keychain을 사용하므로 시뮬레이터에서도 동작한다
- WebSocket(Chat)은 `web_socket_channel` 패키지를 사용한다 (추후 추가 예정)
- 환경별 Base URL은 `.env` 파일로 관리한다 (`.gitignore` 처리됨)
