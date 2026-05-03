/// 絵文字名が現在ログイン中サーバで利用可能かを判定する。
///
/// DB には他サーバ由来の `name@host` 形式が混在するため、
/// リアクション送信で弾かれない候補だけをピッカーに表示する。
bool isEmojiAvailableForHost(String emojiName, {String? sessionHost}) {
  final atIndex = emojiName.lastIndexOf('@');
  if (atIndex < 0) {
    // bare name は自サーバ絵文字として扱う
    return true;
  }

  if (atIndex == emojiName.length - 1) {
    // 不正な `name@` 形式は除外
    return false;
  }

  final host = emojiName.substring(atIndex + 1).toLowerCase();
  if (host == '.') {
    return true;
  }

  final normalizedSessionHost = sessionHost?.trim().toLowerCase();
  if (normalizedSessionHost == null || normalizedSessionHost.isEmpty) {
    return false;
  }

  return host == normalizedSessionHost;
}
