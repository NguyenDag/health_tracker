import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/blood_sugar.dart';
import '../../../viewmodels/add_record_viewmodel/add_record_viewmodel.dart';

class BloodSugarForm extends StatefulWidget {
  const BloodSugarForm({super.key});

  @override
  State<BloodSugarForm> createState() => _BloodSugarFormState();
}

class _BloodSugarFormState extends State<BloodSugarForm> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController sugarController = TextEditingController(
    text: "100",
  );

  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddRecordViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// GLUCOSE VALUE
        const Text(
          "ĐƯỜNG HUYẾT",
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
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: sugarController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  onChanged: (v) {
                    vm.glucoseValue = double.tryParse(v) ?? 0;
                    setState(() {});
                  },
                ),
              ),
              Text(
                vm.sugarUnit == SugarUnit.mgDl ? "mg/dL" : "mmol/L",
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _dropdownCard(
          title: "ĐƠN VỊ",
          child: DropdownButton<SugarUnit>(
            value: vm.sugarUnit,
            isExpanded: true,
            underline: const SizedBox(),
            items: SugarUnit.values.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e == SugarUnit.mgDl ? "mg/dL" : "mmol/L"),
              );
            }).toList(),
            onChanged: (v) => vm.sugarUnit = v!,
          ),
        ),

        const SizedBox(height: 20),

        _dropdownCard(
          title: "THỜI ĐIỂM ĐO",
          child: DropdownButton<SugarMeasurementType>(
            value: vm.sugarType,
            isExpanded: true,
            underline: const SizedBox(),
            items: SugarMeasurementType.values.map((e) {
              String label;
              if (e.name == "fasting") {
                label = "Nhịn ăn";
              } else if (e.name == "beforeMeal") {
                label = "Trước khi ăn";
              } else {
                label = "Sau khi ăn";
              }

              return DropdownMenuItem(
                value: e,
                child: Text(label),
              );
            }).toList(),
            onChanged: (v) => vm.sugarType = v!,
          ),
        ),

        const SizedBox(height: 20),

        _noteCard(context),

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
          child: child,
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
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _noteCard(BuildContext context) {

    final vm = context.read<AddRecordViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CHÚ THÍCH",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.black,
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
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Thêm chú thích nếu cần",
              border: InputBorder.none,
            ),
            onChanged: (value) {
              vm.sugarNote = value;
            },
          ),
        ),
      ],
    );
  }
}
