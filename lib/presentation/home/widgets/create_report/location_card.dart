import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../../services/geocoding_service.dart';

class LocationCard extends StatefulWidget {
  final bool isMobile;
  final double? lat;
  final double? lng;
  final String? currentAddress;
  final bool isLocationLoading;
  final VoidCallback onGetLocation;
  final Function(double lat, double lng, String? address) onLocationSelected;
  final Function(String? address) onAddressUpdated;

  const LocationCard({
    super.key,
    required this.isMobile,
    this.lat,
    this.lng,
    this.currentAddress,
    this.isLocationLoading = false,
    required this.onGetLocation,
    required this.onLocationSelected,
    required this.onAddressUpdated,
  });

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  Timer? _debounce;
  List<AddressSearchResult> _searchResults = [];
  bool _isSearching = false;
  String? _displayedAddress;
  bool _showSearchResults = false;
  bool _isFetchingAddress = false;
  bool _isFromGps = false;

  // Default location: Ho Chi Minh City, Vietnam
  static const LatLng _defaultLocation = LatLng(10.776889, 106.700806);

  LatLng get _currentLocation {
    if (widget.lat != null && widget.lng != null) {
      return LatLng(widget.lat!, widget.lng!);
    }
    return _defaultLocation;
  }

  @override
  void initState() {
    super.initState();
    _displayedAddress = widget.currentAddress;
    if (widget.lat != null &&
        widget.lng != null &&
        widget.currentAddress == null) {
      _fetchAddress(widget.lat!, widget.lng!);
    }
  }

