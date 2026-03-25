import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../../domain/entities/health_record.dart';
import '../../../domain/enums/health_type.dart';
import '../../../viewmodels/stats_viewmodel.dart';

class StatsPage extends StatefulWidget {
  final HealthType? initialType;
  const StatsPage({super.key, this.initialType});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    _refreshData(widget.initialType ?? HealthType.BP);
  }

  @override
  void didUpdateWidget(StatsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialType != null && widget.initialType != oldWidget.initialType) {
      _refreshData(widget.initialType!);
    }
  }

  void _refreshData(HealthType type) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StatsViewModel>().setActiveType(type, force: true);
      }
    });
  }

  final List<String> _segments = ['Ngày', 'Tuần', 'Tháng', 'Năm'];

  String _getValueForRecord(HealthRecord? record, HealthType type) {
    if (record == null) return '--';
    switch (type) {
      case HealthType.BP:
        return '${record.systolic ?? '--'}/${record.diastolic ?? '--'}';
      case HealthType.Sugar:
        return '${record.glucoseValue ?? '--'}';
      case HealthType.Weight:
        return '${record.weight ?? '--'}';
      case HealthType.Spo2:
        return '${record.spo2 ?? '--'}';
    }
  }

  String _getUnitForType(HealthType type) {
    switch (type) {
      case HealthType.BP:
        return 'mmHg';
      case HealthType.Sugar:
        return 'mg/dL';
      case HealthType.Weight:
        return 'kg';
      case HealthType.Spo2:
        return '%';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsViewModel>(
      builder: (context, viewModel, child) {
        final latestRecord = viewModel.records.isNotEmpty ? viewModel.records.first : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSegmentControl(viewModel),
              const SizedBox(height: 24),
              _buildChartCard(viewModel, latestRecord),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Lời khuyên sức khỏe AI', style: AppTextStyles.h2),
                ],
              ),
              const SizedBox(height: 16),
              _buildActionNeededCard(latestRecord, viewModel),
              const SizedBox(height: 16),
              _buildSmartNutritionCard(latestRecord, viewModel),
              const SizedBox(height: 16),
              _buildActivityAdviceCard(latestRecord, viewModel),
              const SizedBox(height: 80), // Padding for BottomNav
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentControl(StatsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_segments.length, (index) {
          final isSelected = viewModel.selectedSegment == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => viewModel.setSegment(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _segments[index],
                    style: AppTextStyles.subtitle.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartCard(StatsViewModel viewModel, HealthRecord? latestRecord) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<HealthType>(
                  offset: const Offset(0, 40),
                  onSelected: (HealthType type) {
                    viewModel.setActiveType(type);
                  },
                  itemBuilder: (BuildContext context) => HealthType.values.map((type) {
                    return PopupMenuItem<HealthType>(
                      value: type,
                      child: Text(_getHealthTypeName(type)),
                    );
                  }).toList(),
                  child: Row(
                    children: [
                      Text(_getHealthTypeName(viewModel.activeType), style: AppTextStyles.label),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(_getValueForRecord(latestRecord, viewModel.activeType), style: AppTextStyles.h1.copyWith(fontSize: 36)),
                const SizedBox(width: 4),
                Text(_getUnitForType(viewModel.activeType), style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 4),
            if (viewModel.isLoading)
              const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
            if (!viewModel.isLoading && viewModel.records.isEmpty)
              const SizedBox(height: 150, child: Center(child: Text('Không có dữ liệu'))),
            if (!viewModel.isLoading && viewModel.records.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withAlpha(50)),
                      ),
                    ),
                    child: CustomPaint(
                      painter: _RealChartPainter(viewModel.records, viewModel.activeType),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatChartDate(viewModel.records.last.createdAt, viewModel.selectedSegment),
                        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                      Text(_formatChartDate(viewModel.records.first.createdAt, viewModel.selectedSegment),
                        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                    ],
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getHealthTypeName(HealthType type) {
    switch (type) {
      case HealthType.BP:
        return 'HUYẾT ÁP';
      case HealthType.Sugar:
        return 'ĐƯỜNG HUYẾT';
      case HealthType.Weight:
        return 'CÂN NẶNG';
      case HealthType.Spo2:
        return 'SPO2';
    }
  }

  String _formatChartDate(DateTime date, int segment) {
    if (segment == 0) { // Day
      return DateFormat('HH:mm').format(date);
    } else if (segment == 3) { // Year
      return DateFormat('MM/yyyy').format(date);
    } else { // Week, Month
      return DateFormat('dd/MM').format(date);
    }
  }

  /// Returns 'NORMAL', 'DANGER', or 'CRITICAL' based on threshold from DB.
  String _evaluateRecord(HealthRecord? record, StatsViewModel vm) {
    if (record == null) return 'NORMAL';
    switch (record.type) {
      case HealthType.BP:
        if (record.systolic == null) return 'NORMAL';
        return vm.thresholdSystolic?.evaluate(record.systolic!.toDouble()) ?? 'NORMAL';
      case HealthType.Sugar:
        if (record.glucoseValue == null) return 'NORMAL';
        return vm.thresholdSugar?.evaluate(record.glucoseValue!) ?? 'NORMAL';
      case HealthType.Spo2:
        if (record.spo2 == null) return 'NORMAL';
        return vm.thresholdSpo2?.evaluate(record.spo2!.toDouble()) ?? 'NORMAL';
      case HealthType.Weight:
        return 'NORMAL';
    }
  }

  Widget _buildActionNeededCard(HealthRecord? record, StatsViewModel viewModel) {
    final status = _evaluateRecord(record, viewModel);

    final Color bgColor;
    final Color iconColor;
    final IconData icon;
    final String title;
    final Color titleColor;
    String advice;

    switch (status) {
      case 'CRITICAL':
        bgColor = const Color(0xFFFFF0F2);
        iconColor = Colors.red;
        icon = Icons.emergency;
        title = 'Cần Hành Động Ngay';
        titleColor = Colors.red.shade900;
        advice = _criticalAdvice(record);
        break;
      case 'DANGER':
        bgColor = const Color(0xFFFFF3E0);
        iconColor = Colors.orange;
        icon = Icons.warning_amber_rounded;
        title = 'Cảnh Báo';
        titleColor = Colors.orange.shade900;
        advice = _dangerAdvice(record);
        break;
      default:
        bgColor = const Color(0xFFF0FFF4);
        iconColor = Colors.green;
        icon = Icons.check_circle;
        title = 'Tình Trạng Sức Khỏe';
        titleColor = Colors.green.shade900;
        advice = 'Các chỉ số của bạn đang trong ngưỡng bình thường. Hãy duy trì lối sống lành mạnh!';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withAlpha(30), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle.copyWith(color: titleColor)),
                const SizedBox(height: 4),
                Text(advice, style: AppTextStyles.bodyMedium.copyWith(color: titleColor.withAlpha(200))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dangerAdvice(HealthRecord? r) {
    if (r == null) return 'Một số chỉ số hơi vượt ngưỡng. Hãy theo dõi sát sao hơn.';
    switch (r.type) {
      case HealthType.BP:
        return 'Huyết áp hơi cao (${r.systolic}/${r.diastolic} mmHg). Hãy nghỉ ngơi, giảm căng thẳng và kiểm tra lại sau 30 phút.';
      case HealthType.Sugar:
        return 'Đường huyết ngoài ngưỡng bình thường (${r.glucoseValue} ${r.glucoseUnit ?? 'mg/dL'}). Theo dõi chế độ ăn và kiểm tra lại sớm.';
      case HealthType.Spo2:
        return 'SpO2 hơi thấp (${r.spo2}%). Hãy thử tập thở sâu ở nơi thoáng mát.';
      case HealthType.Weight:
        return 'Cân nặng đang vượt ngưỡng. Cần điều chỉnh chế độ ăn uống và vận động.';
    }
  }

  String _criticalAdvice(HealthRecord? r) {
    if (r == null) return 'Phát hiện chỉ số nguy hiểm. Hãy tìm kiếm hỗ trợ y tế ngay lập tức.';
    switch (r.type) {
      case HealthType.BP:
        return 'Huyết áp quá cao (${r.systolic}/${r.diastolic} mmHg). Dừng hoạt động, ngồi xuống và liên hệ bác sĩ ngay.';
      case HealthType.Sugar:
        return 'Đường huyết ở mức nguy hiểm (${r.glucoseValue} ${r.glucoseUnit ?? 'mg/dL'}). Cần tìm kiếm hỗ trợ y tế ngay.';
      case HealthType.Spo2:
        return 'SpO2 quá thấp (${r.spo2}%). Cần cấp cứu y tế ngay lập tức.';
      case HealthType.Weight:
        return 'Cân nặng ở mức nguy hiểm. Hãy gặp bác sĩ càng sớm càng tốt.';
    }
  }

  Widget _buildSmartNutritionCard(HealthRecord? record, StatsViewModel viewModel) {
    final status = _evaluateRecord(record, viewModel);

    String tag = 'LỜI KHUYÊN CHUNG';
    String tip = 'Duy trì chế độ ăn cân bằng với ngũ cốc nguyên hạt và rau xanh để ổn định các chỉ số sức khỏe.';

    if (record != null) {
      switch (record.type) {
        case HealthType.Sugar:
          switch (status) {
            case 'CRITICAL':
              tag = 'ĐƯỜNG HUYẾT – NGUY HIỂM';
              tip = 'Tránh ngay thực phẩm nhiều đường và tinh bột. Uống nước và tìm kiếm hỗ trợ y tế để kiểm soát đường huyết.';
              break;
            case 'DANGER':
              tag = 'ĐƯỜNG HUYẾT – CẢNH BÁO';
              tip = 'Giảm tinh bột tinh chế và nước ngọt. Chọn thực phẩm chỉ số GI thấp như rau củ, đậu đỏ, ngũ cốc nguyên hạt.';
              break;
            default:
              tag = 'ĐƯỜNG HUYẾT – BÌNH THƯỜNG';
              tip = 'Đường huyết ổn định! Tiếp tục chế độ ăn cân bằng và hạn chế đường bổ sung.';
          }
          break;
        case HealthType.BP:
          switch (status) {
            case 'CRITICAL':
              tag = 'HUYẾT ÁP – NGUY HIỂM';
              tip = 'Tránh tuyệt đối muối, caffeine và thực phẩm chế biến sẵn. Thực hiện ngay chỉ dẫn ăn uống của bác sĩ.';
              break;
            case 'DANGER':
              tag = 'HUYẾT ÁP – CẢNH BÁO';
              tip = 'Áp dụng chế độ ăn ít muối (DASH). Tăng thực phẩm giàu kali như chuối, rau lá xanh và tránh thực phẩm chế biến sẵn.';
              break;
            default:
              tag = 'HUYẾT ÁP – BÌNH THƯỜNG';
              tip = 'Huyết áp được kiểm soát tốt. Tiếp tục chế độ ăn nhiều trái cây, rau củ và ngũ cốc nguyên hạt.';
          }
          break;
        case HealthType.Weight:
          tag = 'QUẢN LÝ CÂN NẶNG';
          tip = 'Kiểm soát khẩu phần ăn và chọn thực phẩm giàu dinh dưỡng. Hạn chế chất béo bão hòa và đường bổ sung để duy trì cân nặng hợp lý.';
          break;
        case HealthType.Spo2:
          tag = 'HỖ TRỢ HÔ HẤP';
          tip = 'Thực phẩm giàu sắt và chống oxy hóa (rau lá xanh, quả mọng, đậu đỏ) giúp cải thiện lưu thông oxy trong máu.';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFF8D6), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.restaurant, color: Colors.orange[700], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gợi Ý Dinh Dưỡng', style: AppTextStyles.subtitle.copyWith(color: Colors.black87)),
                Text(tag, style: AppTextStyles.label.copyWith(color: Colors.orange[800], fontSize: 10)),
                const SizedBox(height: 8),
                Text(tip, style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityAdviceCard(HealthRecord? record, StatsViewModel viewModel) {
    final status = _evaluateRecord(record, viewModel);

    String tag = 'TIẾN ĐỘ HẰNG NGÀY';
    String advice = 'Vận động thể chất đều đặn như đi bộ 20 phút mỗi ngày có thể cải thiện đáng kể sức khỏe tim mạch.';

    if (record != null) {
      switch (record.type) {
        case HealthType.Spo2:
          switch (status) {
            case 'CRITICAL':
              tag = 'SPO2 – NGUY HIỂM';
              advice = 'Không tập thể dục. Nghỉ ngơi ngay ở nơi thoáng mát và tìm kiếm cấp cứu y tế nếu SpO2 không phục hồi.';
              break;
            case 'DANGER':
              tag = 'SPO2 – CẢNH BÁO';
              advice = 'Tránh vận động mạnh. Tập thở sâu chậm rãi ở nơi thoáng mát. Kiểm tra lại SpO2 thường xuyên.';
              break;
            default:
              tag = 'SPO2 – BÌNH THƯỜNG';
              advice = 'Mức oxy ổn định! Bạn có thể tập luyện từ vừa đến cao. Uống đủ nước và duy trì vận động đều đặn.';
          }
          break;
        case HealthType.BP:
          switch (status) {
            case 'CRITICAL':
              tag = 'HUYẾT ÁP – NGUY HIỂM';
              advice = 'Dừng ngay mọi hoạt động thể chất. Nằm xuống, giữ bình tĩnh và liên hệ bác sĩ hoặc cấp cứu ngay lập tức.';
              break;
            case 'DANGER':
              tag = 'HUYẾT ÁP – CẢNH BÁO';
              advice = 'Chỉ chọn các hoạt động nhẹ như đi bộ hoặc yoga nhẹ. Tránh nâng tạ và cardio cường độ cao cho đến khi huyết áp về bình thường.';
              break;
            default:
              tag = 'HUYẾT ÁP – BÌNH THƯỜNG';
              advice = 'Huyết áp được kiểm soát tốt. Đặt mục tiêu ít nhất 30 phút vận động thể dục vừa phải mỗi ngày.';
          }
          break;
        case HealthType.Sugar:
          switch (status) {
            case 'CRITICAL':
              tag = 'ĐƯỜNG HUYẾT – NGUY HIỂM';
              advice = 'Không tập khi đường huyết quá cao hoặc quá thấp. Ổn định chỉ số trước, tham khảo bác sĩ trước khi tập lại.';
              break;
            case 'DANGER':
              tag = 'ĐƯỜNG HUYẾT – CẢNH BÁO';
              advice = 'Đi bộ nhẹ sau bữa ăn giúp điều hòa đường huyết. Tránh tập nặng cho đến khi chỉ số ổn định trở lại.';
              break;
            default:
              tag = 'ĐƯỜNG HUYẾT – BÌNH THƯỜNG';
              advice = 'Đường huyết ổn định. Tập luyện đều đặn (150 phút/tuần) giúp duy trì mức glucose khỏe mạnh. Tiếp tục phát huy!';
          }
          break;
        case HealthType.Weight:
          tag = 'MỤC TIÊU CÂN NẶNG';
          advice = 'Đặt mục tiêu ít nhất 150 phút vận động thể dục vừa phải mỗi tuần. Kết hợp cardio với luyện sức mạnh để đạt hiệu quả tốt nhất.';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryLight.withAlpha(50), shape: BoxShape.circle),
            child: Icon(Icons.fitness_center, color: Colors.blue[600], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lời Khuyên Vận Động', style: AppTextStyles.subtitle.copyWith(color: Colors.black87)),
                Text(tag, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                const SizedBox(height: 8),
                Text(advice, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RealChartPainter extends CustomPainter {
  final List<HealthRecord> records;
  final HealthType type;

  _RealChartPainter(this.records, this.type);

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Reverse records to have chronological order (left to right)
    final dataPoints = records.reversed.toList();
    
    double getVal(HealthRecord r) {
      switch (type) {
        case HealthType.BP:
          return (r.systolic ?? 0).toDouble();
        case HealthType.Sugar:
          return (r.glucoseValue ?? 0).toDouble();
        case HealthType.Weight:
          return (r.weight ?? 0).toDouble();
        case HealthType.Spo2:
          return (r.spo2 ?? 0).toDouble();
      }
    }

    // Find min and max for scaling
    double minVal = getVal(dataPoints[0]);
    double maxVal = getVal(dataPoints[0]);
    
    for (var r in dataPoints) {
      double v = getVal(r);
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }

    // Add some padding to min/max
    if (maxVal == minVal) {
      maxVal += 10;
      minVal -= 10;
    } else {
      double range = maxVal - minVal;
      maxVal += range * 0.2;
      minVal -= range * 0.2;
    }

    double xStep = size.width / (dataPoints.length > 1 ? dataPoints.length - 1 : 1);
    
    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * xStep;
      double normalizedY = (getVal(dataPoints[i]) - minVal) / (maxVal - minVal);
      double y = size.height - (normalizedY * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
    
    // Draw latest point dot
    final lastX = (dataPoints.length - 1) * xStep;
    final lastValNormalized = (getVal(dataPoints.last) - minVal) / (maxVal - minVal);
    final lastY = size.height - (lastValNormalized * size.height);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
    canvas.drawCircle(Offset(lastX, lastY), 4, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _RealChartPainter oldDelegate) => 
    oldDelegate.records != records || oldDelegate.type != type;
}
