import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';


abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCartEvent extends CartEvent {
  final ProductModel product;

  const AddToCartEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromCartEvent extends CartEvent {
  final int productId;

  const RemoveFromCartEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}




