part of 'pay_bloc.dart';

@immutable
abstract class PayEvent {}

class OnSelectCreditcard extends PayEvent {
  final CreditcardCustom creditcard;

  OnSelectCreditcard(this.creditcard);
}

class OnDeactivateCreditcard extends PayEvent {}
