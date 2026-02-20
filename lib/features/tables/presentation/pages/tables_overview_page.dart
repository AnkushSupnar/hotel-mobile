import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/services/bill_cache_service.dart';
import 'package:hotel/core/services/waiter_storage_service.dart';
import 'package:hotel/core/constants/font_constants.dart';
import 'package:hotel/features/orders/presentation/pages/order_page.dart';
import 'package:hotel/features/tables/bloc/table_selection_bloc.dart';
import 'package:hotel/features/tables/bloc/table_selection_event.dart';
import 'package:hotel/features/tables/bloc/table_selection_state.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';
import 'package:hotel/features/tables/data/models/waiter_model.dart';
import 'package:hotel/features/tables/presentation/pages/bill_preview_page.dart';

enum TableStatusFilter { all, available, ongoing, closed }

class TablesOverviewPage extends StatelessWidget {
  const TablesOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = TableSelectionBloc();
        bloc.add(const LoadTables(forceRefresh: true));
        return bloc;
      },
      child: const _TablesOverviewView(),
    );
  }
}

class _TablesOverviewView extends StatefulWidget {
  const _TablesOverviewView();

  @override
  State<_TablesOverviewView> createState() => _TablesOverviewViewState();
}

class _TablesOverviewViewState extends State<_TablesOverviewView> {
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);
  static const Color favoriteColor = Color(0xFFED8936);

  static const List<Color> sectionColors = [
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

  TableStatusFilter _statusFilter = TableStatusFilter.all;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        if (mounted) {
          context
              .read<TableSelectionBloc>()
              .add(const LoadTables(forceRefresh: true));
        }
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  List<DiningTableModel> _getAllTables(TableSelectionState state) {
    return state.sections.expand((s) => s.tables).toList();
  }

  List<DiningTableModel> _getFilteredTables(TableSelectionState state) {
    var tables = _getAllTables(state);

    // Apply section filter
    if (state.selectedSection != null &&
        state.selectedSection != TableSelectionState.favoritesSection) {
      tables = tables
          .where((t) => t.section == state.selectedSection)
          .toList();
    } else if (state.selectedSection ==
        TableSelectionState.favoritesSection) {
      tables = state.favoriteTables;
    }

    // Apply status filter
    switch (_statusFilter) {
      case TableStatusFilter.all:
        break;
      case TableStatusFilter.available:
        tables = tables.where((t) => t.isAvailable).toList();
        break;
      case TableStatusFilter.ongoing:
        tables = tables.where((t) => t.isOngoing).toList();
        break;
      case TableStatusFilter.closed:
        tables = tables.where((t) => t.isClosed).toList();
        break;
    }

    return tables;
  }

  int _countByStatus(
      TableSelectionState state, bool Function(DiningTableModel) test) {
    return _getAllTables(state).where(test).length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusFilterTabs(context),
        _buildSectionTabs(context),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildStatusFilterTabs(BuildContext context) {
    return BlocBuilder<TableSelectionBloc, TableSelectionState>(
      buildWhen: (prev, curr) =>
          prev.sections != curr.sections || prev.status != curr.status,
      builder: (context, state) {
        final ongoingCount =
            _countByStatus(state, (t) => t.isOngoing);
        final closedCount =
            _countByStatus(state, (t) => t.isClosed);
        final availableCount =
            _countByStatus(state, (t) => t.isAvailable);

        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildStatusTab(
                label: 'All',
                filter: TableStatusFilter.all,
                isActive: _statusFilter == TableStatusFilter.all,
              ),
              const SizedBox(width: 8),
              _buildStatusTab(
                label: 'Free',
                filter: TableStatusFilter.available,
                isActive: _statusFilter == TableStatusFilter.available,
                badgeCount: availableCount,
              ),
              const SizedBox(width: 8),
              _buildStatusTab(
                label: 'Ongoing',
                filter: TableStatusFilter.ongoing,
                isActive: _statusFilter == TableStatusFilter.ongoing,
                badgeCount: ongoingCount,
              ),
              const SizedBox(width: 8),
              _buildStatusTab(
                label: 'Closed',
                filter: TableStatusFilter.closed,
                isActive: _statusFilter == TableStatusFilter.closed,
                badgeCount: closedCount,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTab({
    required String label,
    required TableStatusFilter filter,
    required bool isActive,
    int badgeCount = 0,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _statusFilter = filter),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? primaryGradientStart : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? primaryGradientStart.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : textDark,
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.3)
                          : primaryGradientStart
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.white
                            : primaryGradientStart,
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

  Widget _buildSectionTabs(BuildContext context) {
    return BlocBuilder<TableSelectionBloc, TableSelectionState>(
      buildWhen: (prev, curr) =>
          prev.sections != curr.sections ||
          prev.selectedSection != curr.selectedSection ||
          prev.favoriteTables != curr.favoriteTables,
      builder: (context, state) {
        if (state.sections.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 46,
          margin: const EdgeInsets.only(bottom: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount:
                state.sections.length + 2, // All + Favorites + sections
            itemBuilder: (context, index) {
              // "All" tab
              if (index == 0) {
                final isSelected = state.selectedSection == null;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildSectionChip(
                    context,
                    label: 'All',
                    color: primaryGradientStart,
                    isSelected: isSelected,
                    onTap: () {
                      context
                          .read<TableSelectionBloc>()
                          .add(const SelectSection(null));
                    },
                  ),
                );
              }

              // Favorites tab
              if (index == 1) {
                final isSelected = state.selectedSection ==
                    TableSelectionState.favoritesSection;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildSectionChip(
                    context,
                    label: 'Favorites',
                    icon: Icons.star_rounded,
                    color: favoriteColor,
                    isSelected: isSelected,
                    count: state.favoriteTables.length,
                    onTap: () {
                      context.read<TableSelectionBloc>().add(
                            const SelectSection(
                                TableSelectionState.favoritesSection),
                          );
                    },
                  ),
                );
              }

              // Section tabs
              final secIndex = index - 2;
              final section = state.sections[secIndex];
              final isSelected =
                  state.selectedSection == section.name;
              final color =
                  sectionColors[secIndex % sectionColors.length];

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildSectionChip(
                  context,
                  label: section.name,
                  color: color,
                  isSelected: isSelected,
                  count: section.tables.length,
                  onTap: () {
                    context
                        .read<TableSelectionBloc>()
                        .add(SelectSection(section.name));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionChip(
    BuildContext context, {
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    int? count,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)])
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.3)
                        : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
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
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<TableSelectionBloc, TableSelectionState>(
      listenWhen: (prev, curr) =>
          (prev.closingTableId != null &&
              curr.closingTableId == null) ||
          (prev.closedTablePdfBytes == null &&
              curr.closedTablePdfBytes != null),
      listener: (context, state) {
        if (state.closedTablePdfBytes != null) {
          final pdfBytes = state.closedTablePdfBytes!;
          final tableName = state.closedTableName ?? '';
          final billNo = state.closedTableBillNo ?? 0;
          final netAmount = state.closedTableNetAmount ?? 0.0;
          final tableId = state.closedTableId ?? 0;
          context
              .read<TableSelectionBloc>()
              .add(const ClearClosedTablePdf());
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

        if (state.errorMessage != null &&
            state.errorMessage!.contains('close table')) {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state.closingTableId == null &&
            state.closedTablePdfBytes == null) {
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == TableSelectionStatus.loading &&
            state.sections.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryGradientStart,
              strokeWidth: 2,
            ),
          );
        }

        if (state.status == TableSelectionStatus.failure &&
            state.sections.isEmpty) {
          return _buildErrorState(context, state);
        }

        final tables = _getFilteredTables(state);

        if (tables.isEmpty) {
          return _buildEmptyState();
        }

        final screenWidth = MediaQuery.sizeOf(context).width;
        final crossAxisCount = screenWidth < 320 ? 2 : 3;
        final childAspectRatio = screenWidth < 360
            ? 0.85
            : (screenWidth < 400 ? 0.92 : 1.0);

        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<TableSelectionBloc>();
            bloc.add(const RefreshTables());
            await bloc.stream.first.timeout(
              const Duration(seconds: 10),
              onTimeout: () => bloc.state,
            );
          },
          color: primaryGradientStart,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              return _buildTableCard(
                  context, state, tables[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
      BuildContext context, TableSelectionState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 64, color: textMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            state.errorMessage ?? 'Failed to load tables',
            style: TextStyle(color: textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<TableSelectionBloc>()
                  .add(const LoadTables());
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

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_statusFilter) {
      case TableStatusFilter.available:
        message = 'No free tables right now';
        icon = Icons.event_busy_rounded;
        break;
      case TableStatusFilter.ongoing:
        message = 'No ongoing tables';
        icon = Icons.table_bar_rounded;
        break;
      case TableStatusFilter.closed:
        message = 'No closed tables';
        icon = Icons.lock_rounded;
        break;
      case TableStatusFilter.all:
        message = 'No tables found';
        icon = Icons.table_bar_rounded;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: textMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 14,
              color: textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(
    BuildContext context,
    TableSelectionState state,
    DiningTableModel table,
  ) {
    final isFavorite = state.isFavorite(table.id);
    final isOngoing = table.isOngoing;
    final isClosed = table.isClosed;
    final isClosing = state.isClosingTable(table.id);

    // Determine section color
    final sectionIndex =
        state.sections.indexWhere((s) => s.name == table.section);
    final sectionColor = sectionIndex >= 0
        ? sectionColors[sectionIndex % sectionColors.length]
        : primaryGradientStart;

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
            _navigateToClosedTable(context, table);
          } else if (table.isAvailable) {
            _showStartOrderDialog(context, table, sectionColor);
          } else {
            _navigateToExistingOrder(context, table);
          }
        },
        onLongPress:
            isOngoing ? () => _showCloseTableDialog(context, table) : null,
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
                  if (isFavorite)
                    Positioned(
                      top: posOffset,
                      right: posOffset,
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: starIconSize,
                      ),
                    ),
                  if (isOngoing)
                    Positioned(
                      top: posOffset,
                      left: posOffset,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isClosing
                              ? null
                              : () => _showCloseTableDialog(
                                  context, table),
                          borderRadius:
                              BorderRadius.circular(posOffset + 2),
                          child: Container(
                            padding: EdgeInsets.all(smallPad),
                            decoration: BoxDecoration(
                              color:
                                  Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  posOffset + 2),
                            ),
                            child: isClosing
                                ? SizedBox(
                                    width: smallIconSize,
                                    height: smallIconSize,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red.shade400,
                                    ),
                                  )
                                : Icon(
                                    Icons
                                        .lock_outline_rounded,
                                    color:
                                        Colors.red.shade400,
                                    size: smallIconSize,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  if (isClosed)
                    Positioned(
                      top: posOffset,
                      left: posOffset,
                      child: Container(
                        padding: EdgeInsets.all(smallPad),
                        decoration: BoxDecoration(
                          color:
                              Colors.red.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(posOffset + 2),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: Colors.red.shade400,
                          size: smallIconSize,
                        ),
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: w * 0.06,
                        vertical: h * 0.04,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding:
                                  EdgeInsets.all(iconPadding),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: (isOngoing || isClosed)
                                      ? [
                                          iconColor.withValues(
                                              alpha: 0.3),
                                          iconColor.withValues(
                                              alpha: 0.15),
                                        ]
                                      : [
                                          sectionColor.withValues(
                                              alpha: 0.15),
                                          sectionColor.withValues(
                                              alpha: 0.05),
                                        ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                        iconRadius),
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
                            SizedBox(height: h * 0.02),
                            Text(
                              table.section,
                              style: TextStyle(
                                fontSize: statusFontSize,
                                color: textMuted,
                              ),
                            ),
                            SizedBox(height: h * 0.03),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: badgeHPad,
                                vertical: smallPad,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(
                                    alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(
                                        badgeRadius),
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
      BuildContext context, DiningTableModel table) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderPage(
          table: table,
          loadExistingOrders: true,
        ),
      ),
    );
  }

  void _navigateToClosedTable(
      BuildContext context, DiningTableModel table) {
    final cachedBill = BillCacheService.getCachedBill(table.id);
    if (cachedBill != null) {
      final pdfBase64 = cachedBill['pdfBase64'] as String;
      final pdfBytes = base64Decode(pdfBase64);
      final tableName = cachedBill['tableName'] as String;
      final billNo = cachedBill['billNo'] as int;
      final netAmount =
          (cachedBill['netAmount'] as num).toDouble();
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
      BuildContext context, DiningTableModel table) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock_outline_rounded,
                color: Colors.red.shade400),
            const SizedBox(width: 12),
            const Text('Close Table?'),
          ],
        ),
        content: Text(
          'Are you sure you want to close Table ${table.tableName}? This will finalize the bill.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<TableSelectionBloc>()
                  .add(CloseTable(table.id, table.tableName));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Close Table',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showStartOrderDialog(
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
              builder: (_) =>
                  OrderPage(table: table, waiter: waiter),
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
    final waiters =
        await WaiterStorageService.getWaitersWithFallback();
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.sectionColor,
                  widget.sectionColor.withValues(alpha: 0.8)
                ],
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
            style: TextStyle(fontSize: 14, color: textMuted),
          ),
          const SizedBox(height: 20),
          _buildWaiterDropdown(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                        color: textMuted.withValues(alpha: 0.3)),
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
                      colors: [
                        widget.sectionColor,
                        widget.sectionColor
                            .withValues(alpha: 0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.sectionColor
                            .withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () =>
                        widget.onStartOrder(_selectedWaiter),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
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
                valueColor: AlwaysStoppedAnimation<Color>(
                    widget.sectionColor),
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
