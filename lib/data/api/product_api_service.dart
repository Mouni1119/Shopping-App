import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductApiService {

  static const String baseUrl = 'https://fakestoreapi.com/products';

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) {
          try {
            return ProductModel.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            throw Exception('Error parsing product: $e. JSON: $json');
          }
        }).toList();
      } else {
        throw Exception('Failed to load products. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } on FormatException catch (e) {
      throw Exception('JSON parsing error: $e');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

}

