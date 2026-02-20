import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/constants/font_constants.dart';
import 'package:hotel/features/menu_items/bloc/menu_items_catalog_bloc.dart';
import 'package:hotel/features/menu_items/bloc/menu_items_catalog_event.dart';
import 'package:hotel/features/menu_items/bloc/menu_items_catalog_state.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';

class MenuItemsPage extends StatelessWidget {
  const MenuItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = MenuItemsCatalogBloc();
        bloc.add(const LoadMenuItemsCatalog());
        return bloc;
      },
      child: const _MenuItemsView(),
    );
  }
}

class _MenuItemsView extends StatefulWidget {
  const _MenuItemsView();

  @override
  State<_MenuItemsView> createState() => _MenuItemsViewState();
}

class _MenuItemsViewState extends State<_MenuItemsView> {
  static const Color primaryGradientStart = Color(0xFF667eea);
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

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Color _getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        _buildCategoryTabs(context),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return BlocBuilder<MenuItemsCatalogBloc, MenuItemsCatalogState>(
      buildWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (query) {
              context
                  .read<MenuItemsCatalogBloc>()
                  .add(SearchMenuItems(query));
            },
            style: AppFonts.kiranText(
              fontSize: 20,
              color: textDark,
            ),
            decoration: InputDecoration(
              hintText: 'maalaacao naava ikMvaa kaoD SaaoQaa...',
              hintStyle: AppFonts.kiranText(
                fontSize: 20,
                color: textMuted.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: primaryGradientStart.withValues(alpha: 0.6),
                size: 22,
              ),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: textMuted,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<MenuItemsCatalogBloc>()
                            .add(const SearchMenuItems(''));
                        _searchFocusNode.unfocus();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: primaryGradientStart.withValues(alpha: 0.15),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: primaryGradientStart.withValues(alpha: 0.15),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: primaryGradientStart,
                  width: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return BlocBuilder<MenuItemsCatalogBloc, MenuItemsCatalogState>(
      buildWhen: (prev, curr) =>
          prev.categories != curr.categories ||
          prev.selectedCategoryId != curr.selectedCategoryId ||
          prev.allItems != curr.allItems,
      builder: (context, state) {
        if (state.categories.isEmpty) {
          return const SizedBox(height: 8);
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.categories.length + 1, // +1 for "All" tab
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = state.selectedCategoryId == null;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildCategoryChip(
                    context,
                    label: 'All',
                    count: state.totalItemCount,
                    color: primaryGradientStart,
                    isSelected: isSelected,
                    onTap: () {
                      context
                          .read<MenuItemsCatalogBloc>()
                          .add(const SelectCatalogCategory(null));
                    },
                  ),
                );
              }

              final catIndex = index - 1;
              final category = state.categories[catIndex];
              final isSelected =
                  state.selectedCategoryId == category.id;
              final color = _getCategoryColor(catIndex);
              final count = state.itemCountForCategory(category.id);

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildCategoryChip(
                  context,
                  label: category.name,
                  count: count,
                  color: color,
                  isSelected: isSelected,
                  useKiranFont: true,
                  onTap: () {
                    context
                        .read<MenuItemsCatalogBloc>()
                        .add(SelectCatalogCategory(category.id));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    bool useKiranFont = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)])
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: useKiranFont
                    ? AppFonts.kiranCategory(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color,
                      )
                    : TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color,
                      ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<MenuItemsCatalogBloc, MenuItemsCatalogState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: const Color(0xFFE53E3E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == MenuItemsCatalogStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryGradientStart,
              strokeWidth: 2,
            ),
          );
        }

        if (state.status == MenuItemsCatalogStatus.failure) {
          return _buildErrorState(context);
        }

        final items = state.filteredItems;

        if (state.status == MenuItemsCatalogStatus.success &&
            items.isEmpty) {
          return _buildEmptyState(state);
        }

        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<MenuItemsCatalogBloc>();
            bloc.add(const RefreshMenuItemsCatalog());
            await bloc.stream.first.timeout(
              const Duration(seconds: 10),
              onTimeout: () => bloc.state,
            );
          },
          color: primaryGradientStart,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isFavorite =
                  state.favoriteIds.contains(item.id);
              final catIndex = state.categories
                  .indexWhere((c) => c.id == item.categoryId);
              final color = catIndex >= 0
                  ? _getCategoryColor(catIndex)
                  : primaryGradientStart;

              return _buildItemCard(
                  context, item, color, isFavorite);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load menu items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<MenuItemsCatalogBloc>()
                  .add(const LoadMenuItemsCatalog());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGradientStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(MenuItemsCatalogState state) {
    final isSearching = state.searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching
                ? Icons.search_off_rounded
                : Icons.restaurant_menu_rounded,
            size: 64,
            color: textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No items found' : 'No menu items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term'
                : 'Items will appear here when available',
            style: TextStyle(
              fontSize: 14,
              color: textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    MenuItemModel item,
    Color color,
    bool isFavorite,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Item name + favorite star
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: AppFonts.kiranText(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    context
                        .read<MenuItemsCatalogBloc>()
                        .add(ToggleCatalogFavorite(item.id));
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      key: ValueKey(isFavorite),
                      color: isFavorite
                          ? const Color(0xFFED8936)
                          : textMuted.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Row 2: Item code
            if (item.itemCode.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  item.itemCode,
                  style: TextStyle(
                    fontSize: 11,
                    color: textMuted.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            // Row 3: Category tag + price
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.categoryName,
                      style: AppFonts.kiranCategory(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${item.rate.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
