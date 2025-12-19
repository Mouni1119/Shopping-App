import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/hive/hive_service.dart';
import '../../../data/models/product_model.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartLoadedState([])) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
    on<LoadCartEvent>(_onLoadCart);

    // Load cart from Hive when bloc is created
    add(const LoadCartEvent());
  }

  Future<void> _onAddToCart(
      AddToCartEvent event,
      Emitter<CartState> emit,
      ) async {
    try {
      // Save to Hive
      await HiveService.addToCart(event.product);

      // Update state
      final currentState = state;
      if (currentState is CartLoadedState) {
        final updatedCart = List<ProductModel>.from(currentState.cartItems);
        updatedCart.add(event.product);
        emit(CartLoadedState(updatedCart));
      }
    } catch (e) {
      // Handle error but still update UI
      final currentState = state;
      if (currentState is CartLoadedState) {
        final updatedCart = List<ProductModel>.from(currentState.cartItems);
        updatedCart.add(event.product);
        emit(CartLoadedState(updatedCart));
      }
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCartEvent event,
      Emitter<CartState> emit,
      ) async {
    try {
      // Remove from Hive
      await HiveService.removeFromCart(event.productId);

      // Update state
      final currentState = state;
      if (currentState is CartLoadedState) {
        final updatedCart = List<ProductModel>.from(currentState.cartItems);
        updatedCart.removeWhere((product) => product.id == event.productId);
        emit(CartLoadedState(updatedCart));
      }
    } catch (e) {
      // Handle error
      final currentState = state;
      if (currentState is CartLoadedState) {
        final updatedCart = List<ProductModel>.from(currentState.cartItems);
        updatedCart.removeWhere((product) => product.id == event.productId);
        emit(CartLoadedState(updatedCart));
      }
    }
  }

  Future<void> _onClearCart(
      ClearCartEvent event,
      Emitter<CartState> emit,
      ) async {
    try {
      // Clear from Hive
      await HiveService.clearCart();

      // Update state
      emit(const CartLoadedState([]));
    } catch (e) {
      emit(const CartLoadedState([]));
    }
  }

  Future<void> _onLoadCart(
      LoadCartEvent event,
      Emitter<CartState> emit,
      ) async {
    try {
      // Load from Hive
      final cartItems = await HiveService.getCartItems();
      emit(CartLoadedState(cartItems));
    } catch (e) {
      // If error, start with empty cart
      emit(const CartLoadedState([]));
    }
  }
}


