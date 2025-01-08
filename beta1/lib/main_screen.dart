import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'map_screen.dart';
import 'utils/exif_utils.dart';

class MainScreen extends StatefulWidget { //상태기반 위젯을 상속받아
  @override
  _MainScreenState createState() => _MainScreenState(); // 상태화면을 만든다.
}

class _MainScreenState extends State<MainScreen> {
  File? _selectedImage; // 이미지를 담을 변수
  DateTime? _selectedDateTime; // 수정할 시각을 담을 변수
  File? _modifiedImage; // 결과 이미지를 담을 변수
  LatLng? _selectedLocation;

  Future<void> _pickImage() async { // 유저가 이미지를 고를 때 처리할 함수
    final picker = ImagePicker(); // 이미지 피커 생성
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // 갤러에서 이미지를 선택하면 저장

    if (pickedFile != null) { // 선택한 이미지가 존재한다면
      setState(() { // 상태를 설정한다
        _selectedImage = File(pickedFile.path); // 선택한 파일의 경로를 기반으로 File 객체를 생성하여 변수에 저장
        print("[DEBUG]_MainScreenState._pickImage() 선택된 이미지: ${_selectedImage!.path}");
      });
    } else{ // 이미지를 선택하지 않았을 경우
      print("[DEBUG]_MainScreenState._pickImage() 갤러리에서 이미지를 선택하지 않았습니다.");
    }
  }

  void _openMap() { // 유저가 위치를 설정할 때 처리할 함수
    if (_selectedImage==null) { // 유저가 선택한 사진이 존재하지 않는다면
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("먼저 사진을 선택해주세요.")), // 어플리케이션 내에 pop알림을 출력한다.
      );
      print("[DEBUG]_MainScreenState._openMap() 사진을 선택하지 않음.");
      return;
    }

    print("[DEBUG]_MainScreenState._openMap() 지도에서 위치 선택 열기.");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(// MapScreen을 실행
          onLocationSelected: (location) { // 위치를 설정하면 실행할 이벤트 콜백. 결과로서 location을 받아옴
            print("[DEBUG]_MainScreenState._openMap() 위치 선택됨: ${location.latitude}, ${location.longitude}");
            setState(() {
              _selectedLocation=location;
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
          print("[DEBUG]_MainScreenState._selectDateTime()선택된 날짜와 시간: $_selectedDateTime");
        });
      }
    }
  }

  Future<void> _saveImage() async { // with modify
    if (_selectedImage == null) { // 유저가 선택한 사진이 존재하지 않는다면
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("먼저 사진을 선택해주세요.")), // 어플리케이션 내에 pop알림을 출력한다.
      );
      print("[DEBUG]_MainScreenState._saveImage() 사진을 선택하지 않음.");
      return;
    }

    if (_selectedDateTime == null) { // 유저가 선택한 날짜와 시간이 존재하지 않는다면
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("날짜와 시간을 선택해주세요.")),
      );
      print("[DEBUG]_MainScreenState._modifyImage() 날짜와 시간을 선택하지 않음.");
      return;
    }

    if (_selectedLocation == null) { // 유저가 선택한 날짜와 시간이 존재하지 않는다면
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("위치를 선택해주세요.")),
      );
      print("[DEBUG]_MainScreenState._modifyImage() 위치를 선택하지 않음.");
      return;
    }

    updatePhotoMetadata( // 사진의 메타정보를 갱신하는 함수(Util)
      _selectedImage!,
      _selectedLocation!.latitude,
      _selectedLocation!.longitude,
      _selectedDateTime!,
    ).then((updatedImage) { // 수정된 사진을 인자로 받아옴
      if (updatedImage != null) {
        setState(() {
          _modifiedImage = updatedImage;  // 수정된 이미지를 상태에 저장
          print("[DEBUG]_MainScreenState._modifyImage() 수정된 이미지 저장됨.");
        });
      } else {
        print("[DEBUG]_MainScreenState._modifyImage() 이미지 수정 실패.");
      }
    });
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
