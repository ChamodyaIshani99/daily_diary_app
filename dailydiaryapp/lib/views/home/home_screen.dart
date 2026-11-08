import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/diary_viewmodel.dart';
import '../add_entry_screen.dart';
import '../settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedFilterDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<DiaryViewModel>(context, listen: false).fetchEntries());
  }

  // Date Picker Dialog එක පෙන්වීම
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedFilterDate = picked;
      });
      Provider.of<DiaryViewModel>(context, listen: false).filterByDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DiaryViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade100,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search entries...',
                  border: InputBorder.none,
                ),
                onChanged: (query) => viewModel.searchEntries(query),
              )
            : const Text("My Daily Diary", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Search Button
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  viewModel.clearFilter();
                }
              });
            },
          ),
          // Date Filter Button
          IconButton(
            icon: Icon(
              Icons.calendar_month,
              color: _selectedFilterDate != null ? Colors.deepPurple : Colors.black,
            ),
            onPressed: () => _selectDate(context),
          ),
          // Clear Filter Button (Date filter එකක් දමා තිබේ නම් පමණක් පෙන්නයි)
          if (_selectedFilterDate != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                setState(() {
                  _selectedFilterDate = null;
                });
                viewModel.clearFilter();
              },
            ),
          // Settings Screen Button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<DiaryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.entries.isEmpty) {
            return const Center(
              child: Text(
                "No Diary Entries Found!\nTap '+' to add one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: viewModel.entries.length,
            itemBuilder: (context, index) {
              final entry = viewModel.entries[index];
              DateTime parsedDate = DateTime.tryParse(entry.date) ?? DateTime.now();
              String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(parsedDate);

              return Dismissible(
                key: Key(entry.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.redAccent,
                  child: const Icon(Icons.delete, color: Colors.white, size: 28),
                ),
                onDismissed: (direction) {
                  if (entry.id != null) {
                    viewModel.deleteEntry(entry.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entry deleted')),
                    );
                  }
                },
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    // Multi-image list එකෙන් පළමු Image එක Thumbnail එකක් ලෙස පෙන්වීම
                    leading: entry.imagePaths.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(entry.imagePaths.first),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null,
                    title: Text(
                      entry.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          entry.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              formattedDate,
                              style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade400),
                            ),
                            // Voice note එකක් ඇතොත් Mic icon එකක් පෙන්වීම
                            if (entry.audioPath != null && entry.audioPath!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.mic, size: 14, color: Colors.deepPurple),
                            ],
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEntryScreen(entryToEdit: entry),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEntryScreen()),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}