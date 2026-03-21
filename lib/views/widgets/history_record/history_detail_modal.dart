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
                  "Chi tiết bản ghi",
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
              "THÔNG TIN CÁC CHỈ SỐ",
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
              "CHÚ THÍCH",
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
                record.note ?? "Không có lưu ý",
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            /// NOTE
            const Text(
              "CHẨN ĐOÁN",
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
                record.result ?? "Không có kết quả",
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text("Đóng"),
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
                      "Xoá",
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
        return "HUYẾT ÁP";
      case HealthType.Sugar:
        return "ĐƯỜNG HUYẾT";
      case HealthType.Weight:
        return "CÂN NẶNG";
      case HealthType.Spo2:
        return "CHỈ SÔ O2";
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
            _detailRow("Huyết áp tâm thu", record.systolic?.toString() ?? "-"),
            _detailRow(
              "Huyết áp tâm trương",
              record.diastolic?.toString() ?? "-",
            ),
            _detailRow("Mạch tim", record.pulse?.toString() ?? "-"),
          ],
        );

      case HealthType.Sugar:
        return Column(
          children: [
            _detailRow("Đường huyết", record.glucoseValue?.toString() ?? "-"),
            _detailRow("Đơn vị", record.glucoseUnit ?? "-"),
          ],
        );

      case HealthType.Weight:
        return Column(
          children: [_detailRow("Cân nặng", "${record.weight ?? "-"} kg")],
        );

      case HealthType.Spo2:
        return Column(
          children: [_detailRow("Nồng độ O2", "${record.spo2 ?? "-"}%")],
        );
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
