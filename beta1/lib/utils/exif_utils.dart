import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart';

Future<File?> updatePhotoMetadata(File imageFile, double latitude, double longitude, DateTime dateTime) async {
  try {
    // 1. 원본 이미지의 바이트를 읽기
    final bytes = await imageFile.readAsBytes();

    // 2. EXIF 데이터를 읽기
    final data = await readExifFromBytes(bytes);

    // 3. EXIF 데이터가 없는 경우 처리
    if (data.isEmpty) {
      print("No EXIF data found.");
      return null;
    }

    // 4. GPS 데이터 업데이트
    data['GPSLatitude'] = [latitude.abs(), 0, 0] as IfdTag;  // Latitude 값 업데이트
    data['GPSLongitude'] = [longitude.abs(), 0, 0] as IfdTag;  // Longitude 값 업데이트
    data['GPSLatitudeRef'] = (latitude >= 0 ? 'N' : 'S') as IfdTag;  // Latitude 방향 업데이트
    data['GPSLongitudeRef'] = (longitude >= 0 ? 'E' : 'W') as IfdTag;  // Longitude 방향 업데이트

    // 5. 날짜와 시간 정보 업데이트
    final formattedDateTime = '${dateTime.year}:${dateTime.month}:${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
    data['DateTimeOriginal'] = formattedDateTime as IfdTag;  // 시간 정보 업데이트

    // 6. EXIF 데이터를 바이트로 변환하여 업데이트
    final updatedBytes = await _writeExifData(bytes, data);

    // 7. 임시 파일 경로 생성 (기존 이미지를 덮어쓰지 않기 위해)
    final tempDirectory = Directory.systemTemp;
    final tempFile = File('${tempDirectory.path}/temp_image.jpg');

    // 8. 새로운 파일에 EXIF 수정된 데이터를 저장 (갤러리에만 저장하면 됨)
    await tempFile.writeAsBytes(updatedBytes);

    return tempFile;  // 수정된 파일 반환

  } catch (e) {
    print("Failed to update photo metadata: $e");
    return null;
  }
}

/// EXIF 데이터를 이미지 바이트에 적용하는 함수
Future<List<int>> _writeExifData(List<int> bytes, Map<String, IfdTag> updatedData) async {
  // EXIF 데이터를 변경한 바이트를 반환하는 로직을 구현해야 합니다.
  final newBytes = await replaceExifData(bytes, updatedData);
  return newBytes ?? bytes;
}

/// EXIF 데이터를 바이트로 변환하여 새로운 이미지로 저장하는 예시 함수
Future<List<int>?> replaceExifData(List<int> imageBytes, Map<String, IfdTag> updatedData) async {
  // EXIF 데이터를 변경한 바이트를 반환하는 로직을 구현해야 합니다.
  // 이 예시는 EXIF 데이터를 수정할 수 있는 방법을 제공하지 않지만, 일반적으로 EXIF 수정 라이브러리 사용 필요

  // EXIF 수정 로직: 'exif' 패키지 또는 다른 EXIF 라이브러리를 활용해 EXIF 데이터를 바이트에 반영할 수 있습니다.

  return imageBytes;  // 이 부분은 실제 EXIF 수정 후 바이트로 교체해야 합니다.
}
