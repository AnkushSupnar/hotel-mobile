import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/constants/font_constants.dart';
import 'package:hotel/features/orders/bloc/order_bloc.dart';
import 'package:hotel/features/orders/bloc/order_event.dart';
import 'package:hotel/features/orders/bloc/order_state.dart';
import 'package:hotel/features/orders/data/models/menu_item_model.dart';
import 'package:hotel/features/orders/data/models/transaction_item_model.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';
import 'package:hotel/features/tables/data/models/waiter_model.dart';

class OrderPage extends StatelessWidget {
  final DiningTableModel table;
  final WaiterModel? waiter;
  final bool loadExistingOrders;

  const OrderPage({
    super.key,
    required this.table,
    this.waiter,
    this.loadExistingOrders = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderBloc()
        ..add(loadExistingOrders
            ? LoadMenuWithExistingOrders(tableId: table.id)
            : const LoadMenu()),
      child: OrderView(table: table, waiter: waiter),
    );
  }
}

class OrderView extends StatefulWidget {
  final DiningTableModel table;
  final WaiterModel? waiter;

  const OrderView({super.key, required this.table, this.waiter});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  // Modern Material Color Palette
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);
  static const Color successColor = Color(0xFF38A169);
  static const Color accentColor = Color(0xFF3182CE);

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state.status == OrderStatus.submitted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Order sent to kitchen!'),
                  ],
                ),
                backgroundColor: successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildAppBar(context, state),
              _buildCategoryTabs(context, state),
              if (state.hasExistingOrders) _buildExistingOrdersBar(context, state),
              Expanded(
                child: _buildItemsGrid(context, state),
              ),
              _buildOrderSummary(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, OrderState state) {
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showExitConfirmation(context, state),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'New Order',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Table ${widget.table.tableName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Section ${widget.table.section}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    if (widget.waiter != null) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        Icons.person_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.waiter!.fullName,
                        style: AppFonts.kiranText(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (state.orderItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: primaryGradientStart, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${state.totalItems}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryGradientStart,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context, OrderState state) {
    if (state.categories.isEmpty) {
      return const SizedBox(height: 16);
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categories.length + 1, // +1 for Favorites tab
        itemBuilder: (context, index) {
          // First tab is Favorites
          if (index == 0) {
            final isSelected = state.isFavoritesSelected;
            const color = Color(0xFFED8936); // Orange for favorites

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<OrderBloc>().add(const SelectFavoritesCategory());
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)])
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
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
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: isSelected ? Colors.white : color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Favorites',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                        if (state.favoriteItems.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withValues(alpha: 0.3) : color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${state.favoriteItems.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Regular category tabs
          final categoryIndex = index - 1;
          final category = state.categories[categoryIndex];
          final isSelected = state.selectedCategoryId == category.id && !state.isFavoritesSelected;
          final color = categoryColors[categoryIndex % categoryColors.length];

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.read<OrderBloc>().add(SelectCategory(category.id));
                },
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)])
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
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
                  child: Text(
                    category.name,
                    style: AppFonts.kiranCategory(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExistingOrdersBar(BuildContext context, OrderState state) {
    return Container(
      margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            successColor.withValues(alpha: 0.15),
            successColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: successColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showExistingOrdersPreview(context, state),
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: successColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: successColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Existing Orders',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.existingOrdersItemCount} items • ₹${state.existingOrdersTotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: successColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'View',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExistingOrdersPreview(BuildContext context, OrderState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<OrderBloc>(),
        child: _ExistingOrdersSheet(
          tableId: widget.table.id,
          tableNumber: widget.table.tableName,
          sectionName: widget.table.section,
        ),
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, OrderState state) {
    if (state.status == OrderStatus.loading && state.currentItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGradientStart),
      );
    }

    if (state.selectedCategoryId == null && !state.isFavoritesSelected && state.currentItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryGradientStart.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 64,
                color: primaryGradientStart.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select a Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a category above to view items',
              style: TextStyle(fontSize: 14, color: textMuted),
            ),
          ],
        ),
      );
    }

    // Favorites selected but empty
    if (state.isFavoritesSelected && state.currentItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFED8936).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_outline_rounded,
                size: 64,
                color: const Color(0xFFED8936).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorite Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to favorites from Settings',
              style: TextStyle(fontSize: 14, color: textMuted),
            ),
          ],
        ),
      );
    }

    if (state.currentItems.isEmpty) {
      return Center(
        child: Text(
          'No items in this category',
          style: TextStyle(fontSize: 16, color: textMuted),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: state.currentItems.length,
      itemBuilder: (context, index) {
        final item = state.currentItems[index];
        return _buildItemCard(context, state, item);
      },
    );
  }

  Widget _buildItemCard(BuildContext context, OrderState state, MenuItemModel item) {
    final isInOrder = state.isItemInOrder(item.id);
    final isFavorite = state.isItemFavorite(item.id);
    final quantity = state.getItemQuantity(item.id);
    final categoryIndex = state.categories.indexWhere(
      (c) => c.id == item.categoryId,
    );
    final color = categoryIndex >= 0
        ? categoryColors[categoryIndex % categoryColors.length]
        : accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<OrderBloc>().add(AddItemToOrder(item));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isInOrder
                ? Border.all(color: successColor, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: (isInOrder ? successColor : color).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFavorite)
                          Padding(
                            padding: const EdgeInsets.only(right: 4, top: 2),
                            child: Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: const Color(0xFFED8936),
                            ),
                          ),
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
                      ],
                    ),
                  ),
                  if (isInOrder)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: successColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${item.rate.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  if (isInOrder)
                    Row(
                      children: [
                        _buildQuantityButton(
                          context,
                          Icons.remove,
                          () {
                            context.read<OrderBloc>().add(
                                  UpdateItemQuantity(item.id, quantity - 1),
                                );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildQuantityButton(
                          context,
                          Icons.add,
                          () {
                            context.read<OrderBloc>().add(
                                  UpdateItemQuantity(item.id, quantity + 1),
                                );
                          },
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: color,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: textMuted.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: textDark),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, OrderState state) {
    if (state.orderItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order summary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tappable area to preview items
                Expanded(
                  child: InkWell(
                    onTap: () => _showOrderPreview(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${state.totalItems} items',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textMuted,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.visibility_rounded,
                                        size: 14,
                                        color: accentColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Preview',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${state.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Send Order Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [successColor, Color(0xFF2F855A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: successColor.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: state.status == OrderStatus.submitting
                        ? null
                        : () {
                            context.read<OrderBloc>().add(SubmitOrder(
                              tableId: widget.table.id,
                              waiterId: widget.waiter?.id,
                            ));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.status == OrderStatus.submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            children: [
                              Icon(Icons.send_rounded, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Send Order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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

  void _showOrderPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<OrderBloc>(),
        child: _OrderPreviewSheet(
          tableId: widget.table.id,
          waiterId: widget.waiter?.id,
          tableNumber: widget.table.tableName,
          sectionName: widget.table.section,
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, OrderState state) {
    if (state.orderItems.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFD69E2E)),
            SizedBox(width: 12),
            Text('Discard Order?'),
          ],
        ),
        content: Text(
          'You have ${state.totalItems} items in your order. Are you sure you want to discard?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _OrderPreviewSheet extends StatelessWidget {
  final int tableId;
  final int? waiterId;
  final String tableNumber;
  final String sectionName;

  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);
  static const Color successColor = Color(0xFF38A169);

  const _OrderPreviewSheet({
    required this.tableId,
    this.waiterId,
    required this.tableNumber,
    required this.sectionName,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        // Close the sheet if all items are removed
        if (state.orderItems.isEmpty) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryGradientStart, primaryGradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Preview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Table $tableNumber • Section $sectionName',
                            style: TextStyle(
                              fontSize: 14,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: textMuted),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Items list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: state.orderItems.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final orderItem = state.orderItems[index];
                    return _buildOrderItemRow(context, state, orderItem, index);
                  },
                ),
              ),
              // Footer with total and send button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      // Summary row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total (${state.totalItems} items)',
                            style: TextStyle(
                              fontSize: 16,
                              color: textMuted,
                            ),
                          ),
                          Text(
                            '₹${state.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Send Order Button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [successColor, Color(0xFF2F855A)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: successColor.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: state.status == OrderStatus.submitting
                                ? null
                                : () {
                                    context.read<OrderBloc>().add(SubmitOrder(
                                      tableId: tableId,
                                      waiterId: waiterId,
                                    ));
                                    Navigator.of(context).pop();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: state.status == OrderStatus.submitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send_rounded, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text(
                                        'Send Order to Kitchen',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItemRow(BuildContext context, OrderState state, OrderItemModel orderItem, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Serial number
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: primaryGradientStart.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryGradientStart,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Item details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderItem.item.itemName,
                style: AppFonts.kiranText(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${orderItem.item.rate.toStringAsFixed(0)} × ${orderItem.quantity}',
                style: TextStyle(
                  fontSize: 14,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
        // Quantity controls
        Row(
          children: [
            _buildQuantityButton(
              context,
              Icons.remove,
              () {
                context.read<OrderBloc>().add(
                      UpdateItemQuantity(orderItem.item.id, orderItem.quantity - 1),
                    );
              },
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${orderItem.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ),
            _buildQuantityButton(
              context,
              Icons.add,
              () {
                context.read<OrderBloc>().add(
                      UpdateItemQuantity(orderItem.item.id, orderItem.quantity + 1),
                    );
              },
            ),
          ],
        ),
        const SizedBox(width: 16),
        // Item total
        SizedBox(
          width: 70,
          child: Text(
            '₹${orderItem.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: textMuted.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: textDark),
        ),
      ),
    );
  }
}

class _ExistingOrdersSheet extends StatelessWidget {
  final int tableId;
  final String tableNumber;
  final String sectionName;

  static const Color successColor = Color(0xFF38A169);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);

  const _ExistingOrdersSheet({
    required this.tableId,
    required this.tableNumber,
    required this.sectionName,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        // Show success message when update is submitted
        if (state.status == OrderStatus.submitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Order updated successfully!'),
                ],
              ),
              backgroundColor: successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final transactions = state.existingTransactions;
        final totalAmount = state.existingOrdersTotal;
        final totalItems = state.existingOrdersItemCount;

        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [successColor, successColor.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Existing Orders',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Table $tableNumber • Section $sectionName',
                            style: TextStyle(
                              fontSize: 14,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: textMuted),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Items list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    return _buildTransactionItemRow(context, item, index);
                  },
                ),
              ),
              // Footer with total and Send Order button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Summary row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total ($totalItems items)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textMuted,
                                ),
                              ),
                              if (state.hasModifiedTransactions)
                                Text(
                                  '${state.modifiedTransactionIds.length} items modified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: successColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: successColor,
                            ),
                          ),
                        ],
                      ),
                      if (state.hasModifiedTransactions || state.modifiedTransactionIds.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Send Order Button
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [successColor, Color(0xFF2F855A)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: successColor.withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: state.status == OrderStatus.submitting
                                  ? null
                                  : () {
                                      context.read<OrderBloc>().add(
                                            SubmitUpdatedTransactions(tableId: tableId),
                                          );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: state.status == OrderStatus.submitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded, color: Colors.white),
                                        SizedBox(width: 10),
                                        Text(
                                          'Update Order',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionItemRow(BuildContext context, TransactionItemModel item, int index) {
    final isRemoved = item.quantity == 0;
    final displayColor = isRemoved ? textMuted.withValues(alpha: 0.5) : textDark;
    final itemAmount = item.quantity * item.rate;

    return Opacity(
      opacity: isRemoved ? 0.5 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Serial number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isRemoved
                  ? Colors.red.withValues(alpha: 0.1)
                  : successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: isRemoved
                  ? Icon(Icons.remove_circle_outline, size: 16, color: Colors.red.withValues(alpha: 0.7))
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: successColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: AppFonts.kiranText(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: displayColor,
                    decoration: isRemoved ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.rate.toStringAsFixed(0)} × ${item.quantity}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isRemoved ? textMuted.withValues(alpha: 0.5) : textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Row(
            children: [
              _buildQuantityButton(
                context,
                Icons.remove,
                isRemoved
                    ? null
                    : () {
                        context.read<OrderBloc>().add(
                              UpdateExistingTransactionQuantity(item.id, item.quantity - 1),
                            );
                      },
                disabled: isRemoved,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: displayColor,
                  ),
                ),
              ),
              _buildQuantityButton(
                context,
                Icons.add,
                () {
                  context.read<OrderBloc>().add(
                        UpdateExistingTransactionQuantity(item.id, item.quantity + 1),
                      );
                },
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Item total
          SizedBox(
            width: 70,
            child: Text(
              '₹${itemAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: displayColor,
                decoration: isRemoved ? TextDecoration.lineThrough : null,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    VoidCallback? onTap, {
    bool disabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: disabled
                ? textMuted.withValues(alpha: 0.05)
                : textMuted.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: disabled ? textMuted.withValues(alpha: 0.3) : textDark,
          ),
        ),
      ),
    );
  }
}
