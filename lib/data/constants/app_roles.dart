/// Role IDs matching Backend (BE):
/// 1 = Citizen, 2 = Enterprise, 3 = Collector, 4 = Admin
class AppRoles {
  AppRoles._();

  static const int citizen = 1;
  static const int enterprise = 2;
  static const int collector = 3;
  static const int admin = 4;

  static String getRoleName(int roleId) {
    switch (roleId) {
      case citizen:
        return 'Citizen';
      case enterprise:
        return 'Enterprise';
      case collector:
        return 'Collector';
      case admin:
        return 'Admin';
      default:
        return 'Unknown';
    }
  }

  static bool isAdmin(int roleId) => roleId == admin;
  static bool isEnterprise(int roleId) => roleId == enterprise;
  static bool isCollector(int roleId) => roleId == collector;
  static bool isCitizen(int roleId) => roleId == citizen;
}
