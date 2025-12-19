import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/cart/cart_bloc.dart';
import '../../logic/bloc/cart/cart_event.dart';
import '../../logic/bloc/cart/cart_state.dart';
import '../../logic/bloc/checkout/checkout_bloc.dart';
import '../../logic/bloc/checkout/checkout_event.dart';
import '../../logic/bloc/checkout/checkout_state.dart';
import '../../data/models/product_model.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app comes back to foreground, check if payment is still processing
    if (state == AppLifecycleState.resumed && mounted) {
      final checkoutBloc = context.read<CheckoutBloc>();
      final checkoutState = checkoutBloc.state;
      if (checkoutState is PaymentProcessingState) {
        // User came back without completing payment, reset the state
        checkoutBloc.add(const PaymentCancelledEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckoutBloc(),
      child: WillPopScope(
        onWillPop: () async {
          // When user presses back, check if payment is processing
          final checkoutState = context.read<CheckoutBloc>().state;
          if (checkoutState is PaymentProcessingState) {
            // Cancel payment if user goes back
            context.read<CheckoutBloc>().add(const PaymentCancelledEvent());
          }
          return true;
        },
        child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: MultiBlocListener(
          listeners: [
            // Listen for payment success
            BlocListener<CheckoutBloc, CheckoutState>(
              listener: (context, state) {
                if (state is PaymentSuccessState) {
                  _showSuccessDialog(context, state);
                } else if (state is PaymentErrorState) {
                  _showErrorSnackbar(context, state.errorMessage);
                }
              },
            ),
          ],
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is! CartLoadedState || cartState.cartItems.isEmpty) {
                return const Center(
                  child: Text('Your cart is empty'),
                );
              }

              return _buildCheckoutContent(context, cartState);
            },
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildCheckoutContent(BuildContext context, CartLoadedState cartState) {
    final cartItems = cartState.cartItems;
    final totalAmount = cartState.totalPrice;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildOrderSummary(cartItems, totalAmount),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildPaymentMethods(),
            ),
          ),

          const SizedBox(height: 32),

          // Pay Now Button
          BlocBuilder<CheckoutBloc, CheckoutState>(
            builder: (context, checkoutState) {
              final isProcessing = checkoutState is PaymentProcessingState ||
                  (checkoutState is CheckoutLoadedState && checkoutState.isProcessing);

              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () => _processPayment(context, totalAmount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'PAY NOW',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build order summary section
  Widget _buildOrderSummary(
    List<ProductModel> cartItems,
    double totalAmount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Items List
        ...cartItems.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),

        const Divider(height: 24),

        // Total Amount
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₹${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build payment methods selection
  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            final selectedMethod = state is CheckoutLoadedState
                ? state.selectedMethod
                : PaymentOption.razorpay;

            return Column(
              children: [
                // Razorpay Option
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.deepPurple),
                  title: const Text('Razorpay'),
                  subtitle: const Text('UPI, Cards, NetBanking'),
                  trailing: Radio<PaymentOption>(
                    value: PaymentOption.razorpay,
                    groupValue: selectedMethod,
                    onChanged: (value) => _selectPaymentMethod(context, value!),
                  ),
                  onTap: () => _selectPaymentMethod(context, PaymentOption.razorpay),
                ),

                const Divider(),

                // Stripe Option
                ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.deepPurple),
                  title: const Text('Stripe'),
                  subtitle: const Text('International Cards'),
                  trailing: Radio<PaymentOption>(
                    value: PaymentOption.stripe,
                    groupValue: selectedMethod,
                    onChanged: (value) => _selectPaymentMethod(context, value!),
                  ),
                  onTap: () => _selectPaymentMethod(context, PaymentOption.stripe),
                ),

                const Divider(),

                // Cash on Delivery
                ListTile(
                  leading: const Icon(Icons.money, color: Colors.deepPurple),
                  title: const Text('Cash on Delivery'),
                  subtitle: const Text('Pay when you receive'),
                  trailing: Radio<PaymentOption>(
                    value: PaymentOption.cod,
                    groupValue: selectedMethod,
                    onChanged: (value) => _selectPaymentMethod(context, value!),
                  ),
                  onTap: () => _selectPaymentMethod(context, PaymentOption.cod),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Select payment method
  void _selectPaymentMethod(BuildContext context, PaymentOption method) {
    context.read<CheckoutBloc>().add(SelectPaymentMethodEvent(method));
  }

  /// Process payment
  void _processPayment(BuildContext context, double amount) {
    context.read<CheckoutBloc>().add(ProcessPaymentEvent(amount));
  }

  /// Show success dialog
  void _showSuccessDialog(BuildContext context, PaymentSuccessState state) {
    if (state.method == PaymentOption.cod) {
      // Cash on Delivery - show special dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Confirmed'),
          content: const Text(
            'Your order has been placed successfully. Pay when you receive your items.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<CartBloc>().add(const ClearCartEvent());
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Online payment - show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Successful! ID: ${state.paymentId}'),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        context.read<CartBloc>().add(const ClearCartEvent());
        Navigator.pop(context);
      });
    }
  }

  /// Show error snackbar
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
