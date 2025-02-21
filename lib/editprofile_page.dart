import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Future<User>? userFuture;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isInitialized = false;

  Future<int> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('UserId') ?? 0;
  }

  Future<String> getAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ?? '';
  }

  Future<User> fetchUserDetails(int userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.16:8086/api/parlour/id?id=1'),
      headers: {
        'Cookie': 'JSESSIONID=ACF91BC7C0410372B5E2DF5E978E186B',
        'Authorization': 'Bearer ',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        return User.fromJson(data);
      } else if (data is List && data.isNotEmpty) {
        return User.fromJson(data[0]);
      } else {
        throw Exception('Unexpected data format');
      }
    } else {
      throw Exception('Failed to load parlour details');
    }
  }

  Future<void> saveChanges(int userId) async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse('http://192.168.1.3:8080/api/parlour/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Cookie': 'JSESSIONID=ACF91BC7C0410372B5E2DF5E978E186B',
      },
      body: json.encode({
        'id': userId,
        'parlourName': _nameController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Changes saved successfully')),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: ${response.body}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    userFuture = getUserId().then((userId) => fetchUserDetails(userId));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeControllers(User userData) {
    if (!_isInitialized) {
      _nameController.text = userData.parlourName;
      _phoneController.text = userData.phoneNumber;
      _emailController.text = userData.email;
      _isInitialized = true;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Handle the selected image (e.g., upload it or display it)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "User Details",
          style: TextStyle(color: Colors.deepPurple.shade800),
        ),
        iconTheme: IconThemeData(color: Colors.deepPurple.shade800),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () async {
              setState(() {
                if (_isEditing) {
                  if (_formKey.currentState!.validate()) {
                    getUserId().then((userId) {
                      saveChanges(userId);
                    });
                  }
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<User>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userData = snapshot.data!;
            _initializeControllers(userData);

            Uint8List? decodedImage;
            if (userData.image.isNotEmpty) {
              try {
                decodedImage = base64Decode(userData.image);
              } catch (e) {
                // ignore: avoid_print
                print('Error decoding image: $e');
              }
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: decodedImage != null
                                  ? Image.memory(
                                      decodedImage,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.store, size: 60),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                radius: 18,
                                child: IconButton(
                                  icon: Icon(Icons.camera_alt,
                                      size: 18, color: Colors.white),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'User Name',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.store, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        enabled: _isEditing,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter User name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}

class User {
  final String parlourName;
  final String phoneNumber;
  final String email;
  final String image;

  User({
    required this.parlourName,
    required this.phoneNumber,
    required this.email,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      parlourName: json['parlourName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      image: json['image'],
    );
  }
}
