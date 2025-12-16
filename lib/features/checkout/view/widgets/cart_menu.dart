import 'package:flutter/material.dart';

class CartMenu extends StatelessWidget {
  const CartMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/billPage');
            },
            child: Text('Checkout', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
