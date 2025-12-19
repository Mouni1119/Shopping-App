import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';


abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductEvent {
  const LoadProductsEvent();
}

class LoadProductByIdEvent extends ProductEvent {
  final int id;

  const LoadProductByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateProductEvent extends ProductEvent {
  final ProductModel product;

  const CreateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final int id;
  final ProductModel product;

  const UpdateProductEvent(this.id, this.product);

  @override
  List<Object?> get props => [id, product];
}

class DeleteProductEvent extends ProductEvent {
  final int id;

  const DeleteProductEvent(this.id);

  @override
  List<Object?> get props => [id];
}


