import 'package:carousel_slider/carousel_slider.dart';
import 'package:firrst_projuct/offer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/services.dart' show rootBundle;

class ImageCarousel extends StatefulWidget {
  final Function(int) onImageTap; // Add a callback function

  ImageCarousel({super.key, required this.onImageTap}); // Accept the callback

  @override
  State<ImageCarousel> createState() => _ImageCarousel();
}

class _ImageCarousel extends State<ImageCarousel> {
  int activeIndex = 0;
  List<Offer> offerImages = []; // Change to List<Offer>

  @override
  void initState() {
    super.initState();
    fetchImages(); // Fetch images when the widget is initialized
  }

  Future<void> fetchImages() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.16:8086/api/offer/getAllOffers'));

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
                  // Call the callback with the offer ID
                  widget.onImageTap(offerImages[index].id);
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
