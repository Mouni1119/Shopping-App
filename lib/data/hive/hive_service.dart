import 'package:hive/hive.dart';
import '../models/product_model.dart';

class HiveService {
  static const String productsBox = 'products_box';
  static const String cartBox = 'cart_box';

  // Save products to cache
  static Future<void> cacheProducts(List<ProductModel> products) async {
    final box = Hive.box(productsBox);
    await box.clear();

    for (var product in products) {
      await box.put(product.id, product);
    }
  }

  // Get cached products
  static Future<List<ProductModel>> getCachedProducts() async {
    final box = Hive.box(productsBox);
    return box.values.cast<ProductModel>().toList();
  }

  // Check if cache exists
  static Future<bool> hasCachedProducts() async {
    final box = Hive.box(productsBox);
    return box.isNotEmpty;
  }

  // CART FUNCTIONS

  // Add product to cart
  static Future<void> addToCart(ProductModel product) async {
    final box = Hive.box(cartBox);
    await box.put(product.id, product);
  }

  // Get all cart items
  static Future<List<ProductModel>> getCartItems() async {
    final box = Hive.box(cartBox);
    return box.values.cast<ProductModel>().toList();
  }

  // Remove from cart
  static Future<void> removeFromCart(int productId) async {
    final box = Hive.box(cartBox);
    await box.delete(productId);
  }

  // Clear cart
  static Future<void> clearCart() async {
    final box = Hive.box(cartBox);
    await box.clear();
  }

  // Check if product is in cart
  static Future<bool> isInCart(int productId) async {
    final box = Hive.box(cartBox);
    return box.containsKey(productId);
  }

  // Clear all data (for testing/logout)
  static Future<void> clearAllData() async {
    await Hive.box(productsBox).clear();
    await Hive.box(cartBox).clear();
  }
}