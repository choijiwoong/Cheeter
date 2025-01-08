import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget { // 상태 위젯을 상속
  final Function(LatLng) onLocationSelected; // 콜백으로 넘어올 이벤트 처리 함수. 아래의 생성자 호출 시점에 처리됨

  const MapScreen({Key? key, required this.onLocationSelected}) : super(key: key); 

  @override
  _MapScreenState createState() => _MapScreenState(); // 상태 화면을 생성함
}

class _MapScreenState extends State<MapScreen> {
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // 초기 위치 (샌프란시스코)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("지도에서 위치 선택"), // 제목
      ),
      body: GoogleMap( // 구글 맵 API 사용
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 10,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: _selectedLocation, // 초기 위치값에 마커 표시
            draggable: true,
            onDragEnd: (newPosition) { // 화면을 드래그 하면 
              setState(() {// 선택된 위치 상태를 새 위치 값으로 갱신함
                _selectedLocation = newPosition;
              });
            },
          ),
        },
        onTap: (position) { // 화면을 클릭하면 
          setState(() {// 선택된 위치 상태를 새 위치 값으로 갱신함
            _selectedLocation = position;
          });
        },
      ),
      floatingActionButton: FloatingActionButton( // 위치를 최종적으로 선택하는 버튼
        onPressed: () {
          widget.onLocationSelected(_selectedLocation);//선택한 위치를 콜백으로 넘어온 함수에 전달
          Navigator.pop(context);// 화면 되돌아가기
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
