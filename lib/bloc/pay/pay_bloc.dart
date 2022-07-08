import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:stripe_app/models/creditcard_custom.dart';

part 'pay_event.dart';
part 'pay_state.dart';

class PayBloc extends Bloc<PayEvent, PayState> {
  PayBloc() : super(const PayState()) {
    on<OnSelectCreditcard>((event, emit) => emit(state.copyWith(activeCreditcard: true, creditcard: event.creditcard)));

    on<OnDeactivateCreditcard>((event, emit) => emit(state.copyWith(activeCreditcard: false)));
  }
}
