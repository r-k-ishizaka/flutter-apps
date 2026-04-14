import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Default', type: CustomButton)
Widget buildCustomButtonDefaultUseCase(BuildContext context) {
  return CustomButton(
    label: '押してね',
    onPressed: () {},
  );
}

@UseCase(name: 'Disabled', type: CustomButton)
Widget customButtonDisabledUseCase(BuildContext context) {
  return CustomButton(
    label: '無効',
    onPressed: null,
  );
}