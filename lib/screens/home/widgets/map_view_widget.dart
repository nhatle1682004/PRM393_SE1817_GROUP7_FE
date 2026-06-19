import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewWidget extends StatelessWidget {
  final Function(LatLng) onLocationSelected;

  const MapViewWidget({super.key, required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    // return GoogleMap(
    //   initialCameraPosition: const CameraPosition(
    //     target: LatLng(10.762622, 106.660172), // Tọa độ mặc định (VD: TP.HCM)
    //     zoom: 14,
    //   ),
    //   onTap: (LatLng location) {
    //     onLocationSelected(location); // Trả tọa độ về cho màn hình cha
    //   },
    //   myLocationEnabled: true,
    // );
    return Container(
      color: const Color(0xfff1f5f9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 48, color: Color(0xff94a3b8)),
            const SizedBox(height: 8),
            const Text("Bản đồ đang chờ cấu hình API",
                style: TextStyle(color: Color(0xff64748b))),
          ],
        ),
      ),
    );
  }
}