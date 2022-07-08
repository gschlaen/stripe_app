import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stripe_app/bloc/pay/pay_bloc.dart';
import 'package:stripe_app/helpers/helpers.dart';
import 'package:stripe_app/services/stripe_service.dart';
import 'package:stripe_payment/stripe_payment.dart';

class TotalPayButton extends StatelessWidget {
  const TotalPayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final payBloc = BlocProvider.of<PayBloc>(context).state;

    return Container(
      width: width,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${payBloc.amount.toString()} ${payBloc.currency}', style: const TextStyle(fontSize: 20)),
            ],
          ),
          BlocBuilder<PayBloc, PayState>(
            builder: (context, state) {
              return _BtnPay(state: state);
            },
          )
        ],
      ),
    );
  }
}

class _BtnPay extends StatelessWidget {
  final PayState state;
  const _BtnPay({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return state.activeCreditcard ? buildCreditcardButton(context) : buildAndroidAndGooglePay(context);
  }

  Widget buildCreditcardButton(BuildContext context) {
    return MaterialButton(
      height: 45,
      minWidth: 170,
      shape: const StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      child: Row(
        children: const [
          Icon(FontAwesomeIcons.solidCreditCard, color: Colors.white),
          Text('  Pay', style: TextStyle(color: Colors.white, fontSize: 22)),
        ],
      ),
      onPressed: () async {
        showLoading(context);

        final stripeService = StripeService();
        final payBloc = BlocProvider.of<PayBloc>(context).state;
        final card = BlocProvider.of<PayBloc>(context).state.creditcard;
        final monthYear = card!.expiracyDate.split('/');

        final resp = await stripeService.payWithExistingCreditcard(
          amount: payBloc.amountToString,
          currency: payBloc.currency,
          creditcard: CreditCard(
            number: card.cardNumber,
            expMonth: int.parse(monthYear[0]),
            expYear: int.parse(monthYear[1]),
          ),
        );

        Navigator.pop(context);

        if (resp.ok) {
          showAlert(context, 'Tajeta ok', 'Todo Correcto');
        } else {
          showAlert(context, 'Algo salio mal', resp.msg!);
        }
      },
    );
  }

  Widget buildAndroidAndGooglePay(BuildContext context) {
    return MaterialButton(
      height: 45,
      minWidth: 150,
      shape: const StadiumBorder(),
      elevation: 0,
      color: Colors.black,
      child: Row(
        children: [
          Icon(
            Platform.isAndroid ? FontAwesomeIcons.google : FontAwesomeIcons.apple,
            color: Colors.white,
          ),
          const Text('  Pay', style: TextStyle(color: Colors.white, fontSize: 22)),
        ],
      ),
      onPressed: () async {
        final stripeService = StripeService();
        final payBloc = BlocProvider.of<PayBloc>(context).state;

        final resp = await stripeService.payWithApplePayGooglePay(
          amount: payBloc.amountToString,
          currency: payBloc.currency,
        );
      },
    );
  }
}
