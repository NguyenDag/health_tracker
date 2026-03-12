import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/spo2_record.dart';
import '../../../viewmodels/add_record_viewmodel/add_record_viewmodel.dart';

class Spo2Form extends StatefulWidget {
  const Spo2Form({super.key});

  @override
  State<Spo2Form> createState() => _Spo2FormState();
}

class _Spo2FormState extends State<Spo2Form> {
  DateTime selectedDate = DateTime.now();

  final TextEditingController spo2Controller =
  TextEditingController(text: "98");

  bool get isLow {
    final value = int.tryParse(spo2Controller.text) ?? 0;
    return value < 95;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddRecordViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// SPO2 VALUE
        const Text(
          "SpO₂",
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
            border: Border.all(
              color: isLow ? Colors.red : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: spo2Controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration:
                  const InputDecoration(border: InputBorder.none),
                  onChanged: (v) {
                    vm.spo2 = int.tryParse(v) ?? 0;
                    setState(() {});
                  },
                ),
              ),
              const Text("%", style: TextStyle(color: Colors.black))
            ],
          ),
        ),
        if (isLow)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              "Low oxygen level",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        const SizedBox(height: 20),

        /// CONDITION
        _dropdownCard(
          title: "CONDITION",
          child: DropdownButton<Spo2Condition>(
            value: vm.spo2Condition,
            isExpanded: true,
            underline: const SizedBox(),
            items: Spo2Condition.values.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                    e == Spo2Condition.resting ? "Resting" : "After Exercise"),
              );
            }).toList(),
            onChanged: (v) => vm.spo2Condition = v!,
          ),
        ),

        const SizedBox(height: 20),

        /// NOTE
        _noteCard(
          onChanged: (v) => vm.spo2Note = v,
        ),

        const SizedBox(height: 20),

        /// DATE & TIME
        _dateTimeCard(),

      ],
    );
  }

  Widget _dropdownCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12, color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        )
      ],
    );
  }

  Widget _noteCard({required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "NOTE",
          style: TextStyle(
              fontSize: 12, color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1),
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
          "DATE & TIME",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );

            if (pickedDate != null) {
              setState(() {
                selectedDate = pickedDate;
              });
            }
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}