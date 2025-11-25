import 'package:bloc/bloc.dart';
import 'package:slm_poc/features/checkout/cubit/checkout_state.dart';
import 'package:slm_poc/features/checkout/model/checkout_model.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(const CheckoutState());

  /// ---------------------------------------------------
  /// ADD ITEM (or increase quantity if exists)
  /// ---------------------------------------------------
  void addItem(CheckoutItem item) {
    final list = List<CheckoutItem>.from(state.items);

    final index = list.indexWhere((e) => e.productId == item.productId);

    if (index >= 0) {
      // Product already in cart → increase quantity
      final updated = list[index].copyWith(quantity: list[index].quantity + 1);
      list[index] = updated;
    } else {
      list.add(item);
    }

    emit(CheckoutState(items: list));
  }

  /// ---------------------------------------------------
  /// REMOVE ITEM COMPLETELY
  /// ---------------------------------------------------
  void removeItem(int productId) {
    final list = state.items.where((e) => e.productId != productId).toList();
    emit(CheckoutState(items: list));
  }

  /// ---------------------------------------------------
  /// INCREASE QUANTITY
  /// ---------------------------------------------------
  void increaseQty(int productId) {
    final list = List<CheckoutItem>.from(state.items);
    final index = list.indexWhere((e) => e.productId == productId);

    if (index >= 0) {
      list[index] = list[index].copyWith(quantity: list[index].quantity + 1);
    }

    emit(CheckoutState(items: list));
  }

  /// ---------------------------------------------------
  /// DECREASE QUANTITY
  /// ---------------------------------------------------
  void decreaseQty(int productId) {
    final list = List<CheckoutItem>.from(state.items);
    final index = list.indexWhere((e) => e.productId == productId);

    if (index >= 0) {
      if (list[index].quantity > 1) {
        list[index] = list[index].copyWith(quantity: list[index].quantity - 1);
      } else {
        list.removeAt(index); // remove if qty goes to 0
      }
    }

    emit(CheckoutState(items: list));
  }

  /// ---------------------------------------------------
  /// CLEAR CART
  /// ---------------------------------------------------
  void clearCart() {
    emit(const CheckoutState(items: []));
  }
}
