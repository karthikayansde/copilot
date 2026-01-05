class ChatMessage {
  final String text; // Or htmlContent for AI
  final bool isUser;
  final DateTime timestamp;
  String? feedbackStatus; // 'liked', 'disliked', or null

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.feedbackStatus,
  }) : timestamp = timestamp ?? DateTime.now();
}
