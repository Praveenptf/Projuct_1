import 'dart:convert';
import 'dart:typed_data';

import 'package:firrst_projuct/cartmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "My Cart",
          style: GoogleFonts.roboto(color: Colors.deepPurple.shade800),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/chevron-back.svg', // Replace with your actual SVG file path
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              Colors.deepPurple.shade800,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: IconThemeData(color: Colors.deepPurple.shade800),
      ),
      body: Consumer<CartModel>(
        builder: (context, cartModel, child) {
          final cartItems = cartModel.cartItems;

          return cartItems.isEmpty
              ? Center(
                  child: Text(
                    "Your cart is empty  !",
                    style: GoogleFonts.roboto(fontSize: 17),
                  ),
                )
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    Uint8List? imageBytes;

                    if (item['itemImage'] != null) {
                      imageBytes = base64Decode(item['itemImage']!);
                    }

                    return Column(
                      children: [
                        ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: imageBytes != null
                                ? Image.memory(
                                    imageBytes,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey,
                                        child: Icon(Icons.error,
                                            color: Colors.white),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey,
                                    child:
                                        Icon(Icons.image, color: Colors.white),
                                  ),
                          ),
                          title: Text(
                            item['title'] ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.roboto(),
                          ),
                          subtitle: Text(
                            '\$${(double.tryParse(item['price'] ?? '0.0') ?? 0.0).toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.roboto(),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.black),
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, index);
                            },
                          ),
                        ),
                        if (index != cartItems.length - 1)
                          Divider(thickness: 1, color: Colors.grey),
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
          title: Text(
            "Confirm Deletion",
            style:
                GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete this item from your cart?",
            style: GoogleFonts.roboto(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.roboto(),
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<CartModel>(context, listen: false)
                    .removeItem(index);
                Navigator.of(context).pop();
              },
              child:
                  Text("Delete", style: GoogleFonts.roboto(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
