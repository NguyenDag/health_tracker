import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/health_record.dart';
import '../../../domain/enums/health_type.dart';
import '../../../viewmodels/history_record_viewmodel/history_record_viewmodel.dart';
import 'confirm_delete_modal.dart';

class HistoryDetailModal extends StatelessWidget {
  final HealthRecord record;
  final HistoryViewModel vm;

  const HistoryDetailModal({super.key, required this.record, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 30),
                const Text(
                  "Detail for record",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// TYPE CHIP
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _typeColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _typeName(),
                  style: TextStyle(
                    color: _typeColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// VALUE
            Center(
              child: Text(
                _mainValue(),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            /// DATE
            Center(
              child: Text(
                "${_formatDate(record.createdAt)}",
                style: const TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 25),

            /// DETAIL
            const Text(
              "INDEX INFORMATION",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _detailSection(),

            const SizedBox(height: 20),

            /// NOTE
            const Text(
              "NOTE",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                record.note ?? "No note",
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            /// NOTE
            const Text(
              "RESULT",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                record.result ?? "No result",
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            /// AI SUGGESTION
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.blue, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "AI Advice",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Index is normal.",
                      // record.result ??
                          style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text("Close"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmDeleteModal(
                          onDelete: () async {
                            await vm.deleteRecord(record);

                            Navigator.pop(context); // close confirm
                            Navigator.pop(context); // close detail
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// VALUE
  String _mainValue() {
    switch (record.type) {
      case HealthType.BP:
        return "${record.systolic}/${record.diastolic} mmHg";
      case HealthType.Sugar:
        return "${record.glucoseValue} ${record.glucoseUnit}";
      case HealthType.Weight:
        return "${record.weight} kg";
      case HealthType.Spo2:
        return "${record.spo2}%";
    }
  }

  /// TYPE NAME
  String _typeName() {
    switch (record.type) {
      case HealthType.BP:
        return "BLOOD PRESSURE";
      case HealthType.Sugar:
        return "BLOOD SUGAR";
      case HealthType.Weight:
        return "WEIGHT";
      case HealthType.Spo2:
        return "SPO2";
    }
  }

  /// TYPE COLOR
  Color _typeColor() {
    switch (record.type) {
      case HealthType.BP:
        return Colors.teal;
      case HealthType.Sugar:
        return Colors.red;
      case HealthType.Weight:
        return Colors.blue;
      case HealthType.Spo2:
        return Colors.green;
    }
  }

  /// DATE FORMAT
  String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return "$hour:$minute, $day/$month/${date.year}";
  }

  Widget _detailSection() {
    switch (record.type) {
      case HealthType.BP:
        return Column(
          children: [
            _detailRow("Systolic", record.systolic?.toString() ?? "-"),
            _detailRow("Diastolic", record.diastolic?.toString() ?? "-"),
            _detailRow("Pulse", record.pulse?.toString() ?? "-"),
          ],
        );

      case HealthType.Sugar:
        return Column(
          children: [
            _detailRow("Glucose", record.glucoseValue?.toString() ?? "-"),
            _detailRow("Unit", record.glucoseUnit ?? "-"),
          ],
        );

      case HealthType.Weight:
        return Column(
          children: [_detailRow("Weight", "${record.weight ?? "-"} kg")],
        );

      case HealthType.Spo2:
        return Column(children: [_detailRow("SpO2", "${record.spo2 ?? "-"}%")]);
    }
  }

  Widget _detailRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
