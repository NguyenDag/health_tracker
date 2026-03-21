import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/history_record_viewmodel/history_record_viewmodel.dart';

class HistorySearch extends StatelessWidget {
  const HistorySearch({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HistoryViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: vm.search,
        decoration: InputDecoration(
          hintText: "Tìm kiếm bản ghi",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}