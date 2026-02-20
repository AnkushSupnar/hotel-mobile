import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/features/orders/presentation/pages/order_page.dart';
import 'package:hotel/features/orders_overview/bloc/orders_overview_bloc.dart';
import 'package:hotel/features/orders_overview/bloc/orders_overview_event.dart';
import 'package:hotel/features/orders_overview/bloc/orders_overview_state.dart';
import 'package:hotel/features/orders_overview/data/models/table_order_summary.dart';

class OrdersOverviewPage extends StatelessWidget {
  const OrdersOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = OrdersOverviewBloc();
        bloc.add(const LoadOrdersOverview());
        bloc.startAutoRefresh();
        return bloc;
      },
      child: const _OrdersOverviewView(),
    );
  }
}

class _OrdersOverviewView extends StatelessWidget {
  const _OrdersOverviewView();

  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterTabs(context),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return BlocBuilder<OrdersOverviewBloc, OrdersOverviewState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildFilterTab(
                context,
                label: 'All',
                filter: OrdersOverviewFilter.all,
                isActive: state.filter == OrdersOverviewFilter.all,
              ),
              const SizedBox(width: 8),
              _buildFilterTab(
                context,
                label: 'Ongoing',
                filter: OrdersOverviewFilter.ongoing,
                isActive: state.filter == OrdersOverviewFilter.ongoing,
                badgeCount: state.ongoingCount,
              ),
              const SizedBox(width: 8),
              _buildFilterTab(
                context,
                label: 'Closed',
                filter: OrdersOverviewFilter.closed,
                isActive: state.filter == OrdersOverviewFilter.closed,
                badgeCount: state.closedCount,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTab(
    BuildContext context, {
    required String label,
    required OrdersOverviewFilter filter,
    required bool isActive,
    int badgeCount = 0,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context
                .read<OrdersOverviewBloc>()
                .add(ChangeOrdersFilter(filter));
          },
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : textDark,
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.3)
                          : primaryGradientStart.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        fontSize: 11,
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

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<OrdersOverviewBloc, OrdersOverviewState>(
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
        if (state.status == OrdersOverviewStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryGradientStart,
              strokeWidth: 2,
            ),
          );
        }

        final orders = state.filteredOrders;

        if (state.status == OrdersOverviewStatus.success &&
            orders.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<OrdersOverviewBloc>();
            bloc.add(const RefreshOrdersOverview());
            await bloc.stream.first.timeout(
              const Duration(seconds: 10),
              onTimeout: () => bloc.state,
            );
          },
          color: primaryGradientStart,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildTableOrderCard(context, orders[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No active orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here when tables are occupied',
            style: TextStyle(
              fontSize: 14,
              color: textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableOrderCard(
      BuildContext context, TableOrderSummary summary) {
    final isOngoing = summary.table.isOngoing;
    final statusColor =
        isOngoing ? const Color(0xFF38A169) : const Color(0xFFE53E3E);
    final statusLabel = isOngoing ? 'ONGOING' : 'CLOSED';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderPage(
              table: summary.table,
              loadExistingOrders: true,
              isTableClosed: summary.table.isClosed,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryGradientStart.withValues(alpha: 0.08),
                    primaryGradientEnd.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          primaryGradientStart.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.table_bar_rounded,
                      color: primaryGradientStart,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.table.tableName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Text(
                          summary.table.section,
                          style: TextStyle(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${summary.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),
            // Items list
            if (summary.transactions.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: summary.transactions.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: primaryGradientStart
                                  .withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Kiran',
                                color: textDark,
                              ),
                            ),
                          ),
                          Text(
                            'x${item.quantity}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '₹${item.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${summary.totalItems} items (${summary.uniqueItemCount} unique)',
                    style: TextStyle(
                      fontSize: 13,
                      color: textMuted,
                    ),
                  ),
                  Text(
                    '₹${summary.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
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
}
