import 'dart:async';
import '../../../../services/geocoding_service.dart';
import 'location_contract.dart';

class LocationPresenterImpl implements LocationPresenter {
  final LocationView _view;
  Timer? _debounce;

  LocationPresenterImpl(this._view);

  @override
  void searchAddress(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      _view.onSearchResultsLoaded([]);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _view.onSearchStarted();
      try {
        final results = await GeocodingService.searchAddress(query);
        _view.onSearchResultsLoaded(results);
      } catch (_) {
        _view.onSearchResultsLoaded([]);
      } finally {
        _view.onSearchEnded();
      }
    });
  }

  @override
  Future<void> fetchAddressFromCoordinates(double lat, double lng) async {
    _view.onLoadingStateChanged(true);
    try {
      final address = await GeocodingService.getAddressFromCoordinates(lat, lng);
      _view.onAddressFetched(address);
    } catch (_) {
      _view.onAddressFetched(null);
    } finally {
      _view.onLoadingStateChanged(false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
  }
}
