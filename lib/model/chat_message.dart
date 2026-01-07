class ChatMessage {
  final String text; // Or htmlContent for AI
  final bool isUser;
  final DateTime timestamp;
  String? feedbackStatus; // 'liked', 'disliked', or null
  final bool isLoading;
  final bool hasRefresh;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.feedbackStatus,
    this.isLoading = false,
    this.hasRefresh = true,
  }) : timestamp = timestamp ?? DateTime.now();
}
