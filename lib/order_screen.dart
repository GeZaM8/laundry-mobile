import 'package:flutter/material.dart';
import 'api_client.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _telpController = TextEditingController();
  final _catatanController = TextEditingController();

  static const Color _blue = Color(0xFF0079B9);

  final List<_OrderItem> _daftarItem = [
    _OrderItem(),
  ];

  final ApiClient _api = ApiClient();
  List<CategoryDto> _categories = [];
  bool _loadingCats = true;
  String? _loadError;
  String _status = 'pending';

  double _itemSubtotal(_OrderItem it) {
    if (it.categoryId == null) return 0;
    final cat = _categories.where((c) => c.id == it.categoryId).cast<CategoryDto?>().firstWhere((c) => c != null, orElse: () => null);
    if (cat == null) return 0;
    final price = cat.pricePerUnit;
    if (it.unit == 'kg') {
      final w = it.weightKg ?? 0;
      return price * w;
    } else if (it.unit == 'item') {
      final q = it.qty ?? 0;
      return price * q;
    }
    return 0;
  }

  double get _totalPrice => _daftarItem.fold(0.0, (sum, it) => sum + _itemSubtotal(it));

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await _api.getCategories();
      setState(() {
        _categories = cats;
        _loadingCats = false;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _loadingCats = false;
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _telpController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _tambahItem() {
    setState(() => _daftarItem.add(_OrderItem()));
  }

  void _hapusItem(int index) {
    setState(() => _daftarItem.removeAt(index));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final order = {
      'notes': _catatanController.text.trim(), // catatan level order
      'status': _status,
      'customer': {
        'name': _namaController.text.trim(),
        'phone': _telpController.text.trim(),
      },
      'items': _daftarItem.map((e) => e.toBackendJson()).toList(),
    };

    try {
      await _api.createOrder(order);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order berhasil dibuat')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Order'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Data Customer', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Customer', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telpController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'No. Telepon', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _catatanController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status Order', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Belum Selesai')),
                  DropdownMenuItem(value: 'done', child: Text('Selesai')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'pending'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Items', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton.icon(onPressed: _tambahItem, icon: const Icon(Icons.add), label: const Text('Tambah Item')),
                ],
              ),
              if (_loadingCats)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('Gagal memuat kategori: $_loadError'),
                )
              else
                ...List.generate(_daftarItem.length, (index) {
                  return _ItemCard(
                    key: ValueKey('item-$index'),
                    item: _daftarItem[index],
                    categories: _categories,
                    onChanged: () => setState(() {}),
                    onRemove: () => _hapusItem(index),
                  );
                }),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: Rp ${_totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _submit,
                  child: const Text('Simpan Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatefulWidget {
  const _ItemCard({super.key, required this.item, required this.categories, required this.onRemove, required this.onChanged});
  final _OrderItem item;
  final List<CategoryDto> categories;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _qtyController.text = widget.item.qty?.toString() ?? '';
    _weightController.text = widget.item.weightKg?.toString() ?? '';
    _notesController.text = widget.item.notes ?? '';
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // removed old category change handler; handled inline where dropdown changes

  @override
  Widget build(BuildContext context) {
    final String? unit = widget.item.unit;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: widget.item.categoryId,
                    items: widget.categories
                        .map((c) => DropdownMenuItem<int>(value: c.id, child: Text('${c.name} (${c.unit})')))
                        .toList(),
                    onChanged: (val) {
                      final cat = widget.categories.firstWhere((c) => c.id == val);
                      setState(() {
                        widget.item.categoryId = val;
                        widget.item.unit = cat.unit;
                        widget.item.qty = null;
                        widget.item.weightKg = null;
                        _qtyController.clear();
                        _weightController.clear();
                      });
                      widget.onChanged();
                    },
                    decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                    validator: (v) => (v == null) ? 'Pilih kategori' : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Hapus item',
                )
              ],
            ),
            const SizedBox(height: 12),
            if (unit == 'kg')
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Berat (kg)', border: OutlineInputBorder()),
                onChanged: (v) {
                  widget.item.weightKg = double.tryParse(v.replaceAll(',', '.'));
                  widget.onChanged();
                },
              )
            else if (unit == 'item')
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Qty (item)', border: OutlineInputBorder()),
                onChanged: (v) {
                  widget.item.qty = int.tryParse(v);
                  widget.onChanged();
                },
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Catatan item', border: OutlineInputBorder()),
              onChanged: (v) {
                widget.item.notes = v;
                widget.onChanged();
              },
            ),
            const SizedBox(height: 8),
            if (widget.item.categoryId != null)
              Align(
                alignment: Alignment.centerRight,
                child: Builder(builder: (context) {
                  final cat = widget.categories.firstWhere((c) => c.id == widget.item.categoryId, orElse: () => CategoryDto(id: -1, name: '', unit: widget.item.unit ?? 'kg', pricePerUnit: 0));
                  final subtotal = (widget.item.unit == 'kg')
                      ? (cat.pricePerUnit * (widget.item.weightKg ?? 0))
                      : (cat.pricePerUnit * (widget.item.qty ?? 0));
                  return Text('Subtotal: Rp ${subtotal.toStringAsFixed(0)}');
                }),
              ),
          ],
        ),
      ),
    );
  }

}

class _OrderItem {
  int? categoryId; // backend expects category_id
  String? unit; // 'kg' or 'item'
  int? qty; // for item unit
  double? weightKg; // for kg unit
  String? notes;

  Map<String, dynamic> toBackendJson() => {
        'category_id': categoryId,
        'unit': unit,
        'qty': qty,
        'weight_kg': weightKg,
        'notes': notes,
      };
}
