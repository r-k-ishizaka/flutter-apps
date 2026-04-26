import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          '通知画面（仮）\n\nリプライやリアクションの通知一覧をここに表示予定です。',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
