import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/posts.dart';

class ListPostTab extends HookConsumerWidget {
  const ListPostTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    final f = DateFormat('yyyy-MM-dd');

    return Column(
      children: [
        posts.when(
          data: (articles) {
            return DataTable(
              dataRowMaxHeight: 100,
              columns: const [
                DataColumn(label: Text('Index')),
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Tiêu đề')),
                DataColumn(label: Text('Ảnh bìa')),
                DataColumn(label: Text('Tags')),
                DataColumn(label: Text('Trạng thái')),
                DataColumn(label: Text('Thời gian đăng bài')),
              ],
              rows: List.generate(
                articles.length,
                (index) {
                  final post = articles[index];
                  return DataRow(
                    onSelectChanged: (value) {
                      context.go('/create');
                    },
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(post.id ?? '')),
                      DataCell(Text(
                        post.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                      DataCell(Text(post.img ?? '')),
                      DataCell(Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: post.tags
                                  ?.map((e) => Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(e),
                                      ))
                                  .toList() ??
                              [],
                        ),
                      )),
                      DataCell(Text(post.status.toString())),
                      DataCell(Row(
                        children: [
                          const Icon(Icons.replay_circle_filled_outlined),
                          const SizedBox(width: 5),
                          Text(f.format(post.createdAt ?? DateTime.now())),
                        ],
                      )),
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
    );
  }
}
