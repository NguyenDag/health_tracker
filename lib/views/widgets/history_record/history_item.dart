import 'package:flutter/material.dart';

import '../../../domain/entities/health_record.dart';
import '../../../domain/enums/health_type.dart';

class HistoryItem extends StatelessWidget {
  final HealthRecord record;

  const HistoryItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            "${record.measuredAt.hour}:${record.measuredAt.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  String _valueText() {
    switch (record.type) {
      case HealthType.BP:
        return "${record.systolic}/${record.diastolic} mmHg";
      case HealthType.Sugar:
        return "${record.glucose} ${record.glucoseUnit}";
      case HealthType.Weight:
        return "${record.weight} kg";
      case HealthType.Spo2:
        return "${record.spo2}%";
    }
  }

  String _subtitle() {
    switch (record.type) {
      case HealthType.BP:
        return "Blood Pressure";
      case HealthType.Sugar:
        return "Blood Sugar";
      case HealthType.Weight:
        return "Weight";
      case HealthType.Spo2:
        return "SpO2";
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