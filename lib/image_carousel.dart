import 'package:carousel_slider/carousel_slider.dart';
import 'package:firrst_projuct/offer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'booking_page.dart'; // Import your BookingPage

class ImageCarousel extends StatefulWidget {
  final Function(int) onImageTap; // Add a callback function

  ImageCarousel({super.key, required this.onImageTap}); // Accept the callback

  @override
  State<ImageCarousel> createState() => _ImageCarousel();
}

class _ImageCarousel extends State<ImageCarousel> {
  int activeIndex = 0;
  List<Offer> offerImages = []; // Change to List<Offer>
  List<dynamic> allParlours = []; // To store all parlours

  @override
  void initState() {
    super.initState();
    fetchImages(); // Fetch images when the widget is initialized
    fetchAllParlours(); // Fetch all parlours
  }

  Future<void> fetchImages() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.20:8086/api/offer/getAllOffers'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            offerImages = data.map((item) {
              return Offer(
                id: item['parlourId'], // Fetching the id
                image: base64Decode(item['image'] as String),
              );
            }).toList();
          });
        } else {
          await _loadFallbackImages();
        }
      } else {
        await _loadFallbackImages();
      }
    } catch (e) {
      print("Error fetching images: $e"); // Log the error
      await _loadFallbackImages();
    }
  }

  Future<void> fetchAllParlours() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.20:8086/api/parlour/getAllParlours'),
      );

      if (response.statusCode == 200) {
        setState(() {
          allParlours = json.decode(response.body); // Store all parlours
        });
      } else {
        print("Failed to fetch parlours: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching parlours: $e");
    }
  }

  Future<void> _loadFallbackImages() async {
    List<String> assetPaths = [
      'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg',
      'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg',
      'assets/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg'
    ];

    List<Offer> fallbackImages = [];

    for (String path in assetPaths) {
      ByteData bytes = await rootBundle.load(path);
      fallbackImages.add(Offer(
          id: 0,
          image: bytes.buffer.asUint8List())); // Create Offer with dummy id
    }

    setState(() {
      offerImages = fallbackImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _carouselSlider();
  }

  Column _carouselSlider() {
    return Column(
      children: [
        if (offerImages.isNotEmpty)
          CarouselSlider.builder(
            itemCount: offerImages.length,
            itemBuilder: (context, index, realIndex) {
              return GestureDetector(
                onTap: () {
                  // Check if the offerId matches any parlourId
                  final offerId = offerImages[index].id;
                  final matchedParlour = allParlours.firstWhere(
                    (parlour) => parlour['id'] == offerId,
                    orElse: () => null,
                  );

                  if (matchedParlour != null) {
                    // Navigate to BookingPage with the matched parlour details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(
                          title: matchedParlour['parlourName'] ?? '',
                          shopName: matchedParlour['parlourName'] ?? '',
                          shopAddress: matchedParlour['location'] ??
                              'No Address Available',
                          contactNumber: matchedParlour['phoneNumber'] ??
                              'No Contact Available',
                          description: matchedParlour['description'] ??
                              'No Description Available',
                          id: matchedParlour['id'] ?? 0,
                          imageUrl: matchedParlour['image'] ?? '',
                          parlourDetails: matchedParlour,
                        ),
                      ),
                    );
                  } else {
                    print("No matching parlour found for offerId: $offerId");
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    offerImages[index].image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  activeIndex = index;
                });
              },
            ),
          ),
        if (offerImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: AnimatedSmoothIndicator(
              activeIndex: activeIndex,
              count: offerImages.length,
              effect: WormEffect(
                dotWidth: 8,
                dotHeight: 8,
                dotColor: Colors.grey,
                activeDotColor: Colors.deepPurple.shade800,
              ),
            ),
          ),
      ],
    );
  }
}
