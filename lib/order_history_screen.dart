import 'package:flutter/material.dart';
import 'api_client.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final ApiClient _api = ApiClient();
  List<OrderSummaryDto> _orders = [];
  bool _loading = true;
  String? _error;
  String _filter = 'all'; // all, pending, done

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getOrders();
      setState(() {
        _orders = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<OrderSummaryDto> get _filtered {
    if (_filter == 'all') return _orders;
    return _orders.where((o) => o.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Order'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _filter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua')),
                DropdownMenuItem(value: 'pending', child: Text('Belum Selesai')),
                DropdownMenuItem(value: 'done', child: Text('Selesai')),
              ],
              onChanged: (v) => setState(() => _filter = v ?? 'all'),
            ),
          ),
          const SizedBox(width: 8)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [Padding(padding: const EdgeInsets.all(16), child: Text('Error: $_error'))])
                : _filtered.isEmpty
                    ? ListView(children: const [Padding(padding: EdgeInsets.all(16), child: Text('Tidak ada order'))])
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final o = _filtered[i];
                          final statusLabel = o.status == 'done' ? 'Selesai' : 'Belum Selesai';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: o.status == 'done' ? Colors.green.shade100 : Colors.orange.shade100,
                              child: Icon(o.status == 'done' ? Icons.check : Icons.timelapse, color: o.status == 'done' ? Colors.green : Colors.orange),
                            ),
                            title: Text(o.customer?.name.isNotEmpty == true ? o.customer!.name : 'Tanpa Nama'),
                            subtitle: Text('Status: $statusLabel • Total: Rp ${o.totalPrice.toStringAsFixed(0)}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                try {
                                  await _api.updateOrderStatus(o.id, v);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status diperbarui')));
                                  _load();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal update: $e')));
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'pending', child: Text('Tandai Belum Selesai')),
                                PopupMenuItem(value: 'done', child: Text('Tandai Selesai')),
                              ],
                              icon: const Icon(Icons.more_vert),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
