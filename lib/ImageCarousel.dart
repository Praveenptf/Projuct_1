import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageCarousel extends StatefulWidget {
  ImageCarousel({super.key});

  @override
  State<ImageCarousel> createState() => _ImageCarousel();

  // Define the image paths here
  final List<String> offerImage = [
    'assets/6c3762a7da99e7585cc9ef2a9b5e33cd.jpg',
    'assets/images.jpg',
    'assets/Super-Exciting-HAIR-Colour-Offer-by-Bridal-Makeup-Beauty-Parlour-Flyers-and-Card.jpg',
    // Add your image paths here
  ];
}

class _ImageCarousel extends State<ImageCarousel> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return _carouselSlider(); // Fixed method name
  }

  // Fixed method name to _carouselSlider
  Column _carouselSlider() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.offerImage.length, // Use widget.offerImage
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                widget.offerImage[index], // Use widget.offerImage
                fit: BoxFit.cover,
                width: double.infinity,
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: AnimatedSmoothIndicator(
            activeIndex: activeIndex,
            count: widget.offerImage.length, // Use widget.offerImage
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
