import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../data/payment/payment_config.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';


class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  late Razorpay _razorpay;
  Timer? _paymentTimeoutTimer;

  CheckoutBloc() : super(const CheckoutLoadedState()) {
    on<InitializePaymentEvent>(_onInitializePayment);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<ProcessPaymentEvent>(_onProcessPayment);
    on<PaymentSuccessEvent>(_onPaymentSuccess);
    on<PaymentErrorEvent>(_onPaymentError);
    on<PaymentCancelledEvent>(_onPaymentCancelled);
    on<ResetCheckoutEvent>(_onResetCheckout);

    // Initialize payment gateways when BLoC is created
    add(const InitializePaymentEvent());
  }

  /// Initialize Razorpay payment gateway
  Future<void> _onInitializePayment(
    InitializePaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    try {
      _razorpay = Razorpay();
      
      // Listen for payment success
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
        add(PaymentSuccessEvent(
          response.paymentId ?? '',
          PaymentOption.razorpay,
          response.orderId,
        ));
      });
      
      // Listen for payment errors
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
        add(PaymentErrorEvent(response.message ?? 'Payment failed'));
      });

    } catch (e) {
      emit(PaymentErrorState('Initialization failed: $e', PaymentOption.razorpay));
    }
  }

  /// User selects a payment method
  void _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is CheckoutLoadedState) {
      final currentState = state as CheckoutLoadedState;
      emit(currentState.copyWith(selectedMethod: event.method));
    }
  }

  /// Process payment based on selected method
  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoadedState) {
      final currentState = state as CheckoutLoadedState;

      // Show processing state
      emit(PaymentProcessingState(currentState.selectedMethod, event.amount));

      // Process based on selected payment method
      if (currentState.selectedMethod == PaymentOption.razorpay) {
        await _processRazorpayPayment(event.amount);
      } else if (currentState.selectedMethod == PaymentOption.cod) {
        // Cash on Delivery - no payment needed
        await Future.delayed(const Duration(seconds: 1));
        emit(PaymentSuccessState(
          'COD_${DateTime.now().millisecondsSinceEpoch}',
          PaymentOption.cod,
        ));
      } else if (currentState.selectedMethod == PaymentOption.stripe) {
        // Stripe payment - implement Stripe logic here
        await Future.delayed(const Duration(seconds: 1));
        emit(PaymentSuccessState(
          'STRIPE_${DateTime.now().millisecondsSinceEpoch}',
          PaymentOption.stripe,
        ));
      }
    }
  }

  /// Process Razorpay payment
  Future<void> _processRazorpayPayment(double amount) async {
    try {
      // Cancel any existing timer
      _paymentTimeoutTimer?.cancel();
      
      final amountInPaise = (amount * 100).toInt();

      final options = {
        'key': PaymentConfig.razorpayKey,
        'amount': amountInPaise,
        'name': PaymentConfig.companyName,
        'description': 'Order Payment',
        'prefill': {
          'contact': '9999999999',
          'email': 'test@example.com',
        },
        'external': {
          'wallets': ['paytm', 'phonepe', 'gpay']
        }
      };

      _razorpay.open(options);
      
      // Set a timeout to detect if payment window was closed without action
      _paymentTimeoutTimer = Timer(const Duration(seconds: 60), () {
        if (state is PaymentProcessingState) {
          add(const PaymentCancelledEvent());
        }
      });
    } catch (e) {
      _paymentTimeoutTimer?.cancel();
      add(PaymentErrorEvent('Razorpay error: $e'));
    }
  }
  
  /// Payment was cancelled by user
  void _onPaymentCancelled(
    PaymentCancelledEvent event,
    Emitter<CheckoutState> emit,
  ) {
    // Cancel timeout timer
    _paymentTimeoutTimer?.cancel();
    
    // Reset back to loaded state so user can try again
    if (state is CheckoutLoadedState) {
      final currentState = state as CheckoutLoadedState;
      emit(currentState.copyWith(isProcessing: false));
    } else {
      emit(const CheckoutLoadedState());
    }
  }

  /// Payment was successful
  void _onPaymentSuccess(
    PaymentSuccessEvent event,
    Emitter<CheckoutState> emit,
  ) {
    // Cancel timeout timer since payment completed
    _paymentTimeoutTimer?.cancel();
    
    emit(PaymentSuccessState(
      event.paymentId,
      event.method,
      event.orderId,
    ));

    // Reset after showing success
    Future.delayed(const Duration(seconds: 2), () {
      add(const ResetCheckoutEvent());
    });
  }

  /// Payment failed
  void _onPaymentError(
    PaymentErrorEvent event,
    Emitter<CheckoutState> emit,
  ) {
    // Cancel timeout timer since payment completed (with error)
    _paymentTimeoutTimer?.cancel();
    
    if (state is CheckoutLoadedState) {
      final currentState = state as CheckoutLoadedState;
      emit(PaymentErrorState(event.errorMessage, currentState.selectedMethod));

      // Reset error state after delay
      Future.delayed(const Duration(seconds: 2), () {
        add(const ResetCheckoutEvent());
      });
    } else {
      // If not in CheckoutLoadedState, reset to it
      emit(const CheckoutLoadedState());
    }
  }

  /// Reset checkout to initial state
  void _onResetCheckout(
    ResetCheckoutEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(const CheckoutLoadedState());
  }

  @override
  Future<void> close() {
    _paymentTimeoutTimer?.cancel();
    _razorpay.clear();
    return super.close();
  }
}
