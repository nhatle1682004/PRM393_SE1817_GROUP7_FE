import 'package:flutter/material.dart';

class LocationMarker extends StatelessWidget {
  final Color color;
  const LocationMarker({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.2))),
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]), child: const Icon(Icons.location_on, color: Colors.white, size: 20)),
    ]);
  }
}

class SearchResultDropdown extends StatelessWidget {
  final List<dynamic> results;
  final Function(dynamic) onSelect;
  const SearchResultDropdown({super.key, required this.results, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: ListView.builder(shrinkWrap: true, padding: EdgeInsets.zero, itemCount: results.length, itemBuilder: (c, i) => ListTile(dense: true, leading: const Icon(Icons.location_on, color: Colors.green, size: 20), title: Text(results[i].shortAddress, style: const TextStyle(fontSize: 13)), onTap: () => onSelect(results[i])))),
    );
  }
}
