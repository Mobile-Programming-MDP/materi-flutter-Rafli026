import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  static const route = '/map';

  final double initialLat;
  final double initialLng;
  final String? title;

  const MapScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(initialLat, initialLng);

    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Map')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Text(
                'Lat: ${initialLat.toStringAsFixed(5)}\nLng: ${initialLng.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),

          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: point, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.pelaporankejadian_app',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
