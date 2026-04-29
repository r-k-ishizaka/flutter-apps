/// カスタム絵文字の1アイテムを表すモデル。
class CustomEmojiItem {
  const CustomEmojiItem({
    required this.name,
    required this.url,
    required this.aliases,
    required this.categoryPath,
  });

  final String name;
  final String url;
  final List<String> aliases;
  final String categoryPath;
}
