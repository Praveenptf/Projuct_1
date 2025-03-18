import 'package:firrst_projuct/booking_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  final List<dynamic> parlours;

  const SearchPage({super.key, required this.parlours});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredParlours = [];

  @override
  void initState() {
    super.initState();
    filteredParlours = widget.parlours; // Initialize with all parlours
  }

  void _filterParlours(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredParlours = widget.parlours; // Reset to original list
      });
    } else {
      setState(() {
        filteredParlours = widget.parlours.where((parlour) {
          String parlourName = parlour['parlourName']?.toLowerCase() ?? '';
          return parlourName.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.all(5.0), // Add padding to the left
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterParlours,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.lato(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.deepPurple.shade300,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: Colors.grey), // Set border color to gray
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: Colors
                                .grey), // Set enabled border color to gray
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: Colors
                                .grey), // Set focused border color to gray
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: GoogleFonts.lato(
                        color: Colors.black), // Change text color
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white, // Set your desired background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 2),
            Expanded(
              child: ListView.builder(
                itemCount: filteredParlours.length,
                itemBuilder: (context, index) {
                  final parlour = filteredParlours[index];
                  return ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.deepPurple
                          .shade300, // You can change the color as needed
                    ),
                    title: Text(
                      parlour['parlourName'] ?? 'Unknown',
                      style: GoogleFonts.lato(),
                    ),
                    subtitle: Text(
                      parlour['location'] ?? 'No Location',
                      style: GoogleFonts.lato(),
                    ),
                    onTap: () {
                      // Navigate to BookingPage or any other page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            title: parlour['parlourName'] ?? '',
                            shopName: parlour['parlourName'] ?? '',
                            shopAddress:
                                parlour['location'] ?? 'No Address Available',
                            contactNumber: parlour['phoneNumber'] ??
                                'No Contact Available',
                            description: parlour['description'] ??
                                'No Description Available',
                            id: parlour['id'] ?? 'No id',
                            imageUrl: parlour['image'] ?? '',
                            parlourDetails: parlour,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
