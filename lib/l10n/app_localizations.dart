import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'SENT'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get edit;

  /// No description provided for @register.
  ///
  /// In ko, this message translates to:
  /// **'등록'**
  String get register;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @none.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get none;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @manage.
  ///
  /// In ko, this message translates to:
  /// **'관리'**
  String get manage;

  /// No description provided for @loadFailed.
  ///
  /// In ko, this message translates to:
  /// **'불러오기 실패'**
  String get loadFailed;

  /// No description provided for @pageNotFound.
  ///
  /// In ko, this message translates to:
  /// **'페이지를 찾을 수 없습니다'**
  String get pageNotFound;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notifications;

  /// No description provided for @friendRequestNotification.
  ///
  /// In ko, this message translates to:
  /// **'친구 요청 알림'**
  String get friendRequestNotification;

  /// No description provided for @todoReminderNotification.
  ///
  /// In ko, this message translates to:
  /// **'할 일 알림'**
  String get todoReminderNotification;

  /// No description provided for @categoryManagement.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 관리'**
  String get categoryManagement;

  /// No description provided for @info.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get info;

  /// No description provided for @account.
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get account;

  /// No description provided for @appearance.
  ///
  /// In ko, this message translates to:
  /// **'화면'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In ko, this message translates to:
  /// **'시스템 기본값'**
  String get systemDefault;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get themeLight;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 하시겠어요?'**
  String get logoutConfirmMessage;

  /// No description provided for @legalInfo.
  ///
  /// In ko, this message translates to:
  /// **'법적 정보'**
  String get legalInfo;

  /// No description provided for @termsOfService.
  ///
  /// In ko, this message translates to:
  /// **'서비스 이용약관'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get privacyPolicy;

  /// No description provided for @openSourceLicense.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get openSourceLicense;

  /// No description provided for @version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// No description provided for @comingSoon.
  ///
  /// In ko, this message translates to:
  /// **'준비 중인 기능이에요.'**
  String get comingSoon;

  /// No description provided for @privateAccount.
  ///
  /// In ko, this message translates to:
  /// **'비공개 계정'**
  String get privateAccount;

  /// No description provided for @blockedUsers.
  ///
  /// In ko, this message translates to:
  /// **'차단 목록'**
  String get blockedUsers;

  /// No description provided for @privacy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 보호'**
  String get privacy;

  /// No description provided for @loginTagline.
  ///
  /// In ko, this message translates to:
  /// **'일상을 체계적으로 관리하세요'**
  String get loginTagline;

  /// No description provided for @loginSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'소셜 계정으로 간편하게 시작하세요'**
  String get loginSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 계속하기'**
  String get continueWithGoogle;

  /// No description provided for @continueWithNaver.
  ///
  /// In ko, this message translates to:
  /// **'네이버로 계속하기'**
  String get continueWithNaver;

  /// No description provided for @continueWithKakao.
  ///
  /// In ko, this message translates to:
  /// **'카카오로 계속하기'**
  String get continueWithKakao;

  /// No description provided for @loginError.
  ///
  /// In ko, this message translates to:
  /// **'로그인 중 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.'**
  String get loginError;

  /// No description provided for @today.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get today;

  /// No description provided for @allDone.
  ///
  /// In ko, this message translates to:
  /// **'전량 완료했습니다.'**
  String get allDone;

  /// No description provided for @remainingCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개의 할 일이 남아있습니다.'**
  String remainingCount(int count);

  /// No description provided for @todoAddTask.
  ///
  /// In ko, this message translates to:
  /// **'할 일을 추가해보세요'**
  String get todoAddTask;

  /// No description provided for @todoEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'할 일이 없습니다'**
  String get todoEmptyTitle;

  /// No description provided for @todoEmptySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'아래 + 버튼으로\n첫 번째 할 일을 추가해보세요'**
  String get todoEmptySubtitle;

  /// No description provided for @todoCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get todoCategory;

  /// No description provided for @todoTime.
  ///
  /// In ko, this message translates to:
  /// **'시간 선택'**
  String get todoTime;

  /// No description provided for @todoNotification.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get todoNotification;

  /// No description provided for @todoContentHint.
  ///
  /// In ko, this message translates to:
  /// **'내용을 입력하세요'**
  String get todoContentHint;

  /// No description provided for @categoryEdit.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 편집'**
  String get categoryEdit;

  /// No description provided for @categoryNew.
  ///
  /// In ko, this message translates to:
  /// **'새로운 카테고리'**
  String get categoryNew;

  /// No description provided for @categorySelect.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 선택'**
  String get categorySelect;

  /// No description provided for @categoryIcon.
  ///
  /// In ko, this message translates to:
  /// **'아이콘'**
  String get categoryIcon;

  /// No description provided for @categoryColor.
  ///
  /// In ko, this message translates to:
  /// **'색상'**
  String get categoryColor;

  /// No description provided for @categoryNameHint.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력하세요'**
  String get categoryNameHint;

  /// No description provided for @memoEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'메모가 없습니다'**
  String get memoEmptyTitle;

  /// No description provided for @memoEmptySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'아래 + 버튼으로\n첫 번째 메모를 작성해보세요'**
  String get memoEmptySubtitle;

  /// No description provided for @memoCategory.
  ///
  /// In ko, this message translates to:
  /// **'메모 카테고리'**
  String get memoCategory;

  /// No description provided for @memoTitleHint.
  ///
  /// In ko, this message translates to:
  /// **'제목을 입력하세요'**
  String get memoTitleHint;

  /// No description provided for @memoContentHint.
  ///
  /// In ko, this message translates to:
  /// **'내용을 입력하세요 (선택)'**
  String get memoContentHint;

  /// No description provided for @memoTags.
  ///
  /// In ko, this message translates to:
  /// **'태그'**
  String get memoTags;

  /// No description provided for @memoTagsHint.
  ///
  /// In ko, this message translates to:
  /// **'쉼표로 구분 (예: 공부, 독서)'**
  String get memoTagsHint;

  /// No description provided for @friendsSection.
  ///
  /// In ko, this message translates to:
  /// **'친구'**
  String get friendsSection;

  /// No description provided for @friendRequestsSection.
  ///
  /// In ko, this message translates to:
  /// **'받은 친구 요청'**
  String get friendRequestsSection;

  /// No description provided for @friendsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'친구가 없습니다'**
  String get friendsEmpty;

  /// No description provided for @friendsEmptySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'오른쪽 위 버튼으로\n첫 번째 친구를 추가해보세요'**
  String get friendsEmptySubtitle;

  /// No description provided for @friendDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'친구 삭제'**
  String get friendDeleteTitle;

  /// No description provided for @friendDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'{name}님을 친구 목록에서 삭제할까요?'**
  String friendDeleteMessage(String name);

  /// No description provided for @accept.
  ///
  /// In ko, this message translates to:
  /// **'수락'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In ko, this message translates to:
  /// **'거절'**
  String get reject;

  /// No description provided for @myCode.
  ///
  /// In ko, this message translates to:
  /// **'내 코드'**
  String get myCode;

  /// No description provided for @codeCopied.
  ///
  /// In ko, this message translates to:
  /// **'코드가 복사됐습니다.'**
  String get codeCopied;

  /// No description provided for @copy.
  ///
  /// In ko, this message translates to:
  /// **'복사'**
  String get copy;

  /// No description provided for @addFriend.
  ///
  /// In ko, this message translates to:
  /// **'친구 추가'**
  String get addFriend;

  /// No description provided for @addFriendSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'유저코드로 친구를 검색하세요.'**
  String get addFriendSubtitle;

  /// No description provided for @codeHint.
  ///
  /// In ko, this message translates to:
  /// **'유저코드 (예: ABCD1234)'**
  String get codeHint;

  /// No description provided for @search.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get search;

  /// No description provided for @userNotFound.
  ///
  /// In ko, this message translates to:
  /// **'일치하는 사용자를 찾을 수 없습니다.'**
  String get userNotFound;

  /// No description provided for @friendRequestSent.
  ///
  /// In ko, this message translates to:
  /// **'{name}님께 친구 요청을 보냈습니다.'**
  String friendRequestSent(String name);

  /// No description provided for @sentRequestsSection.
  ///
  /// In ko, this message translates to:
  /// **'보낸 친구 요청'**
  String get sentRequestsSection;

  /// No description provided for @statusPending.
  ///
  /// In ko, this message translates to:
  /// **'대기 중'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In ko, this message translates to:
  /// **'수락됨'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In ko, this message translates to:
  /// **'거절됨'**
  String get statusRejected;

  /// No description provided for @chatListTitle.
  ///
  /// In ko, this message translates to:
  /// **'채팅'**
  String get chatListTitle;

  /// No description provided for @chatListEmpty.
  ///
  /// In ko, this message translates to:
  /// **'진행 중인 대화가 없습니다'**
  String get chatListEmpty;

  /// No description provided for @chatListEmptySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'친구를 탭해\n대화를 시작해보세요'**
  String get chatListEmptySubtitle;

  /// No description provided for @request.
  ///
  /// In ko, this message translates to:
  /// **'요청'**
  String get request;

  /// No description provided for @connectingToServer.
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결 중...'**
  String get connectingToServer;

  /// No description provided for @chatEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 메시지가 없어요\n먼저 인사해보세요'**
  String get chatEmpty;

  /// No description provided for @messageHint.
  ///
  /// In ko, this message translates to:
  /// **'메시지'**
  String get messageHint;

  /// No description provided for @connectingHint.
  ///
  /// In ko, this message translates to:
  /// **'연결 중...'**
  String get connectingHint;

  /// No description provided for @currencySymbol.
  ///
  /// In ko, this message translates to:
  /// **'원'**
  String get currencySymbol;

  /// No description provided for @income.
  ///
  /// In ko, this message translates to:
  /// **'수입'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In ko, this message translates to:
  /// **'지출'**
  String get expense;

  /// No description provided for @netAmount.
  ///
  /// In ko, this message translates to:
  /// **'순액'**
  String get netAmount;

  /// No description provided for @transactionDate.
  ///
  /// In ko, this message translates to:
  /// **'거래일'**
  String get transactionDate;

  /// No description provided for @paymentMethod.
  ///
  /// In ko, this message translates to:
  /// **'결제수단'**
  String get paymentMethod;

  /// No description provided for @memoOptionalHint.
  ///
  /// In ko, this message translates to:
  /// **'메모 (선택)'**
  String get memoOptionalHint;

  /// No description provided for @ledgerEmptyMonth.
  ///
  /// In ko, this message translates to:
  /// **'이번 달 내역이 없습니다'**
  String get ledgerEmptyMonth;

  /// No description provided for @ledgerEmptyDay.
  ///
  /// In ko, this message translates to:
  /// **'이 날 내역이 없습니다'**
  String get ledgerEmptyDay;

  /// No description provided for @ledgerDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'내역을 삭제할까요?'**
  String get ledgerDeleteTitle;

  /// No description provided for @ledgerDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'삭제된 내역은 복구할 수 없습니다.'**
  String get ledgerDeleteMessage;

  /// No description provided for @addEntry.
  ///
  /// In ko, this message translates to:
  /// **'내역 추가'**
  String get addEntry;

  /// No description provided for @editEntry.
  ///
  /// In ko, this message translates to:
  /// **'내역 수정'**
  String get editEntry;

  /// No description provided for @selectDate.
  ///
  /// In ko, this message translates to:
  /// **'거래일 선택'**
  String get selectDate;

  /// No description provided for @ledgerCategory.
  ///
  /// In ko, this message translates to:
  /// **'가계부 카테고리'**
  String get ledgerCategory;

  /// No description provided for @ledgerCategoryNew.
  ///
  /// In ko, this message translates to:
  /// **'새로운 카테고리'**
  String get ledgerCategoryNew;

  /// No description provided for @reset.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get reset;

  /// No description provided for @alarmBefore5min.
  ///
  /// In ko, this message translates to:
  /// **'5분 전'**
  String get alarmBefore5min;

  /// No description provided for @alarmBefore10min.
  ///
  /// In ko, this message translates to:
  /// **'10분 전'**
  String get alarmBefore10min;

  /// No description provided for @alarmBefore15min.
  ///
  /// In ko, this message translates to:
  /// **'15분 전'**
  String get alarmBefore15min;

  /// No description provided for @alarmBefore30min.
  ///
  /// In ko, this message translates to:
  /// **'30분 전'**
  String get alarmBefore30min;

  /// No description provided for @alarmBefore1hour.
  ///
  /// In ko, this message translates to:
  /// **'1시간 전'**
  String get alarmBefore1hour;

  /// No description provided for @sentRequestAwaiting.
  ///
  /// In ko, this message translates to:
  /// **'수락 대기 중'**
  String get sentRequestAwaiting;

  /// No description provided for @leaveChatRoom.
  ///
  /// In ko, this message translates to:
  /// **'대화방 나가기'**
  String get leaveChatRoom;

  /// No description provided for @blockUser.
  ///
  /// In ko, this message translates to:
  /// **'차단하기'**
  String get blockUser;

  /// No description provided for @chatDateLabel.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 {day}일'**
  String chatDateLabel(int year, int month, int day);

  /// No description provided for @sentRequestAccepted.
  ///
  /// In ko, this message translates to:
  /// **'수락됨'**
  String get sentRequestAccepted;

  /// No description provided for @sentRequestRejected.
  ///
  /// In ko, this message translates to:
  /// **'거절됨'**
  String get sentRequestRejected;

  /// No description provided for @sentRequestsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'보낸 친구 요청이 없습니다.'**
  String get sentRequestsEmpty;

  /// No description provided for @noReceivedRequests.
  ///
  /// In ko, this message translates to:
  /// **'받은 친구 요청이 없습니다.'**
  String get noReceivedRequests;

  /// No description provided for @deleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 항목을 삭제할까요?'**
  String get deleteConfirm;

  /// No description provided for @friendRejectConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{name}님의 친구 요청을 거절할까요?'**
  String friendRejectConfirm(String name);

  /// No description provided for @friendRequestCancelConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{name}님께 보낸 친구 요청을 취소할까요?'**
  String friendRequestCancelConfirm(String name);

  /// No description provided for @friendRequestCancel.
  ///
  /// In ko, this message translates to:
  /// **'요청 취소'**
  String get friendRequestCancel;

  /// No description provided for @homeTodo.
  ///
  /// In ko, this message translates to:
  /// **'투두'**
  String get homeTodo;

  /// No description provided for @homeLedger.
  ///
  /// In ko, this message translates to:
  /// **'가계부'**
  String get homeLedger;

  /// No description provided for @homeNoTasks.
  ///
  /// In ko, this message translates to:
  /// **'이번 달 할 일이 없어요'**
  String get homeNoTasks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
