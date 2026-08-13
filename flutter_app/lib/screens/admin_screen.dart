import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../models/blacklist_item.dart';
import '../providers/app_providers.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<ReportModel> _reports = [];
  List<BlacklistItemModel> _blacklist = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAdminData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(adminRepositoryProvider);
      final reps = await repo.getReports();
      final bls = await repo.getBlacklist();
      setState(() {
        _reports = reps;
        _blacklist = bls;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveReport(int id) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.approveReport(id);
      await _fetchAdminData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectReport(int id) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.rejectReport(id);
      await _fetchAdminData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteBlacklist(int id) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.deleteBlacklist(id);
      await _fetchAdminData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddBlacklistDialog() {
    final dataController = TextEditingController();
    final typeController = TextEditingController(text: 'UPI');
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Blacklist Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dataController,
              decoration: const InputDecoration(labelText: 'UPI / Phone / Domain'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type (UPI / Phone / URL)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final data = dataController.text.trim();
              final type = typeController.text.trim();
              final reason = reasonController.text.trim();
              if (data.isNotEmpty && type.isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  final repo = ref.read(adminRepositoryProvider);
                  await repo.addBlacklist(data, type, reason);
                  await _fetchAdminData();
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Add Entry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchAdminData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.rate_review), text: 'User Reports'),
            Tab(icon: Icon(Icons.block), text: 'Blacklist DB'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.security, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _fetchAdminData, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Reports Tab
                    _reports.isEmpty
                        ? const Center(child: Text('No pending community reports.'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _reports.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final r = _reports[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Chip(label: Text(r.type), backgroundColor: Colors.blue.shade100),
                                          Chip(
                                            label: Text(r.status, style: const TextStyle(color: Colors.white)),
                                            backgroundColor: r.status.toLowerCase() == 'approved'
                                                ? Colors.green
                                                : r.status.toLowerCase() == 'rejected'
                                                    ? Colors.red
                                                    : Colors.orange,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(r.inputData, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Reason: ${r.reason}'),
                                      if (r.proofData != null) ...[
                                        const SizedBox(height: 4),
                                        Text('Proof: ${r.proofData}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                      const SizedBox(height: 12),
                                      if (r.status.toLowerCase() == 'pending')
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () => _rejectReport(r.id),
                                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                              child: const Text('Reject'),
                                            ),
                                            const SizedBox(width: 8),
                                            FilledButton(
                                              onPressed: () => _approveReport(r.id),
                                              style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                              child: const Text('Approve & Blacklist'),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    // Blacklist Tab
                    Scaffold(
                      floatingActionButton: FloatingActionButton.extended(
                        onPressed: _showAddBlacklistDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Blacklist'),
                      ),
                      body: _blacklist.isEmpty
                          ? const Center(child: Text('No items in blacklist database.'))
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _blacklist.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final b = _blacklist[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.red.shade100,
                                      child: const Icon(Icons.block, color: Colors.red),
                                    ),
                                    title: Text(b.data, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${b.type} • ${b.reason}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _deleteBlacklist(b.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
