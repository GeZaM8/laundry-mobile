import 'package:flutter/material.dart';
import 'api_client.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, this.edit});
  final CategoryDto? edit;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  String _unit = 'kg';
  final ApiClient _api = ApiClient();

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e != null) {
      _name.text = e.name;
      _unit = (e.unit == 'kg' || e.unit == 'item') ? e.unit : 'kg';
      _price.text = e.pricePerUnit.toString();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final payload = CategoryDto(
      id: widget.edit?.id ?? -1,
      name: _name.text.trim(),
      unit: _unit,
      pricePerUnit: double.tryParse(_price.text.replaceAll(',', '.')) ?? 0,
    );
    try {
      if (widget.edit == null) {
        await _api.createCategory(payload);
      } else {
        await _api.updateCategory(widget.edit!.id, payload);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori disimpan')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.edit == null ? 'Tambah Kategori' : 'Edit Kategori')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _unit,
                decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'item', child: Text('item')),
                ],
                onChanged: (v) => setState(() => _unit = v ?? 'kg'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Harga per unit', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Simpan'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
