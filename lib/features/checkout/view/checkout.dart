import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slm_poc/features/checkout/cubit/checkout_cubit.dart';
import 'package:slm_poc/features/checkout/cubit/checkout_state.dart';
import 'package:slm_poc/features/checkout/view/widgets/empty_cart.dart';
import 'package:slm_poc/features/checkout/view/widgets/item_card.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add to cart')),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => CheckoutCubit(),
          child: BlocConsumer<CheckoutCubit, CheckoutState>(
            listener: (context, state) {},
            builder: (context, state) {
              return state.items.isEmpty
                  ? EmptyCart()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ItemCard(items: state.items),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 20,
                                bottom: 20,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/billPage',
                                    arguments: state.items,
                                  );
                                },
                                child: Text(
                                  'Checkout',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
