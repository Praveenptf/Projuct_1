import 'dart:convert';
import 'dart:typed_data';
import 'package:firrst_projuct/BookingConfirmationPage.dart';
import 'package:firrst_projuct/CartModel.dart';
import 'package:firrst_projuct/CartPage.dart';
import 'package:firrst_projuct/ServicePage.dart';
import 'package:firrst_projuct/TokenManager.dart';
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
  final String imageUrl; // Add this line

  const BookingPage({
    super.key,
    required this.title,
    required this.shopName,
    required this.shopAddress,
    required this.contactNumber,
    required this.description,
    required this.id,
    required this.imageUrl,
    required parlourDetails, // Add this line
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isAvailable = true;
  final Set<String> selectedServiceTitles = {};
  bool isLoading = false;
  int get shopId => widget.id;
  List<Map<String, dynamic>> services = [];
  String? selectedEmployeeId;
  String? selectedEmployeeName;

  void addToCart(BuildContext context, Map<String, dynamic> service) {
    // Add the service to the cart
    Provider.of<CartModel>(context, listen: false).addItem({
      'title': service['itemName'],
      'price': service['price'].toString(),
      'itemImage': service['itemImage'] ?? '', // Ensure you have an image URL
    });

    selectedServiceTitles.add(service['itemName']!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${service['itemName']} added to cart!',
          style: GoogleFonts.oxanium(),
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
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.26:8086/api/Items/itemByParlourId?parlourId=$shopId'), // Update the URL as needed
        headers: {
          'Content-Type': 'application/json',
          'Cookie':
              'JSESSIONID=88A396C56F7380D4FE65D5FBACB52C14', // Include the session ID
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
              'itemImage': service['itemImage'], // Adjust the key if necessary
            };
          }).toList();
        });
      } else {
        setState(() {
          services = []; // Set to empty list if no services are available
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
    }
  }

  List<Map<String, dynamic>> employees = [];

  Future<void> _fetchEmployees() async {
    try {
      // String? token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.26:8086/api/employees/by-parlourId?parlourId=$shopId'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          employees = jsonResponse.map((employee) {
            return {
              'id': employee['id'],
              'employeeName': employee['employeeName'],
              'isAvailable':
                  employee['isAvailable'] ?? true, // Default to false if null
              // 'image': employee['image'], // Assuming you have an image URL
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load employees');
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
        "itemId": 1, // Replace with the actual item ID
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
      Uri.parse('http://192.168.1.26:8086/api/cart/add'),
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
      print('Appointment booked successfully!');
      Navigator.push(
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
      print('Failed to book appointment: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book appointment: ${response.body}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.oxanium(color: Colors.deepPurple.shade800),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/chevron-back.svg', // Replace with your SVG asset path
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
                        style: GoogleFonts.oxanium(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: widget.imageUrl.isEmpty
                  ? Image.asset(
                      'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg',
                    )
                  : Image.memory(
                      Uint8List.fromList(base64Decode(widget.imageUrl)),
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error'); // Debugging
                        return Image.asset(
                          'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            Divider(),
            _buildSectionTitle('Shop Information'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shopName,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
                SizedBox(height: 5), // Small gap
                Text(
                  widget.shopAddress,
                  style: GoogleFonts.oxanium(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8), // Slightly bigger gap

                Text(
                  widget.contactNumber,
                  style: GoogleFonts.oxanium(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 5), // Small gap
                Text(
                  widget.description,
                  style: GoogleFonts.oxanium(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 13,
            ),
            Divider(),
            Row(
              children: [
                _buildSectionTitle('Available Services'),
                Spacer(), // Pushes the button to the right
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServicePage(services: services),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: GoogleFonts.oxanium(
                      color: Colors.deepPurple.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            _buildServiceList(),
            SizedBox(height: 20),
            Divider(),
            _buildSectionTitle('Available Employees'), // New section title
            _buildEmployeeList(),
            SizedBox(
              height: 10,
            ), // Display employee list
            _buildSectionTitle('Booking Time'),
            Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 0), // Remove default padding
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.deepPurple.shade800),
                          SizedBox(width: 8), // Space between icon and text
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              selectedDate != null
                                  ? DateFormat.yMMMd().format(selectedDate!)
                                  : 'Select Date',
                              style: GoogleFonts.oxanium(
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
                  onTap: () => _selectDate(context),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 0), // Remove default padding
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              color: Colors.deepPurple.shade800),
                          SizedBox(width: 8), // Space between icon and text
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
                              style: GoogleFonts.oxanium(
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
              style: GoogleFonts.oxanium(
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    textStyle: GoogleFonts.oxanium(fontSize: 16),
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
                          style: GoogleFonts.oxanium(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.oxanium(
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
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.65,
      ),
      itemCount: limitedServices.length,
      itemBuilder: (context, index) {
        final service = limitedServices[index];
        Uint8List? imageBytes;

        // Decode the base64 image if available
        if (service['itemImage'] != null) {
          imageBytes = base64Decode(service['itemImage']);
        }

        return Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
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
              // Display the image
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(8.0), // Rounded corners for the image
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.grey[400],
                        child: Center(
                          child:
                              Icon(Icons.image, color: Colors.white, size: 50),
                        ),
                      ),
              ),
              SizedBox(height: 8.0),

              // Item Name
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  service['itemName'] ?? 'Unknown Item',
                  style: GoogleFonts.oxanium(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 6.0),

              // Price
              Text(
                '\$${service['price'] ?? 'N/A'}',
                style: GoogleFonts.oxanium(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5.0),

              // // Description
              // Flexible(
              //   child: Text(
              //     service['description'] ?? 'No Description', // Handle null
              //     style: TextStyle(color: Colors.black, fontSize: 12.0),
              //     maxLines: 2, // Limit to two lines
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // ),
              // SizedBox(height: 5.0),

              // // Availability
              Text(
                'Available: ${service['availability'] == true ? 'Yes' : 'No'}',
                style: GoogleFonts.oxanium(
                  color: Colors.black,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 3.0),

              // Service Time
              Text(
                'Service Time: ${service['serviceTime'] ?? 'N/A'}',
                style: GoogleFonts.oxanium(
                  color: Colors.black,
                  fontSize: 12.0,
                ),
              ),
              SizedBox(height: 7.0),

              // Add to Cart Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    addToCart(context, service);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    'Add to Cart',
                    style: GoogleFonts.oxanium(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildEmployeeList() {
    return Container(
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
                      style: GoogleFonts.oxanium(
                          color: Colors.black, fontSize: 14.0)),
                  Text(employee['employeeName'],
                      style: GoogleFonts.oxanium(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold)),
                  Text(
                    employee['isAvailable'] ? 'Available' : 'Not Available',
                    style: GoogleFonts.oxanium(
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

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showSpinnerTimePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Time',
            style: GoogleFonts.oxanium(),
          ),
          content: Container(
            height: 200,
            child: TimePickerSpinner(
              is24HourMode: false,
              normalTextStyle:
                  GoogleFonts.oxanium(fontSize: 20, color: Colors.black),
              highlightedTextStyle: GoogleFonts.oxanium(
                  fontSize: 24, color: Colors.deepPurple.shade800),
              spacing: 20,
              itemHeight: 40,
              onTimeChange: (time) {
                setState(() {
                  selectedTime = TimeOfDay.fromDateTime(time);
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
