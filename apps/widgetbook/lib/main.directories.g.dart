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
import 'package:widgetbook_workspace/usecases/buttons/custom_button_usecase.dart'
    as _widgetbook_workspace_usecases_buttons_custom_button_usecase;
import 'package:widgetbook_workspace/usecases/contents/contents_usecase.dart'
    as _widgetbook_workspace_usecases_contents_contents_usecase;
import 'package:widgetbook_workspace/usecases/scaffolds/scaffolds_usecase.dart'
    as _widgetbook_workspace_usecases_scaffolds_scaffolds_usecase;
import 'package:widgetbook_workspace/usecases/snackbars/snackbars_usecase.dart'
    as _widgetbook_workspace_usecases_snackbars_snackbars_usecase;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'buttons',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'CustomButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder:
                _widgetbook_workspace_usecases_buttons_custom_button_usecase
                    .buildCustomButtonDefaultUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Disabled',
            builder:
                _widgetbook_workspace_usecases_buttons_custom_button_usecase
                    .customButtonDisabledUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'contents',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'ErrorContent',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _widgetbook_workspace_usecases_contents_contents_usecase
                .errorContentDefaultUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With message',
            builder: _widgetbook_workspace_usecases_contents_contents_usecase
                .errorContentWithMessageUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With retry',
            builder: _widgetbook_workspace_usecases_contents_contents_usecase
                .errorContentWithRetryUseCase,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'LoadingContent',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _widgetbook_workspace_usecases_contents_contents_usecase
                .loadingContentDefaultUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With message',
            builder: _widgetbook_workspace_usecases_contents_contents_usecase
                .loadingContentWithMessageUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'scaffolds',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'DefaultScaffold',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _widgetbook_workspace_usecases_scaffolds_scaffolds_usecase
                .defaultScaffoldDefaultUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With AppBar',
            builder: _widgetbook_workspace_usecases_scaffolds_scaffolds_usecase
                .defaultScaffoldWithAppBarUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With FAB',
            builder: _widgetbook_workspace_usecases_scaffolds_scaffolds_usecase
                .defaultScaffoldWithFabUseCase,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'snackbars',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'DefaultSnackBar',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Default',
            builder: _widgetbook_workspace_usecases_snackbars_snackbars_usecase
                .defaultSnackBarDefaultUseCase,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'With Action',
            builder: _widgetbook_workspace_usecases_snackbars_snackbars_usecase
                .defaultSnackBarWithActionUseCase,
          ),
        ],
      ),
    ],
  ),
];
