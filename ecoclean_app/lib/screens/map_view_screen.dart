import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';

class MapViewScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String category;

  const MapViewScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Deteksi apakah HP sedang menggunakan Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lokasi: $category",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.transparent : Colors.green.shade700,
        foregroundColor: isDark ? Colors.white : Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          // LatLng sekarang sudah dikenali berkat import latlong2
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 16.0, // Zoom level yang pas untuk melihat jalan
        ),
        children: [
          TileLayer(
            // Ini adalah server peta gratis dari OpenStreetMap
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ecoclean.app',

            // FITUR UX: Jika mode gelap aktif, kita beri filter warna gelap pada peta
            // agar mata user tidak sakit karena melihat peta yang terlalu terang
            tileBuilder: isDark
                ? (context, tileWidget, tile) => ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      -1,
                      0,
                      0,
                      0,
                      255,
                      0,
                      -1,
                      0,
                      0,
                      255,
                      0,
                      0,
                      -1,
                      0,
                      255,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: tileWidget,
                  )
                : null,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitude, longitude),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 45, // Ukuran marker diperbesar sedikit agar jelas
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
