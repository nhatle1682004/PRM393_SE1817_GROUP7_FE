import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/home/widgets/create_report_screen.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_screen.dart';
import 'package:waste_collection_management_system/presentation/rewards/rewards_screen.dart';
import 'package:waste_collection_management_system/presentation/history/history_screen.dart';
import 'package:waste_collection_management_system/presentation/home/citizen_notification_screen.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/widgets/app_layout.dart';
import '../../data/models/home_stats.dart';
import 'home_contract.dart';
import 'home_presenter.dart';

// ============================================================
// DATA MODELS
// ============================================================

class ReportStats {
  final int pending;
  final int processing;
  final int rejected;
  final int total;

  const ReportStats({
    required this.pending,
    required this.processing,
    required this.rejected,
    required this.total,
  });
}

class CommunityPhoto {
  final String assetPath;
  final String label;

  const CommunityPhoto({required this.assetPath, required this.label});
}

// ============================================================
// PROFILE WRAPPER
// ============================================================

class _ProfileScreenContent extends StatelessWidget {
  const _ProfileScreenContent();

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

class _RewardsScreenContent extends StatelessWidget {
  final ValueChanged<int> onBalanceChanged;

  const _RewardsScreenContent({required this.onBalanceChanged});

  @override
  Widget build(BuildContext context) {
    return RewardsScreen(onBalanceChanged: onBalanceChanged);
  }
}

class _HistoryScreenContent extends StatelessWidget {
  const _HistoryScreenContent();

  @override
  Widget build(BuildContext context) {
    return const HistoryScreen();
  }
}

class _NotificationScreenContent extends StatelessWidget {
  const _NotificationScreenContent();

