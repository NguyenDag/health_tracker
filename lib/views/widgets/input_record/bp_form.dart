import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../viewmodels/add_record_viewmodel/add_record_viewmodel.dart';

class BloodPressureForm extends StatefulWidget {
  const BloodPressureForm({super.key});

  @override
  State<BloodPressureForm> createState() => _BloodPressureFormState();
}

class _BloodPressureFormState extends State<BloodPressureForm> {
  final TextEditingController systolicController = TextEditingController(
    text: "120",
  );
  final TextEditingController diastolicController = TextEditingController(
    text: "80",
  );
  final TextEditingController pulseController = TextEditingController(
    text: "72",
  );

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AddRecordViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// SYSTOLIC & DIASTOLIC
        Row(
          children: [
            _pressureCard(
              title: "HUYẾT ÁP TÂM THU *",
              controller: systolicController,
              unit: "mmHg",
            ),
            const SizedBox(width: 15),
            _pressureCard(
              title: "HUYẾT ÁP TÂM TRƯƠNG *",
              controller: diastolicController,
              unit: "mmHg",
            ),
          ],
        ),

        const SizedBox(height: 20),

        /// PULSE
        _pulseCard(),

        const SizedBox(height: 20),

        /// DATE & TIME
        _dateTimeCard(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _pressureCard({
    required String title,
    required TextEditingController controller,
    required String unit,
    bool isError = false,
  }) {
    return Expanded(
      child: Column(
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
              border: Border.all(
                color: isError ? Colors.red : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Không để trống";
                      }
                      if (int.tryParse(value)! <= 0 ||
                          int.tryParse(value)! > 200) {
                        return "Không hợp lệ";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final vm = context.read<AddRecordViewModel>();

                      if (title == "HUYẾT ÁP TÂM THU") {
                        vm.systolic = int.tryParse(value) ?? 0;
                      } else {
                        vm.diastolic = int.tryParse(value) ?? 0;
                      }

                      setState(() {});
                    },
                  ),
                ),
                Text(unit, style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
          if (isError)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Slightly high",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pulseCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "NHỊP TIM *",
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
                  controller: pulseController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Không để trống";
                    }
                    if (int.tryParse(value)! <= 0 ||
                        int.tryParse(value)! > 200) {
                      return "Không hợp lệ";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final vm = context.read<AddRecordViewModel>();
                    vm.pulse = int.tryParse(value) ?? 0;
                  },
                ),
              ),
              const Text("bpm", style: TextStyle(color: Colors.black)),
            ],
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
          "NGÀY HIỆN TẠI",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w900,
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

  Widget _healthTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.tips_and_updates, color: Color(0xFF2ECC71)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Your diastolic reading is higher than your usual average. "
              "Ensure you've been resting for 5 minutes before recording.",
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
