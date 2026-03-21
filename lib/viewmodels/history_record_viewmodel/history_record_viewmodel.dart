import 'package:flutter/material.dart';
import 'package:health_tracker/data/implementations/api/blood_pressure_api.dart';
import 'package:health_tracker/data/implementations/api/blood_sugar_api.dart';
import 'package:health_tracker/data/implementations/api/spo2_api.dart';
import 'package:health_tracker/data/implementations/api/weight_api.dart';

import '../../core/network/supabase_config.dart';
import '../../data/implementations/repositories/health_repository.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/enums/health_type.dart';

class HistoryViewModel extends ChangeNotifier {
  final _repo = HealthRepository(
    bloodPressureApi: BloodPressureApi(supabase: supabase),
    bloodSugarApi: BloodSugarApi(supabase: supabase),
    spo2Api: Spo2Api(supabase: supabase),
    weightApi: WeightApi(supabase: supabase),
  );

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
      final matchType = selectedFilter == null || record.type == selectedFilter;

      final matchSearch = record.type.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      return matchType && matchSearch;
    }).toList();

    notifyListeners();
  }

  Future<void> deleteRecord(HealthRecord record) async {
    print("Deleting record id: ${record.id}");
    await _repo.deleteRecord(record);
    await load();
    _all.removeWhere((r) => r.id == record.id);
    _applyFilter();

    notifyListeners();
  }

  Map<String, List<HealthRecord>> get groupedRecords {
    Map<String, List<HealthRecord>> map = {};

    for (var record in filtered) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final recordDate = DateTime(
        record.createdAt.year,
        record.createdAt.month,
        record.createdAt.day,
      );

      final diff = today.difference(recordDate).inDays;

      String key;
      if (diff == 0) {
        key = "HÔM NAY";
      } else if (diff == 1) {
        key = "NGÀY MAI";
      } else {
        key =
            "${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}";
      }

      map.putIfAbsent(key, () => []);
      map[key]!.add(record);
    }

    return map;
  }
}
