import 'package:flutter/material.dart';

import '../../../domain/entities/health_record.dart';
import 'history_item.dart';

class HistoryList extends StatelessWidget {
  final List<HealthRecord> records;

  const HistoryList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (_, index) {
        return HistoryItem(record: records[index]);
      },
    );
  }
}