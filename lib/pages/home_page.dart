import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:stripe_app/bloc/pay/pay_bloc.dart';

import 'package:stripe_app/data/creditcards.dart';
import 'package:stripe_app/helpers/helpers.dart';
import 'package:stripe_app/pages/creditcard_page.dart';
import 'package:stripe_app/services/stripe_service.dart';
import 'package:stripe_app/widgets/total_pay_button.dart';

class HomePage extends StatelessWidget {
  final stripService = StripeService();

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final payBloc = BlocProvider.of<PayBloc>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              showLoading(context);

              final amount = payBloc.state.amountToString;
              final currency = payBloc.state.currency;

              final resp = await stripService.payWithNewCreditcard(
                amount: amount,
                currency: currency,
              );

              Navigator.pop(context);

              if (resp.ok) {
                showAlert(context, 'Tajeta ok', 'Todo Correcto');
              } else {
                showAlert(context, 'Algo salio mal', resp.msg!);
              }
            },
          )
        ],
        title: const Text('Pay'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            width: size.width,
            height: size.height,
            top: 200,
            child: PageView.builder(
                controller: PageController(
                  viewportFraction: 0.9,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: creditcards.length,
                itemBuilder: (_, i) {
                  final creditcard = creditcards[i];

                  return GestureDetector(
                    onTap: () {
                      final payBloc = BlocProvider.of<PayBloc>(context);
                      payBloc.add(OnSelectCreditcard(creditcard));

                      Navigator.push(context, navigateFadeIn(context, const CreditcardPage()));
                    },
                    child: Hero(
                      tag: creditcard.cardNumber,
                      child: CreditCardWidget(
                        cardNumber: creditcard.cardNumber,
                        expiryDate: creditcard.expiracyDate,
                        cardHolderName: creditcard.cardHolderName,
                        cvvCode: creditcard.cvv,
                        showBackView: false,
                      ),
                    ),
                  );
                }),
          ),
          const Positioned(
            bottom: 0,
            child: TotalPayButton(),
          )
        ],
      ),
    );
  }
}
