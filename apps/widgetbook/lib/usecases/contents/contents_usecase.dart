import 'package:design_system/contents/error_content.dart';
import 'package:design_system/contents/loading_content.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';


@UseCase(name: 'Default', type: ErrorContent)
Widget errorContentDefaultUseCase(BuildContext context) => const ErrorContent();

@UseCase(name: 'With message', type: ErrorContent)
Widget errorContentWithMessageUseCase(BuildContext context) => const ErrorContent(message: 'カスタムエラーメッセージ');

@UseCase(name: 'With retry', type: ErrorContent)
Widget errorContentWithRetryUseCase(BuildContext context) => ErrorContent(
  message: '再試行可能',
  onRetry: () {},
);


@UseCase(name: 'Default', type: LoadingContent)
Widget loadingContentDefaultUseCase(BuildContext context) => const LoadingContent();

@UseCase(name: 'With message', type: LoadingContent)
Widget loadingContentWithMessageUseCase(BuildContext context) => const LoadingContent(message: '読み込み中...');
