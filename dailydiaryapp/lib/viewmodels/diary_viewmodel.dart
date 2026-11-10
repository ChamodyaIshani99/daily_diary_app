import 'package:flutter/material.dart';
import '../data/database/db_helper.dart';
import '../data/models/diary_entry_model.dart';

class DiaryViewModel extends ChangeNotifier {
  List<DiaryEntry> _allEntries = [];
  List<DiaryEntry> _filteredEntries = [];
  bool _isLoading = false;

  List<DiaryEntry> get entries => _filteredEntries;
  bool get isLoading => _isLoading;

  final DBHelper _dbHelper = DBHelper();

  Future<void> fetchEntries() async {
    _isLoading = true;
    notifyListeners();

    _allEntries = await _dbHelper.getEntries();
    _filteredEntries = List.from(_allEntries);

    _isLoading = false;
    notifyListeners();
  }

  // 1. Text search logic
  void searchEntries(String query) {
    if (query.isEmpty) {
      _filteredEntries = List.from(_allEntries);
    } else {
      _filteredEntries = _allEntries.where((entry) {
        final titleMatches = entry.title.toLowerCase().contains(query.toLowerCase());
        final contentMatches = entry.content.toLowerCase().contains(query.toLowerCase());
        return titleMatches || contentMatches;
      }).toList();
    }
    notifyListeners();
  }

  // 2. Date filter logic
  void filterByDate(DateTime selectedDate) {
    _filteredEntries = _allEntries.where((entry) {
      final entryDate = DateTime.tryParse(entry.date);
      if (entryDate == null) return false;
      return entryDate.year == selectedDate.year &&
          entryDate.month == selectedDate.month &&
          entryDate.day == selectedDate.day;
    }).toList();
    notifyListeners();
  }

  // Clear the filter and show all entries again
  void clearFilter() {
    _filteredEntries = List.from(_allEntries);
    notifyListeners();
  }

  Future<void> addEntry(DiaryEntry entry) async {
    await _dbHelper.insertEntry(entry);
    await fetchEntries();
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await _dbHelper.updateEntry(entry);
    await fetchEntries();
  }

  Future<void> deleteEntry(int id) async {
    await _dbHelper.deleteEntry(id);
    await fetchEntries();
  }
}