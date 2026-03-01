// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'SENT';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get save => '저장';

  @override
  String get edit => '수정';

  @override
  String get register => '등록';

  @override
  String get retry => '다시 시도';

  @override
  String get none => '없음';

  @override
  String get confirm => '확인';

  @override
  String get close => '닫기';

  @override
  String get manage => '관리';

  @override
  String get loadFailed => '불러오기 실패';

  @override
  String get pageNotFound => '페이지를 찾을 수 없습니다';

  @override
  String get settings => '설정';

  @override
  String get profile => '프로필';

  @override
  String get notifications => '알림';

  @override
  String get info => '정보';

  @override
  String get account => '계정';

  @override
  String get appearance => '화면';

  @override
  String get theme => '테마';

  @override
  String get language => '언어';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeDark => '다크';

  @override
  String get themeLight => '라이트';

  @override
  String get logout => '로그아웃';

  @override
  String get logoutConfirmTitle => '로그아웃';

  @override
  String get logoutConfirmMessage => '로그아웃 하시겠어요?';

  @override
  String get legalInfo => '법적 정보';

  @override
  String get termsOfService => '서비스 이용약관';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get openSourceLicense => '오픈소스 라이선스';

  @override
  String get version => '버전';

  @override
  String get comingSoon => '준비 중인 기능이에요.';

  @override
  String get privateAccount => '비공개 계정';

  @override
  String get blockedUsers => '차단 목록';

  @override
  String get privacy => '개인정보 보호';

  @override
  String get loginTagline => '일상을 체계적으로 관리하세요';

  @override
  String get loginSubtitle => '소셜 계정으로 간편하게 시작하세요';

  @override
  String get continueWithGoogle => 'Google로 계속하기';

  @override
  String get continueWithNaver => '네이버로 계속하기';

  @override
  String get continueWithKakao => '카카오로 계속하기';

  @override
  String get loginError => '로그인 중 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.';

  @override
  String get today => '오늘';

  @override
  String get allDone => '전량 완료했습니다.';

  @override
  String remainingCount(int count) {
    return '$count개의 할 일이 남아있습니다.';
  }

  @override
  String get todoAddTask => '할 일을 추가해보세요';

  @override
  String get todoEmptyTitle => '할 일이 없습니다';

  @override
  String get todoEmptySubtitle => '아래 + 버튼으로\n첫 번째 할 일을 추가해보세요';

  @override
  String get todoCategory => '카테고리';

  @override
  String get todoTime => '시간 선택';

  @override
  String get todoNotification => '알림';

  @override
  String get todoContentHint => '내용을 입력하세요';

  @override
  String get categoryEdit => '카테고리 편집';

  @override
  String get categoryNew => '새로운 카테고리';

  @override
  String get categorySelect => '카테고리 선택';

  @override
  String get categoryIcon => '아이콘';

  @override
  String get categoryColor => '색상';

  @override
  String get categoryNameHint => '이름을 입력하세요';

  @override
  String get memoEmptyTitle => '메모가 없습니다';

  @override
  String get memoEmptySubtitle => '아래 + 버튼으로\n첫 번째 메모를 작성해보세요';

  @override
  String get friendsSection => '친구';

  @override
  String get friendRequestsSection => '받은 친구 요청';

  @override
  String get friendsEmpty => '친구가 없습니다';

  @override
  String get friendsEmptySubtitle => '오른쪽 위 버튼으로\n첫 번째 친구를 추가해보세요';

  @override
  String get friendDeleteTitle => '친구 삭제';

  @override
  String friendDeleteMessage(String name) {
    return '$name님을 친구 목록에서 삭제할까요?';
  }

  @override
  String get accept => '수락';

  @override
  String get reject => '거절';

  @override
  String get myCode => '내 코드';

  @override
  String get codeCopied => '코드가 복사됐습니다.';

  @override
  String get copy => '복사';

  @override
  String get addFriend => '친구 추가';

  @override
  String get addFriendSubtitle => '유저코드로 친구를 검색하세요.';

  @override
  String get codeHint => '유저코드 (예: ABCD1234)';

  @override
  String get search => '검색';

  @override
  String get userNotFound => '일치하는 사용자를 찾을 수 없습니다.';

  @override
  String friendRequestSent(String name) {
    return '$name님께 친구 요청을 보냈습니다.';
  }

  @override
  String get request => '요청';

  @override
  String get connectingToServer => '서버에 연결 중...';

  @override
  String get chatEmpty => '아직 메시지가 없어요\n먼저 인사해보세요';

  @override
  String get messageHint => '메시지';

  @override
  String get connectingHint => '연결 중...';

  @override
  String get currencySymbol => '원';

  @override
  String get income => '수입';

  @override
  String get expense => '지출';

  @override
  String get netAmount => '순액';

  @override
  String get transactionDate => '거래일';

  @override
  String get paymentMethod => '결제수단';

  @override
  String get memoOptionalHint => '메모 (선택)';

  @override
  String get ledgerEmptyMonth => '이번 달 내역이 없습니다';

  @override
  String get ledgerEmptyDay => '이 날 내역이 없습니다';

  @override
  String get ledgerDeleteTitle => '내역을 삭제할까요?';

  @override
  String get ledgerDeleteMessage => '삭제된 내역은 복구할 수 없습니다.';

  @override
  String get addEntry => '내역 추가';

  @override
  String get editEntry => '내역 수정';

  @override
  String get selectDate => '거래일 선택';

  @override
  String get ledgerCategory => '가계부 카테고리';

  @override
  String get ledgerCategoryNew => '새로운 카테고리';
}
