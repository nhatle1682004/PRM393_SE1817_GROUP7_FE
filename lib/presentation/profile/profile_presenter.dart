import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';
import '../../data/models/user_profile_data.dart';
import 'profile_contract.dart';

class ProfilePresenterImpl implements ProfilePresenter {
  final ProfileView _view;

  ProfilePresenterImpl(this._view);

  @override
  void loadProfile() async {
    _view.onLoadingStateChanged(true);
    _view.onError(null);

    try {
      final response = await ApiService.get(ApiConfig.profile);
      final data = response.data as Map<String, dynamic>;
      final profile = UserProfileData.fromJson(data);
      _view.onProfileLoaded(profile);
    } catch (e) {
      _view.onError(e.toString());
    } finally {
      _view.onLoadingStateChanged(false);
    }
  }

  @override
  void updateProfile(UserProfileData profile) async {
    _view.onLoadingStateChanged(true);
    _view.onError(null);

    try {
      final response = await ApiService.put(
        ApiConfig.profile,
        body: profile.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      final updatedProfile = UserProfileData.fromJson(data);
      _view.onProfileLoaded(updatedProfile);
    } catch (e) {
      _view.onError(e.toString());
    } finally {
      _view.onLoadingStateChanged(false);
    }
  }

  @override
  void logout() async {
    try {
      final authService = AuthService();
      await authService.logout();
      _view.onLogoutSuccess();
    } catch (e) {
      _view.onError(e.toString());
    }
  }

  @override
  void dispose() {}
}
