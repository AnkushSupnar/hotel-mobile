import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/constants/font_constants.dart';
import 'package:hotel/core/services/bill_cache_service.dart';
import 'package:hotel/core/services/waiter_storage_service.dart';
import 'package:hotel/features/orders/presentation/pages/order_page.dart';
import 'package:hotel/features/tables/bloc/table_selection_bloc.dart';
import 'package:hotel/features/tables/bloc/table_selection_event.dart';
import 'package:hotel/features/tables/bloc/table_selection_state.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';
import 'package:hotel/features/tables/data/models/waiter_model.dart';
import 'package:hotel/features/tables/presentation/pages/bill_preview_page.dart';

class TableSelectionPage extends StatelessWidget {
  final bool showOnlyActive;

  const TableSelectionPage({super.key, this.showOnlyActive = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TableSelectionBloc()..add(const LoadTables()),
      child: TableSelectionView(showOnlyActive: showOnlyActive),
    );
  }
}

class TableSelectionView extends StatelessWidget {
  final bool showOnlyActive;

  const TableSelectionView({super.key, this.showOnlyActive = false});

  // Modern Material Color Palette
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);
  static const Color favoriteColor = Color(0xFFED8936);

  // Section colors
  static const List<Color> sectionColors = [
    Color(0xFF667eea), // Purple
    Color(0xFF38A169), // Green
    Color(0xFF3182CE), // Blue
    Color(0xFFD69E2E), // Yellow
    Color(0xFFE53E3E), // Red
    Color(0xFF805AD5), // Violet
    Color(0xFF00B5D8), // Cyan
    Color(0xFFED64A6), // Pink
    Color(0xFFDD6B20), // Orange
    Color(0xFF319795), // Teal
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: BlocListener<TableSelectionBloc, TableSelectionState>(
        listenWhen: (previous, current) =>
            (previous.closingTableId != null && current.closingTableId == null) ||
            (previous.closedTablePdfBytes == null && current.closedTablePdfBytes != null),
        listener: (context, state) {
          // Show PDF bill preview if available
          if (state.closedTablePdfBytes != null) {
            final pdfBytes = state.closedTablePdfBytes!;
            final tableName = state.closedTableName ?? '';
            final billNo = state.closedTableBillNo ?? 0;
            final netAmount = state.closedTableNetAmount ?? 0.0;
            final tableId = state.closedTableId ?? 0;
            // Clear the PDF from state before navigating
            context.read<TableSelectionBloc>().add(const ClearClosedTablePdf());
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BillPreviewPage(
                  pdfBytes: pdfBytes,
                  tableName: tableName,
                  billNo: billNo,
                  netAmount: netAmount,
                  tableId: tableId,
                ),
              ),
            );
            return;
          }

          if (state.errorMessage != null && state.errorMessage!.contains('close table')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          } else if (state.closingTableId == null && state.closedTablePdfBytes == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Table closed successfully'),
                  ],
                ),
                backgroundColor: const Color(0xFF38A169),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocBuilder<TableSelectionBloc, TableSelectionState>(
              builder: (context, state) {
                if (state.status == TableSelectionStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryGradientStart,
                    ),
                  );
                }

                if (state.status == TableSelectionStatus.failure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? 'Failed to load tables',
                          style: TextStyle(color: textMuted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<TableSelectionBloc>().add(const LoadTables());
                          },
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

                if (showOnlyActive) {
                  return _buildActiveTablesGrid(context, state);
                }

                return Column(
                  children: [
                    _buildSectionTabs(context, state),
                    Expanded(
                      child: _buildTableGrid(context, state),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
                Text(
                  showOnlyActive ? 'Active Tables' : 'Select Table',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  showOnlyActive
                      ? 'Tap a table to manage orders'
                      : 'Choose a table to start new order',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Refresh Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.read<TableSelectionBloc>().add(const RefreshTables());
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs(BuildContext context, TableSelectionState state) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.sections.length + 1, // +1 for Favorites
        itemBuilder: (context, index) {
          // First tab is always Favorites
          if (index == 0) {
            final isSelected = state.selectedSection == TableSelectionState.favoritesSection;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<TableSelectionBloc>().add(
                      const SelectSection(TableSelectionState.favoritesSection),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [favoriteColor, favoriteColor.withValues(alpha: 0.8)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : favoriteColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: favoriteColor.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: isSelected ? Colors.white : favoriteColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Favorites',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : favoriteColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : favoriteColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${state.favoriteTables.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : favoriteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final section = state.sections[index - 1];
          final isSelected = state.selectedSection == section.name;
          final color = sectionColors[(index - 1) % sectionColors.length];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.read<TableSelectionBloc>().add(SelectSection(section.name));
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [color, color.withValues(alpha: 0.8)],
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        section.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${section.tables.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableGrid(BuildContext context, TableSelectionState state) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = screenWidth < 320 ? 2 : 3;
    final childAspectRatio = screenWidth < 360 ? 0.85 : (screenWidth < 400 ? 0.92 : 1.0);

    // Show favorites when no section selected or Favorites section selected
    if (state.selectedSection == null || state.selectedSection == TableSelectionState.favoritesSection) {
      if (state.favoriteTables.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: favoriteColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_outline_rounded,
                  size: 64,
                  color: favoriteColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Favorite Tables',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Add your frequently used tables to favorites from Settings > Favorite Tables',
                  style: TextStyle(
                    fontSize: 14,
                    color: textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Or select a section above',
                style: TextStyle(
                  fontSize: 13,
                  color: textMuted.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      }

      // Show favorites grid
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: state.favoriteTables.length,
        itemBuilder: (context, index) {
          final table = state.favoriteTables[index];
          return _buildTableCard(context, state, table, favoriteColor, isFavoriteSection: true);
        },
      );
    }

    final tables = state.currentSectionTables;
    final sectionIndex = state.sections.indexWhere((s) => s.name == state.selectedSection);
    final sectionColor = sectionColors[sectionIndex % sectionColors.length];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return _buildTableCard(context, state, table, sectionColor);
      },
    );
  }

  Widget _buildActiveTablesGrid(BuildContext context, TableSelectionState state) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = screenWidth < 320 ? 2 : 3;
    final childAspectRatio = screenWidth < 360 ? 0.85 : (screenWidth < 400 ? 0.92 : 1.0);

    final activeTables = state.sections
        .expand((s) => s.tables)
        .where((t) => t.isOngoing)
        .toList();

    if (activeTables.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF38A169).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.table_bar_rounded,
                size: 64,
                color: const Color(0xFF38A169).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Tables',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no tables with ongoing orders right now',
              style: TextStyle(
                fontSize: 14,
                color: textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: activeTables.length,
      itemBuilder: (context, index) {
        final table = activeTables[index];
        return _buildTableCard(context, state, table, const Color(0xFF38A169));
      },
    );
  }

  Widget _buildTableCard(
    BuildContext context,
    TableSelectionState state,
    DiningTableModel table,
    Color sectionColor, {
    bool isFavoriteSection = false,
  }) {
    final isFavorite = state.isFavorite(table.id);
    final isAvailable = table.isAvailable;
    final isOngoing = table.isOngoing;
    final isClosed = table.isClosed;
    final isClosing = state.isClosingTable(table.id);

    // Status color: green for ongoing, red for closed, section color for available
    final Color statusColor;
    final Color cardColor;
    final Color borderColor;
    final Color iconColor;
    final Color nameColor;

    if (isClosed) {
      statusColor = Colors.red;
      cardColor = Colors.red.withValues(alpha: 0.08);
      borderColor = Colors.red.shade300;
      iconColor = Colors.red.shade400;
      nameColor = Colors.red.shade700;
    } else if (isOngoing) {
      statusColor = const Color(0xFF38A169);
      cardColor = const Color(0xFF38A169).withValues(alpha: 0.15);
      borderColor = const Color(0xFF38A169);
      iconColor = const Color(0xFF38A169);
      nameColor = const Color(0xFF2F855A);
    } else {
      statusColor = sectionColor;
      cardColor = Colors.white;
      borderColor = Colors.transparent;
      iconColor = sectionColor;
      nameColor = textDark;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isClosed) {
            // Navigate to read-only order view for closed tables
            _navigateToClosedTableOrder(context, table);
          } else if (isAvailable) {
            _showTableSelectedDialog(context, table, sectionColor);
          } else {
            // Navigate to order page with existing orders
            _navigateToExistingOrder(context, table, sectionColor);
          }
        },
        onLongPress: isOngoing ? () => _showCloseTableDialog(context, table) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: (isOngoing || isClosed)
                ? Border.all(color: borderColor, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: (isOngoing || isClosed)
                    ? borderColor.withValues(alpha: 0.25)
                    : sectionColor.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              // Scale all dimensions relative to card size
              final iconSize = (w * 0.26).clamp(16.0, 32.0);
              final iconPadding = (w * 0.13).clamp(8.0, 16.0);
              final iconRadius = (w * 0.15).clamp(10.0, 18.0);
              final nameFontSize = (w * 0.15).clamp(10.0, 18.0);
              final statusFontSize = (w * 0.094).clamp(7.0, 12.0);
              final smallIconSize = (w * 0.15).clamp(12.0, 18.0);
              final starIconSize = (w * 0.16).clamp(12.0, 20.0);
              final posOffset = (w * 0.06).clamp(4.0, 8.0);
              final smallPad = (w * 0.035).clamp(2.0, 5.0);
              final badgeHPad = (w * 0.09).clamp(6.0, 12.0);
              final badgeRadius = (w * 0.075).clamp(6.0, 10.0);

              return Stack(
                children: [
                  // Favorite indicator
                  if (isFavorite && !isFavoriteSection)
                    Positioned(
                      top: posOffset,
                      right: posOffset,
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: starIconSize,
                      ),
                    ),
                  // Close button for ongoing tables
                  if (isOngoing)
                    Positioned(
                      top: posOffset,
                      left: posOffset,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isClosing
                              ? null
                              : () => _showCloseTableDialog(context, table),
                          borderRadius: BorderRadius.circular(posOffset + 2),
                          child: Container(
                            padding: EdgeInsets.all(smallPad),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(posOffset + 2),
                            ),
                            child: isClosing
                                ? SizedBox(
                                    width: smallIconSize,
                                    height: smallIconSize,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red.shade400,
                                    ),
                                  )
                                : Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.red.shade400,
                                    size: smallIconSize,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  // Closed lock icon
                  if (isClosed)
                    Positioned(
                      top: posOffset,
                      left: posOffset,
                      child: Container(
                        padding: EdgeInsets.all(smallPad),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(posOffset + 2),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.red.shade400,
                          size: smallIconSize,
                        ),
                      ),
                    ),
                  // Table content
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.06,
                        vertical: h * 0.04,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(iconPadding),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: (isOngoing || isClosed)
                                      ? [
                                          iconColor.withValues(alpha: 0.3),
                                          iconColor.withValues(alpha: 0.15),
                                        ]
                                      : [
                                          sectionColor.withValues(alpha: 0.15),
                                          sectionColor.withValues(alpha: 0.05),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(iconRadius),
                              ),
                              child: Icon(
                                Icons.table_bar_rounded,
                                color: iconColor,
                                size: iconSize,
                              ),
                            ),
                            SizedBox(height: h * 0.06),
                            Text(
                              table.tableName,
                              style: TextStyle(
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.bold,
                                color: nameColor,
                              ),
                              maxLines: 1,
                            ),
                            SizedBox(height: h * 0.03),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: badgeHPad,
                                vertical: smallPad,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(badgeRadius),
                              ),
                              child: Text(
                                table.status,
                                style: TextStyle(
                                  fontSize: statusFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToExistingOrder(
    BuildContext context,
    DiningTableModel table,
    Color sectionColor,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderPage(
          table: table,
          loadExistingOrders: true,
        ),
      ),
    );
  }

  void _navigateToClosedTableOrder(
    BuildContext context,
    DiningTableModel table,
  ) {
    // Check if we have a cached bill for this closed table
    final cachedBill = BillCacheService.getCachedBill(table.id);
    if (cachedBill != null) {
      final pdfBase64 = cachedBill['pdfBase64'] as String;
      final pdfBytes = base64Decode(pdfBase64);
      final tableName = cachedBill['tableName'] as String;
      final billNo = cachedBill['billNo'] as int;
      final netAmount = (cachedBill['netAmount'] as num).toDouble();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BillPreviewPage(
            pdfBytes: pdfBytes,
            tableName: tableName,
            billNo: billNo,
            netAmount: netAmount,
            tableId: table.id,
          ),
        ),
      );
      return;
    }

    // No cached bill — show read-only order view
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderPage(
          table: table,
          loadExistingOrders: true,
          isTableClosed: true,
        ),
      ),
    );
  }

  void _showCloseTableDialog(
    BuildContext context,
    DiningTableModel table,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: Colors.red.shade400),
            const SizedBox(width: 12),
            const Text('Close Table?'),
          ],
        ),
        content: Text(
          'Are you sure you want to close Table ${table.tableName}? This will finalize the bill and no further changes can be made.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TableSelectionBloc>().add(CloseTable(table.id, table.tableName));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Close Table', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTableSelectedDialog(
    BuildContext context,
    DiningTableModel table,
    Color sectionColor,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => _StartOrderDialog(
        table: table,
        sectionColor: sectionColor,
        onStartOrder: (waiter) {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderPage(table: table, waiter: waiter),
            ),
          );
        },
      ),
    );
  }
}

