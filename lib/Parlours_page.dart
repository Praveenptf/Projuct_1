import 'dart:convert';
import 'dart:typed_data';

import 'package:firrst_projuct/BookingPage.dart';
import 'package:flutter/material.dart';

class Parlours extends StatefulWidget {
  final List<dynamic> parlourShops;
  final String serviceFilter;

  const Parlours({
    Key? key,
    required this.parlourShops,
    this.serviceFilter = '',
  }) : super(key: key);

  @override
  _ParloursState createState() => _ParloursState();
}

class _ParloursState extends State<Parlours> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> parlourShops = [];
  bool isSearchVisible = false;
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    parlourShops = widget.parlourShops;
    _filterShops(widget.serviceFilter);
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  void _filterShops([String query = '']) {
    setState(() {
      if (query.isEmpty) {
        parlourShops = widget.parlourShops;
      } else {
        parlourShops = widget.parlourShops.where((shop) {
          final shopName = shop['parlourName']?.toLowerCase() ?? '';
          return shopName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: isSearchVisible
          ? TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey)),
              onChanged: _filterShops,
              cursorColor: Colors.deepPurple,
              style: const TextStyle(color: Colors.deepPurple),
            )
          : Text(
              'Parlours ${widget.serviceFilter}',
              style: TextStyle(color: Colors.deepPurple.shade800),
            ),
      iconTheme: IconThemeData(color: Colors.deepPurple.shade800),
      actions: [
        IconButton(
          icon: Icon(isSearchVisible ? Icons.clear : Icons.search),
          onPressed: () {
            setState(() {
              isSearchVisible = !isSearchVisible;
              if (!isSearchVisible) {
                searchController.clear();
                _filterShops();
                searchFocusNode.unfocus();
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  searchFocusNode.requestFocus();
                });
              }
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Add space here
        child: parlourShops.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
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
                    itemCount: parlourShops.length,
                    itemBuilder: (context, index) {
                      final parlour = parlourShops[index];
                      String? imageUrl = parlour['image'];
                      ImageProvider imageProvider;

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
                                    parlourDetails: parlour,
                                    title: parlour['parlourName'] ?? '',
                                    shopName: parlour['parlourName'] ?? '',
                                    shopAddress: parlour['location'] ??
                                        'No Address Available',
                                    contactNumber: parlour['phoneNumber'] ??
                                        'No Contact Available',
                                    description: parlour['description'] ??
                                        'No Description Available',
                                    id: parlour['id'] ?? 'No id',
                                    imageUrl: parlour['image'] ??
                                        '', // Pass the image URL or base64 string// Decode base64 if necessary
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Container(
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
                                        style: TextStyle(
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
                                        style: TextStyle(
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
                                            style: TextStyle(
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
              )
            : const Center(
                child: Text('No parlours available',
                    style: TextStyle(fontSize: 16)),
              ),
      ),
    );
  }
}
