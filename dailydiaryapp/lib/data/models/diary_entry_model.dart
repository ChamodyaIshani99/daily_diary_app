class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final String date;
  final List<String> imagePaths; // Images කිහිපයක් සඳහා List එකක්
  final String? audioPath;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.imagePaths,
    this.audioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      // List එක Database එකට Save කරන්න string එකක් (comma separated) බවට හැරවීම
      'imagePaths': imagePaths.join(','), 
      'audioPath': audioPath,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    // Database එකෙන් එන string එක නැවත List එකක් බවට හැරවීම
    String imagesString = map['imagePaths'] ?? '';
    List<String> loadedImages = imagesString.isNotEmpty ? imagesString.split(',') : [];

    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      imagePaths: loadedImages,
      audioPath: map['audioPath'],
    );
  }
}