  @override
  void didUpdateWidget(LocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update address when location changes from GPS
    if (widget.lat != oldWidget.lat || widget.lng != oldWidget.lng) {
      // If location was set by search, keep the search address
      // If location was set by GPS, fetch new address but DON'T update search field
      if (widget.currentAddress != null &&
          widget.currentAddress != _displayedAddress) {
        _displayedAddress = widget.currentAddress;
        // Only update search text if it's a search result, not GPS
        if (!_isFromGps) {
          _searchController.text = widget.currentAddress!;
        }
      } else if (widget.lat != null &&
          widget.lng != null &&
          !_isFetchingAddress) {
        _fetchAddress(widget.lat!, widget.lng!);
      }
      if (widget.lat != null && widget.lng != null) {
        _mapController.move(LatLng(widget.lat!, widget.lng!), 15);
      }
    }
    // Update address from external source (search) - reset GPS flag when search happens
    if (widget.currentAddress != oldWidget.currentAddress &&
        widget.currentAddress != null) {
      _displayedAddress = widget.currentAddress;
      // Only update search text if it's a search result
      if (!_isFromGps) {
        _searchController.text = widget.currentAddress!;
      }
    }
    // Reset GPS flag when user types in search
    if (oldWidget.currentAddress == null && widget.currentAddress != null) {
      _isFromGps = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    if (_isFetchingAddress) return;
    setState(() {
      _isFetchingAddress = true;
      _isFromGps = true;
    });

    try {
      final address = await GeocodingService.getAddressFromCoordinates(
        lat,
        lng,
      );
      if (mounted) {
        setState(() {
          _isFetchingAddress = false;
          if (address != null && _searchResults.isEmpty) {
            _displayedAddress = address;
            widget.onAddressUpdated(address);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingAddress = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    // Reset GPS flag when user types in search field
    _isFromGps = false;

    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      final results = await GeocodingService.searchAddress(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
          _showSearchResults = results.isNotEmpty;
        });
      }
    });
  }

  void _selectAddress(AddressSearchResult result) {
    _searchController.text = result.displayName;
    _displayedAddress = result.displayName;
    setState(() {
      _showSearchResults = false;
      _searchResults = [];
    });
    widget.onLocationSelected(result.lat, result.lon, result.displayName);
    widget.onAddressUpdated(result.displayName);
    _mapController.move(LatLng(result.lat, result.lon), 16);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    _fetchAddressAndUpdate(point.latitude, point.longitude);
  }

  void _fetchAddressAndUpdate(double lat, double lng) async {
    setState(() {
      _isFetchingAddress = true;
      _isFromGps = true;
    });
    try {
      final address = await GeocodingService.getAddressFromCoordinates(
        lat,
        lng,
      );
      if (mounted) {
        setState(() {
          _isFetchingAddress = false;
          _displayedAddress = address;
        });
        widget.onLocationSelected(lat, lng, address);
        widget.onAddressUpdated(address);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingAddress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = widget.isMobile ? 200.0 : 220.0;
    final buttonHeight = widget.isMobile ? 48.0 : 50.0;

    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(),
          SizedBox(height: widget.isMobile ? 14 : 20),
          _buildSearchField(),
          SizedBox(height: widget.isMobile ? 12 : 16),
          _buildMapPreview(mapHeight),
          SizedBox(height: widget.isMobile ? 12 : 16),
          _buildLocationButton(buttonHeight),
          SizedBox(height: widget.isMobile ? 12 : 16),
          if (_displayedAddress != null) _buildAddressDisplay(),
          if (widget.lat != null && widget.lng != null) _buildCoordinates(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() => Row(
    children: [
      Icon(
        Icons.location_on,
        color: const Color(0xFF059669),
        size: widget.isMobile ? 20 : 22,
      ),
      SizedBox(width: widget.isMobile ? 10 : 14),
      Text(
        'Vị trí thu gom',
        style: TextStyle(
          fontSize: widget.isMobile ? 16 : 17,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
      ),
    ],
  );

  Widget _buildSearchField() => Column(
    children: [
      TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        onTap: () {
          if (_searchResults.isNotEmpty) {
            setState(() => _showSearchResults = true);
          }
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm địa chỉ ở Việt Nam...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                      _showSearchResults = false;
                      _isFromGps = false;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: widget.isMobile ? 12 : 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
          ),
        ),
      ),
      if (_showSearchResults && _searchResults.isNotEmpty)
        _buildSearchResultsDropdown(),
    ],
  );

  Widget _buildSearchResultsDropdown() => Container(
    margin: const EdgeInsets.only(top: 4),
    constraints: const BoxConstraints(maxHeight: 200),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return ListTile(
            dense: true,
            leading: const Icon(
              Icons.location_on,
              color: Color(0xFF10B981),
              size: 20,
            ),
            title: Text(
              result.shortAddress,
              style: const TextStyle(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectAddress(result),
          );
        },
      ),
    ),
  );

  Widget _buildMapPreview(double mapHeight) => Container(
    height: mapHeight,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    clipBehavior: Clip.antiAlias,
    child: FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: widget.lat != null ? 15 : 13,
        onTap: _onMapTap,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.waste_collection',
          tileProvider: CancellableNetworkTileProvider(),
          maxZoom: 19,
        ),
        if (widget.lat != null && widget.lng != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.lat!, widget.lng!),
                width: 50,
                height: 50,
                child: _buildLocationMarker(),
              ),
            ],
          )
        else
          MarkerLayer(
            markers: [
              Marker(
                point: _defaultLocation,
                width: 50,
                height: 50,
                child: _buildDefaultMarker(),
              ),
            ],
          ),
      ],
    ),
  );

  Widget _buildLocationMarker() => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
        ),
      ),
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF10B981),
          boxShadow: [
            BoxShadow(
              color: Color(0x4010B981),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.location_on, color: Colors.white, size: 20),
      ),
    ],
  );

  Widget _buildDefaultMarker() => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEF4444),
          boxShadow: [
            BoxShadow(
              color: const Color(0x40EF4444),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.location_on, color: Colors.white, size: 20),
      ),
    ],
  );

  Widget _buildLocationButton(double buttonHeight) => SizedBox(
    width: double.infinity,
    height: buttonHeight,
    child: ElevatedButton.icon(
      onPressed: widget.isLocationLoading ? null : widget.onGetLocation,
      icon: widget.isLocationLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.my_location, size: 20),
      label: Text(
        widget.isLocationLoading ? 'Đang lấy vị trí...' : 'Vị trí hiện tại',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: widget.isMobile ? 14 : 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  Widget _buildAddressDisplay() => Container(
    width: double.infinity,
    padding: EdgeInsets.all(widget.isMobile ? 12 : 14),
    margin: EdgeInsets.only(bottom: widget.isMobile ? 10 : 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF0FDF4),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFBBF7D0)),
    ),
    child: Row(
      children: [
        const Icon(Icons.home, color: Color(0xFF059669), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _displayedAddress ?? '',
            style: TextStyle(
              fontSize: widget.isMobile ? 13 : 14,
              color: const Color(0xFF166534),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _buildCoordinates() => Container(
    padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vĩ độ',
                style: TextStyle(
                  fontSize: widget.isMobile ? 11 : 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.lat?.toStringAsFixed(6) ?? "—",
                style: TextStyle(
                  fontSize: widget.isMobile ? 13 : 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: widget.isMobile ? 30 : 36,
          color: const Color(0xFFE2E8F0),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kinh độ',
                  style: TextStyle(
                    fontSize: widget.isMobile ? 11 : 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.lng?.toStringAsFixed(6) ?? "—",
                  style: TextStyle(
                    fontSize: widget.isMobile ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
