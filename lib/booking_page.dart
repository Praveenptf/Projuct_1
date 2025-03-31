import 'dart:convert';
import 'dart:typed_data';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:firrst_projuct/bookingconfirmation_page.dart';
import 'package:firrst_projuct/cartmodel.dart';
import 'package:firrst_projuct/cart_page.dart';
import 'package:firrst_projuct/service_page.dart';
import 'package:firrst_projuct/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class BookingPage extends StatefulWidget {
  final String title;
  final String shopName;
  final String shopAddress;
  final String contactNumber;
  final String description;
  final int id;
  final String imageUrl;

  const BookingPage({
    super.key,
    required this.title,
    required this.shopName,
    required this.shopAddress,
    required this.contactNumber,
    required this.description,
    required this.id,
    required this.imageUrl,
    required parlourDetails,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isAvailable = true;
  final Set<String> selectedServiceTitles = {};
  bool isLoading = true;
  int get shopId => widget.id;
  List<Map<String, dynamic>> services = [];
  String? selectedEmployeeId;
  String? selectedEmployeeName;

  void addToCart(BuildContext context, Map<String, dynamic> service) {
    // Add the service to the cart
    Provider.of<CartModel>(context, listen: false).addItem({
      'title': service['itemName'],
      'price': service['price'].toString(),
      'itemImage': service['itemImage'] ?? '',
    });

    selectedServiceTitles.add(service['itemName']!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${service['itemName']} added to cart!',
          style: GoogleFonts.roboto(),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  double _calculateTotalAmount() {
    double total = 0.0;
    for (var item in Provider.of<CartModel>(context, listen: false).cartItems) {
      String priceString = item['price'] ?? '0.0';
      double price = double.tryParse(priceString) ?? 0.0;
      int quantity = int.tryParse(item['quantity'] ?? '1') ?? 1;
      total += price * quantity;
    }
    return total;
  }

  int _calculateTotalQuantity() {
    int totalQuantity = 0;
    for (var item in Provider.of<CartModel>(context, listen: false).cartItems) {
      int quantity = int.tryParse(item['quantity'] ?? '1') ?? 1;
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _fetchEmployees();
  }

  Future<void> _fetchServices() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.20:8086/api/Items/itemByParlourId?parlourId=$shopId'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'JSESSIONID=88A396C56F7380D4FE65D5FBACB52C14',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          // Assuming the response is a list of items
          services = jsonResponse.map((service) {
            return {
              'itemName': service['itemName'],
              'price': service['price'],
              'description': service['description'],
              'availability': service['availability'],
              'serviceTime': service['serviceTime'],
              'itemImage': service['itemImage'],
            };
          }).toList();
        });
      } else {
        setState(() {
          services = [];
        });
      }
    } catch (e) {
      print('Error fetching services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching services: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  List<Map<String, dynamic>> employees = [];
  Future<void> _fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.20:8086/api/employees/by-parlourId?parlourId=$shopId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          employees = jsonResponse.map((employee) {
            return {
              'id': employee['id'],
              'employeeName': employee['employeeName'],
              'image': employee['image'],
              'isAvailable': employee['isAvailable'] ?? true,
            };
          }).toList();
        });
      } else {
        print(
            'Error fetching employees: ${response.statusCode} - ${response.body}');
        setState(() {
          employees = [];
        });
      }
    } catch (e) {
      print('Error fetching employees: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching employees: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _bookAppointment() async {
    setState(() {
      isLoading = true;
    });

    String? token = await TokenManager.getToken();

    List<Map<String, dynamic>> bookingData = [
      {
        "userId": 1, // Use the retrieved user ID here
        "itemIds": 1, // Replace with the actual item ID
        "itemName": selectedServiceTitles.join(', '),
        "actualPrice": _calculateTotalAmount(),
        "parlourId": shopId,
        "parlourName": widget.shopName,
        "employeeId": selectedEmployeeId,
        "employeeName": selectedEmployeeName,
        "quantity": _calculateTotalQuantity(),
        "bookingDate": DateFormat('yyyy-MM-dd').format(selectedDate!),
        "bookingTime": DateFormat('HH:mm:ss').format(
            DateTime(2020, 1, 1, selectedTime!.hour, selectedTime!.minute, 00)),
      }
    ];

    final response = await http.post(
      Uri.parse('http://192.168.1.20:8086/bookings/book'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(bookingData),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // ignore: avoid_print
      print('Appointment booked successfully!');
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationPage(
            selectedServices:
                Provider.of<CartModel>(context, listen: false).cartItems,
            selectedDate: selectedDate!,
            selectedTime: selectedTime!,
            customerName: '',
            contactNumber: '',
            orderId: '',
            paymentId: '',
            uniqueId: '',
            shopId: shopId,
            selectedEmployeeId: selectedEmployeeId, // Pass selected employee ID
          ),
        ),
      );
    } else {
      // ignore: avoid_print
      print('Failed to book appointment: ${response.body}');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment: ${response.body}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
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
                      style: GoogleFonts.lato(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      service['description'] ?? 'No description available',
                      style:
                          GoogleFonts.lato(fontSize: 16, color: Colors.black54),
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
                        style: GoogleFonts.lato(
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
        style: GoogleFonts.lato(fontSize: 16, color: Colors.black),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 300.0,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.imageUrl.isEmpty
                  ? Image.asset(
                      'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg',
                      fit: BoxFit.cover,
                    )
                  : Image.memory(
                      Uint8List.fromList(base64Decode(widget.imageUrl)),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
            pinned: true,
            backgroundColor: Colors.transparent,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/chevron-back.svg',
                        width: 24,
                        height: 24,
                        color: Colors.white, // Use dynamic text color
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Consumer<CartModel>(
                      builder: (context, cart, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon:
                                Icon(Icons.shopping_cart, color: Colors.white),
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
                                  style: GoogleFonts.lato(
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
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.shopName,
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Aligns children to the start
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .start, // Aligns items to the start
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(
                                  width:
                                      8), // Horizontal spacing between icon and text
                              Expanded(
                                // Allows the text to take up remaining space
                                child: Text(
                                  widget.shopAddress,
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8), // Vertical spacing between rows
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.phone,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.contactNumber,
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8), // Consistent vertical spacing
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.description,
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          _buildSectionTitle('Available Services'),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ServicePage(services: services),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: GoogleFonts.lato(
                                color: Colors.deepPurple.shade400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildServiceList(),
                      Divider(),
                      _buildSectionTitle('Available Employees'),
                      _buildEmployeeList(),
                      Divider(),
                      SizedBox(height: 10),
                      _buildSectionTitle('Booking Time'),
                      Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.deepPurple.shade800),
                                    SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        selectedDate != null
                                            ? DateFormat.yMMMd()
                                                .format(selectedDate!)
                                            : 'Select Date',
                                        style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.deepPurple.shade800),
                              ],
                            ),
                            onTap: () => _selectDate(),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Colors.deepPurple.shade800),
                                    SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        selectedTime != null
                                            ? DateFormat.jm().format(DateTime(
                                                2020,
                                                1,
                                                1,
                                                selectedTime!.hour,
                                                selectedTime!.minute,
                                                00))
                                            : 'Select Time',
                                        style: GoogleFonts.lato(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.deepPurple.shade800),
                              ],
                            ),
                            onTap: () {
                              _showSpinnerTimePicker(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildSectionTitle('Availability'),
                      Text(
                        isAvailable
                            ? 'The shop is available at this time.'
                            : 'The shop is not available at this time.',
                        style: GoogleFonts.lato(
                            fontSize: 16,
                            color: isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Center(
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              textStyle: GoogleFonts.lato(fontSize: 16),
                              backgroundColor: Colors.deepPurple.shade800,
                              foregroundColor: Colors.deepPurple.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: isAvailable &&
                                    selectedDate != null &&
                                    selectedTime != null &&
                                    !isLoading
                                ? () async {
                                    await _bookAppointment();
                                  }
                                : null,
                            child: isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color.fromARGB(255, 69, 39, 160)),
                                  )
                                : Text('Book Now',
                                    style:
                                        GoogleFonts.lato(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lato(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildServiceList() {
    final limitedServices = services.take(2).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0, // Match the first code
        mainAxisSpacing: 8.0, // Match the first code
        childAspectRatio: 0.8, // Match the first code
      ),
      itemCount: limitedServices.length,
      itemBuilder: (context, index) {
        final service = limitedServices[index];
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
                    padding: const EdgeInsets.all(8.0), // Padding for details
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Ensure text is left-aligned
                      children: [
                        // Service Name
                        Text(
                          service['itemName'] ?? 'Unknown Item',
                          style: GoogleFonts.lato(
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
                          style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 12.0, // Match the first code
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.0), // Match the first code

                        // Availability
                        Text(
                          'Available: ${service['availability'] == true ? 'Yes' : 'No'}',
                          style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 11.0, // Match the first code
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.0), // Match the first code

                        // Service Time
                        Text(
                          'Service Time: ${service['serviceTime'] ?? 'N/A'}',
                          style: GoogleFonts.lato(
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
    );
  }

  Widget _buildEmployeeList() {
    return SizedBox(
      height: 200, // Set a fixed height for the horizontal list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          Uint8List? imageBytes;

          if (employee['image'] != null) {
            imageBytes = base64Decode(employee['image']);
          }

          bool isSelected = selectedEmployeeId == employee['id'].toString();

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  // Unselect if already selected
                  selectedEmployeeId = '';
                  selectedEmployeeName = '';
                } else {
                  // Select the employee
                  selectedEmployeeId = employee['id'].toString();
                  selectedEmployeeName = employee['employeeName'];
                }
              });
            },
            child: Container(
              width: 140, // Set a fixed width for each employee card
              margin: EdgeInsets.symmetric(horizontal: 4.0), // Add some spacing
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[100] : Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  imageBytes != null
                      ? Image.memory(
                          imageBytes,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 100,
                          color: Colors.grey[500],
                          child: Center(
                            child: Icon(Icons.person,
                                color: Colors.white, size: 50),
                          ),
                        ),
                  SizedBox(height: 8.0),
                  Text('ID: ${employee['id']}',
                      style: GoogleFonts.lato(
                          color: Colors.black, fontSize: 14.0)),
                  Text(employee['employeeName'],
                      style: GoogleFonts.raleway(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold)),
                  Text(
                    employee['isAvailable'] ? 'Available' : 'Not Available',
                    style: GoogleFonts.lato(
                      color:
                          employee['isAvailable'] ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isSelected) // Show a checkmark or any indicator if selected
                    Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectDate() async {
    List<DateTime?> picked = await showCalendarDatePicker2Dialog(
          context: context,
          config: CalendarDatePicker2WithActionButtonsConfig(
            calendarType:
                CalendarDatePicker2Type.single, // Single date selection
            selectedDayHighlightColor: Colors.deepPurple.shade800,
            firstDate: DateTime.now(),
            dayTextStyle:
                TextStyle(color: Colors.black), // Change text color to black
            selectedDayTextStyle: TextStyle(
                color:
                    Colors.white), // Change selected day text color if needed
          ),
          dialogBackgroundColor: Colors.white,
          value: [selectedDate],
          dialogSize: Size(350, 350),
        ) ??
        [];

    if (picked.isNotEmpty && picked.first != null) {
      setState(() {
        selectedDate = picked.first!;
      });
    }
  }

  void _showSpinnerTimePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: Text(
            'Select Time',
            style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center, // Center highlight effect
              children: [
                // Highlighter Box for Selected Time
                Positioned(
                  top: 80, // Adjust based on itemHeight
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40, // Same height as itemHeight
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100
                          .withOpacity(0.5), // Highlight color
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Time Picker
                TimePickerSpinner(
                  is24HourMode: false,
                  normalTextStyle: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.grey.shade600, // Unselected text dimmed
                  ),
                  highlightedTextStyle: GoogleFonts.lato(
                    fontSize: 24, // Larger font for selected time
                    fontWeight: FontWeight.bold,
                    color:
                        Colors.deepPurple.shade800, // Highlighted selected time
                  ),
                  spacing: 20,
                  itemHeight: 40, // Must match highlighter height
                  isForce2Digits: true,
                  onTimeChange: (time) {
                    setState(() {
                      selectedTime = TimeOfDay.fromDateTime(time);
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Done',
                style:
                    GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
