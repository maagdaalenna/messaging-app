class MessageItem {
  final String body;
  final String from;
  final String time;
  final bool onRight;

  MessageItem({
    required this.body,
    required this.from,
    required this.time,
    this.onRight = false,
  });

  String showFromAndDate() {
    return from + ", " + time;
  }
}
