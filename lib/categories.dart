import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'booking_page.dart'; // Make sure to import your BookingPage

class CategoryFilteredParlours extends StatefulWidget {
  final String category;
  final List<dynamic> allParlours;

  const CategoryFilteredParlours({
    Key? key,
    required this.category,
    required this.allParlours,
  }) : super(key: key);

  @override
  _CategoryFilteredParloursState createState() =>
      _CategoryFilteredParloursState();
}

class _CategoryFilteredParloursState extends State<CategoryFilteredParlours> {
  List<dynamic> filteredParlours = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _filterParloursByCategory();
  }

  Future<void> _filterParloursByCategory() async {
    setState(() {
      isLoading = true;
    });

    List<dynamic> validParlours = [];

    // Iterate through all parlours
    for (var parlour in widget.allParlours) {
      bool matchFound = await _checkParlourServices(parlour['id']);
      if (matchFound) {
        validParlours.add(parlour);
      }
    }

    setState(() {
      filteredParlours = validParlours;
      isLoading = false;
    });
  }

  Future<bool> _checkParlourServices(int parlourId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.20:8086/api/Items/itemByParlourId?parlourId=$parlourId'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'JSESSIONID=YOUR_SESSION_ID_HERE',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<dynamic> services = json.decode(response.body);
        String categoryLower = widget.category.toLowerCase();

        return services.any((service) {
          String serviceName = (service['itemName'] ?? '').toLowerCase();
          return serviceName.contains(categoryLower);
        });
      }
    } catch (e) {
      print('Error checking parlour services: $e');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.category} Services',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.deepPurple.shade800),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/chevron-back.svg', // Make sure to have this asset
            width: 24,
            height: 24,
            colorFilter:
                ColorFilter.mode(Colors.deepPurple.shade800, BlendMode.srcIn),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to the previous screen
          },
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.deepPurple.shade400,
                ),
              ),
            )
          : filteredParlours.isEmpty
              ? Center(
                  child: Text(
                    'No ${widget.category} services found',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0, left: 14, right: 14), // Add space here
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredParlours.length,
                      itemBuilder: (context, index) {
                        final parlour = filteredParlours[index];
                        String? imageUrl = parlour['image'];
                        ImageProvider imageProvider;

                        if (imageUrl == null || imageUrl.isEmpty) {
                          imageProvider = AssetImage(
                              'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg');
                        } else {
                          try {
                            final base64String = imageUrl.contains(',')
                                ? imageUrl.split(',')[1]
                                : imageUrl;
                            final Uint8List imageBytes =
                                base64Decode(base64String);
                            imageProvider = MemoryImage(imageBytes);
                          } catch (e) {
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
                                      shopName: parlour['parlourName'] ?? '',
                                      shopAddress: parlour['location'] ??
                                          'No Address Available',
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
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
                                          print('Error loading image: $error');
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
                                            color: Colors.deepPurple.shade800,
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
                                              parlour['ratings']?.toString() ??
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
    );
  }
}

class CategoriesSection extends StatefulWidget {
  @override
  _CategoriesSectionState createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  List<dynamic> allParlours = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllParlours();
  }

  Future<void> fetchAllParlours() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.20:8086/api/parlour/getAllParlours'),
        headers: {
          'Cookie': 'JSESSIONID=YOUR_SESSION_ID_HERE',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          allParlours = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load parlours');
      }
    } catch (e) {
      print('Error fetching parlours: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final categories = [
      {
        'name': 'Hair',
        'icon': Icons.cut,
        'color': Colors.deepPurple.shade100,
      },
      {
        'name': 'Skin',
        'icon': Icons.face,
        'color': Colors.deepPurple.shade100,
      },
      {
        'name': 'Nail',
        'icon': Icons.water_drop_outlined,
        'color': Colors.deepPurple.shade100,
      },
      {
        'name': 'Spa',
        'icon': Icons.spa_outlined,
        'color': Colors.deepPurple.shade100,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade800,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories.map((category) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryFilteredParlours(
                        category: category['name'] as String,
                        allParlours: allParlours,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 75,
                  decoration: BoxDecoration(
                    color: category['color'] as Color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple.shade300.withOpacity(0.7),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            category['icon'] as IconData,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          category['name'] as String,
                          style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
