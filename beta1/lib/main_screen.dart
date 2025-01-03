import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'map_screen.dart';
import 'utils/exif_utils.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _openMap() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("먼저 사진을 선택해주세요.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          onLocationSelected: (location) {
            updatePhotoMetadata(
              _selectedImage!,
              location.latitude,
              location.longitude,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("사진 메타데이터 편집기")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200, width: 200)
                : Text("사진을 선택해주세요."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("사진 선택"),
            ),
            ElevatedButton(
              onPressed: _openMap,
              child: Text("지도에서 위치 선택"),
            ),
          ],
        ),
      ),
    );
  }
}
