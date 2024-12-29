import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _CreatePostScreenState();
  }
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _faculties = ['FENS', 'FASS', 'FLW', 'FEDU', 'FBA'];
  final List<String> _categories = [
    'Announcement',
    'Event',
    'Job',
    'Internship'
  ];
  String _selectedFacultyController = '';
  String _selectedCategoryController = '';

  Future<void> _createPost() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw 'User not authenticated';

      // Generate and upload QR code for 'Event' category
      String? qrCodeImageUrl;
      if (_selectedCategoryController == 'Event') {
        qrCodeImageUrl = await _generateAndUploadQrCode(
          title: _titleController.text,
          content: _contentController.text,
        );
      }

      // Insert post data into Supabase
      await Supabase.instance.client.from('posts').insert({
        'title': _titleController.text,
        'content': _contentController.text,
        'description': _descriptionController.text,
        'faculty': _selectedFacultyController,
        'category': _selectedCategoryController,
        'author_id': userId,
        'qr_code_image_url': qrCodeImageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context); // Navigate back after successful operation
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    }
  }

  Future<String> _generateAndUploadQrCode({
    required String title,
    required String content,
  }) async {
    try {
      // Generate the QR code image as bytes
      final qrValidationResult = QrValidator.validate(
        data: 'Title: $title\nContent: $content',
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status != QrValidationStatus.valid) {
        throw 'Invalid QR Code data';
      }
      final qrCodeImage = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCodeImage,
        eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square, color: Color(0xFF000000)),
        gapless: true,
      );
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/qr_code.png';
      final file = File(filePath);
      final byteData =
          await painter.toImageData(300); // QR code image size: 300x300
      if (byteData != null) {
        await file.writeAsBytes(byteData.buffer.asUint8List());
      }

      // Upload QR code image to Supabase storage
      final storageResponse = await Supabase.instance.client.storage
          .from('qr_codes')
          .upload('qr_code_${DateTime.now().millisecondsSinceEpoch}.png', file);

      // Get public URL of the uploaded file
      final publicUrl = Supabase.instance.client.storage
          .from('qr_codes')
          .getPublicUrl(storageResponse);

      return publicUrl;
    } catch (e) {
      throw 'Error generating and uploading QR Code: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
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
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Content is required' : null,
              ),
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
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) _createPost();
                  },
                  child: const Text('Create Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
