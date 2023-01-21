class MessageItem {
  final String body;
  final String from;
  final String time;

  MessageItem({
    required this.body,
    required this.from,
    required this.time,
  });

  String showFromAndDate() {
    return from + ", " + time;
  }
}
