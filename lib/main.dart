import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Add this
import 'data/models/product_model.dart';
import 'di/injection_container.dart';
import 'logic/bloc/cart/cart_bloc.dart';
import 'logic/bloc/poduct/product_bloc.dart';
import 'logic/bloc/poduct/product_event.dart';
import 'presentation/screens/product_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(RatingModelAdapter());

  // Open Hive boxes (already registered adapters above)

  if (!Hive.isBoxOpen('products_box')) {
    await Hive.openBox('products_box');
  }
  if (!Hive.isBoxOpen('cart_box')) {
    await Hive.openBox('cart_box');
  }

  setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ProductBloc>()..add(const LoadProductsEvent()),
        ),
        BlocProvider(
          create: (context) => getIt<CartBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Shopping App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}