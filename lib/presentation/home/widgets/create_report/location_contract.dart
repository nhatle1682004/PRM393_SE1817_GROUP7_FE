import 'package:waste_collection_management_system/services/geocoding_service.dart';

abstract class LocationView {
  void onSearchStarted();
  void onSearchResultsLoaded(List<AddressSearchResult> results);
  void onSearchEnded();
  void onAddressFetched(String? address);
  void onLoadingStateChanged(bool isLoading);
}

abstract class LocationPresenter {
  void searchAddress(String query);
  void fetchAddressFromCoordinates(double lat, double lng);
  void dispose();
}