  @override
  Widget build(BuildContext context) {
    return const CitizenNotificationScreen();
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeView {
  late HomePresenter _presenter;
  int _currentTabIndex = 0;
  HomeStats _stats = HomeStats();
  bool _isLoading = false;
  String? _errorMessage;
  List<CitizenNotificationItem> _notifications = [];

  static const _communityPhotos = [
    CommunityPhoto(assetPath: 'assets/images/community_1.png', label: 'Dọn rác Đà Nẵng'),
    CommunityPhoto(assetPath: 'assets/images/community_2.png', label: 'Ra quân tình nguyện'),
    CommunityPhoto(assetPath: 'assets/images/community_3.png', label: 'Phố xanh sạch đẹp'),
  ];

  ReportStats _buildReportStats() {
    return ReportStats(
      pending: 0,
      processing: 0,
      rejected: 0,
      total: int.tryParse(_stats.reportsSubmitted) ?? 0,
    );
  }

  double _levelProgress = 0.22;
  String _levelLabel = 'Cấp 1';

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenterImpl(this);
    _presenter.loadDashboardData();
  }

  Future<List<CitizenNotificationItem>> _loadNotifications() async {
    try {
      final response = await ApiService.get(ApiConfig.notifications);
      final data = response.data;
      if (data is List) {
        _notifications = data
            .map((e) => CitizenNotificationItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return _notifications;
      }
    } catch (_) {
      // Ignore errors
    }
    return [];
  }

  Future<void> _markNotificationsAsRead(List<int> ids) async {
    try {
      for (final id in ids) {
        await ApiService.put(ApiConfig.markNotificationRead(id));
      }
    } catch (_) {
      // Ignore errors
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    try {
      await ApiService.put(ApiConfig.notificationsReadAll);
    } catch (_) {
      // Ignore errors
    }
  }

  void _handleNotificationTap() {
    setState(() => _currentTabIndex = 5);
  }

  @override
  void onTabUpdated(int index) {
    if (mounted) setState(() => _currentTabIndex = index);
  }

  @override
  void onStatsLoaded(HomeStats stats) {
    if (mounted) setState(() => _stats = stats);
  }

  void _handleRewardBalanceChanged(int balance) {
    if (mounted) {
      setState(() => _stats = _stats.copyWith(totalPoints: balance.toString()));
    }
  }

  @override
  void onLoadingStateChanged(bool isLoading) {
    if (mounted) setState(() => _isLoading = isLoading);
  }

  @override
  void onError(String? error) {
    if (mounted) setState(() => _errorMessage = error);
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final authService = AuthService();
    await authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 768;

    if (!isMobile) {
      return AppLayout(
        currentTabIndex: _currentTabIndex,
        onTabChanged: (index) => _presenter.handleTabChange(index),
        onLogout: _handleLogout,
        userName: _stats.userName.isNotEmpty ? _stats.userName : null,
        points: int.tryParse(_stats.totalPoints.replaceAll(',', '')) ?? 0,
        onNotificationTap: _handleNotificationTap,
        onLoadNotifications: _loadNotifications,
        onMarkAsRead: _markNotificationsAsRead,
        onMarkAllAsRead: _markAllNotificationsAsRead,
        child: _buildContent(isMobile),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff1f5f9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Waste Collection', style: TextStyle(color: Color(0xff0f172a), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xff475569)),
        actions: [
          _buildMobileNotificationBell(),
          const SizedBox(width: 4),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildContent(isMobile),
    );
  }

  Widget _buildMobileNotificationBell() {
    return GestureDetector(
      onTap: _handleNotificationTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.notifications_outlined,
          color: Color(0xFF64748B),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xff2ecc71)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Color(0xffdc2626), size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xffdc2626), fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _presenter.loadDashboardData(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2ecc71)),
                child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    switch (_currentTabIndex) {
      case 1: return const CreateReportScreen();
      case 2: return _RewardsScreenContent(onBalanceChanged: _handleRewardBalanceChanged);
      case 3: return const _HistoryScreenContent();
      case 4: return const _ProfileScreenContent();
      case 5: return const _NotificationScreenContent();
      default:
        return HomePage(
          points: int.tryParse(_stats.totalPoints.replaceAll(',', '')) ?? 0,
          levelProgress: _levelProgress,
          levelLabel: _levelLabel,
          stats: _buildReportStats(),
          communityPhotos: _communityPhotos,
          onRedeemTap: () => _presenter.handleTabChange(2),
          onViewAllReportsTap: () => _presenter.handleTabChange(3),
          onReportTap: () => _presenter.handleTabChange(1),
        );
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            decoration: const BoxDecoration(color: Color(0xff2ecc71)),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, color: Colors.white, size: 48),
                SizedBox(height: 10),
                Text('Waste Collection', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _drawerItem(Icons.home, 'Trang chủ', 0),
          _drawerItem(Icons.assignment, 'Tạo báo cáo', 1),
          _drawerItem(Icons.emoji_events, 'Phần thưởng', 2),
          _drawerItem(Icons.history, 'Lịch sử', 3),
          const Spacer(),
          _drawerItem(Icons.person, 'Trang cá nhân', 4),
          _drawerItem(Icons.logout, 'Đăng xuất', -1),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    bool isActive = _currentTabIndex == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? const Color(0xff2ecc71) : const Color(0xff64748b)),
      title: Text(label, style: TextStyle(color: isActive ? const Color(0xff2ecc71) : const Color(0xff1e293b), fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      selected: isActive,
      onTap: () {
        Navigator.pop(context);
        if (index == -1) _handleLogout(); else _presenter.handleTabChange(index);
      },
    );
  }
}

// ============================================================
// HOME PAGE WIDGET
// ============================================================

class HomePage extends StatelessWidget {
  final int points;
  final double levelProgress;
  final String levelLabel;
  final ReportStats stats;
  final List<CommunityPhoto> communityPhotos;
  final VoidCallback onRedeemTap;
  final VoidCallback onViewAllReportsTap;
  final VoidCallback onReportTap;

  const HomePage({
    super.key,
    required this.points,
    required this.levelProgress,
    required this.levelLabel,
    required this.stats,
    required this.communityPhotos,
    required this.onRedeemTap,
    required this.onViewAllReportsTap,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F8),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          EcoBanner(
            levelLabel: levelLabel,
            levelProgress: levelProgress,
            onReportTap: onReportTap,
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Cộng đồng chung tay'),
          const SizedBox(height: 12),
          _CommunityGallery(photos: communityPhotos),
          const SizedBox(height: 24),
          _RewardsCard(onRedeemTap: onRedeemTap),
          const SizedBox(height: 24),
          const _SectionLabel('Hướng dẫn tham gia'),
          const SizedBox(height: 12),
          const _StepsRow(),
          const SizedBox(height: 24),
          const _SectionLabel('Thống kê báo cáo của bạn'),
          const SizedBox(height: 12),
          _StatsGrid(stats: stats),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onViewAllReportsTap,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Xem chi tiết tất cả báo cáo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700));
  }
}

// ============================================================
// ECO BANNER
// ============================================================

class EcoBanner extends StatefulWidget {
  final String levelLabel;
  final double levelProgress;
  final VoidCallback onReportTap;

  const EcoBanner({super.key, required this.levelLabel, required this.levelProgress, required this.onReportTap});

  @override
  State<EcoBanner> createState() => _EcoBannerState();
}

class _EcoBannerState extends State<EcoBanner> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _spinController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F6E56),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF0F6E56).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          padding: const EdgeInsets.all(32),
          child: isMobile 
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildText(true), const SizedBox(height: 32), _buildBadge()])
            : Row(children: [Expanded(child: _buildText(false)), const SizedBox(width: 40), _buildBadge()]),
        );
      },
    );
  }

  Widget _buildText(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vì một Việt Nam xanh', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 12),
        const Text('Thấy rác là báo, sạch lối sạch đường. Hãy cùng nhau phân loại rác tại nguồn để bảo vệ môi trường Việt Nam.', style: TextStyle(color: Color(0xFFC0DD97), fontSize: 15, height: 1.5)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: widget.onReportTap,
          icon: const Icon(Icons.camera_alt, size: 18),
          label: const Text('Báo cáo rác ngay', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF085041), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return SizedBox(
      width: 140, height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 140, height: 140, decoration: const BoxDecoration(color: Color(0xFF085041), shape: BoxShape.circle)),
          Container(width: 110, height: 110, decoration: BoxDecoration(color: const Color(0xFF0F6E56), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1)))),
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) => Transform.translate(offset: Offset(0, -5 * math.sin(_floatController.value * math.pi)), child: child),
            child: const Icon(Icons.eco, size: 50, color: Colors.white),
          ),
          Positioned(top: 0, right: 0, child: _smallChip(Icons.park, 36)),
          Positioned(bottom: 5, left: 5, child: AnimatedBuilder(animation: _spinController, builder: (context, child) => Transform.rotate(angle: _spinController.value * 2 * math.pi, child: child), child: _smallChip(Icons.recycling, 32))),
        ],
      ),
    );
  }

  Widget _smallChip(IconData icon, double size) => Container(width: size, height: size, decoration: const BoxDecoration(color: Color(0xFF04342C), shape: BoxShape.circle), child: Icon(icon, size: size * 0.5, color: const Color(0xFF9FE1CB)));
}

