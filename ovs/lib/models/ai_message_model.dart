class AiMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? category;
  final List<String> suggestedActions;

  AiMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.category,
    this.suggestedActions = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'category': category,
        'suggestedActions': suggestedActions,
      };

  factory AiMessageModel.fromJson(Map<String, dynamic> json) => AiMessageModel(
        id: json['id'] as String,
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
        category: json['category'] as String?,
        suggestedActions: (json['suggestedActions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}
