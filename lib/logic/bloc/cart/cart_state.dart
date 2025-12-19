import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';


abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitialState extends CartState {
  const CartInitialState();
}

class CartLoadedState extends CartState {
  final List<ProductModel> cartItems;

  const CartLoadedState(this.cartItems);

  @override
  List<Object?> get props => [cartItems];

  int get itemCount => cartItems.length;

  double get totalPrice {
    return cartItems.fold(0.0, (sum, product) => sum + product.price);
  }
}




