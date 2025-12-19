import 'package:equatable/equatable.dart';
import 'checkout_event.dart';

/// Checkout States
/// These states represent different stages of the checkout process
abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

/// Initial state when checkout screen first loads
class CheckoutInitialState extends CheckoutState {
  const CheckoutInitialState();
}

/// Loading state (e.g., initializing payment gateways)
class CheckoutLoadingState extends CheckoutState {
  const CheckoutLoadingState();
}

/// Checkout is ready - user can select payment method and proceed
class CheckoutLoadedState extends CheckoutState {
  final PaymentOption selectedMethod;
  final bool isProcessing;

  const CheckoutLoadedState({
    this.selectedMethod = PaymentOption.razorpay,
    this.isProcessing = false,
  });

  /// Create a copy with updated values
  CheckoutLoadedState copyWith({
    PaymentOption? selectedMethod,
    bool? isProcessing,
  }) {
    return CheckoutLoadedState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [selectedMethod, isProcessing];
}

/// Payment is being processed
class PaymentProcessingState extends CheckoutState {
  final PaymentOption method;
  final double amount;

  const PaymentProcessingState(this.method, this.amount);

  @override
  List<Object?> get props => [method, amount];
}

/// Payment completed successfully
class PaymentSuccessState extends CheckoutState {
  final String paymentId;
  final PaymentOption method;
  final String? orderId;

  const PaymentSuccessState(this.paymentId, this.method, [this.orderId]);

  @override
  List<Object?> get props => [paymentId, method, orderId];
}

/// Payment failed with error
class PaymentErrorState extends CheckoutState {
  final String errorMessage;
  final PaymentOption method;

  const PaymentErrorState(this.errorMessage, this.method);

  @override
  List<Object?> get props => [errorMessage, method];
}
