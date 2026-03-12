import 'package:flutter/material.dart';
import 'package:health_tracker/core/constants/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../domain/enums/health_type.dart';
import '../../../viewmodels/add_record_viewmodel/add_record_viewmodel.dart';
import '../../widgets/input_record/bp_form.dart';
import '../../widgets/input_record/health_type_selector.dart';
import '../../widgets/input_record/spo2_form.dart';
import '../../widgets/input_record/sugar_form.dart';
import '../../widgets/input_record/weight_form.dart';

class AddRecordScreen extends StatelessWidget {
  const AddRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddRecordViewModel(),
      child: const _AddRecordView(),
    );
  }
}

class _AddRecordView extends StatelessWidget {
  const _AddRecordView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddRecordViewModel>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Add New Record",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// 🔹 Tab chọn loại chỉ số
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              // child: HealthTypeSelector(),
              child: HealthSegmentedControl(),
            ),

            const SizedBox(height: 16),

            /// 🔹 Form thay đổi theo type
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildForm(vm),

                    const SizedBox(height: 44),

                    /// 🔹 Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () {
                          vm.saveMock(); // mock save
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Record Saved (Mock)"),
                            ),
                          );
                        },
                        child: const Text("Save Record", style: TextStyle(
                          color: Colors.white,
                          fontSize: 16
                        ),),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AddRecordViewModel vm) {
    switch (vm.selectedType) {
      case HealthType.BP:
        return BloodPressureForm();
      case HealthType.Sugar:
        return BloodSugarForm();
      case HealthType.Weight:
        return WeightForm();
      case HealthType.Spo2:
        return Spo2Form();
    }
  }
}