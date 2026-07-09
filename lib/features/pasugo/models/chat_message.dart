/// Who sent the chat message.
enum MessageSender {
  customer,
  rider;

  String toJson() => name;
  static MessageSender fromJson(String json) =>
      MessageSender.values.firstWhere((e) => e.name == json);
}

/// A single message within a pasugo chat session.
class ChatMessage {
  final String? id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final String? type; // 'text' or 'location_pin'

  const ChatMessage({
    this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sender': sender.toJson(),
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      if (type != null) 'type': type,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatMessage(
      id: id ?? map['id'] as String?,
      sender: MessageSender.fromJson(map['sender'] as String),
      text: map['text'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      type: map['type'] as String?,
    );
  }
}
