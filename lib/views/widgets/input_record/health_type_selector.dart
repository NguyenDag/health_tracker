import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/enums/health_type.dart';
import '../../../viewmodels/add_record_viewmodel/add_record_viewmodel.dart';

class HealthSegmentedControl extends StatelessWidget {
  const HealthSegmentedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddRecordViewModel>();

    final items = HealthType.values;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final type = items[index];

          String label;
          if (type.name == "BP") {
            label = "HUYẾT ÁP";
          } else if (type.name == "Sugar") {
            label = "ĐƯỜNG MÁU";
          }else if (type.name == "Weight") {
            label = "CÂN NẶNG";
          } else {
            label = "NỒNG ĐỘ O2";
          }

          final isSelected = vm.selectedType == type;

          return Expanded(
            child: GestureDetector(
              onTap: () => vm.changeType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.black : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}