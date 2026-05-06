import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapDetailScreen extends StatefulWidget {
  final dynamic post;
  
  const MapDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<MapDetailScreen> createState() => _MapDetailScreenState();
}

class _MapDetailScreenState extends State<MapDetailScreen> {
  late MapController mapController;
  List<Marker> markers = [];
  
  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    // Tambahkan marker location di sini
    setState(() {
      markers = [
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(0, 0), // Ganti dengan koordinat sebenarnya
          builder: (ctx) => const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40,
          ),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Detail'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: const MapOptions(
                center: LatLng(0, 0),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                // Action untuk elevated button
              },
              icon: const Icon(Icons.zoom_in),
              label: const Text('Zoom In'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator ke MapDetailScreen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}