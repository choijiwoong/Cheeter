import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const MapScreen({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // 초기 위치 (샌프란시스코)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("지도에서 위치 선택"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 10,
        ),
        markers: {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: _selectedLocation,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _selectedLocation = newPosition;
              });
            },
          ),
        },
        onTap: (position) {
          setState(() {
            _selectedLocation = position;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onLocationSelected(_selectedLocation);
          Navigator.pop(context);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
