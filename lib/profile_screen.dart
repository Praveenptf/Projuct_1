import 'dart:io';
import 'package:firrst_projuct/editprofile_page.dart';
import 'package:firrst_projuct/home_page.dart';
import 'package:firrst_projuct/login_page.dart';
import 'package:firrst_projuct/notifications_page.dart';
import 'package:firrst_projuct/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage; // Holds the selected profile image

  Future<void> _pickImage() async {
    // Show options for picking image
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery, // or ImageSource.camera for camera
      maxWidth: 600,
      imageQuality: 85, // Adjust quality to save data
    );

    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        _navigateToHomePage(context);
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Profile',
            style: GoogleFonts.lato(color: Colors.deepPurple.shade800),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.transparent, // Temporary background for debugging
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/chevron-back.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                      Colors.deepPurple.shade800, BlendMode.srcIn),
                ),
                onPressed: () => _navigateToHomePage(context),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage == null
                          ? NetworkImage(
                              'https://i0.wp.com/therighthairstyles.com/wp-content/uploads/2021/09/2-mens-undercut.jpg?resize=500%2C503',
                            )
                          : FileImage(File(_profileImage!.path))
                              as ImageProvider, // Show selected image
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                            ),
                            color: Colors.white,
                            onPressed: _pickImage, // Open image picker
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Positioned name and email
            Positioned(
              top: 130,
              left: 60, // Adjust the left alignment to 0
              right: 0,
              child: Center(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center the text horizontally
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: 16,
              right: 16,
              bottom: 0,
              child: ListView(
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.person, color: Colors.deepPurple.shade800),
                    title: Text('Edit Profile',
                        style: GoogleFonts.lato(
                            color: Colors.deepPurple.shade800)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.deepPurple.shade800),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserProfile()));
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.history, color: Colors.deepPurple.shade800),
                    title: Text('Booking History',
                        style: GoogleFonts.lato(
                            color: Colors.deepPurple.shade800)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.deepPurple.shade800),
                    onTap: () {
                      // Navigate to Booking History Screen
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications,
                        color: Colors.deepPurple.shade800),
                    title: Text('Notifications',
                        style: GoogleFonts.lato(
                            color: Colors.deepPurple.shade800)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.deepPurple.shade800),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationPage(
                                  title: '',
                                  message: '',
                                  date: '',
                                  time: '',
                                )),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.logout, color: Colors.deepPurple.shade800),
                    title: Text('Logout',
                        style: GoogleFonts.lato(
                            color: Colors.deepPurple.shade800)),
                    trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.deepPurple.shade800),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHomePage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Logout',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          content: Text(
            'Are you sure you want to Logout ?',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w600,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  TokenManager.deleteToken(); // Clear the token
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Logged out successfully',
                      style: GoogleFonts.lato(),
                    ),
                  ));
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text(
                  'Logout',
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
