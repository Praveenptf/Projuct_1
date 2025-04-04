import 'dart:convert';
import 'dart:typed_data';
import 'package:firrst_projuct/DoorToDoorService.dart';
import 'package:firrst_projuct/booking_page.dart';
import 'package:firrst_projuct/categories.dart';
import 'package:firrst_projuct/image_carousel.dart';
import 'package:firrst_projuct/map_page.dart';
import 'package:firrst_projuct/parlourspage.dart';
import 'package:firrst_projuct/profile_screen.dart';
import 'package:firrst_projuct/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'package:http/http.dart' as http; // Import http for network requests

class HomePage extends StatefulWidget {
  final List<dynamic> initialNearbyParlours;

  const HomePage({super.key, this.initialNearbyParlours = const []});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  List<dynamic> _nearbyParlours = [];
  bool _isLoading = true;
  bool _isAppBarVisible = true;
  TextEditingController searchController = TextEditingController();
  late ScrollController _scrollController;
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _nearbyParlours = widget.initialNearbyParlours;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        searchController.clear();
      }
    });

    // Call the async method to get location and nearby parlours
    _getLocationAndNearbyParlours();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  Future<void> _getLocationAndNearbyParlours() async {
    setState(() {
      _isLoading = true; // Set loading state
    });

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.high);
      await _fetchNearbyParlours(position.latitude, position.longitude);
    } else {
      // Handle permission denied case
      _showLocationPermissionDialog();
    }
  }

  Future<void> _fetchNearbyParlours(double latitude, double longitude) async {
    final url = Uri.parse(
        "http://192.168.1.20:8086/api/user/userLocation?latitude=$latitude&longitude=$longitude");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> nearbyParlours = jsonDecode(response.body);
        setState(() {
          _nearbyParlours = nearbyParlours; // Update nearby parlours
          _isLoading = false; // Set loading state to false
        });
      } else {
        // ignore: avoid_print
        print(
            "Failed to fetch nearby parlours. Status Code: ${response.statusCode}");
        setState(() {
          _isLoading = false; // Set loading state to false
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching nearby parlours: $e");
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Location Permission Required"),
          content:
              Text("Please grant location permission to use this feature."),
          actions: [
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isAppBarVisible) setState(() => _isAppBarVisible = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isAppBarVisible) setState(() => _isAppBarVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Scaffold(
        backgroundColor: Colors.white,
        appBar: _isAppBarVisible
            ? AppBar(
                elevation: 0,
                toolbarHeight: 125,
                backgroundColor: Colors.white,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.deepPurple.shade50,
                        Colors.white,
                      ],
                    ),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Salon Info",
                          style: GoogleFonts.lato(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade800,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple.shade400,
                                Colors.deepPurple.shade800,
                              ],
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.location_on, color: Colors.white),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Mappage(
                                    onLocationSelected:
                                        (location, nearbyParlours) {
                                      setState(() {
                                        _nearbyParlours = nearbyParlours;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
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
                        onTap: () {
                          // Navigate to the SearchPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SearchPage(parlours: _nearbyParlours),
                            ),
                          );
                        },
                        readOnly:
                            true, // Make it read-only to prevent keyboard from showing
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle:
                              GoogleFonts.lato(color: Colors.grey.shade400),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.deepPurple.shade300,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                automaticallyImplyLeading: false,
              )
            : null,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 16),
                  ImageCarousel(
                    onImageTap: (offerId) {
                      // Find the corresponding parlour using the offerId
                      final parlour = _nearbyParlours.firstWhere(
                        (parlour) =>
                            parlour['id'] ==
                            offerId, // Ensure this matches your data structure
                        orElse: () => null,
                      );

                      if (parlour != null) {
                        // Navigate to the BookingPage with the parlour details
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
                              id: parlour['id'] ?? 0,
                              imageUrl: parlour['image'] ?? '',
                              parlourDetails: parlour,
                            ),
                          ),
                        );
                      } else {
                        // Handle the case where no matching parlour is found
                        print(
                            "No matching parlour found for offerId: $offerId");
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  // In your build method
                  CategoriesSection(),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Services',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade800,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Parlours(
                                  parlourShops: _nearbyParlours,
                                  serviceFilter: searchController.text,
                                ),
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
                  ),
                  SizedBox(height: 16),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple.shade400,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _nearbyParlours.length,
                          itemBuilder: (context, index) {
                            final parlour = _nearbyParlours[index];
                            String? imageUrl = parlour['image'];
                            ImageProvider imageProvider;

                            // ignore: avoid_print
                            print('Image URL: $imageUrl'); // Debugging

                            if (imageUrl == null || imageUrl.isEmpty) {
                              imageProvider = AssetImage(
                                  'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg');
                            } else {
                              try {
                                // Remove data:image/jpeg;base64, or similar prefixes if present
                                final base64String = imageUrl.contains(',')
                                    ? imageUrl.split(',')[1]
                                    : imageUrl;

                                // Decode base64 to Uint8List
                                final Uint8List imageBytes =
                                    base64Decode(base64String);
                                imageProvider = MemoryImage(imageBytes);
                              } catch (e) {
                                // ignore: avoid_print
                                print('Error processing base64 image: $e');
                                imageProvider = AssetImage(
                                    'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg');
                              }
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookingPage(
                                          title: parlour['parlourName'] ?? '',
                                          shopName:
                                              parlour['parlourName'] ?? '',
                                          shopAddress: parlour['location'] ??
                                              'No Address Available',
                                          contactNumber:
                                              parlour['phoneNumber'] ??
                                                  'No Contact Available',
                                          description: parlour['description'] ??
                                              'No Description Available',
                                          id: parlour['id'] ?? 'No id',
                                          imageUrl: parlour['image'] ??
                                              '', // Pass the image URL or base64 string
                                          parlourDetails:
                                              parlour, // Decode base64 if necessary
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                        child: SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: FadeInImage(
                                            placeholder: AssetImage(
                                                'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg'),
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                            imageErrorBuilder:
                                                (context, error, stackTrace) {
                                              // ignore: avoid_print
                                              print(
                                                  'Error loading image: $error');
                                              return Image.asset(
                                                'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg',
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              parlour['parlourName'] ??
                                                  'Unknown Parlour',
                                              style: GoogleFonts.lato(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Colors.deepPurple.shade800,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              parlour['location'] ??
                                                  'No Location Available',
                                              style: GoogleFonts.lato(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amber,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  parlour['ratings']
                                                          ?.toString() ??
                                                      'No Ratings',
                                                  style: GoogleFonts.lato(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
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
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      DoorToDoorServicePage(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade800,
            ],
          ),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          // ignore: deprecated_member_use
          unselectedItemColor: Colors.white.withOpacity(0.6),
          selectedLabelStyle: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.lato(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              // New item for Door to Door Service
              icon: Icon(Icons.doorbell_outlined), // Choose an appropriate icon
              activeIcon: Icon(Icons.doorbell), // Active icon
              label: 'Door to Door',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
