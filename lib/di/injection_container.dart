import 'package:get_it/get_it.dart';
import '../data/api/product_api_service.dart';
import '../logic/bloc/cart/cart_bloc.dart';
import '../logic/bloc/checkout/checkout_bloc.dart';
import '../logic/bloc/product_bloc.dart';


// GetIt is a service locator - a container that holds all our dependencies
final getIt = GetIt.instance;

void setupDependencyInjection() {

  getIt.registerLazySingleton<ProductApiService>(
    () => ProductApiService(),
  );


  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(getIt<ProductApiService>()),
  );


  getIt.registerLazySingleton<CartBloc>(
    () => CartBloc(),
  );

  // Register Checkout BLoC - NEW
  getIt.registerFactory<CheckoutBloc>(
        () => CheckoutBloc(),
  );
}

