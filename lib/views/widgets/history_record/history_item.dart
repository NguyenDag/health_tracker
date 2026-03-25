import 'package:flutter/material.dart';

import '../../../domain/entities/health_record.dart';
import '../../../domain/enums/health_type.dart';
import '../../../viewmodels/history_record_viewmodel/history_record_viewmodel.dart';
import 'history_detail_modal.dart';

class HistoryItem extends StatelessWidget {
  final HealthRecord record;
  final HistoryViewModel vm;

  const HistoryItem({
    super.key,
    required this.record,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => HistoryDetailModal(record: record, vm: vm,),
          );
        },
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _color().withOpacity(0.15),
            child: Icon(_icon(), color: _color()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _valueText(),
                  style: const TextStyle(
                      fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          Text(
            "${record.createdAt.hour}:${record.createdAt.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    ),
    );
  }

  String _valueText() {
    switch (record.type) {
      case HealthType.BP:
        return "${record.systolic}/${record.diastolic} mmHg";
      case HealthType.Sugar:
        return "${record.glucoseValue} ${record.glucoseUnit}";
      case HealthType.Weight:
        return "${record.weight} kg";
      case HealthType.Spo2:
        return "${record.spo2}%";
    }
  }

  String _subtitle() {
    switch (record.type) {
      case HealthType.BP:
        return "Huyết áp (HA)";
      case HealthType.Sugar:
        return "Đường máu (Đường)";
      case HealthType.Weight:
        return "Cân nặng";
      case HealthType.Spo2:
        return "Nồng độ O2";
    }
  }

  IconData _icon() {
    switch (record.type) {
      case HealthType.BP:
        return Icons.favorite;
      case HealthType.Sugar:
        return Icons.water_drop;
      case HealthType.Weight:
        return Icons.monitor_weight;
      case HealthType.Spo2:
        return Icons.air;
    }
  }

  Color _color() {
    switch (record.type) {
      case HealthType.BP:
        return Colors.teal;
      case HealthType.Sugar:
        return Colors.red;
      case HealthType.Weight:
        return Colors.blue;
      case HealthType.Spo2:
        return Colors.green;
    }
  }
}