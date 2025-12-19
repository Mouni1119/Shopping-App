import 'package:equatable/equatable.dart';


abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize payment gateways when checkout screen opens
class InitializePaymentEvent extends CheckoutEvent {
  const InitializePaymentEvent();
}

/// User selects a payment method (Razorpay, Stripe, or COD)
class SelectPaymentMethodEvent extends CheckoutEvent {
  final PaymentOption method;

  const SelectPaymentMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}

/// User clicks "Pay Now" button - process the payment
class ProcessPaymentEvent extends CheckoutEvent {
  final double amount;

  const ProcessPaymentEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

/// Payment was successful
class PaymentSuccessEvent extends CheckoutEvent {
  final String paymentId;
  final PaymentOption method;
  final String? orderId;

  const PaymentSuccessEvent(this.paymentId, this.method, [this.orderId]);

  @override
  List<Object?> get props => [paymentId, method, orderId];
}

/// Payment failed with error
class PaymentErrorEvent extends CheckoutEvent {
  final String errorMessage;

  const PaymentErrorEvent(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

/// Payment was cancelled by user
class PaymentCancelledEvent extends CheckoutEvent {
  const PaymentCancelledEvent();
}

/// Reset checkout state (after success or error)
class ResetCheckoutEvent extends CheckoutEvent {
  const ResetCheckoutEvent();
}

/// Payment method options
enum PaymentOption {
  razorpay,  // Razorpay payment gateway
  stripe,    // Stripe payment gateway
  cod        // Cash on Delivery
}
