import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/audio_helper.dart';
import '../../core/utils/image_helper.dart';
import '../../data/models/diary_entry_model.dart';
import '../../viewmodels/diary_viewmodel.dart';

class AddEntryScreen extends StatefulWidget {
  final DiaryEntry? entryToEdit;

  const AddEntryScreen({super.key, this.entryToEdit});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  List<String> _selectedImagePaths = [];
  String? _selectedAudioPath;

  final AudioHelper _audioHelper = AudioHelper();
  bool _isRecording = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entryToEdit?.title ?? '');
    _contentController = TextEditingController(text: widget.entryToEdit?.content ?? '');
    _selectedImagePaths = widget.entryToEdit?.imagePaths ?? [];
    _selectedAudioPath = widget.entryToEdit?.audioPath;
  }

  @override
  void dispose() {
    _audioHelper.dispose();
    super.dispose();
  }

  // Pick Multiple Images
  Future<void> _pickImages() async {
    List<String> paths = await ImageHelper.pickMultipleImages();
    if (paths.isNotEmpty) {
      setState(() {
        _selectedImagePaths.addAll(paths);
      });
    }
  }

  Future<void> _handleRecording() async {
    if (_isRecording) {
      String? path = await _audioHelper.stopRecording();
      setState(() {
        _isRecording = false;
        _selectedAudioPath = path;
      });
    } else {
      await _audioHelper.startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _handleAudioPlay() async {
    if (_selectedAudioPath == null) return;

    if (_isPlaying) {
      await _audioHelper.stopAudio();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _audioHelper.playAudio(_selectedAudioPath!, () {
        setState(() => _isPlaying = false);
      });
    }
  }

  void _saveEntry() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and content')),
      );
      return;
    }

    final viewModel = Provider.of<DiaryViewModel>(context, listen: false);

    if (widget.entryToEdit == null) {
      final newEntry = DiaryEntry(
        title: title,
        content: content,
        date: DateTime.now().toIso8601String(),
        imagePaths: _selectedImagePaths,
        audioPath: _selectedAudioPath,
      );
      viewModel.addEntry(newEntry);
    } else {
      final updatedEntry = DiaryEntry(
        id: widget.entryToEdit!.id,
        title: title,
        content: content,
        date: widget.entryToEdit!.date,
        imagePaths: _selectedImagePaths,
        audioPath: _selectedAudioPath,
      );
      viewModel.updateEntry(updatedEntry);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.entryToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Diary Entry' : 'Add Diary Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImages, // Multi-image picker
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Images Horizontal List Preview
            if (_selectedImagePaths.isNotEmpty) ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImagePaths.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_selectedImagePaths[index]),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedImagePaths.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Voice Recording Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic,
                        color: _isRecording ? Colors.red : Colors.deepPurple),
                    onPressed: _handleRecording,
                  ),
                  Text(_isRecording ? "Recording..." : "Record Voice Note"),
                  const Spacer(),
                  if (_selectedAudioPath != null) ...[
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.deepPurple),
                      onPressed: _handleAudioPlay,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {
                        setState(() => _selectedAudioPath = null);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts here...',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}