import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
// ignore: unused_import
import 'product.dart';
import 'checkout.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Cart")),
      body:
          cart.cartItems.isEmpty
              ? Center(child: Text("Your cart is empty"))
              : ListView.builder(
                itemCount: cart.cartItems.length,
                itemBuilder: (context, index) {
                  final product = cart.cartItems[index];
                  return ListTile(
                    leading: Image.asset(product.image, width: 50, height: 50),
                    title: Text(product.name),
                    subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        cart.removeFromCart(product);
                      },
                    ),
                  );
                },
              ),
      bottomNavigationBar:
          cart.cartItems.isNotEmpty
              ? Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    print("Proceed to Checkout"); // Debugging
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckoutPage()),
                    );
                  },
                  child: Text(
                    "Proceed to Checkout (\$${cart.totalPrice.toStringAsFixed(2)})",
                  ),
                ),
              )
              : SizedBox.shrink(),
    );
  }
}
