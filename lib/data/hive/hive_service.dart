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
    final List<ProductModel> products = [];
    int corruptedCount = 0;
    
    try {
      for (var key in box.keys) {
        try {
          final value = box.get(key);
          if (value != null && value is ProductModel) {
            products.add(value);
          } else {
            corruptedCount++;
          }
        } catch (e) {
          // Skip corrupted entries
          corruptedCount++;
          continue;
        }
      }
      
      // If box has entries but all are corrupted, clear the box
      if (box.isNotEmpty && products.isEmpty && corruptedCount > 0) {
        await box.clear();
      }
    } catch (e) {
      // If box is corrupted, clear it
      await box.clear();
    }
    
    return products;
  }

  // Check if cache exists
  static Future<bool> hasCachedProducts() async {
    final cachedProducts = await getCachedProducts();
    return cachedProducts.isNotEmpty;
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
    final List<ProductModel> cartItems = [];
    int corruptedCount = 0;
    
    try {
      for (var key in box.keys) {
        try {
          final value = box.get(key);
          if (value != null && value is ProductModel) {
            cartItems.add(value);
          } else {
            corruptedCount++;
          }
        } catch (e) {
          // Skip corrupted entries
          corruptedCount++;
          continue;
        }
      }
      
      // If box has entries but all are corrupted, clear the box
      if (box.isNotEmpty && cartItems.isEmpty && corruptedCount > 0) {
        await box.clear();
      }
    } catch (e) {
      // If box is corrupted, clear it
      await box.clear();
    }
    
    return cartItems;
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