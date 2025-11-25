import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slm_poc/features/checkout/cubit/checkout_cubit.dart';
import 'package:slm_poc/features/checkout/model/checkout_model.dart';
import 'package:slm_poc/helper/db/data_base_helper.dart';
import 'package:slm_poc/helper/db/models/product_model.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Product? product = await DatabaseHelper.instance
            .getProductByBarcode(barcode: "89010000000029");
        if (product != null) {
          context.read<CheckoutCubit>().addItem(
            CheckoutItem(
              barcode: product.barcode,
              productId: product.productId,
              productName: product.productName,
              price: product.productPrice,
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Product not found')));
        }
      },
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset('assets/icon/empty_cart_ic.png'),
            ),
            const SizedBox(height: 10),
            Text(
              'The cart is empty',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
