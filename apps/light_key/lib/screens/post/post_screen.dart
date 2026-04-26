import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../route/app_routes.dart';
import 'post_provider.dart';
import 'post_screen_state.dart';

class PostScreen extends HookWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final state = context.watch<PostProvider>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
        actions: [
          IconButton(
            onPressed: () => const TimelineRoute().go(context),
            icon: const Icon(Icons.dynamic_feed),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: textController,
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
                    await context.read<PostProvider>().submit(textController.text);
                    if (context.mounted &&
                        context.read<PostProvider>().state.status ==
                            PostStatus.success) {
                      textController.clear();
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
