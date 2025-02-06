import 'package:firrst_projuct/CartModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Services",
          style: TextStyle(color: Colors.deepPurple.shade800),
        ),
        iconTheme: IconThemeData(color: Colors.deepPurple.shade800),
      ),
      body: Consumer<CartModel>(
        builder: (context, cartModel, child) {
          final cartItems = cartModel.cartItems;

          return cartItems.isEmpty
              ? Center(
                  child: Text(
                    "Your cart is empty",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            child: Image.network(
                              item['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  child: Icon(Icons.error, color: Colors.white),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            item['title'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '\$${(double.tryParse(item['price'] ?? '0.0') ?? 0.0).toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.black),
                            onPressed: () {
                              // Show confirmation dialog before deleting
                              _showDeleteConfirmationDialog(context, index);
                            },
                          ),
                        ),
                        if (index != cartItems.length - 1)
                          Divider(
                              thickness: 1,
                              color: Colors.grey), // Add divider between items
                      ],
                    );
                  },
                );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content:
              Text("Are you sure you want to delete this item from your cart?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<CartModel>(context, listen: false)
                    .removeItem(index);
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
