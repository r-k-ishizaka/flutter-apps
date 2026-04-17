import 'package:design_system/scaffolds/default_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';


@UseCase(name: 'Default', type: DefaultScaffold)
Widget defaultScaffoldDefaultUseCase(BuildContext context) => const DefaultScaffold(
  body: Center(child: Text('Default Body')),
);

@UseCase(name: 'With AppBar', type: DefaultScaffold)
Widget defaultScaffoldWithAppBarUseCase(BuildContext context) => DefaultScaffold(
  appBar: AppBar(title: const Text('AppBar')),
  body: const Center(child: Text('With AppBar')),
);

@UseCase(name: 'With FAB', type: DefaultScaffold)
Widget defaultScaffoldWithFabUseCase(BuildContext context) => DefaultScaffold(
  body: const Center(child: Text('With FAB')),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),
);
