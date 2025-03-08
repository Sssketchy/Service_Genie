import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'product.dart';
import 'cart_page.dart';

class MarketplacePage extends StatelessWidget {
  final List<Product> products = [
    Product(
      name: "Car Seat Cover",
      image: "assets/seat_cover.webp",
      price: 100,
    ),
    Product(
      name: "Steering Wheel Cover",
      image: "assets/wheel_cover.jpg",
      price: 2500,
    ),
    Product(name: "Engine Oil", image: "assets/engine_oil.webp", price: 80),
    Product(
      name: "Door Edge Guard",
      image: "assets/door_protector.webp",
      price: 800,
    ),
    Product(name: "Rain Visors", image: "assets/rain_visor.jpg", price: 29.99),
    Product(
      name: "Car Vacuum Cleaner",
      image: "assets/vacuum_cleaner.jpg",
      price: 5000,
    ),
    Product(
      name: "Portable Tire Inflator",
      image: "assets/tire_inflator.jpg",
      price: 3000,
    ),
    Product(
      name: "Jump Starter Kit",
      image: "assets/jump_starter.jpg",
      price: 4000,
    ),
    Product(
      name: "Car Bluetooth FM Transmitter",
      image: "assets/bluetooth.jpg",
      price: 900,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marketplace"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            // Wrap ListTile in a Card for better layout
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            elevation: 4, // Adds a slight shadow effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(
                12,
              ), // Proper spacing inside ListTile
              leading: SizedBox(
                width: 60,
                height: 60,
                child: Image.asset(
                  product.image,
                  fit: BoxFit.cover, // Ensures proper image scaling
                ),
              ),
              title: Text(
                product.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                "Rs${product.price.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).addToCart(product);
                },
                child: Text("Add to Cart"),
              ),
            ),
          );
        },
      ),
    );
  }
}
