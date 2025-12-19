import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';


abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitialState extends ProductState {
  const ProductInitialState();
}

class ProductLoadingState extends ProductState {
  const ProductLoadingState();
}

class ProductLoadedState extends ProductState {
  final List<ProductModel> products;

  const ProductLoadedState(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductErrorState extends ProductState {
  final String message;

  const ProductErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductDetailLoadedState extends ProductState {
  final ProductModel product;

  const ProductDetailLoadedState(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductCreatedState extends ProductState {
  final ProductModel product;

  const ProductCreatedState(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductUpdatedState extends ProductState {
  final ProductModel product;

  const ProductUpdatedState(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductDeletedState extends ProductState {
  final int productId;

  const ProductDeletedState(this.productId);

  @override
  List<Object?> get props => [productId];
}


