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
          style: GoogleFonts.lato(color: Colors.deepPurple.shade800),
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
                    style: GoogleFonts.lato(fontSize: 17),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0), // Adjust the value as needed
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      Uint8List? imageBytes;

                      if (item['itemImage'] != null) {
                        imageBytes = base64Decode(item['itemImage']!);
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 100,
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      12), // Adjust the radius as needed
                                  child: imageBytes != null
                                      ? Image.memory(
                                          imageBytes,
                                          fit: BoxFit.cover,
                                          width:
                                              70, // Increased width for the image
                                          height:
                                              70, // Increased height for the image
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12), // Match the radius
                                                color: Colors.grey,
                                              ),
                                              width:
                                                  70, // Increased width for the placeholder
                                              height:
                                                  100, // Increased height for the placeholder
                                              child: Icon(Icons.error,
                                                  color: Colors.white),
                                            );
                                          },
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                12), // Match the radius
                                            color: Colors.grey,
                                          ),
                                          width:
                                              70, // Increased width for the placeholder
                                          height:
                                              100, // Increased height for the placeholder
                                          child: Icon(Icons.image,
                                              color: Colors.white),
                                        ),
                                ),
                                title: Text(
                                  item['title'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(right: 110),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '\$${(double.tryParse(item['price'] ?? '0.0') ?? 0.0).toStringAsFixed(2)}',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(
                                        color: const Color.fromARGB(
                                            255, 101, 206, 93),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                trailing: Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          context, index);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ));
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Confirm Deletion',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          content: Text(
            'Are you sure you want to delete this from your Cart ?',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w600,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                child: Text('Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
                onPressed: () {
                  Provider.of<CartModel>(context, listen: false)
                      .removeItem(index);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
