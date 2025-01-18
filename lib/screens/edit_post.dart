import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});
  @override
  State<StatefulWidget> createState() {
    return _EditPostScreenState();
  }
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _faculties = ['FENS', 'FASS', 'FLW', 'FEDU', 'FBA', 'All'];
  final List<String> _categories = [
    'Announcement (General)',
    'Announcement (IRO)',
    'Announcement (SAO)',
    'Announcement (SCC)',
    'Announcement (IUS Wolves)',
    'Event',
    'Job',
    'Internship',
    'Erasmus',
    'Clubs',
  ];
  String _selectedFacultyController = '';
  String _selectedCategoryController = '';

  final QuillController _contentController = QuillController.basic();

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  Future<void> _fetchPostData() async {
    try {
      final response = await Supabase.instance.client
          .from('posts')
          .select('title, content, description, faculty, category')
          .eq('id', widget.postId)
          .single();

      final contentJson = response['content'] as String;

      setState(() {
        _titleController.text = response['title'];
        _descriptionController.text = response['description'];
        _selectedFacultyController = response['faculty'];
        _selectedCategoryController = response['category'];
        _contentController.document =
            Document.fromJson(jsonDecode(contentJson));
      });
    } catch (e) {
      debugPrint('Error fetching post data: $e');
    }
  }

  Future<void> _updatePost() async {
    try {
      final contentJson =
          jsonEncode(_contentController.document.toDelta().toJson());

      await Supabase.instance.client.from('posts').update({
        'title': _titleController.text,
        'content': contentJson,
        'description': _descriptionController.text,
        'faculty': _selectedFacultyController,
        'category': _selectedCategoryController,
      }).eq('id', widget.postId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!')),
        );
        Navigator.pop(context); // Navigate back after successful operation
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating post: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Create Post'),
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color(0xFFF8F9FE),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 20),
                const Text('Post content', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        QuillSimpleToolbar(
                            controller: _contentController,
                            configurations:
                                const QuillSimpleToolbarConfigurations(
                                    showSubscript: false,
                                    showSuperscript: false,
                                    showListBullets: false,
                                    showListNumbers: false,
                                    showQuote: false,
                                    showSearchButton: false,
                                    showHeaderStyle: false,
                                    showCodeBlock: false,
                                    showInlineCode: false,
                                    showListCheck: false,
                                    showClearFormat: false)),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 250,
                          child: QuillEditor.basic(
                            controller: _contentController,
                            configurations: const QuillEditorConfigurations(),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedFacultyController.isEmpty
                      ? null
                      : _selectedFacultyController,
                  decoration: InputDecoration(
                    labelText: 'Faculty',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedFacultyController = newValue!;
                    });
                  },
                  items: _faculties
                      .map((faculty) => DropdownMenuItem(
                            value: faculty,
                            child: Text(faculty),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryController.isEmpty
                      ? null
                      : _selectedCategoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategoryController = newValue!;
                    });
                  },
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) _updatePost();
                  },
                  child: const Text('Update Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
