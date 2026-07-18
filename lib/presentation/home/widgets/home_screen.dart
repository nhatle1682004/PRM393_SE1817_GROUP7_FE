import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/home/widgets/create_report_screen.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_screen.dart';
import 'package:waste_collection_management_system/presentation/rewards/rewards_screen.dart';
import 'package:waste_collection_management_system/presentation/history/history_screen.dart';
import 'package:waste_collection_management_system/presentation/home/citizen_notification_screen.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/widgets/app_layout.dart';
import '../../../data/models/home_stats.dart';
import '../home_contract.dart';
import '../home_presenter.dart';
import 'home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeView {
  late HomePresenter _presenter;
  int _tabIndex = 0;
  HomeStats _stats = HomeStats();
  bool _isLoading = false;

  @override
  void initState() { super.initState(); _presenter = HomePresenterImpl(this); _presenter.loadDashboardData(); }

  @override
  void onTabUpdated(int index) => setState(() => _tabIndex = index);
  @override
  void onStatsLoaded(HomeStats stats) => setState(() => _stats = stats);
  @override
  void onLoadingStateChanged(bool isLoading) => setState(() => _isLoading = isLoading);
  @override
  void onError(String? error) {}

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final content = _buildContent();

    if (!isMobile) {
      return AppLayout(
        currentTabIndex: _tabIndex,
        onTabChanged: _presenter.handleTabChange,
        onLogout: _logout,
        userName: _stats.userName,
        points: int.tryParse(_stats.totalPoints) ?? 0,
        child: content,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Waste Collection'), actions: [IconButton(icon: const Icon(Icons.notifications), onPressed: () => setState(() => _tabIndex = 5))]),
      drawer: _buildDrawer(),
      body: content,
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return switch (_tabIndex) {
      1 => const CreateReportScreen(),
      2 => const RewardsScreen(),
      3 => const HistoryScreen(),
      4 => const ProfileScreen(),
      5 => const CitizenNotificationScreen(),
      _ => _homePage(),
    };
  }

  Widget _homePage() => ListView(padding: const EdgeInsets.all(16), children: [
    EcoBanner(onReport: () => _presenter.handleTabChange(1)),
    const SizedBox(height: 20),
    RewardCard(onTap: () => _presenter.handleTabChange(2)),
    const SizedBox(height: 20),
    StatGrid(total: int.tryParse(_stats.reportsSubmitted) ?? 0),
  ]);

  Widget _buildDrawer() => Drawer(child: Column(children: [
    const UserAccountsDrawerHeader(accountName: Text('Waste Collection'), accountEmail: null, currentAccountPicture: CircleAvatar(child: Icon(Icons.eco))),
    ListTile(leading: const Icon(Icons.home), title: const Text('Trang chủ'), onTap: () => _tap(0)),
    ListTile(leading: const Icon(Icons.add), title: const Text('Báo cáo'), onTap: () => _tap(1)),
    ListTile(leading: const Icon(Icons.card_giftcard), title: const Text('Quà tặng'), onTap: () => _tap(2)),
    ListTile(leading: const Icon(Icons.history), title: const Text('Lịch sử'), onTap: () => _tap(3)),
    const Spacer(),
    ListTile(leading: const Icon(Icons.logout), title: const Text('Đăng xuất'), onTap: _logout),
  ]));

  void _tap(int i) { Navigator.pop(context); _presenter.handleTabChange(i); }

  void _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (c) => const LoginScreen()),
      (r) => false,
    );
  }
}
