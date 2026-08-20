class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String? imagePath;
  final String? audioPath;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imagePath,
    this.audioPath,
  });

  // Model එක SQLite එකට Save කරන්න Map (JSON) එකක් බවට හැරවීම
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'imagePath': imagePath,
      'audioPath': audioPath,
    };
  }

  // SQLite එකෙන් එන Map එක Model Object එකක් බවට හැරවීම
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      imagePath: map['imagePath'],
      audioPath: map['audioPath'],
    );
  }
}