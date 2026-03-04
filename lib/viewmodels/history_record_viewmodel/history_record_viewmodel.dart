import 'package:flutter/material.dart';

import '../../data/implementations/repositories/health_repository.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/enums/health_type.dart';

class HistoryViewModel extends ChangeNotifier {
  final _repo = HealthRepository();

  List<HealthRecord> _all = [];
  List<HealthRecord> filtered = [];

  HealthType? selectedFilter;
  String searchQuery = "";

  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    _all = await _repo.fetchRecords();
    _applyFilter();

    isLoading = false;
    notifyListeners();
  }

  void filterBy(HealthType? type) {
    selectedFilter = type;
    _applyFilter();
  }

  void search(String value) {
    searchQuery = value;
    _applyFilter();
  }

  void _applyFilter() {
    filtered = _all.where((record) {
      final matchType =
          selectedFilter == null || record.type == selectedFilter;

      final matchSearch = record.type.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      return matchType && matchSearch;
    }).toList();

    notifyListeners();
  }

  Map<String, List<HealthRecord>> get groupedRecords {
    Map<String, List<HealthRecord>> map = {};

    for (var record in filtered) {
      final now = DateTime.now();
      final diff = now.difference(record.measuredAt).inDays;

      String key;
      if (diff == 0) {
        key = "TODAY";
      } else if (diff == 1) {
        key = "YESTERDAY";
      } else {
        key =
        "${record.measuredAt.day}/${record.measuredAt.month}/${record.measuredAt.year}";
      }

      map.putIfAbsent(key, () => []);
      map[key]!.add(record);
    }

    return map;
  }
}