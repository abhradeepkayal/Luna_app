import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importing the package for launching email

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  // Method to launch the email client
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'lunabeyondsolutions@gmail.com',
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not launch email client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Greyish-black background
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Description
            Text(
              'About Luna',
              style: TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Luna is an app created specifically for neurodiverse individuals, '
                'aimed at enhancing their lives by providing tools that encourage inclusivity, '
                'understanding, and support. Our mission is to create a space where neurodiverse individuals '
                'feel valued and empowered.',
                style: TextStyle(
                  fontFamily: 'OpenDyslexic',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 30),

            // Contact Information Section
            Text(
              'Contact Information',
              style: TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'For any inquiries, feedback, or support, feel free to reach out to us via email:',
                style: TextStyle(
                  fontFamily: 'OpenDyslexic',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Interactive Email Link
            InkWell(
              onTap: _launchEmail, // Call the method to launch the email
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'lunabeyondsolutions@gmail.com',
                      style: TextStyle(
                        fontFamily: 'OpenDyslexic',
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
