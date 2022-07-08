import 'package:dio/dio.dart';
import 'package:stripe_app/models/payment_intent_response.dart';

import 'package:stripe_payment/stripe_payment.dart';

import 'package:stripe_app/models/stripe_custom_response.dart';

class StripeService {
  // Singleton
  StripeService._privateContstructor();
  static final StripeService _instance = StripeService._privateContstructor();
  factory StripeService() => _instance;

// Al escribir en cualquier parte de la app
// final stripeService = StripeService()
// Si existe una instancia del servicio la retorna y si no la crea

  final String _paymentApiUrl = 'https://api.stripe.com/v1/payment_intents';
  static final String _secretKey =
      'sk_test_51LIyBeBIMhU28UAAALnTDWEu2W5xD6k6XCvWIZuKAkV4vMW1n1Vrxqpw0yD2Azn0ZTVppFFv0273z3RAN0socmmg00czUMzELJ';
  final String _apiKey =
      'pk_test_51LIyBeBIMhU28UAAxWlA5XK2JTUVi3fJjn9z1hk0mRMnZTEvZqK3sWJjNuThinqkD4JDP9S0fmMfp3WvM6KiWxeE00t2PgpPBh';

  final headerOptions = Options(contentType: Headers.formUrlEncodedContentType, headers: {
    'Authorization': 'Bearer $_secretKey',
  });

  void init() {
    StripePayment.setOptions(StripeOptions(
      publishableKey: _apiKey,
      androidPayMode: 'test',
      merchantId: 'test',
    ));
  }

  Future<StripeCustomResponse> payWithExistingCreditcard({
    required String amount,
    required String currency,
    required CreditCard creditcard,
  }) async {
    try {
      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(card: creditcard),
      );

      final resp = await _pay(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
      );

      return resp;
    } catch (e) {
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }

  Future<StripeCustomResponse> payWithNewCreditcard({
    required String amount,
    required String currency,
  }) async {
    try {
      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest(),
      );

      final resp = await _pay(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
      );

      return resp;
    } catch (e) {
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }

  Future<StripeCustomResponse> payWithApplePayGooglePay({
    required String amount,
    required String currency,
  }) async {
    try {
      final newAmount = double.parse(amount) / 100;

      final token = await StripePayment.paymentRequestWithNativePay(
        androidPayOptions: AndroidPayPaymentRequest(totalPrice: amount, currencyCode: currency),
        applePayOptions: ApplePayPaymentOptions(countryCode: 'US', currencyCode: currency, items: [
          ApplePayItem(
            label: 'Super producto 1',
            amount: '$newAmount',
          )
        ]),
      );

      final paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(
            card: CreditCard(
          token: token.tokenId,
        )),
      );

      final resp = await _pay(
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
      );
      // Para cerrar la pantalla de pago nativo una vez realizado
      await StripePayment.completeNativePayRequest();
      return resp;
    } catch (e) {
      print('Error in intent: ${e.toString()}');
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }

  Future<PaymentIntentResponse> _createPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    try {
      final dio = Dio();
      final data = {
        'amount': amount,
        'currency': currency,
      };

      final resp = await dio.post(
        _paymentApiUrl,
        data: data,
        options: headerOptions,
      );

      return PaymentIntentResponse.fromMap(resp.data);
    } catch (e) {
      print('Error in intent: ${e.toString()}');
      return PaymentIntentResponse(
        status: '400',
      );
    }
  }

  Future<StripeCustomResponse> _pay({
    required String amount,
    required String currency,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      // Create payment intent
      final paymentIntent = await _createPaymentIntent(
        amount: amount,
        currency: currency,
      );

      final paymentConfirmation = await StripePayment.confirmPaymentIntent(PaymentIntent(
        clientSecret: paymentIntent.clientSecret,
        paymentMethodId: paymentMethod.id,
      ));

      if (paymentConfirmation.status == 'succeeded') {
        return StripeCustomResponse(ok: true);
      } else {
        return StripeCustomResponse(
          ok: false,
          msg: 'Failure: ${paymentConfirmation.status}',
        );
      }
    } catch (e) {
      print(e.toString());
      return StripeCustomResponse(
        ok: false,
        msg: e.toString(),
      );
    }
  }
}