class _CommunityGallery extends StatelessWidget {
  final List<CommunityPhoto> photos;
  const _CommunityGallery({required this.photos});
  @override
  Widget build(BuildContext context) {
    return Row(children: photos.map((p) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: _CommunityPhotoTile(photo: p)))).toList());
  }
}

class _CommunityPhotoTile extends StatelessWidget {
  final CommunityPhoto photo;
  const _CommunityPhotoTile({required this.photo});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(photo.assetPath, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey))),
          Positioned(bottom: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)), child: Text(photo.label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)))),
        ]),
      ),
    );
  }
}

class _RewardsCard extends StatelessWidget {
  final VoidCallback onRedeemTap;
  const _RewardsCard({required this.onRedeemTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.card_giftcard, size: 20, color: Color(0xFF0F6E56)), SizedBox(width: 10), Expanded(child: Text('Tích điểm xanh, đổi quà sạch', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1))]),
          const SizedBox(height: 8),
          Text('Mỗi báo cáo thành công giúp bạn tích điểm để đổi túi vải canvas, bình nước hoặc voucher mua sắm.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRedeemTap, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF9F27), foregroundColor: const Color(0xFF412402), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Đổi quà ngay', style: TextStyle(fontWeight: FontWeight.bold))),
        ])),
        const SizedBox(width: 20),
        Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.redeem, size: 40, color: Colors.grey)),
      ]),
    );
  }
}

