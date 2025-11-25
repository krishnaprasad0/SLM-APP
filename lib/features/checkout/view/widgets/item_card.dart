import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slm_poc/features/checkout/cubit/checkout_cubit.dart';
import 'package:slm_poc/features/checkout/model/checkout_model.dart';
import 'package:slm_poc/features/checkout/view/widgets/item_list.dart';
import 'package:slm_poc/helper/db/data_base_helper.dart';
import 'package:slm_poc/helper/db/models/product_model.dart';

class ItemCard extends StatelessWidget {
  final List<CheckoutItem> items;
  const ItemCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset('assets/icon/package_ic.png'),
                    ),
                    Text(
                      "₹${items.last.price.toString()}",
                      style: TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        items.last.productName.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.remove, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          items.last.quantity.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final Product? product = await DatabaseHelper
                                  .instance
                                  .getProductByBarcode(
                                    barcode: getRandomItem(),
                                  );
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Product not found'),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.add, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        ItemList(items: items),
      ],
    );
  }
}

String getRandomItem() {
  final products = [
    "89010000000001",
    "89010000000002",
    "89010000000003",
    "89010000000004",
    "89010000000005",
    "89010000000006",
    "89010000000007",
    "89010000000008",
    "89010000000009",
    "89010000000010",
  ];
  return products[Random().nextInt(products.length)];
}
