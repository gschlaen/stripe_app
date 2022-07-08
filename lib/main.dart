import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stripe_app/bloc/pay/pay_bloc.dart';

import 'package:stripe_app/pages/home_page.dart';
import 'package:stripe_app/pages/payment_complete.dart';
import 'package:stripe_app/services/stripe_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize StripeService
    StripeService().init();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PayBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StripeApp',
        initialRoute: 'home',
        routes: {
          'home': (_) => HomePage(),
          'payment_complete': (_) => const PaymentCompletePage(),
        },
        theme: ThemeData().copyWith(
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xff284879)),
          // primaryColor: const Color(0xff284879),
          scaffoldBackgroundColor: const Color(0xff21232A),
        ),
      ),
    );
  }
}
