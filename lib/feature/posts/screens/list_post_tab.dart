import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:irohasu_admin/feature/widget/drawer_widget.dart';

import '../providers/posts.dart';

class ListPostTab extends HookConsumerWidget {
  const ListPostTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      body: IrhDrawer(
        content: Column(
          children: [
            posts.when(
              data: (articles) {
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Index')),
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Tiêu đề')),
                    DataColumn(label: Text('Ảnh bìa')),
                    DataColumn(label: Text('Trạng thái')),
                    DataColumn(label: Text('Thời gian đăng bài')),
                  ],
                  rows: List.generate(
                    articles.length,
                    (index) {
                      final post = articles[index];
                      return DataRow(
                        onSelectChanged: (value) {
                          context.go('/posts/${post.id}');
                        },
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(post.id ?? '')),
                          DataCell(Text(post.title ?? '')),
                          DataCell(Text(post.img ?? '')),
                          DataCell(Text(post.status.toString())),
                          DataCell(Text(post.createdAt ?? '')),
                        ],
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }
}
