import 'package:flutter/material.dart';
import 'package:hotel/features/auth/data/models/user_model.dart';
import 'package:hotel/features/auth/presentation/pages/login_page.dart';
import 'package:hotel/features/home/presentation/widgets/app_drawer.dart';
import 'package:hotel/features/tables/presentation/pages/table_selection_page.dart';

class HomePage extends StatefulWidget {
  final UserModel user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Modern Material Color Palette
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);

  final List<_PageInfo> _pages = [
    _PageInfo('Dashboard', Icons.dashboard_rounded, const Color(0xFF667eea)),
    _PageInfo('Tables', Icons.table_bar_rounded, const Color(0xFF38A169)),
    _PageInfo('Orders', Icons.receipt_long_rounded, const Color(0xFF3182CE)),
    _PageInfo('Menu Items', Icons.restaurant_menu_rounded, const Color(0xFFD69E2E)),
    _PageInfo('Kitchen', Icons.soup_kitchen_rounded, const Color(0xFFE53E3E)),
    _PageInfo('Billing', Icons.point_of_sale_rounded, const Color(0xFF805AD5)),
    _PageInfo('Reports', Icons.analytics_rounded, const Color(0xFF00B5D8)),
    _PageInfo('Settings', Icons.settings_rounded, const Color(0xFF718096)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: surfaceColor,
      drawer: AppDrawer(
        user: widget.user,
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onLogout: _handleLogout,
      ),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final currentPage = _pages[_selectedIndex];

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryGradientStart, primaryGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGradientStart.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          // Hamburger Menu Button
          _buildMenuButton(),
          const SizedBox(width: 16),
          // Page Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentPage.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: 'Welcome back, ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    children: [
                      TextSpan(
                        text: widget.user.displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Kiran',
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Notification & Profile
          _buildNotificationButton(),
          const SizedBox(width: 12),
          _buildProfileAvatar(),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _scaffoldKey.currentState?.openDrawer(),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              const Icon(
                Icons.notifications_rounded,
                color: Colors.white,
                size: 24,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final avatarColor = Color(
      int.parse(widget.user.avatarColor.replaceFirst('#', '0xFF')),
    );

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [avatarColor, avatarColor.withValues(alpha: 0.7)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              widget.user.initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kiran',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final currentPage = _pages[_selectedIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Cards
          _buildQuickStats(),
          const SizedBox(height: 24),
          // Recent Activity Section
          _buildSectionTitle('Recent Activity'),
          const SizedBox(height: 16),
          _buildRecentActivityList(),
          const SizedBox(height: 24),
          // Quick Actions
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          _buildQuickActions(currentPage),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      _StatCard(
        title: 'Total Tables',
        value: '24',
        icon: Icons.table_bar_rounded,
        color: const Color(0xFF38A169),
        trend: '18 Free',
        isPositive: true,
      ),
      _StatCard(
        title: 'Active Orders',
        value: '12',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF3182CE),
        trend: '+3 new',
        isPositive: true,
      ),
      _StatCard(
        title: 'Kitchen Queue',
        value: '8',
        icon: Icons.soup_kitchen_rounded,
        color: const Color(0xFFE53E3E),
        trend: 'Pending',
        isPositive: false,
      ),
      _StatCard(
        title: "Today's Sales",
        value: '\$1,842',
        icon: Icons.point_of_sale_rounded,
        color: const Color(0xFF805AD5),
        trend: '+15%',
        isPositive: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(stat);
      },
    );
  }

  Widget _buildStatCard(_StatCard stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: stat.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stat.color.withValues(alpha: 0.2),
                      stat.color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat.icon, color: stat.color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stat.isPositive
                      ? const Color(0xFF38A169).withValues(alpha: 0.1)
                      : const Color(0xFFE53E3E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      stat.isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: stat.isPositive
                          ? const Color(0xFF38A169)
                          : const Color(0xFFE53E3E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stat.trend,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: stat.isPositive
                            ? const Color(0xFF38A169)
                            : const Color(0xFFE53E3E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Text(
                stat.title,
                style: TextStyle(
                  fontSize: 12,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final activities = [
      _Activity(
        title: 'New Order',
        subtitle: 'Table 5 - 4 items',
        time: '2 min ago',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF3182CE),
      ),
      _Activity(
        title: 'Order Ready',
        subtitle: 'Table 3 - Ready to serve',
        time: '5 min ago',
        icon: Icons.soup_kitchen_rounded,
        color: const Color(0xFF38A169),
      ),
      _Activity(
        title: 'Bill Generated',
        subtitle: 'Table 8 - \$125.50',
        time: '12 min ago',
        icon: Icons.point_of_sale_rounded,
        color: const Color(0xFF805AD5),
      ),
      _Activity(
        title: 'Table Occupied',
        subtitle: 'Table 12 - 6 guests',
        time: '18 min ago',
        icon: Icons.table_bar_rounded,
        color: const Color(0xFFD69E2E),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.withValues(alpha: 0.1),
          indent: 72,
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    activity.color.withValues(alpha: 0.2),
                    activity.color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(activity.icon, color: activity.color, size: 24),
            ),
            title: Text(
              activity.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            subtitle: Text(
              activity.subtitle,
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
            trailing: Text(
              activity.time,
              style: TextStyle(
                color: textMuted,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToNewOrder() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TableSelectionPage()),
    );
  }

  Widget _buildQuickActions(_PageInfo currentPage) {
    final actions = [
      _QuickAction(
        title: 'New Order',
        icon: Icons.add_circle_outline_rounded,
        color: const Color(0xFF3182CE),
        onTap: _navigateToNewOrder,
      ),
      _QuickAction(
        title: 'Tables',
        icon: Icons.table_bar_rounded,
        color: const Color(0xFF38A169),
        onTap: () {
          setState(() => _selectedIndex = 1);
        },
      ),
      _QuickAction(
        title: 'Kitchen',
        icon: Icons.soup_kitchen_rounded,
        color: const Color(0xFFE53E3E),
        onTap: () {
          setState(() => _selectedIndex = 4);
        },
      ),
      _QuickAction(
        title: 'Billing',
        icon: Icons.point_of_sale_rounded,
        color: const Color(0xFF805AD5),
        onTap: () {
          setState(() => _selectedIndex = 5);
        },
      ),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: actions.indexOf(action) < actions.length - 1 ? 12 : 0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: action.color.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              action.color,
                              action.color.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          action.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFE53E3E)),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageInfo {
  final String title;
  final IconData icon;
  final Color color;

  _PageInfo(this.title, this.icon, this.color);
}

class _StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;

  _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
  });
}

class _Activity {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  _Activity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });
}
