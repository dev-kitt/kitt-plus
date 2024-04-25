enum ChatMessageType { user, bot }

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.chatMessageType,
    required this.source,
  });

  final String text;
  final ChatMessageType chatMessageType;
  final String source;
}
