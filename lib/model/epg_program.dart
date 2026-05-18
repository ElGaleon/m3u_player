class EpgProgram {
  final String channelId;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime stop;

  const EpgProgram({
    required this.channelId,
    required this.title,
    required this.start,
    required this.stop,
    this.description,
  });

  bool isAiringAt(DateTime dateTime) {
    return !dateTime.isBefore(start) && dateTime.isBefore(stop);
  }
}
