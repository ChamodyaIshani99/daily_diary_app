import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entryToEdit?.title ?? '');
    _contentController = TextEditingController(text: widget.entryToEdit?.content ?? '');
    _selectedImagePath = widget.entryToEdit?.imagePath;
  }

  // Image එකක් Pick කරන Dialog එක
  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                String? imagePath = await ImageHelper.pickAndSaveImage(ImageSource.gallery);
                if (imagePath != null) {
                  setState(() => _selectedImagePath = imagePath);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                String? imagePath = await ImageHelper.pickAndSaveImage(ImageSource.camera);
                if (imagePath != null) {
                  setState(() => _selectedImagePath = imagePath);
                }
              },
            ),
          ],
        ),
      ),
    );
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
        imagePath: _selectedImagePath,
      );
      viewModel.addEntry(newEntry);
    } else {
      final updatedEntry = DiaryEntry(
        id: widget.entryToEdit!.id,
        title: title,
        content: content,
        date: widget.entryToEdit!.date,
        imagePath: _selectedImagePath,
        audioPath: widget.entryToEdit!.audioPath,
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
            onPressed: _showImageSourceBottomSheet,
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
            // Selected Image එක Preview කිරීම
            if (_selectedImagePath != null) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_selectedImagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                    onPressed: () => setState(() => _selectedImagePath = null),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
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