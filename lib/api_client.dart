import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? defaultBaseUrl;

  static const String defaultBaseUrl = 'http://localhost:8000';
  final String baseUrl;

  Uri _uri(String path, [Map<String, dynamic>? query]) => Uri.parse('$baseUrl$path').replace(queryParameters: query?.map((k, v) => MapEntry(k, v.toString())));

  Future<List<CategoryDto>> getCategories() async {
    final res = await http.get(_uri('/category'));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> body = json.decode(res.body);
      final List data = body['data'] as List? ?? [];
      return data.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load categories (${res.statusCode})');
  }

  Future<CategoryDto> getCategory(int id) async {
    final res = await http.get(_uri('/category/$id'));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> body = json.decode(res.body);
      return CategoryDto.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load category (${res.statusCode})');
  }

  Future<CategoryDto> createCategory(CategoryDto payload) async {
    final res = await http.post(
      _uri('/category'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload.toJson()),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> body = json.decode(res.body);
      return CategoryDto.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to create category (${res.statusCode})');
  }

  Future<CategoryDto> updateCategory(int id, CategoryDto payload) async {
    final res = await http.put(
      _uri('/category/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload.toJson()),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> body = json.decode(res.body);
      return CategoryDto.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to update category (${res.statusCode})');
  }

  Future<void> deleteCategory(int id) async {
    final res = await http.delete(_uri('/category/$id'));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return;
    }
    throw Exception('Failed to delete category (${res.statusCode})');
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    final res = await http.post(
      _uri('/order'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create order (${res.statusCode})');
  }

  Future<List<OrderSummaryDto>> getOrders() async {
    final res = await http.get(_uri('/order'));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final Map<String, dynamic> body = json.decode(res.body);
      final List data = body['data'] as List? ?? [];
      return data.map((e) => OrderSummaryDto.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load orders (${res.statusCode})');
  }

  Future<void> updateOrderStatus(int id, String status) async {
    final res = await http.put(
      _uri('/order/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw Exception('Failed to update status (${res.statusCode})');
  }
}

class CategoryDto {
  final int id;
  final String name;
  final String unit; 
  final double pricePerUnit;

  CategoryDto({required this.id, required this.name, required this.unit, required this.pricePerUnit});

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
        id: (json['id'] as num).toInt(),
        name: (json['name'] as String?) ?? '',
        unit: (json['unit'] as String?) ?? 'kg',
        pricePerUnit: (json['price_per_unit'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (id != -1) 'id': id,
        'name': name,
        'unit': unit,
        'price_per_unit': pricePerUnit,
      };
}

class OrderSummaryDto {
  final int id;
  final String status;
  final String notes;
  final double totalPrice;
  final OrderCustomerDto? customer;

  OrderSummaryDto({required this.id, required this.status, required this.notes, required this.totalPrice, required this.customer});

  factory OrderSummaryDto.fromJson(Map<String, dynamic> json) => OrderSummaryDto(
        id: (json['id'] as num).toInt(),
        status: (json['status'] as String?) ?? 'pending',
        notes: (json['notes'] as String?) ?? '',
        totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
        customer: json['customer'] == null ? null : OrderCustomerDto.fromJson(json['customer'] as Map<String, dynamic>),
      );
}

class OrderCustomerDto {
  final int id;
  final String name;
  final String phone;

  OrderCustomerDto({required this.id, required this.name, required this.phone});

  factory OrderCustomerDto.fromJson(Map<String, dynamic> json) => OrderCustomerDto(
        id: (json['id'] as num).toInt(),
        name: (json['name'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
      );
}
