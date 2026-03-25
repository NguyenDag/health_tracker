import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../viewmodels/threshold_viewmodel.dart';
import 'widgets/threshold_bar.dart';

class ThresholdsScreen extends StatefulWidget {
  const ThresholdsScreen({super.key});

  @override
  State<ThresholdsScreen> createState() => _ThresholdsScreenState();
}

class _ThresholdsScreenState extends State<ThresholdsScreen> {

  bool morning = true;
  bool evening = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ThresholdViewModel>().loadThresholds();
    });
  }

  @override
  Widget build(BuildContext context) {

    final vm = context.watch<ThresholdViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Ngưỡng Sức Khỏe",style: AppTextStyles.h2),
      ),

      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "PHẠM VI AN TOÀN & NGƯỠNG SỨC KHỎE",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),

          const SizedBox(height: 16),

          ThresholdBar(
            title: "Huyết Áp Tâm Thu",
            unit: vm.systolic?.unit ?? "",
            min: vm.systolic!.dangerMin,
            safeMin: vm.systolic!.normalMin,
            safeMax: vm.systolic!.normalMax,
            max: vm.systolic!.dangerMax,
          ),

          ThresholdBar(
            title: "Huyết Áp Tâm Trương",
            unit: vm.diastolic?.unit ?? "",
            min: vm.diastolic!.dangerMin,
            safeMin: vm.diastolic!.normalMin,
            safeMax: vm.diastolic!.normalMax,
            max: vm.diastolic!.dangerMax,
          ),

          ThresholdBar(
            title: "Huyết Áp Xung",
            unit: vm.pulse?.unit ?? "",
            min: vm.pulse!.dangerMin,
            safeMin: vm.pulse!.normalMin,
            safeMax: vm.pulse!.normalMax,
            max: vm.pulse!.dangerMax,
          ),

          ThresholdBar(
            title: "Đường Huyết",
            min: vm.bloodSugar!.dangerMin,
            safeMin: vm.bloodSugar!.normalMin,
            safeMax: vm.bloodSugar!.normalMax,
            max: vm.bloodSugar!.dangerMax,
            unit: vm.bloodSugar!.unit ?? "",
          ),

          ThresholdBar(
            title: "SpO2 (Oxy)",
            min: vm.spo2!.dangerMin,
            safeMin: vm.spo2!.normalMin,
            safeMax: vm.spo2!.normalMax,
            max: vm.spo2!.dangerMax,
            unit: vm.spo2!.unit ?? "",
          ),

          const SizedBox(height: 24),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "MẸO SỨC KHỎE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 12),

              const Text("• Duy trì huyết áp dưới 120 mmHg."),
              const SizedBox(height: 6),

              const Text("• Giữ lượng đường trong máu ổn định bằng các bữa ăn cân bằng dinh dưỡng."),
              const SizedBox(height: 6),

              const Text("• Nồng độ SpO2 dưới 92% có thể cần được chăm sóc y tế."),
            ],
          )
        ],
      ),
    );
  }
}