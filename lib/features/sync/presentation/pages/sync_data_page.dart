import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/features/sync/bloc/sync_data_bloc.dart';
import 'package:hotel/features/sync/bloc/sync_data_event.dart';
import 'package:hotel/features/sync/bloc/sync_data_state.dart';

class SyncDataPage extends StatefulWidget {
  const SyncDataPage({super.key});

  @override
  State<SyncDataPage> createState() => _SyncDataPageState();
}

class _SyncDataPageState extends State<SyncDataPage> {
  late final SyncDataBloc _syncBloc;

  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    _syncBloc = SyncDataBloc();
  }

  @override
  void dispose() {
    _syncBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncDataBloc, SyncDataState>(
      bloc: _syncBloc,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(state),
              const SizedBox(height: 24),
              const Text(
                'Data Sources',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),
              ...state.items.asMap().entries.map(
                    (entry) => _buildSyncItemCard(entry.key, entry.value, state),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(SyncDataState state) {
    final progressText = state.isSyncing
        ? 'Syncing ${state.completedCount + 1}/${state.items.length}...'
        : state.completedCount > 0
            ? '${state.completedCount}/${state.items.length} synced${state.failedCount > 0 ? ', ${state.failedCount} failed' : ''}'
            : 'Tap below to refresh cached data';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF805AD5), Color(0xFF667eea)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF805AD5).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync Data',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progressText,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isSyncing
                  ? null
                  : () => _syncBloc.add(const StartFullSync()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                foregroundColor: const Color(0xFF805AD5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isSyncing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF805AD5)),
                      ),
                    )
                  else
                    const Icon(Icons.sync_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    state.isSyncing
                        ? 'Syncing ${state.completedCount + 1}/${state.items.length}...'
                        : 'Sync All',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncItemCard(int index, SyncItemState item, SyncDataState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.color.withValues(alpha: 0.2),
                    item.color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const SizedBox(width: 16),
            // Name + status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(item),
                    style: TextStyle(
                      fontSize: 13,
                      color: _getStatusTextColor(item),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Status indicator
            _buildStatusIndicator(index, item, state),
          ],
        ),
      ),
    );
  }

  String _getStatusText(SyncItemState item) {
    switch (item.status) {
      case SyncItemStatus.pending:
        return 'Waiting...';
      case SyncItemStatus.syncing:
        return 'Syncing...';
      case SyncItemStatus.completed:
        return '${item.itemCount} items synced';
      case SyncItemStatus.failed:
        return 'Failed: ${item.errorMessage ?? 'Unknown error'}';
    }
  }

  Color _getStatusTextColor(SyncItemState item) {
    switch (item.status) {
      case SyncItemStatus.pending:
        return textMuted;
      case SyncItemStatus.syncing:
        return const Color(0xFF3182CE);
      case SyncItemStatus.completed:
        return const Color(0xFF38A169);
      case SyncItemStatus.failed:
        return const Color(0xFFE53E3E);
    }
  }

  Widget _buildStatusIndicator(int index, SyncItemState item, SyncDataState state) {
    switch (item.status) {
      case SyncItemStatus.pending:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.schedule_rounded,
            color: Color(0xFF718096),
            size: 20,
          ),
        );
      case SyncItemStatus.syncing:
        return const SizedBox(
          width: 36,
          height: 36,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Color(0xFF3182CE)),
            ),
          ),
        );
      case SyncItemStatus.completed:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF38A169).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF38A169),
            size: 20,
          ),
        );
      case SyncItemStatus.failed:
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: state.isSyncing
                ? null
                : () => _syncBloc.add(RetrySync(index)),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFFE53E3E),
                size: 20,
              ),
            ),
          ),
        );
    }
  }
}
