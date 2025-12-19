import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/api/product_api_service.dart';
import '../../../data/hive/hive_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductApiService _apiService;

  ProductBloc(this._apiService) : super(const ProductInitialState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<LoadProductByIdEvent>(_onLoadProductById);
  }

  Future<void> _onLoadProducts(
      LoadProductsEvent event,
      Emitter<ProductState> emit,
      ) async {
    // First, try to load cached products
    try {
      final cachedProducts = await HiveService.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        // Show cached data immediately
        emit(ProductLoadedState(cachedProducts));
      } else {
        // No valid cache, show loading
        emit(const ProductLoadingState());
      }
    } catch (e) {
      // If cache read fails, show loading
      emit(const ProductLoadingState());
    }

    // Then, try to fetch fresh data from API
    try {
      final products = await _apiService.getProducts();
      // Cache the fresh products
      await HiveService.cacheProducts(products);
      // Update UI with fresh data (this will replace cached data if it was shown)
      emit(ProductLoadedState(products));
    } catch (e) {
      // If API fails, check if we have cached data to show
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

}