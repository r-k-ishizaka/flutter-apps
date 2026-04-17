import 'package:design_system/snackbars/default_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';


@UseCase(name: 'Default', type: DefaultSnackBar)
Widget defaultSnackBarDefaultUseCase(BuildContext context) => Builder(
  builder: (context) => ElevatedButton(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        DefaultSnackBar(message: 'デフォルトスナックバー'),
      );
    },
    child: const Text('Show SnackBar'),
  ),
);

@UseCase(name: 'With Action', type: DefaultSnackBar)
Widget defaultSnackBarWithActionUseCase(BuildContext context) => Builder(
  builder: (context) => ElevatedButton(
    onPressed: () {
      ScaffoldMessenger.of(context).showSnackBar(
        DefaultSnackBar(
          message: 'アクション付き',
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {},
          ),
        ),
      );
    },
    child: const Text('Show SnackBar with Action'),
  ),
);
