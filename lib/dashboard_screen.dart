import 'package:flutter/material.dart';
import 'order_screen.dart';
import 'category_list_screen.dart';
import 'order_history_screen.dart';
import 'api_client.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color _blue = Color(0xFF0079B9);
  final ApiClient _apiClient = ApiClient();
  
  int _pendingCount = 0;
  int _completedCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrderCounts();
  }

  Future<void> _fetchOrderCounts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pendingResponse = await _apiClient.get('/order/count/pending');
      final completedResponse = await _apiClient.get('/order/count/done');

      if (mounted) {
        setState(() {
          _pendingCount = pendingResponse['count'] ?? 0;
          _completedCount = completedResponse['count'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data order';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        title: const Text('Dashboard Petugas'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchOrderCounts,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Halo, Petugas 👋', 
                            style: TextStyle(fontSize: 14, color: Colors.black54)),
                        SizedBox(height: 4),
                        Text('Kelola order dan kategori', 
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _blue.withOpacity(0.1),
                      child: const Icon(Icons.local_laundry_service, 
                          color: Color(0xFF0079B9)),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Order Pending',
                        _isLoading ? '...' : '$_pendingCount',
                        const Color(0xFFE7F3FB),
                        Icons.timelapse,
                        _blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Order Selesai',
                        _isLoading ? '...' : '$_completedCount',
                        const Color(0xFFE6F7EE),
                        Icons.check_circle_outline,
                        const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                const Text('Aksi Petugas', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ActionTile(
                      color: _blue,
                      icon: Icons.add_shopping_cart,
                      title: 'Buat Order',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OrderScreen()),
                        );
                      },
                    ),
                    _ActionTile(
                      color: const Color(0xFFF59E0B),
                      icon: Icons.timelapse,
                      title: 'Order Belum Selesai',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OrderHistoryScreen(initialFilter: 'pending'),
                          ),
                        );
                      },
                    ),
                    _ActionTile(
                      color: const Color(0xFF10B981),
                      icon: Icons.check_circle_outline,
                      title: 'Order Selesai',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OrderHistoryScreen(initialFilter: 'done'),
                          ),
                        );
                      },
                    ),
                    _ActionTile(
                      color: const Color(0xFF6366F1),
                      icon: Icons.inventory_2_outlined,
                      title: 'Kelola Kategori',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CategoryListScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  Widget _buildStatCard(String title, String value, Color bgColor, 
      IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, 
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Icon(icon, color: iconColor, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
