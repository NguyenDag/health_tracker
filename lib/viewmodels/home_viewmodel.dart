import 'package:flutter/material.dart';
import '../core/services/ai_insight_service.dart';
import '../data/interfaces/repositories/i_health_repository.dart';
import '../domain/entities/health_record.dart';
import '../domain/enums/health_type.dart';

class HomeViewModel extends ChangeNotifier {
  final IHealthRepository _healthRepo;
  final AiInsightService _aiService;

  HomeViewModel(this._healthRepo, this._aiService);

  HealthRecord? _latestBP;
  HealthRecord? _latestSugar;
  HealthRecord? _latestWeight;
  HealthRecord? _latestSpo2;
  List<HealthRecord> _recentRecords = [];

  bool _isLoading = false;
  String? _error;

  String? _aiInsight;
  bool _isLoadingInsight = false;

  HealthRecord? get latestBP => _latestBP;
  HealthRecord? get latestSugar => _latestSugar;
  HealthRecord? get latestWeight => _latestWeight;
  HealthRecord? get latestSpo2 => _latestSpo2;
  List<HealthRecord> get recentRecords => _recentRecords;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get aiInsight => _aiInsight;
  bool get isLoadingInsight => _isLoadingInsight;

  Future<void> fetchLatestVitals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _healthRepo.fetchLatestRecord(HealthType.BP),
        _healthRepo.fetchLatestRecord(HealthType.Sugar),
        _healthRepo.fetchLatestRecord(HealthType.Weight),
        _healthRepo.fetchLatestRecord(HealthType.Spo2),
        _healthRepo.fetchRecords(),
      ]);

      _latestBP = results[0] as HealthRecord?;
      _latestSugar = results[1] as HealthRecord?;
      _latestWeight = results[2] as HealthRecord?;
      _latestSpo2 = results[3] as HealthRecord?;
      
      final allRecords = results[4] as List<HealthRecord>;
      _recentRecords = allRecords.take(3).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    _fetchAiInsight();
  }

  Future<void> _fetchAiInsight() async {
    _isLoadingInsight = true;
    notifyListeners();

    _aiInsight = await _aiService.generateInsight(
      bp: _latestBP,
      sugar: _latestSugar,
      weight: _latestWeight,
      spo2: _latestSpo2,
    );

    _isLoadingInsight = false;
    notifyListeners();
  }
}
