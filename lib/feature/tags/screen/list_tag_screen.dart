import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:irohasu_admin/feature/tags/model/tag_model.dart';
import 'package:irohasu_admin/feature/widget/data_table/data_table.dart';

import '../../widget/data_table/data_column.dart';
import '../../widget/data_table/data_table_source.dart';
import '../provider/tags.dart';

class ListTagTab extends HookConsumerWidget {
  const ListTagTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);
    return tags.when(
      data: (tags) => _DataTableWidget(tags: tags),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _DataTableWidget extends StatelessWidget {
  const _DataTableWidget({super.key, this.tags = const []});

  final List<TagModel> tags;

  @override
  Widget build(BuildContext context) {
    return WebDataTable(
      header: Text('Sample Data'),
      source: WebDataTableSource(
        // sortColumnName: _sortColumnName,
        // sortAscending: _sortAscending,
        // filterTexts: _filterTexts,
        columns: [
          WebDataColumn(
            name: 'id',
            label: const Text('ID'),
            dataCell: (value) => DataCell(Text(value != null ? '$value' : '')),
          ),
          WebDataColumn(
            name: 'name',
            label: const Text('Name'),
            dataCell: (value) => DataCell(Text('$value')),
          ),
          WebDataColumn(
            name: 'created_at',
            label: const Text('Ngày tạo'),
            dataCell: (value) {
              if (value is DateTime) {
                final text = '${value.year}/${value.month}/${value.day} ${value.hour}:${value.minute}:${value.second}';
                return DataCell(Text(text));
              }
              return DataCell(Text(value.toString()));
            },
            filterText: (value) {
              if (value is DateTime) {
                return '${value.year}/${value.month}/${value.day} ${value.hour}:${value.minute}:${value.second}';
              }
              return value.toString();
            },
          ),
          WebDataColumn(
            name: 'updated_at',
            label: const Text('Ngày cập nhật'),
            dataCell: (value) {
              if (value is DateTime) {
                final text = '${value.year}/${value.month}/${value.day} ${value.hour}:${value.minute}:${value.second}';
                return DataCell(Text(text));
              }
              return DataCell(Text(value.toString()));
            },
            filterText: (value) {
              if (value is DateTime) {
                return '${value.year}/${value.month}/${value.day} ${value.hour}:${value.minute}:${value.second}';
              }
              return value.toString();
            },
          ),
          WebDataColumn(
            name: 'count',
            label: const Text('Số lượng'),
            dataCell: (value) => DataCell(Text(value != null ? '$value' : '')),
          ),
        ],
        rows: tags.map((tag) => tag.toJson()).toList(),
        // selectedRowKeys: _selectedRowKeys,
        onTapRow: (rows, index) {
          print('onTapRow(): index = $index, row = ${rows[index]}');
        },
        onSelectRows: (keys) {},
        primaryKeyName: 'id',
      ),
    );
  }
}
