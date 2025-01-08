import 'dart:io';
import 'dart:typed_data'; // Uint8List를 사용하려면 이 패키지를 임포트해야 합니다.
import 'package:exif/exif.dart';

Future<File?> updatePhotoMetadata(File imageFile, double latitude, double longitude, DateTime dateTime) async {
  try {
    // 1. 원본 이미지의 바이트를 읽기
    final bytes = await imageFile.readAsBytes();

    // 2. EXIF 데이터를 읽기
    final exifData = await readExifFromBytes(bytes);

    // 3. EXIF 데이터가 없는 경우 처리
    if (exifData.isEmpty) {
      print("[DEBUG]_exif_utils.updatePhotoMetadata() No EXIF data found.");
      return null;
    }

    // 4. GPS 데이터 추가 또는 업데이트
    exifData['GPSLatitude'] = IfdTag(
      tag: 0x0002, // GPSLatitude 태그 ID
      tagType: 'GPSLatitude',
      printable: _formatDms(latitude.abs()),
      values: IfdRatios(_convertToDmsRatios(latitude.abs())),
    );

    exifData['GPSLongitude'] = IfdTag(
      tag: 0x0004, // GPSLongitude 태그 ID
      tagType: 'GPSLongitude',
      printable: _formatDms(longitude.abs()),
      values: IfdRatios(_convertToDmsRatios(longitude.abs())),
    );

    exifData['GPSLatitudeRef'] = IfdTag(
      tag: 0x0001, // GPSLatitudeRef 태그 ID
      tagType: 'GPSLatitudeRef',
      printable: latitude >= 0 ? 'N' : 'S',
      values: IfdBytes(Uint8List.fromList([latitude >= 0 ? 0x4E : 0x53])), // 'N' or 'S' ASCII
    );

    exifData['GPSLongitudeRef'] = IfdTag(
      tag: 0x0003, // GPSLongitudeRef 태그 ID
      tagType: 'GPSLongitudeRef',
      printable: longitude >= 0 ? 'E' : 'W',
      values: IfdBytes(Uint8List.fromList([longitude >= 0 ? 0x45 : 0x57])), // 'E' or 'W' ASCII
    );

    // 5. 날짜와 시간 정보 업데이트
    final formattedDateTime = '${dateTime.year}:${dateTime.month}:${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
    exifData['DateTimeOriginal'] = IfdTag(
      tag: 0x9003, // DateTimeOriginal 태그 ID
      tagType: 'DateTimeOriginal',
      printable: formattedDateTime,
      values: IfdBytes(Uint8List.fromList(formattedDateTime.codeUnits)),
    );

    // 6. EXIF 데이터를 바이트로 변환하여 업데이트
    final updatedBytes = await _writeExifData(bytes, exifData);

    // 7. 새로운 파일 생성
    final newImagePath = imageFile.parent.path + '/updated_' + imageFile.uri.pathSegments.last;
    print("[DEBUG]_exif_utils.updatePhotoMetadata() 새 파일 경로: ${newImagePath}");
    final newImageFile = File(newImagePath);

    // 8. 수정된 데이터를 새로운 파일에 쓰기
    await newImageFile.writeAsBytes(updatedBytes);
    print("[DEBUG]_exif_utils.updatePhotoMetadata() 이미지 메타데이터 업데이트 성공");
    return newImageFile; // 수정된 새 파일 반환

  } catch (e) {
    print("[DEBUG]_exif_utils.updatePhotoMetadata() 이미지 메타데이터 업데이트 실패: $e");
    return null;
  }
}

/// GPS 좌표를 DMS 형식으로 변환하는 함수
List<Ratio> _convertToDmsRatios(double coordinate) {
  final degrees = coordinate.floor();
  final minutes = ((coordinate - degrees) * 60).floor();
  final seconds = (((coordinate - degrees) * 60 - minutes) * 60 * 100).round();

  return [
    Ratio(degrees, 1),
    Ratio(minutes, 1),
    Ratio(seconds, 100), // 초를 1/100 단위로 표현
  ];
}

/// DMS 형식을 문자열로 변환하는 함수
String _formatDms(double coordinate) {
  final degrees = coordinate.floor();
  final minutes = ((coordinate - degrees) * 60).floor();
  final seconds = (((coordinate - degrees) * 60 - minutes) * 60).toStringAsFixed(2);
  return '$degrees°$minutes\'$seconds"';
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

  return imageBytes; // 이 부분은 실제 EXIF 수정 후 바이트로 교체해야 합니다.
}
