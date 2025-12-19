import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/api/product_api_service.dart';
import '../../data/hive/hive_service.dart'; // Add this import
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductApiService _apiService;

  ProductBloc(this._apiService) : super(const ProductInitialState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<LoadProductByIdEvent>(_onLoadProductById);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
      LoadProductsEvent event,
      Emitter<ProductState> emit,
      ) async {
    try {
      final hasCache = await HiveService.hasCachedProducts();

      if (hasCache) {

        final cachedProducts = await HiveService.getCachedProducts();
        if (cachedProducts.isNotEmpty) {
          emit(ProductLoadedState(cachedProducts));
        }
      } else {
        emit(const ProductLoadingState());
      }
      final products = await _apiService.getProducts();

      // Cache the fresh products
      await HiveService.cacheProducts(products);

      // Update UI with fresh data (this will replace cached data if it was shown)
      emit(ProductLoadedState(products));
    } catch (e) {
      // If API fails, try to show cached data
      try {
        final cachedProducts = await HiveService.getCachedProducts();
        if (cachedProducts.isNotEmpty) {
          // Show cached data even if API failed
          emit(ProductLoadedState(cachedProducts));
        } else {
          // No cache and API failed - show error
          emit(ProductErrorState('No internet connection and no cached data available. Please connect to internet to load products.'));
        }
      } catch (cacheError) {
        emit(ProductErrorState('Error: ${e.toString()}'));
      }
    }
  }


  Future<void> _onLoadProductById(
      LoadProductByIdEvent event,
      Emitter<ProductState> emit,
      ) async {
    emit(const ProductLoadingState());

    try {
      final product = await _apiService.getProductById(event.id);
      emit(ProductDetailLoadedState(product));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  // CREATE - Add a new product
  Future<void> _onCreateProduct(
      CreateProductEvent event,
      Emitter<ProductState> emit,
      ) async {
    emit(const ProductLoadingState());

    try {
      final createdProduct = await _apiService.createProduct(event.product);
      emit(ProductCreatedState(createdProduct));

      // Update cache
      final products = await _apiService.getProducts();
      await HiveService.cacheProducts(products);

      emit(ProductLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  // UPDATE - Update an existing product
  Future<void> _onUpdateProduct(
      UpdateProductEvent event,
      Emitter<ProductState> emit,
      ) async {
    emit(const ProductLoadingState());

    try {
      final updatedProduct = await _apiService.updateProduct(event.id, event.product);
      emit(ProductUpdatedState(updatedProduct));

      // Update cache
      final products = await _apiService.getProducts();
      await HiveService.cacheProducts(products);

      emit(ProductLoadedState(products));
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }

  // DELETE - Delete a product
  Future<void> _onDeleteProduct(
      DeleteProductEvent event,
      Emitter<ProductState> emit,
      ) async {
    emit(const ProductLoadingState());

    try {
      final success = await _apiService.deleteProduct(event.id);
      if (success) {
        emit(ProductDeletedState(event.id));

        // Update cache
        final products = await _apiService.getProducts();
        await HiveService.cacheProducts(products);

        emit(ProductLoadedState(products));
      } else {
        emit(const ProductErrorState('Failed to delete product'));
      }
    } catch (e) {
      emit(ProductErrorState(e.toString()));
    }
  }
}