import 'package:flutter/material.dart';
import 'package:hotel/core/constants/font_constants.dart';
import 'package:hotel/core/services/menu_item_storage_service.dart';
import 'package:hotel/features/orders/data/models/category_model.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';
import 'package:hotel/features/orders/data/repositories/menu_repository.dart';

class FavoriteItemsPage extends StatefulWidget {
  const FavoriteItemsPage({super.key});

  @override
  State<FavoriteItemsPage> createState() => _FavoriteItemsPageState();
}

class _FavoriteItemsPageState extends State<FavoriteItemsPage> {
  final MenuRepository _repository = MenuRepository();
  List<CategoryModel> _categories = [];
  List<MenuItemModel> _allItems = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Modern Material Color Palette
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);

  static const List<Color> categoryColors = [
    Color(0xFF667eea),
    Color(0xFF38A169),
    Color(0xFF3182CE),
    Color(0xFFD69E2E),
    Color(0xFFE53E3E),
    Color(0xFF805AD5),
    Color(0xFF00B5D8),
    Color(0xFFED64A6),
    Color(0xFFDD6B20),
    Color(0xFF319795),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await _repository.getCategories();
      final items = await _repository.getAllItems();
      final favoriteIds = MenuItemStorageService.getFavoriteItemIds();

      setState(() {
        _categories = categories;
        _allItems = items;
        _favoriteIds = favoriteIds.toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load items: ${e.toString()}';
      });
    }
  }

  void _toggleFavorite(int itemId) async {
    await MenuItemStorageService.toggleFavorite(itemId);
    setState(() {
      if (_favoriteIds.contains(itemId)) {
        _favoriteIds.remove(itemId);
      } else {
        _favoriteIds.add(itemId);
      }
    });
  }

  Color _getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  List<MenuItemModel> _getItemsForCategory(int categoryId) {
    return _allItems.where((item) => item.categoryId == categoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
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
          // Back Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favorite Items',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to mark items as favorites',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Favorite count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_favoriteIds.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryGradientStart),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGradientStart,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 64,
              color: textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No items available',
              style: TextStyle(color: textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: primaryGradientStart,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final categoryColor = _getCategoryColor(index);
          final items = _getItemsForCategory(category.id);
          if (items.isEmpty) return const SizedBox.shrink();
          return _buildCategoryCard(category, categoryColor, items);
        },
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, Color color, List<MenuItemModel> items) {
    final favoriteCount = items.where((i) => _favoriteIds.contains(i.id)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: AppFonts.kiranCategory(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$favoriteCount/${items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Items Grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                final isFavorite = _favoriteIds.contains(item.id);
                return _buildItemChip(item, color, isFavorite);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemChip(MenuItemModel item, Color color, bool isFavorite) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleFavorite(item.id),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: isFavorite
                ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                  )
                : null,
            color: isFavorite ? null : surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFavorite ? Colors.transparent : color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFavorite ? Colors.amber : color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  item.itemName,
                  style: AppFonts.kiranText(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isFavorite ? Colors.white : textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '₹${item.rate.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isFavorite ? Colors.white.withValues(alpha: 0.9) : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
