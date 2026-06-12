import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? categoryId, String? query});
  Future<List<CategoryModel>> getCategories();
  Future<ProductModel> getProductById(String id);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final ApiClient apiClient;

  CatalogRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts({String? categoryId, String? query}) async {
    String endpoint = '/products';
    final queryParams = <String, String>{};
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['category_id'] = categoryId;
    }
    if (query != null && query.isNotEmpty) {
      queryParams['search'] = query;
    }
    
    if (queryParams.isNotEmpty) {
      final queryString = Uri(queryParameters: queryParams).query;
      endpoint += '?$queryString';
    }

    final response = await apiClient.get(endpoint);
    final data = jsonDecode(response.body);
    
    // Soporte para respuestas paginadas de Laravel Resource { "data": [...] }
    final List list = data is Map ? (data['data'] ?? data['products'] ?? []) : data;
    return list.map((item) => ProductModel.fromJson(item)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await apiClient.get('/categories');
    final data = jsonDecode(response.body);
    final List list = data is Map ? (data['data'] ?? data['categories'] ?? []) : data;
    return list.map((item) => CategoryModel.fromJson(item)).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final response = await apiClient.get('/products/$id');
    final data = jsonDecode(response.body);
    final productJson = data is Map && data.containsKey('data') ? data['data'] : data;
    return ProductModel.fromJson(productJson);
  }
}
