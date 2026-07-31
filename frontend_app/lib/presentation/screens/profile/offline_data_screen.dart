import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/discover/data/datasources/attraction_local_datasource.dart';
import '../../../injection_container.dart' as di;

class OfflineDataScreen extends StatefulWidget {
  const OfflineDataScreen({super.key});

  @override
  State<OfflineDataScreen> createState() => _OfflineDataScreenState();
}

class _OfflineDataScreenState extends State<OfflineDataScreen> {
  late Future<int> _cachedCount;

  @override
  void initState() {
    super.initState();
    _cachedCount = _loadCount();
  }

  Future<int> _loadCount() async {
    final local = di.sl<AttractionLocalDataSource>();
    if (!local.hasCache) return 0;
    return (await local.getCached()).length;
  }

  Future<void> _clearCache() async {
    await di.sl<AttractionLocalDataSource>().clear();
    if (!mounted) return;
    setState(() => _cachedCount = _loadCount());
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Offline cache cleared'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offline Data'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: FutureBuilder<int>(
        future: _cachedCount,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          final loading = snapshot.connectionState == ConnectionState.waiting;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.download_done_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loading
                                ? 'Checking cache…'
                                : '$count ${count == 1 ? 'place' : 'places'} cached',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Available on the Discover tab with no connectivity',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Attractions load from Firestore when online and are saved '
                'here automatically, so Discover keeps working offline. The '
                'bundled seed data is always available as a last resort even '
                'if the cache is cleared.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: count == 0 ? null : _clearCache,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear offline cache'),
              ),
            ],
          );
        },
      ),
    );
  }
}
