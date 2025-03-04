// door_to_door_service.dart
import 'package:firrst_projuct/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DoorToDoorServicePage extends StatelessWidget {
  // ignore: use_super_parameters
  const DoorToDoorServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Door to Door Service',
          style: GoogleFonts.raleway(
            color: Colors.deepPurple.shade800,
          ),
        ),
        backgroundColor: Colors.white,
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
        iconTheme: IconThemeData(color: Colors.deepPurple.shade800),
      ),
    );
  }
}
