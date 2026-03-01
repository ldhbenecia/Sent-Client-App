// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'SENT';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get save => '保存';

  @override
  String get edit => '編集';

  @override
  String get register => '追加';

  @override
  String get retry => '再試行';

  @override
  String get none => 'なし';

  @override
  String get confirm => '確認';

  @override
  String get close => '閉じる';

  @override
  String get manage => '管理';

  @override
  String get loadFailed => '読み込みに失敗しました';

  @override
  String get pageNotFound => 'ページが見つかりません';

  @override
  String get settings => '設定';

  @override
  String get profile => 'プロフィール';

  @override
  String get notifications => '通知';

  @override
  String get info => '情報';

  @override
  String get account => 'アカウント';

  @override
  String get appearance => '外観';

  @override
  String get theme => 'テーマ';

  @override
  String get language => '言語';

  @override
  String get systemDefault => 'システムのデフォルト';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeLight => 'ライト';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirmTitle => 'ログアウト';

  @override
  String get logoutConfirmMessage => 'ログアウトしますか？';

  @override
  String get legalInfo => '法的情報';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get openSourceLicense => 'オープンソースライセンス';

  @override
  String get version => 'バージョン';

  @override
  String get comingSoon => 'この機能は近日公開予定です。';

  @override
  String get privateAccount => '非公開アカウント';

  @override
  String get blockedUsers => 'ブロックリスト';

  @override
  String get privacy => 'プライバシー';

  @override
  String get loginTagline => '日常を効率的に管理しましょう';

  @override
  String get loginSubtitle => 'ソーシャルアカウントで簡単に始める';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get continueWithNaver => 'Naverで続ける';

  @override
  String get continueWithKakao => 'Kakaoで続ける';

  @override
  String get loginError => 'ログイン中に問題が発生しました。\nしばらくしてからもう一度お試しください。';

  @override
  String get today => '今日';

  @override
  String get allDone => '全て完了しました！';

  @override
  String remainingCount(int count) {
    return '残り$count件のタスクがあります';
  }

  @override
  String get todoAddTask => 'タスクを追加しましょう';

  @override
  String get todoEmptyTitle => 'タスクがありません';

  @override
  String get todoEmptySubtitle => '下の＋ボタンで\n最初のタスクを追加しましょう';

  @override
  String get todoCategory => 'カテゴリ';

  @override
  String get todoTime => '時間を設定';

  @override
  String get todoNotification => 'リマインダー';

  @override
  String get todoContentHint => '内容を入力してください';

  @override
  String get categoryEdit => 'カテゴリ編集';

  @override
  String get categoryNew => '新しいカテゴリ';

  @override
  String get categorySelect => 'カテゴリを選択';

  @override
  String get categoryIcon => 'アイコン';

  @override
  String get categoryColor => 'カラー';

  @override
  String get categoryNameHint => '名前を入力してください';

  @override
  String get memoEmptyTitle => 'メモがありません';

  @override
  String get memoEmptySubtitle => '下の＋ボタンで\n最初のメモを作成しましょう';

  @override
  String get friendsSection => '友達';

  @override
  String get friendRequestsSection => 'フレンドリクエスト';

  @override
  String get friendsEmpty => '友達がいません';

  @override
  String get friendsEmptySubtitle => '右上のボタンで\n最初の友達を追加しましょう';

  @override
  String get friendDeleteTitle => '友達を削除';

  @override
  String friendDeleteMessage(String name) {
    return '$nameさんを友達リストから削除しますか？';
  }

  @override
  String get accept => '承認';

  @override
  String get reject => '拒否';

  @override
  String get myCode => 'マイコード';

  @override
  String get codeCopied => 'コードをコピーしました。';

  @override
  String get copy => 'コピー';

  @override
  String get addFriend => '友達を追加';

  @override
  String get addFriendSubtitle => 'ユーザーコードで友達を検索してください。';

  @override
  String get codeHint => 'ユーザーコード（例: ABCD1234）';

  @override
  String get search => '検索';

  @override
  String get userNotFound => '一致するユーザーが見つかりません。';

  @override
  String friendRequestSent(String name) {
    return '$nameさんにフレンドリクエストを送りました。';
  }

  @override
  String get sentRequestsSection => '送ったリクエスト';

  @override
  String get statusPending => '保留中';

  @override
  String get statusAccepted => '承認済み';

  @override
  String get statusRejected => '拒否済み';

  @override
  String get chatListTitle => 'チャット';

  @override
  String get chatListEmpty => '進行中の会話はありません';

  @override
  String get chatListEmptySubtitle => '友達をタップして\n会話を始めましょう';

  @override
  String get request => 'リクエスト';

  @override
  String get connectingToServer => 'サーバーに接続中...';

  @override
  String get chatEmpty => 'まだメッセージがありません\n最初に挨拶してみましょう';

  @override
  String get messageHint => 'メッセージ';

  @override
  String get connectingHint => '接続中...';

  @override
  String get currencySymbol => '₩';

  @override
  String get income => '収入';

  @override
  String get expense => '支出';

  @override
  String get netAmount => '収支';

  @override
  String get transactionDate => '取引日';

  @override
  String get paymentMethod => '支払方法';

  @override
  String get memoOptionalHint => 'メモ（任意）';

  @override
  String get ledgerEmptyMonth => '今月の取引はありません';

  @override
  String get ledgerEmptyDay => 'この日の取引はありません';

  @override
  String get ledgerDeleteTitle => '取引を削除しますか？';

  @override
  String get ledgerDeleteMessage => 'この操作は元に戻せません。';

  @override
  String get addEntry => '取引を追加';

  @override
  String get editEntry => '取引を編集';

  @override
  String get selectDate => '日付を選択';

  @override
  String get ledgerCategory => '家計簿カテゴリ';

  @override
  String get ledgerCategoryNew => '新しいカテゴリ';
}
