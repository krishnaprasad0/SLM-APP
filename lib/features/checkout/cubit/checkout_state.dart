import 'package:equatable/equatable.dart';
import 'package:slm_poc/features/checkout/model/checkout_model.dart';

class CheckoutState extends Equatable {
  final List<CheckoutItem> items;

  const CheckoutState({this.items = const []});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  @override
  List<Object?> get props => [items];
}
