import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart';

class Mappage extends StatefulWidget {
  final Function(LatLng, List<dynamic>)
      onLocationSelected; // Updated callback to include nearby parlours

  const Mappage({super.key, required this.onLocationSelected});

  @override
  State<Mappage> createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  LatLng? _tappedLocation;
  final TextEditingController _searchController = TextEditingController();
  late MapController _mapController;
  bool _isLoading = false;
  String? _locationName;
  List<String> _suggestions = [];
  List<dynamic> _nearbyParlours = []; // To store nearby parlours

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkLocationPermission(); // Check location permission on init
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    } else {
      _showLocationPermissionDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _tappedLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_tappedLocation!, 13.0);
    });

    // Fetch nearby parlours for the current location
    await _fetchNearbyParlours(position.latitude, position.longitude);
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enable Location Services"),
          content: Text("Please enable location services to use this feature."),
          actions: [
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                Geolocator.openLocationSettings();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Search Nearby Parlours",
          style: GoogleFonts.lato(color: Colors.deepPurple.shade800),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/chevron-back.svg', // Replace with your actual SVG file path
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Location',
                  hintStyle: GoogleFonts.lato(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.deepPurple.shade300,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Colors.black), // Set border color to black
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Colors.black), // Set border color to black
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2), // Black border when focused
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _fetchSuggestions(value);
                  } else {
                    setState(() {
                      _suggestions.clear();
                    });
                  }
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchLocation(value);
                  }
                },
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () {
                      _searchController.text = _suggestions[index];
                      _searchLocation(_suggestions[index]);
                      setState(() {
                        _suggestions.clear();
                      });
                    },
                  );
                },
              ),
            ),
          if (_isLoading) Center(child: CircularProgressIndicator()),
          Expanded(child: content()),
          if (_locationName != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Location: $_locationName"),
            ),
          if (_nearbyParlours.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text("Nearby Parlours",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Divider(),
                  ),
                  for (var i = 0; i < _nearbyParlours.length && i < 4; i += 2)
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Aligns the columns
                      children: [
                        Expanded(
                          child: Text(
                            _nearbyParlours[i]['parlourName'],
                            textAlign: TextAlign
                                .center, // Center the text in the column
                          ),
                        ),
                        if (i + 1 <
                            _nearbyParlours
                                .length) // Check if there is a second parlour
                          Expanded(
                            child: Text(
                              _nearbyParlours[i + 1]['parlourName'],
                              textAlign: TextAlign
                                  .center, // Center the text in the column
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget content() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(9.4981, 76.3388),
        initialZoom: 8,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: (tapPosition, point) {
          _placeMarker(point);
        },
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(markers: [
          if (_tappedLocation != null)
            Marker(
              point: _tappedLocation!,
              width: 60,
              height: 60,
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  _showLocationDetails();
                },
                child: Icon(
                  Icons.location_pin,
                  size: 50,
                  color: Colors.red,
                ),
              ),
            ),
        ]),
      ],
    );
  }

  Future<void> _fetchSuggestions(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List data = json.decode(response.body);
        setState(() {
          _suggestions =
              data.map((item) => item['display_name'] as String).toList();
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Exception: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch suggestions")),
      );
    }
  }

  void _placeMarker(LatLng point) async {
    final url =
        "https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        String locationName = data['display_name'];

        setState(() {
          _tappedLocation = point;
          _mapController.move(point, 13.0);
          _locationName = locationName;
        });

        // Fetch nearby parlours for the selected location
        await _fetchNearbyParlours(point.latitude, point.longitude);
      }
    } catch (e) {
      // ignore: avoid_print
      print("Exception: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get location details")),
      );
      widget.onLocationSelected(
          point, _nearbyParlours); // Pass empty list if failed
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
        });

        // Call the callback function to pass the selected location and nearby parlours back
        widget.onLocationSelected(_tappedLocation!, _nearbyParlours);
      } else {
        // ignore: avoid_print
        print(
            "Failed to fetch nearby parlours. Status Code: ${response.statusCode}");
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch nearby parlours")),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching nearby parlours: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching nearby parlours")),
      );
    }
  }

  void _showLocationDetails() {
    if (_locationName != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Location Details"),
            content: Text("You are at: $_locationName"),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1";
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          LatLng searchedLocation = LatLng(lat, lon);
          String locationName = data[0]['display_name'];

          setState(() {
            _tappedLocation = searchedLocation;
            _mapController.move(searchedLocation, 13.0);
            _locationName = locationName;
          });

          // Fetch nearby parlours for searched location
          await _fetchNearbyParlours(lat, lon);
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location not found")),
          );
        }
      } else {
        // ignore: avoid_print
        print("Failed to load location data");
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching data")),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("Exception: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
