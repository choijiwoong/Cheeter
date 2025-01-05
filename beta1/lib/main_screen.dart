import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'map_screen.dart';
import 'utils/exif_utils.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? _selectedImage;
  DateTime? _selectedDateTime;
  File? _modifiedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        print("선택된 이미지: ${_selectedImage!.path}");
      });
    }
  }

  void _openMap() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("먼저 사진을 선택해주세요.")),
      );
      print("사진을 선택하지 않음.");
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("날짜와 시간을 선택해주세요.")),
      );
      print("날짜와 시간을 선택하지 않음.");
      return;
    }

    print("지도에서 위치 선택 열기.");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          onLocationSelected: (location) {
            print("위치 선택됨: ${location.latitude}, ${location.longitude}");
            updatePhotoMetadata(
              _selectedImage!,
              location.latitude,
              location.longitude,
              _selectedDateTime!,
            ).then((updatedImage) {
              if (updatedImage != null) {
                setState(() {
                  _modifiedImage = updatedImage;  // 수정된 이미지를 상태에 저장
                  print("수정된 이미지 저장됨.");
                });
              } else {
                print("이미지 수정 실패.");
              }
            });
          },
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          print("선택된 날짜와 시간: $_selectedDateTime");
        });
      }
    }
  }

  Future<void> _saveImage() async {
    if (_modifiedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("수정된 이미지를 먼저 선택해주세요.")),
      );
      print("수정된 이미지가 없습니다.");
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/modified_image.jpg';
      await _modifiedImage!.copy(savePath);
      print("이미지 저장 경로: $savePath");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미지가 저장되었습니다: $savePath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미지 저장 실패: $e")),
      );
      print("이미지 저장 실패: $e");
    }
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectDateTime,
              child: Text(_selectedDateTime == null
                  ? "날짜와 시간 선택"
                  : "선택된 날짜: ${_selectedDateTime!.year}-${_selectedDateTime!.month}-${_selectedDateTime!.day} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute}"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveImage,
              child: Text("저장"),
            ),
          ],
        ),
      ),
    );
  }
}
