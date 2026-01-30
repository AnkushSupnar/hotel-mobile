import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/features/kitchen/bloc/kitchen_bloc.dart';
import 'package:hotel/features/kitchen/bloc/kitchen_event.dart';
import 'package:hotel/features/kitchen/bloc/kitchen_state.dart';
import 'package:hotel/features/kitchen/data/models/kitchen_order_model.dart';

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = KitchenBloc();
        bloc.add(const LoadKitchenOrders());
        bloc.startAutoRefresh();
        return bloc;
      },
      child: const _KitchenView(),
    );
  }
}

class _KitchenView extends StatelessWidget {
  const _KitchenView();

  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: Column(
        children: [
          _buildAppBar(context),
          _buildFilterTabs(context),
          Expanded(child: _buildBody(context)),
        ],
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
          const Expanded(
            child: Text(
              'Kitchen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.read<KitchenBloc>().add(const LoadKitchenOrders());
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

  Widget _buildFilterTabs(BuildContext context) {
    return BlocBuilder<KitchenBloc, KitchenState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildFilterTab(
                context,
                label: 'All',
                filter: KitchenFilter.all,
                isActive: state.filter == KitchenFilter.all,
              ),
              const SizedBox(width: 8),
              _buildFilterTab(
                context,
                label: 'Pending',
                filter: KitchenFilter.pending,
                isActive: state.filter == KitchenFilter.pending,
                badgeCount: state.totalPendingCount,
              ),
              const SizedBox(width: 8),
              _buildFilterTab(
                context,
                label: 'Ready',
                filter: KitchenFilter.ready,
                isActive: state.filter == KitchenFilter.ready,
                badgeCount: state.totalReadyCount,
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
    required KitchenFilter filter,
    required bool isActive,
    int badgeCount = 0,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<KitchenBloc>().add(ChangeFilter(filter));
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                        color: isActive ? Colors.white : primaryGradientStart,
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
    return BlocConsumer<KitchenBloc, KitchenState>(
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
        if (state.status == KitchenStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryGradientStart,
              strokeWidth: 2,
            ),
          );
        }

        final groups = state.filteredGroups;

        if (state.status == KitchenStatus.success && groups.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<KitchenBloc>();
            bloc.add(const RefreshKitchenOrders());
            await bloc.stream.first.timeout(
              const Duration(seconds: 10),
              onTimeout: () => bloc.state,
            );
          },
          color: primaryGradientStart,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return _buildTableCard(context, groups[index], state);
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
            Icons.soup_kitchen_rounded,
            size: 64,
            color: textMuted.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No kitchen orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here when placed',
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
    TableKitchenOrders tableGroup,
    KitchenState state,
  ) {
    return Container(
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
          // Table header
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
                    color: primaryGradientStart.withValues(alpha: 0.15),
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
                        tableGroup.tableName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        '${tableGroup.orders.length} order${tableGroup.orders.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // KOT items
          ...tableGroup.orders.map(
            (kot) => _buildKotSection(context, kot, state),
          ),
        ],
      ),
    );
  }

  Widget _buildKotSection(
    BuildContext context,
    KitchenOrderModel kot,
    KitchenState state,
  ) {
    final isProcessing = state.processingKotId == kot.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KOT header with status and action
          Row(
            children: [
              Text(
                'KOT #${kot.id}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(kot.status),
              const Spacer(),
              _buildActionButton(context, kot, isProcessing),
            ],
          ),
          const SizedBox(height: 10),
          // Item list
          ...kot.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(KotStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case KotStatus.sent:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        label = 'SENT';
        break;
      case KotStatus.ready:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = 'READY';
        break;
      case KotStatus.serve:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF757575);
        label = 'SERVED';
        break;
      case KotStatus.unknown:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF757575);
        label = 'UNKNOWN';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    KitchenOrderModel kot,
    bool isProcessing,
  ) {
    if (isProcessing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (kot.status == KotStatus.sent) {
      return SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: () {
            context.read<KitchenBloc>().add(MarkKotReady(kot.id));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF38A169),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Ready',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (kot.status == KotStatus.ready) {
      return SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: () {
            context.read<KitchenBloc>().add(MarkKotServed(kot.id));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3182CE),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Serve',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildItemRow(KotItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: primaryGradientStart.withValues(alpha: 0.4),
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
        ],
      ),
    );
  }
}
