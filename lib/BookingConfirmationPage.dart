import 'package:firrst_projuct/PaymentPage.dart';
import 'package:flutter/material.dart';

class BookingConfirmationPage extends StatelessWidget {
  final List<Map<String, String>> selectedServices;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String customerName; // New field for customer name
  final String contactNumber; // New field for contact number
  final int? userId; // Made nullable
  final String orderId; // New field for order ID
  final String paymentId; // New field for payment ID
  final int? itemId; // Made nullable
  final int? shopId; // Made nullable
  final String? selectedEmployeeId;
  final int? quantity; // Made nullable
  final String uniqueId; // New field for unique ID
  final String status; // New field for status

  const BookingConfirmationPage({
    Key? key,
    required this.selectedServices,
    required this.selectedDate,
    required this.selectedTime,
    required this.customerName,
    required this.contactNumber,
    this.userId, // Now nullable
    required this.orderId,
    required this.paymentId,
    this.itemId, // Now nullable
    this.shopId, // Now nullable
    this.selectedEmployeeId,
    this.quantity, // Now nullable
    required this.uniqueId,
    this.status = "Pending", // Default status
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use totalPrice directly, handle null case
    double totalPrice = _calculateTotalAmount();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Booking Confirmation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        // Make the body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Services',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 10),
            // Display selected services
            ListView.builder(
              itemCount: selectedServices.length,
              shrinkWrap:
                  true, // Prevents the ListView from taking infinite height
              physics:
                  NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
              itemBuilder: (context, index) {
                final service = selectedServices[index];
                return Card(
                  color: Colors.white,
                  elevation: 3, // Add shadow for depth
                  margin: EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0), // Reduced padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['title'] ?? '',
                          style: TextStyle(
                            fontSize: 15, // Reduced font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8), // Reduced space
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price: ₹${service['price'] ?? '0.0'}',
                              style: TextStyle(
                                fontSize: 13, // Reduced font size
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Quantity: ${service['quantity'] ?? '1'}',
                              style: TextStyle(
                                fontSize: 13, // Reduced font size
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8), // Reduced space
                        Icon(Icons.check_circle,
                            color: Colors.green, size: 20), // Reduced icon size
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Booking Details',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 15),
                  _buildBookingDetailRow('Customer Name:', customerName),
                  _buildBookingDetailRow('Contact Number:', contactNumber),
                  _buildBookingDetailRow(
                      'User  ID:', userId?.toString() ?? 'N/A'),
                  _buildBookingDetailRow('Order ID:', orderId),
                  _buildBookingDetailRow('Payment ID:', paymentId),
                  _buildBookingDetailRow(
                      'Item ID:', itemId?.toString() ?? 'N/A'),
                  _buildBookingDetailRow(
                      'Parlour ID:', shopId?.toString() ?? 'N/A'),
                  _buildBookingDetailRow(
                      'Employee ID:', selectedEmployeeId?.toString() ?? 'N/A'),
                  _buildBookingDetailRow(
                      'Total Quantity:',
                      _calculateTotalQuantity()
                          .toString()), // Display total quantity
                  _buildBookingDetailRow('Booking Date:',
                      '${selectedDate.toLocal()}'.split(' ')[0]),
                  _buildBookingDetailRow('Booking Time:',
                      '${selectedTime.hourOfPeriod.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00 ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}'),
                  _buildBookingDetailRow('Total Amount:',
                      '₹${totalPrice.toStringAsFixed(2)}'), // Display total amount
                  _buildBookingDetailRow('Unique ID:', uniqueId),
                  _buildBookingDetailRow('Status:', status),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentPage(
                                totalAmount: totalPrice,
                                orderId: orderId,
                              )));
                },
                child: const Text('Confirm Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalAmount() {
    double total = 0.0;
    for (var service in selectedServices) {
      String priceString = service['price'] ?? '0.0';
      double price =
          double.tryParse(priceString.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0.0; // Remove any currency symbols
      int quantity = int.tryParse(service['quantity'] ?? '1') ??
          1; // Default to 1 if quantity is not provided
      total += price * quantity; // Multiply price by quantity
    }
    return total;
  }

  int _calculateTotalQuantity() {
    int totalQuantity = 0;
    for (var service in selectedServices) {
      int quantity = int.tryParse(service['quantity'] ?? '1') ??
          1; // Default to 1 if quantity is not provided
      totalQuantity += quantity;
    }
    return totalQuantity;
  }

  Widget _buildBookingDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