class _StartOrderDialog extends StatefulWidget {
  final DiningTableModel table;
  final Color sectionColor;
  final Function(WaiterModel?) onStartOrder;

  const _StartOrderDialog({
    required this.table,
    required this.sectionColor,
    required this.onStartOrder,
  });

  @override
  State<_StartOrderDialog> createState() => _StartOrderDialogState();
}

class _StartOrderDialogState extends State<_StartOrderDialog> {
  static const Color textMuted = Color(0xFF718096);

  List<WaiterModel> _waiters = [];
  WaiterModel? _selectedWaiter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWaiters();
  }

  Future<void> _loadWaiters() async {
    final waiters = await WaiterStorageService.getWaitersWithFallback();
    if (mounted) {
      setState(() {
        _waiters = waiters;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.sectionColor, widget.sectionColor.withValues(alpha: 0.8)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.table_bar_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Table ${widget.table.tableName}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Section ${widget.table.section}',
            style: TextStyle(
              fontSize: 14,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 20),
          // Waiter Dropdown
          _buildWaiterDropdown(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: textMuted.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.sectionColor, widget.sectionColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.sectionColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => widget.onStartOrder(_selectedWaiter),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaiterDropdown() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(widget.sectionColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading waiters...',
              style: TextStyle(color: textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.sectionColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WaiterModel>(
          isExpanded: true,
          value: _selectedWaiter,
          hint: Text(
            'vaoTr inavaDa',
            style: AppFonts.kiranText(
              fontSize: 20,
              color: textMuted,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: widget.sectionColor,
            size: 28,
          ),
          items: _waiters.map((waiter) {
            return DropdownMenuItem<WaiterModel>(
              value: waiter,
              child: Text(
                waiter.fullName,
                style: AppFonts.kiranText(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A202C),
                ),
              ),
            );
          }).toList(),
          onChanged: (waiter) {
            setState(() {
              _selectedWaiter = waiter;
            });
          },
        ),
      ),
    );
  }
}
