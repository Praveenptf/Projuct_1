import 'package:firrst_projuct/CartModel.dart';
import 'package:firrst_projuct/CartPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
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
      'imageUrl': service['imageUrl'] ?? '', // Ensure you have an image URL
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${service['itemName']} added to cart!'),
        duration: Duration(seconds: 2),
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
          style: TextStyle(color: Colors.deepPurple.shade800),
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
                        builder: (context) =>
                            CartPage(cartItems: cart.cartItems),
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
                        style: TextStyle(
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
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of items in a row
                crossAxisSpacing: 8.0, // Spacing between items horizontally
                mainAxisSpacing: 8.0, // Spacing between items vertically
                childAspectRatio:
                    0.65, // Adjusted aspect ratio to prevent overflow
              ),
              itemCount: _getFilteredServices().length,
              itemBuilder: (context, index) {
                final service = _getFilteredServices()[index];
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color for the container
                      borderRadius: BorderRadius.circular(8.0), // Rounded edges
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image placeholder or actual image
                        Container(
                          height: 100, // Adjusted height
                          width: double
                              .infinity, // Full width of the parent container
                          decoration: BoxDecoration(
                            color: Colors.grey[500], // Placeholder color
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Icon(Icons.image,
                                color: Colors.white, size: 50),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            service['itemName'] ?? 'No Name', // Handle null
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1, // Limit text to one line
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          '\$${service['price']?.toString() ?? '0.00'}', // Handle null
                          style: TextStyle(color: Colors.black, fontSize: 14.0),
                        ),
                        SizedBox(height: 4.0),
                        Flexible(
                          child: Text(
                            service['description'] ??
                                'No Description', // Handle null
                            style:
                                TextStyle(color: Colors.black, fontSize: 12.0),
                            maxLines: 2, // Limit to two lines
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Available: ${service['availability'] ? 'Yes' : 'No'}',
                          style: TextStyle(color: Colors.black, fontSize: 12.0),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Service Time: ${service['serviceTime'] ?? 'N/A'}', // Handle null
                          style: TextStyle(color: Colors.black, fontSize: 12.0),
                        ),
                        SizedBox(height: 8.0), // Reduced space above the button
                        Container(
                          width: double
                              .infinity, // Ensure button spans the container width
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              addToCart(context, service);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Button color
                            ),
                            child: Text('Add to Cart',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
                  child: Text('Continue Booking'),
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
      return widget.services
          .where((service) => service['category'] == _selectedFilter)
          .toList();
    }
  }
}

class FilterDropdown extends StatefulWidget {
  final String value;
  final Function(String?) onChanged;

  const FilterDropdown({Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
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
                    child: Text(value,
                        style: TextStyle(color: Colors.deepPurple.shade800)),
                    value: value,
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
