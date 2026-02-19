class ChatMessage {
  final Map<String, dynamic> text; // Or htmlContent for AI
  final bool isUser;
  final DateTime timestamp;
  String? feedbackStatus; // 'liked', 'disliked', or null
  bool isLoading;
  bool hasRefresh;
  final List<String>? suggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.feedbackStatus,
    this.isLoading = false,
    this.hasRefresh = true,
    this.suggestions,
  }) : timestamp = timestamp ?? DateTime.now();
}
