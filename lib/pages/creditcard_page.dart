import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

import 'package:stripe_app/bloc/pay/pay_bloc.dart';
import 'package:stripe_app/widgets/total_pay_button.dart';

class CreditcardPage extends StatelessWidget {
  const CreditcardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final payBloc = BlocProvider.of<PayBloc>(context);
    final creditcard = payBloc.state.creditcard;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            payBloc.add(OnDeactivateCreditcard());

            Navigator.pop(context);
          },
        ),
        title: const Text('Pay'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Hero(
            tag: creditcard!.cardNumber,
            child: CreditCardWidget(
              cardNumber: creditcard.cardNumber,
              expiryDate: creditcard.expiracyDate,
              cardHolderName: creditcard.cardHolderName,
              cvvCode: creditcard.cvv,
              showBackView: false,
            ),
          ),

          // Este container esta funcionando como un expanded por
          //algun motivo de como funciona el stack o el creditcardWidget
          Container(),
          const Positioned(
            bottom: 0,
            child: TotalPayButton(),
          )
        ],
      ),
    );
  }
}
