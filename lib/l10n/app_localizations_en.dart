// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SENT';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get register => 'Add';

  @override
  String get retry => 'Retry';

  @override
  String get none => 'None';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get manage => 'Manage';

  @override
  String get loadFailed => 'Failed to load';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get info => 'About';

  @override
  String get account => 'Account';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get logout => 'Sign Out';

  @override
  String get logoutConfirmTitle => 'Sign Out';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to sign out?';

  @override
  String get legalInfo => 'Legal';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get openSourceLicense => 'Open Source Licenses';

  @override
  String get version => 'Version';

  @override
  String get comingSoon => 'This feature is coming soon.';

  @override
  String get privateAccount => 'Private Account';

  @override
  String get blockedUsers => 'Blocked Users';

  @override
  String get privacy => 'Privacy';

  @override
  String get loginTagline => 'Organize your daily life';

  @override
  String get loginSubtitle => 'Sign in with your social account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithNaver => 'Continue with Naver';

  @override
  String get continueWithKakao => 'Continue with Kakao';

  @override
  String get loginError =>
      'Something went wrong during sign in.\nPlease try again later.';

  @override
  String get today => 'Today';

  @override
  String get allDone => 'All done!';

  @override
  String remainingCount(int count) {
    return '$count tasks remaining';
  }

  @override
  String get todoAddTask => 'Add a task';

  @override
  String get todoEmptyTitle => 'No tasks yet';

  @override
  String get todoEmptySubtitle =>
      'Tap the + button below\nto add your first task';

  @override
  String get todoCategory => 'Category';

  @override
  String get todoTime => 'Set Time';

  @override
  String get todoNotification => 'Reminder';

  @override
  String get todoContentHint => 'Enter content';

  @override
  String get categoryEdit => 'Edit Categories';

  @override
  String get categoryNew => 'New Category';

  @override
  String get categorySelect => 'Select Category';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get categoryColor => 'Color';

  @override
  String get categoryNameHint => 'Enter a name';

  @override
  String get memoEmptyTitle => 'No memos yet';

  @override
  String get memoEmptySubtitle =>
      'Tap the + button below\nto write your first memo';

  @override
  String get friendsSection => 'Friends';

  @override
  String get friendRequestsSection => 'Friend Requests';

  @override
  String get friendsEmpty => 'No friends yet';

  @override
  String get friendsEmptySubtitle =>
      'Tap the top-right button\nto add your first friend';

  @override
  String get friendDeleteTitle => 'Remove Friend';

  @override
  String friendDeleteMessage(String name) {
    return 'Remove $name from your friends?';
  }

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Decline';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get addFriendSubtitle => 'Search by email address.';

  @override
  String get emailHint => 'Email address';

  @override
  String get search => 'Search';

  @override
  String get userNotFound => 'No matching user found.';

  @override
  String friendRequestSent(String name) {
    return 'Friend request sent to $name.';
  }

  @override
  String get request => 'Request';

  @override
  String get connectingToServer => 'Connecting to server...';

  @override
  String get chatEmpty => 'No messages yet\nSay hello first!';

  @override
  String get messageHint => 'Message';

  @override
  String get connectingHint => 'Connecting...';

  @override
  String get currencySymbol => '₩';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get netAmount => 'Net';

  @override
  String get transactionDate => 'Date';

  @override
  String get paymentMethod => 'Payment';

  @override
  String get memoOptionalHint => 'Memo (optional)';

  @override
  String get ledgerEmptyMonth => 'No transactions this month';

  @override
  String get ledgerEmptyDay => 'No transactions on this day';

  @override
  String get ledgerDeleteTitle => 'Delete transaction?';

  @override
  String get ledgerDeleteMessage => 'This action cannot be undone.';

  @override
  String get addEntry => 'Add Transaction';

  @override
  String get editEntry => 'Edit Transaction';

  @override
  String get selectDate => 'Select Date';

  @override
  String get ledgerCategory => 'Ledger Categories';

  @override
  String get ledgerCategoryNew => 'New Category';
}
