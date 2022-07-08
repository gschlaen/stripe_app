part of 'pay_bloc.dart';

@immutable
class PayState {
  final double amount;
  final String currency;
  final bool activeCreditcard;
  final CreditcardCustom? creditcard;

  String get amountToString => '${(amount * 100).floor()}';

  const PayState({
    this.amount = 375.55,
    this.currency = 'USD',
    this.activeCreditcard = false,
    this.creditcard,
  });

  PayState copyWith({
    double? amount,
    String? currency,
    bool? activeCreditcard,
    CreditcardCustom? creditcard,
  }) =>
      PayState(
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        activeCreditcard: activeCreditcard ?? this.activeCreditcard,
        creditcard: creditcard ?? this.creditcard,
      );
}
