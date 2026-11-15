import '../network/api_client.dart';
import '../../models/ai_message_model.dart';
import 'ai_trained_knowledge_engine.dart';

class AiBotService {
  /// Send query to backend AI API or fallback to On-Device Deep Knowledge Engine
  static Future<AiMessageModel> getAiResponse({
    required String query,
    String? currentOrgCode,
    String? currentOrgName,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return AiMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'অনুগ্রহ করে আপনার প্রশ্ন বা সমস্যাটি লিখুন।',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }

    // 1. First attempt to call Live Backend AI API
    try {
      final response = await ApiClient.post('/ai/chat', {
        'message': cleanQuery,
        'orgContext': {
          'orgCode': currentOrgCode ?? '',
          'orgName': currentOrgName ?? '',
        },
      });

      if (response.success && response.data != null) {
        final data = response.data;
        final replyText = data['reply']?.toString() ?? '';
        final category = data['category']?.toString();
        final List<String> actions = (data['suggestedActions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        if (replyText.isNotEmpty) {
          return AiMessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: replyText,
            isUser: false,
            timestamp: DateTime.now(),
            category: category,
            suggestedActions: actions,
          );
        }
      }
    } catch (_) {
      // Backend unreachable or offline on mobile - fallback to deep local reasoning
    }

    // 2. High-Performance On-Device NLP & Deep Semantic Classifier (1,000+ Trained Patterns)
    return _generateTrainedOnDeviceResponse(cleanQuery);
  }

  static AiMessageModel _generateTrainedOnDeviceResponse(String query) {
    final isBn = RegExp(r'[\u0980-\u09FF]|kivabe|ki bhabe|kibhabe|kemne|korbo|kore|hocche|korte|kono|somossha|ki|bhai|shuno|dekhao|bolo|ache|nai|lagbe|holo|hoy').hasMatch(query.toLowerCase());

    final matched = AiTrainedKnowledgeEngine.matchIntent(query);
    final responseText = isBn ? matched.responseBn : matched.responseEn;
    final followUps = isBn ? matched.suggestedFollowUpsBn : matched.suggestedFollowUpsEn;

    return AiMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: matched.category,
      isUser: false,
      timestamp: DateTime.now(),
      text: responseText,
      suggestedActions: followUps,
    );
  }
}
