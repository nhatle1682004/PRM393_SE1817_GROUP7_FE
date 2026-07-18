import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'location_contract.dart';
import 'location_presenter.dart';
import 'location_card_widgets.dart';

class LocationCard extends StatefulWidget {
  final bool isMobile;
  final double? lat, lng;
  final String? currentAddress;
  final bool isLocationLoading;
  final VoidCallback onGetLocation;
  final Function(double lat, double lng, String? address) onLocationSelected;
  final Function(String? address) onAddressUpdated;

  const LocationCard({super.key, required this.isMobile, this.lat, this.lng, this.currentAddress, this.isLocationLoading = false, required this.onGetLocation, required this.onLocationSelected, required this.onAddressUpdated});
  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> implements LocationView {
  late LocationPresenter _presenter;
  final _search = TextEditingController(), _map = MapController();
  List<dynamic> _results = [];
  bool _isSearching = false, _showResults = false, _isGps = false;
  String? _displayAddr;

  @override
  void initState() {
    super.initState();
    _presenter = LocationPresenterImpl(this);
    _displayAddr = widget.currentAddress;
    if (widget.lat != null && widget.lng != null && widget.currentAddress == null) _presenter.fetchAddressFromCoordinates(widget.lat!, widget.lng!);
  }

  @override
  void onSearchStarted() => setState(() => _isSearching = true);
  @override
  void onSearchResultsLoaded(List<dynamic> r) => setState(() { _results = r; _showResults = r.isNotEmpty; _isSearching = false; });
  @override
  void onSearchEnded() => setState(() => _isSearching = false);
  @override
  void onAddressFetched(String? a) { if (mounted) setState(() { _displayAddr = a; if (a != null) widget.onAddressUpdated(a); }); }
  @override
  void onLoadingStateChanged(bool l) {}

  @override
  void didUpdateWidget(LocationCard old) {
    super.didUpdateWidget(old);
    if (widget.lat != old.lat || widget.lng != old.lng) {
      if (widget.currentAddress != null && widget.currentAddress != _displayAddr) {
        setState(() { _displayAddr = widget.currentAddress; if (!_isGps) _search.text = widget.currentAddress!; });
      } else if (widget.lat != null && widget.lng != null) {
        _isGps = true; _presenter.fetchAddressFromCoordinates(widget.lat!, widget.lng!);
      }
      if (widget.lat != null && widget.lng != null) _map.move(LatLng(widget.lat!, widget.lng!), 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.location_on, color: Colors.green), const SizedBox(width: 10), Text('Vị trí thu gom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: widget.isMobile ? 16 : 17))]),
        const SizedBox(height: 16),
        _buildSearch(),
        const SizedBox(height: 12),
        _buildMap(),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(onPressed: widget.isLocationLoading ? null : widget.onGetLocation, icon: const Icon(Icons.my_location), label: Text(widget.isLocationLoading ? 'Đang lấy...' : 'Vị trí hiện tại'))),
        if (_displayAddr != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_displayAddr!, style: const TextStyle(color: Colors.green, fontSize: 13))),
      ]),
    );
  }

  Widget _buildSearch() => Column(children: [
    TextField(controller: _search, onChanged: (v) { _isGps = false; _presenter.searchAddress(v); }, decoration: InputDecoration(hintText: 'Tìm địa chỉ...', prefixIcon: const Icon(Icons.search), suffixIcon: _isSearching ? const CircularProgressIndicator() : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    if (_showResults) SearchResultDropdown(results: _results, onSelect: (r) { _search.text = r.displayName; _displayAddr = r.displayName; setState(() => _showResults = false); widget.onLocationSelected(r.lat, r.lon, r.displayName); widget.onAddressUpdated(r.displayName); _map.move(LatLng(r.lat, r.lon), 16); }),
  ]);

  Widget _buildMap() => Container(
    height: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), clipBehavior: Clip.antiAlias,
    child: FlutterMap(mapController: _map, options: MapOptions(initialCenter: widget.lat != null ? LatLng(widget.lat!, widget.lng!) : const LatLng(10.7, 106.7), initialZoom: 13, onTap: (p, l) { _isGps = true; _presenter.fetchAddressFromCoordinates(l.latitude, l.longitude); widget.onLocationSelected(l.latitude, l.longitude, null); }), children: [
      TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', tileProvider: CancellableNetworkTileProvider()),
      if (widget.lat != null && widget.lng != null) MarkerLayer(markers: [Marker(point: LatLng(widget.lat!, widget.lng!), width: 50, height: 50, child: const LocationMarker(color: Colors.green))]),
    ]),
  );
}
