// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/usecases/custom_button_usecase.dart'
    as _widgetbook_workspace_usecases_custom_button_usecase;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'buttons',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'CustomButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _widgetbook_workspace_usecases_custom_button_usecase
                .buildCustomButtonDefaultUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Disabled',
            builder: _widgetbook_workspace_usecases_custom_button_usecase
                .customButtonDisabledUseCase,
          ),
        ],
      ),
    ],
  ),
];
