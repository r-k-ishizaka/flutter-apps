import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../route/app_routes.dart';
import 'auth_provider.dart';
import 'auth_screen_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final TextEditingController _baseUrlController;
  late final TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(text: 'https://misskey.io');
    _tokenController = TextEditingController();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthProvider>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('認証')),
      bottomNavigationBar: const AppNavBar(currentPath: '/auth'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              labelText: 'Misskey サーバーURL',
              hintText: 'https://example.tld',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            decoration: const InputDecoration(
              labelText: 'アクセストークン',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.status == AuthStatus.loading
                ? null
                : () async {
                    await context.read<AuthProvider>().signIn(
                      baseUrl: _baseUrlController.text,
                      accessToken: _tokenController.text,
                    );
                  },
            child: state.status == AuthStatus.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('ログインして検証'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.read<AuthProvider>().signOut(),
            child: const Text('ログアウト'),
          ),
          const SizedBox(height: 20),
          if (state.session != null)
            Text('接続先: ${state.session!.baseUrl}'),
          if (state.user != null)
            Text('ユーザー: @${state.user!.username} (${state.user!.name})'),
          if (state.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(state.message!),
            ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            onPressed: () => context.go('/timeline'),
            child: const Text('タイムラインへ'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => context.go('/post'),
            child: const Text('投稿画面へ'),
          ),
        ],
      ),
    );
  }
}
