import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../viewmodels/add_record_viewmodel/add_record_viewmodel.dart';

class WeightForm extends StatefulWidget {
  const WeightForm({super.key});

  @override
  State<WeightForm> createState() => _WeightFormState();
}

class _WeightFormState extends State<WeightForm> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController weightController = TextEditingController(
    text: "65",
  );
  final TextEditingController bodyFatController = TextEditingController(
    text: "5.0",
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddRecordViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CÂN NẶNG *",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Không để trống";
                    }

                    final number = double.tryParse(value);
                    if (number == null || number <= 0 || number >= 300) {
                      return "Không hợp lệ";
                    }
                    return null;
                  },
                  onChanged: (v) => vm.weight = double.tryParse(v) ?? 0,
                ),
              ),
              const Text("kg", style: TextStyle(color: Colors.black)),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "TỈ LỆ MỠ (%)",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: bodyFatController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }

                    final number = double.tryParse(value);

                    if (number == null || number <= 0 || number >= 100) {
                      return "Không hợp lệ";
                    }
                    return null;
                  },
                  onChanged: (v) {
                    if (v.trim().isEmpty) {
                      vm.bodyFat = null;
                    } else {
                      vm.bodyFat = double.tryParse(v);
                    }
                  },
                ),
              ),
              const Text("%", style: TextStyle(color: Colors.black)),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _noteCard(title: "CHÚ THÍCH", onChanged: (v) => vm.weightNote = v),

        const SizedBox(height: 20),

        /// DATE & TIME
        _dateTimeCard(),
      ],
    );
  }

  Widget _noteCard({
    required String title,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _dateTimeCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "NGÀY THỰC HIỆN",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 10),
              Text(
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
