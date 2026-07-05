import '../../data/models/user_profile_data.dart';

abstract class ProfileView {
  void onProfileLoaded(UserProfileData profile);
  void onLoadingStateChanged(bool isLoading);
  void onError(String? error);
  void onLogoutSuccess();
}

abstract class ProfilePresenter {
  void loadProfile();
  void updateProfile(UserProfileData profile);
  void logout();
  void dispose();
}
