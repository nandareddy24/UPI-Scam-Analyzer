import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';
import '../widgets/risk_result_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.threatRed),
            tooltip: 'Clear Scan History',
            onPressed: () => _confirmClearAll(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(historyStateProvider.notifier).loadHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search scan targets or reasons...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.cyberCyan),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['ALL', 'UPI', 'URL', 'SMS', 'QR', 'DANGEROUS'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedFilter = filter),
                          selectedColor: AppTheme.cyberCyan,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          backgroundColor: AppTheme.cardBgElevated,
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),

          // Main List View
          Expanded(
            child: historyState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.cyberCyan)),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.threatRed),
                      const SizedBox(height: 12),
                      Text(err.toString(), textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(historyStateProvider.notifier).loadHistory(),
                        child: const Text('RETRY LOADING HISTORY'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (allItems) {
                // Apply Search & Filter Logic
                final filtered = allItems.where((item) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      item.inputData.toLowerCase().contains(_searchQuery) ||
                      item.reason.toLowerCase().contains(_searchQuery) ||
                      item.type.toLowerCase().contains(_searchQuery);

                  if (!matchesSearch) return false;

                  if (_selectedFilter == 'ALL') return true;
                  if (_selectedFilter == 'DANGEROUS') {
                    return item.result.toLowerCase() == 'dangerous' || item.displayScore > 70;
                  }
                  return item.type.toUpperCase() == _selectedFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined, size: 54, color: AppTheme.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'No matching scan records found.',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Perform scans using the UPI, URL, SMS or QR scanner.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(historyStateProvider.notifier).loadHistory(),
                  color: AppTheme.cyberCyan,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final statusColor = AppTheme.getRiskColor(item.displayScore);

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.threatRedBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: AppTheme.threatRed),
                        ),
                        onDismissed: (_) {
                          ref.read(historyStateProvider.notifier).deleteScan(item.id);
                        },
                        child: CyberCard(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          onTap: () => _showDetailsModal(context, item),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconForType(item.type),
                                  color: statusColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.inputData,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.type.toUpperCase()} • ${item.reason}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.result.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.displayScore}/100',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsModal(BuildContext context, ScanResult item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.darkBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Scan Detail Record',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                RiskResultCard(result: item),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppTheme.threatRed),
            SizedBox(width: 10),
            Text('Clear Scan History'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all local scan history? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.threatRed),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(historyStateProvider.notifier).clearAll();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'upi':
        return Icons.account_balance_wallet_rounded;
      case 'phone':
        return Icons.phone_rounded;
      case 'sms':
        return Icons.message_rounded;
      case 'url':
        return Icons.link_rounded;
      case 'image':
      case 'ocr':
        return Icons.image_rounded;
      case 'qr':
        return Icons.qr_code_rounded;
      default:
        return Icons.security_rounded;
    }
  }
}