class _StepsRow extends StatelessWidget {
  const _StepsRow();
  @override
  Widget build(BuildContext context) {
    final steps = [
      (1, Icons.camera_alt_outlined, 'Chụp ảnh', 'Rác tự phát'),
      (2, Icons.local_shipping_outlined, 'Thu gom', 'Xử lý rác'),
      (3, Icons.emoji_events_outlined, 'Nhận quà', 'Tích điểm xanh'),
    ];
    return Row(children: steps.map((s) => Expanded(child: Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)), child: Column(children: [
      CircleAvatar(radius: 12, backgroundColor: const Color(0xFF0F6E56), child: Text('${s.$1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
      const SizedBox(height: 10),
      Icon(s.$2, color: Colors.grey.shade600, size: 22),
      const SizedBox(height: 6),
      Text(s.$3, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Text(s.$4, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
    ])))).toList());
  }
}

class _StatsGrid extends StatelessWidget {
  final ReportStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isMobile ? (constraints.maxWidth - 18) / 2 : (constraints.maxWidth - 36) / 4;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: isMobile ? cardWidth : (constraints.maxWidth - 36) / 4,
              child: _StatCard(
                title: 'Chờ duyệt',
                value: stats.pending,
                iconBg: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                icon: Icons.access_time_rounded,
                isCompact: isMobile,
              ),
            ),
            SizedBox(
              width: isMobile ? cardWidth : (constraints.maxWidth - 36) / 4,
              child: _StatCard(
                title: 'Đang xử lý',
                value: stats.processing,
                iconBg: const [Color(0xFF60A5FA), Color(0xFF2563EB)],
                icon: Icons.local_shipping_rounded,
                isCompact: isMobile,
              ),
            ),
            SizedBox(
              width: isMobile ? cardWidth : (constraints.maxWidth - 36) / 4,
              child: _StatCard(
                title: 'Từ chối',
                value: stats.rejected,
                iconBg: const [Color(0xFFF87171), Color(0xFFDC2626)],
                icon: Icons.close_rounded,
                isCompact: isMobile,
              ),
            ),
            SizedBox(
              width: isMobile ? cardWidth : (constraints.maxWidth - 36) / 4,
              child: _StatCard(
                title: 'Tổng cộng',
                value: stats.total,
                iconBg: const [Color(0xFF34D399), Color(0xFF059669)],
                icon: Icons.eco_rounded,
                isCompact: isMobile,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final List<Color> iconBg;
  final IconData icon;
  final bool isCompact;

  const _StatCard({
    required this.title,
    required this.value,
    required this.iconBg,
    required this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isCompact ? 32.0 : 42.0;
    final iconChildSize = isCompact ? 28.0 : 22.0;
    final padding = isCompact ? 10.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: iconBg,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconBg.last.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: iconChildSize),
          ),
          SizedBox(height: isCompact ? 8 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isCompact ? 10 : 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: TextStyle(
              fontSize: isCompact ? 16 : 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
