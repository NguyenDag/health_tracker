import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/enums/health_type.dart';
import '../../../viewmodels/history_record_viewmodel/history_record_viewmodel.dart';

class HistoryFilter extends StatelessWidget {
  const HistoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip(context, "All", null),
        _buildChip(context, "BP", HealthType.BP),
        _buildChip(context, "Sugar", HealthType.Sugar),
        _buildChip(context, "Weight", HealthType.Weight),
        _buildChip(context, "SpO2", HealthType.Spo2),
      ],
    );
  }

  Widget _buildChip(
      BuildContext context, String label, HealthType? type) {
    final vm = context.read<HistoryViewModel>();
    final selected = context.watch<HistoryViewModel>().selectedFilter == type;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => vm.filterBy(type),
      ),
    );
  }
}