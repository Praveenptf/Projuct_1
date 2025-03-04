import 'dart:convert';
import 'dart:typed_data';

import 'package:firrst_projuct/cartmodel.dart';
import 'package:firrst_projuct/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ServicePage extends StatefulWidget {
  final List<Map<String, dynamic>> services; // Keep this as dynamic

  const ServicePage({super.key, required this.services});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  String _selectedFilter = 'All';
  late ScrollController _scrollController;
  bool _isFilterVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isFilterVisible) {
        setState(() {
          _isFilterVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isFilterVisible) {
        setState(() {
          _isFilterVisible = true;
        });
      }
    }
  }

  void addToCart(BuildContext context, Map<String, dynamic> service) {
    // Add the service to the cart
    Provider.of<CartModel>(context, listen: false).addItem({
      'title': service['itemName'],
      'price': service['price'].toString(),
      'itemImage': service['itemImage'] ?? '', // Ensure you have an image URL
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${service['itemName']} added to cart!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showServiceDetails(BuildContext context, Map<String, dynamic> service) {
    showDialog(
      context: context,
      barrierColor:
          Colors.black.withOpacity(0.5), // Black overlay with 50% opacity
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          insetPadding: EdgeInsets.all(20), // Adds spacing from screen edges
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Section
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: service['itemImage'] != null
                          ? Image.memory(
                              base64Decode(service['itemImage']),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(Icons.image,
                                    size: 50, color: Colors.white),
                              ),
                            ),
                    ),

                    SizedBox(height: 16.0),

                    // Service Details
                    Text(
                      service['itemName'] ?? 'Unknown Item',
                      style: GoogleFonts.raleway(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      service['description'] ?? 'No description available',
                      style: GoogleFonts.raleway(
                          fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.0),
                    Divider(),
                    SizedBox(height: 12.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailText(
                            'Price:', '\$${service['price'] ?? 'N/A'}'),
                        _buildDetailText('Available:',
                            service['availability'] == true ? 'Yes' : 'No'),
                      ],
                    ),

                    SizedBox(height: 10.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailText(
                            'Service Time:', service['serviceTime'] ?? 'N/A'),
                      ],
                    ),

                    SizedBox(height: 30.0), // Space before button

                    // Add to Cart Button
                    ElevatedButton(
                      onPressed: () => addToCart(context, service),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 20.0),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: 10.0), // Space at the bottom
                  ],
                ),
              ),

              // Close Button (Outside Container)
              Positioned(
                top: -15,
                right: -15,
                child: ClipOval(
                  child: Material(
                    color: Colors.black.withOpacity(0.5), // Black background
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.close, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Helper function for UI consistency
  Widget _buildDetailText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black),
        children: [
          TextSpan(
              text: '$label ', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value, style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Services",
          style: GoogleFonts.raleway(color: Colors.deepPurple.shade800),
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
        actions: [
          Consumer<CartModel>(
            builder: (context, cart, child) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart,
                      color: Colors.deepPurple.shade800),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(),
                      ),
                    );
                  },
                ),
                if (cart.cartItems.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.cartItems.length}',
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isFilterVisible)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilterDropdown(
                    value: _selectedFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue ?? 'All';
                      });
                    },
                  ),
                ),
              ],
            ),
          Expanded(
              child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0, // Match the first code
              mainAxisSpacing: 8.0, // Match the first code
              childAspectRatio: 0.8, // Match the first code
            ),
            itemCount: _getFilteredServices().length,
            itemBuilder: (context, index) {
              final service = _getFilteredServices()[index];
              Uint8List? imageBytes;

              // Decode the base64 image if available
              if (service['itemImage'] != null) {
                imageBytes = base64Decode(service['itemImage']);
              }

              return GestureDetector(
                onTap: () {
                  _showServiceDetails(
                      context, service); // Show service details on card tap
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to the left
                      children: [
                        // Image Container
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16)), // Match the first code
                          child: imageBytes != null
                              ? Image.memory(
                                  imageBytes,
                                  height: 100, // Match the first code
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Icon(Icons.image,
                                      color: Colors.white,
                                      size: 50), // Match the first code
                                ),
                        ),
                        // Service Details
                        Padding(
                          padding:
                              const EdgeInsets.all(10), // Padding for details
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Ensure text is left-aligned
                            children: [
                              // Service Name
                              Text(
                                service['itemName'] ?? 'Unknown Item',
                                style: GoogleFonts.raleway(
                                  color: Colors.black,
                                  fontSize: 14.0, // Match the first code
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.0), // Match the first code

                              // Price
                              Text(
                                '\$${service['price'] ?? 'N/A'}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 12.0, // Match the first code
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.0), // Match the first code

                              // Availability
                              Text(
                                'Available: ${service['availability'] == true ? 'Yes' : 'No'}',
                                style: GoogleFonts.raleway(
                                  color: Colors.black,
                                  fontSize: 11.0, // Match the first code
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.0), // Match the first code

                              // Service Time
                              Text(
                                'Service Time: ${service['serviceTime'] ?? 'N/A'}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 11.0, // Match the first code
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade800,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepPurple.shade800,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Continue Booking',
                    style: GoogleFonts.raleway(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredServices() {
    if (_selectedFilter == 'All') {
      return widget.services;
    } else {
      return widget.services.where((service) {
        // Check if the service name contains the selected filter keyword (case insensitive)
        return service['itemName'] != null &&
            service['itemName']
                .toString()
                .toLowerCase()
                .contains(_selectedFilter.toLowerCase());
      }).toList();
    }
  }
}

class FilterDropdown extends StatefulWidget {
  final String value;
  final Function(String?) onChanged;

  const FilterDropdown(
      {super.key, required this.value, required this.onChanged});

  @override
  // ignore: library_private_types_in_public_api
  _FilterDropdownState createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              'assets/filter-svgrepo-com.svg',
              width: 10,
              height: 10,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                value: _selectedFilter,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                items: [
                  'All',
                  'Hair',
                  'Spa',
                  'Skin',
                  'Nails',
                ].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value,
                        style: GoogleFonts.raleway(
                            color: Colors.deepPurple.shade800)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  widget.onChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
