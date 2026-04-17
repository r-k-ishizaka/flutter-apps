import 'package:flutter/material.dart';

/// エラー画面の中身だけ共通化
class ErrorContent extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorContent({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64),
          SizedBox(height: 16),
          Text(
            message ?? 'エラーが発生しました',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('再試行'),
            ),
          ],
        ],
      ),
    );
  }
}
