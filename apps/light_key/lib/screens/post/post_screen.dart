import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../route/app_routes.dart';
import 'post_provider.dart';
import 'post_screen_state.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostProvider>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
        actions: [
          IconButton(
            onPressed: () => context.go('/timeline'),
            icon: const Icon(Icons.dynamic_feed),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavBar(currentPath: '/post'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _textController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'いまどうしてる？',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.status == PostStatus.submitting
                ? null
                : () async {
                    await context.read<PostProvider>().submit(_textController.text);
                    if (context.mounted &&
                        context.read<PostProvider>().state.status ==
                            PostStatus.success) {
                      _textController.clear();
                    }
                  },
            child: state.status == PostStatus.submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('投稿する'),
          ),
          if (state.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(state.message!),
            ),
        ],
      ),
    );
  }
}
