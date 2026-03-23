import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/health_record.dart';

class AiInsightService {
  static const _systemInstruction =
      'You are a concise home health assistant. '
      'Analyze the user\'s latest vitals and give 1-2 sentences of actionable advice in Vietnamese. '
      'Be warm, simple, and direct. Do not use markdown. Do not include disclaimers.';

  GenerativeModel? _model;

  GenerativeModel _getModel() {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1000,
      ),
    );
    return _model!;
  }

  Future<String> generateInsight({
    required HealthRecord? bp,
    required HealthRecord? sugar,
    required HealthRecord? weight,
    required HealthRecord? spo2,
  }) async {
    final prompt = _buildPrompt(
      bp: bp,
      sugar: sugar,
      weight: weight,
      spo2: spo2,
    );
    print('Generated prompt for AI: $prompt');

    try {
      final response = await _getModel().generateContent([
        Content.text(prompt),
      ]);
      print('AI response: ${response.text}');
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        return 'Hãy tiếp tục duy trì lối sống lành mạnh và theo dõi sức khỏe thường xuyên.';
      }
      return text;
    } catch (e, st) {
      print('AI error: $e\n$st');
      return 'Không thể tải lời khuyên lúc này. Hãy thử lại sau.';
    }
  }

  String _buildPrompt({
    required HealthRecord? bp,
    required HealthRecord? sugar,
    required HealthRecord? weight,
    required HealthRecord? spo2,
  }) {
    final parts = <String>['Dữ liệu chỉ số sức khỏe mới nhất của người dùng:'];

    if (bp != null && bp.systolic != null) {
      parts.add(
        '- Huyết áp: ${bp.systolic}/${bp.diastolic} mmHg'
        '${bp.pulse != null ? ', nhịp tim: ${bp.pulse} bpm' : ''}',
      );
    } else {
      parts.add('- Huyết áp: chưa có dữ liệu');
    }

    if (sugar != null && sugar.glucoseValue != null) {
      parts.add(
        '- Đường huyết: ${sugar.glucoseValue} ${sugar.glucoseUnit ?? 'mg/dL'}',
      );
    } else {
      parts.add('- Đường huyết: chưa có dữ liệu');
    }

    if (spo2 != null && spo2.spo2 != null) {
      parts.add('- SpO2: ${spo2.spo2}%');
    } else {
      parts.add('- SpO2: chưa có dữ liệu');
    }

    if (weight != null && weight.weight != null) {
      parts.add('- Cân nặng: ${weight.weight} kg');
    } else {
      parts.add('- Cân nặng: chưa có dữ liệu');
    }

    parts.add(
      '\nHãy đưa ra lời khuyên sức khỏe ngắn gọn dựa trên các chỉ số trên.',
    );
    return parts.join('\n');
  }
}
