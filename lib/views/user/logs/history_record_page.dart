import 'package:flutter/material.dart';
import 'package:health_tracker/views/user/logs/add_record_page.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/history_record_viewmodel/history_record_viewmodel.dart';
import '../../widgets/history_record/history_filter.dart';
import '../../widgets/history_record/history_item.dart';
import '../../widgets/history_record/history_list.dart';
import '../../widgets/history_record/history_search.dart';
import '../../widgets/history_record/history_section.dart';
import 'input_record_page.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryViewModel()..load(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Record History",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const HistorySearch(),
          const SizedBox(height: 12),
          const HistoryFilter(),
          Expanded(
            child: Consumer<HistoryViewModel>(
              builder: (_, vm, __) {
                final grouped = vm.groupedRecords;

                return ListView(
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HistorySection(title: entry.key),
                        ...entry.value
                            .map((record) => HistoryItem(record: record))
                            .toList(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),

      /// FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA4EADB),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecordScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Trends"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}