import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final String orderId;

  const PaymentPage(
      {super.key, required this.totalAmount, required this.orderId});

  @override
  // ignore: library_private_types_in_public_api
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_Lh738g2oARGFbD',
      'amount': (widget.totalAmount * 100).toInt(),
      'name': 'Test Payment',
      'description': 'Payment for testing',
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      // ignore: avoid_print
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Choose Payment Option"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildPaymentOption("Debit / Credit card",
                svgIcon: SvgPicture.asset(
                  'asset/debit-card-svgrepo-com.svg', // Path to your SVG file
                  height: 20, // Set the height as needed
                  width: 20, // Set the width as needed
                ), onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreditCardPage()));
            }),
            _buildPaymentOption(
              "GooglePay",
              svgIcon: SvgPicture.asset(
                'asset/google-icon-svgrepo-com.svg', // Path to your SVG file
                height: 20, // Set the height as needed
                width: 20, // Set the width as needed
              ),
            ),
            _buildPaymentOption(
              "RazorPay",
              svgIcon: SvgPicture.asset(
                'asset/razorpay-icon.svg', // Path to your Razor Pay SVG file
                height: 12, // Set the height as needed
                width: 12, // Set the width as needed
              ),
              onTap: openCheckout,
            ),
            // _buildPaymentOption("Add another option",   svgIcon: SvgPicture.asset(
            //     'assets/icons/google_pay.svg', // Path to your SVG file
            //     height: 30, // Set the height as needed
            //     width: 30, // Set the width as needed
            //   ),),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title,
      {IconData? icon, SvgPicture? svgIcon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            svgIcon ??
                (icon != null
                    ? Icon(icon, size: 30)
                    : Container()), // Use SVG icon if provided
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // ignore: avoid_print
    print("Payment Success: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // ignore: avoid_print
    print("Payment Error: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // ignore: avoid_print
    print("External Wallet: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}

class CreditCardPage extends StatelessWidget {
  const CreditCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Debit / Credit Card"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: "Card Number",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Expiry Date",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "CVV",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Name on Card",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle payment processing
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Center(
                  child: Text("Pay Now", style: TextStyle(fontSize: 18))),
            ),
          ],
        ),
      ),
    );
  }
}
