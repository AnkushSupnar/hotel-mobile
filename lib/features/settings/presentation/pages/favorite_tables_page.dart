import 'package:flutter/material.dart';
import 'package:hotel/core/services/table_storage_service.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';
import 'package:hotel/features/tables/data/repositories/table_repository.dart';

class FavoriteTablesPage extends StatefulWidget {
  const FavoriteTablesPage({super.key});

  @override
  State<FavoriteTablesPage> createState() => _FavoriteTablesPageState();
}

class _FavoriteTablesPageState extends State<FavoriteTablesPage> {
  final TableRepository _repository = TableRepository();
  List<TableSection> _sections = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Modern Material Color Palette
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color surfaceColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textMuted = Color(0xFF718096);

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
      final sections = await _repository.getTablesBySection();
      final favoriteIds = TableStorageService.getFavoriteTableIds();

      setState(() {
        _sections = sections;
        _favoriteIds = favoriteIds.toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load tables: ${e.toString()}';
      });
    }
  }

  void _toggleFavorite(int tableId) async {
    await TableStorageService.toggleFavorite(tableId);
    setState(() {
      if (_favoriteIds.contains(tableId)) {
        _favoriteIds.remove(tableId);
      } else {
        _favoriteIds.add(tableId);
      }
    });
  }

  Color _getSectionColor(int index) {
    return sectionColors[index % sectionColors.length];
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
                  'Favorite Tables',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to mark tables as favorites',
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

    if (_sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_bar_rounded,
              size: 64,
              color: textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tables available',
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
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          final section = _sections[index];
          final sectionColor = _getSectionColor(index);
          return _buildSectionCard(section, sectionColor);
        },
      ),
    );
  }

  Widget _buildSectionCard(TableSection section, Color color) {
    final favoriteCount = section.tables.where((t) => _favoriteIds.contains(t.id)).length;

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
          // Section Header
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
                    Icons.table_bar_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Section ${section.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                        '$favoriteCount/${section.tables.length}',
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
          // Tables Grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: section.tables.map((table) {
                final isFavorite = _favoriteIds.contains(table.id);
                return _buildTableChip(table, color, isFavorite);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableChip(DiningTableModel table, Color color, bool isFavorite) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleFavorite(table.id),
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
              Text(
                table.tableName,
                style: TextStyle(
                  color: isFavorite ? Colors.white : textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
