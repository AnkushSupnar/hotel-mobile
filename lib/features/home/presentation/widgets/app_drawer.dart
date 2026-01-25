import 'package:flutter/material.dart';
import 'package:hotel/features/auth/data/models/user_model.dart';
import 'package:hotel/features/settings/presentation/pages/favorite_items_page.dart';
import 'package:hotel/features/settings/presentation/pages/favorite_tables_page.dart';

class AppDrawer extends StatefulWidget {
  final UserModel user;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.user,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isSettingsExpanded = false;

  // Modern Material Color Palette
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: _buildMenuItems(context),
          ),
          _buildLogoutSection(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final avatarColor = Color(
      int.parse(widget.user.avatarColor.replaceFirst('#', '0xFF')),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryGradientStart, primaryGradientEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close Button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // User Avatar
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          avatarColor,
                          avatarColor.withValues(alpha: 0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.user.initials,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kiran',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kiran',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.user.role,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      _MenuItem(
        icon: Icons.dashboard_rounded,
        title: 'Dashboard',
        color: const Color(0xFF667eea),
      ),
      _MenuItem(
        icon: Icons.table_bar_rounded,
        title: 'Tables',
        color: const Color(0xFF38A169),
      ),
      _MenuItem(
        icon: Icons.receipt_long_rounded,
        title: 'Orders',
        color: const Color(0xFF3182CE),
      ),
      _MenuItem(
        icon: Icons.restaurant_menu_rounded,
        title: 'Menu Items',
        color: const Color(0xFFD69E2E),
      ),
      _MenuItem(
        icon: Icons.soup_kitchen_rounded,
        title: 'Kitchen',
        color: const Color(0xFFE53E3E),
      ),
      _MenuItem(
        icon: Icons.point_of_sale_rounded,
        title: 'Billing',
        color: const Color(0xFF805AD5),
      ),
      _MenuItem(
        icon: Icons.analytics_rounded,
        title: 'Reports',
        color: const Color(0xFF00B5D8),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      children: [
        // Regular menu items (not Settings)
        ...menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = widget.selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.onItemSelected(index);
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              item.color.withValues(alpha: 0.15),
                              item.color.withValues(alpha: 0.05),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(
                            color: item.color.withValues(alpha: 0.3),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSelected
                                ? [item.color, item.color.withValues(alpha: 0.8)]
                                : [
                                    item.color.withValues(alpha: 0.15),
                                    item.color.withValues(alpha: 0.1),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected ? Colors.white : item.color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? item.color : textDark,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        // Settings with expandable submenu
        _buildSettingsMenu(context),
      ],
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    const settingsColor = Color(0xFF718096);
    final isSelected = widget.selectedIndex == 7;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isSettingsExpanded = !_isSettingsExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected || _isSettingsExpanded
                      ? LinearGradient(
                          colors: [
                            settingsColor.withValues(alpha: 0.15),
                            settingsColor.withValues(alpha: 0.05),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected || _isSettingsExpanded
                      ? Border.all(
                          color: settingsColor.withValues(alpha: 0.3),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSelected || _isSettingsExpanded
                              ? [settingsColor, settingsColor.withValues(alpha: 0.8)]
                              : [
                                  settingsColor.withValues(alpha: 0.15),
                                  settingsColor.withValues(alpha: 0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        color: isSelected || _isSettingsExpanded
                            ? Colors.white
                            : settingsColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected || _isSettingsExpanded
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected || _isSettingsExpanded
                              ? settingsColor
                              : textDark,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isSettingsExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: settingsColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Submenu items
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              children: [
                _buildSubMenuItem(
                  context,
                  icon: Icons.star_rounded,
                  title: 'Favorite Tables',
                  color: const Color(0xFFED8936),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoriteTablesPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                _buildSubMenuItem(
                  context,
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Favorite Items',
                  color: const Color(0xFF805AD5),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoriteItemsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          crossFadeState: _isSettingsExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textDark,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onLogout,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE53E3E).withValues(alpha: 0.1),
                    const Color(0xFFE53E3E).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE53E3E).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE53E3E),
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE53E3E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color color;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.color,
  });
}
