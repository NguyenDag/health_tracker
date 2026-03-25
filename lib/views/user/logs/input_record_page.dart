import 'package:flutter/material.dart';
import 'package:health_tracker/core/constants/app_colors.dart';
import 'package:health_tracker/data/implementations/api/spo2_api.dart';
import 'package:health_tracker/data/implementations/api/weight_api.dart';
import 'package:health_tracker/data/implementations/mapper/spo2_mapper.dart';
import 'package:health_tracker/data/implementations/mapper/weight_mapper.dart';
import 'package:health_tracker/data/implementations/repositories/spo2_repo.dart';
import 'package:health_tracker/data/implementations/repositories/weight_repo.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_config.dart';
import '../../../data/implementations/api/blood_pressure_api.dart';
import '../../../data/implementations/api/blood_sugar_api.dart';
import '../../../data/implementations/mapper/blood_pressure_mapper.dart';
import '../../../data/implementations/mapper/blood_sugar_mapper.dart';
import '../../../data/implementations/repositories/blood_pressure_repo.dart';
import '../../../data/implementations/repositories/blood_sugar_repo.dart';
import '../../../domain/enums/health_type.dart';
import '../../../viewmodels/add_record_viewmodel/add_record_viewmodel.dart';
import '../../../viewmodels/notification_viewmodel.dart';
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
      create: (ctx) => AddRecordViewModel(
        bpRepository: BloodPressureRepo(
          mapper: BloodPressureMapper(),
          api: BloodPressureApi(supabase: supabase),
        ),
        sugarRepository: BloodSugarRepo(
          mapper: BloodSugarMapper(),
          api: BloodSugarApi(supabase: supabase),
        ),
        spo2Repository: Spo2Repo(
          api: Spo2Api(supabase: supabase),
          mapper: Spo2Mapper(),
        ),
        weightRepository: WeightRepo(
          api: WeightApi(supabase: supabase),
          mapper: WeightMapper(),
        ),
        notificationViewModel: ctx.read<NotificationViewModel>(), // 👈 thêm
      ),
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
          "Thêm thông tin chỉ số",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              // child: HealthTypeSelector(),
              child: HealthSegmentedControl(),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildForm(vm),

                    const SizedBox(height: 44),

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
                        onPressed: () async {
                          final success = await vm.save();

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Record Saved")),
                            );
                          }
                          if (success) {
                            Navigator.pop(context, true);
                          }
                        },
                        child: const Text(
                          "Lưu bản ghi",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
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
