class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final String date;
  final List<String> imagePaths; // A list for multiple images
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
      // Convert the list to a single string for database storage (comma separated)
      'imagePaths': imagePaths.join(','), 
      'audioPath': audioPath,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    // Convert the string returned from the database back into a list
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