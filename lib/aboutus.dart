import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // For handling URL links

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Greyish-black background
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible', // Heading font style
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfileCard(
              'Aditya Shaw',
              'Frontend & Backend Developer',
              'Building seamless experiences, one line of code at a time.',
              'Aditya Shaw is a first-year B.Tech student at the Indian Institute of Engineering Science and Technology, Shibpur (IIESTS), pursuing Information Technology. Passionate about competitive coding and full-stack development, he is constantly refining his problem-solving skills. A pupil on Codeforces, Aditya is well-versed in C, C++, Dart, Flutter, and Firebase, crafting robust and scalable applications.',
              'assets/aditya.jpg', // Placeholder for image
              'aditya.email@example.com',
              'https://linkedin.com/in/aditya',
            ),
            _buildProfileCard(
              'Yash Agarwal',
              'Frontend & Backend Developer',
              'Turning ideas into interactive experiences!',
              'Yash Agarwal is a first-year B.Tech student at the Indian Institute of Engineering Science and Technology, Shibpur (IIESTS), pursuing Information Technology. Passionate about app development, Yash is committed to building intuitive and dynamic digital solutions. With expertise in C, C++, HTML, CSS, Dart, Flutter, and Firebase, he crafts seamless user experiences and scalable applications.',
              'assets/yash.jpg',
              'yash.email@example.com',
              'https://linkedin.com/in/yash',
            ),
            _buildProfileCard(
              'Anik Chakraborty',
              'Design & Animation',
              'Bringing ideas to life with creativity and motion!',
              'Anik Chakraborty is a first-year B.Tech student at the Indian Institute of Engineering Science and Technology, Shibpur (IIESTS), pursuing Computer Science and Technology. With a keen eye for design and animation, Anik specializes in crafting smooth, aesthetically pleasing user experiences. He is a researcher of cool ideas for the app and is highly skilled in Canva and Flutter UI design, ensuring that every visual element tells a story.',
              'assets/anik.jpg',
              'anik.email@example.com',
              'https://linkedin.com/in/anik',
            ),
            _buildProfileCard(
              'Abhradeep Kayal',
              'Frontend Developer',
              'Crafting meaningful experiences, one code at a time!',
              'Abhradeep Kayal is a first-year B.Tech student at the Indian Institute of Engineering Science and Technology, Shibpur (IIESTS), pursuing Electrical Engineering. He has a strong interest in development and is passionate about creating intuitive and user-friendly interfaces. Abhradeep created Mindora, a mental health tracker website, showcasing his development skills. With expertise in C, Java, Python, HTML, CSS, JavaScript, MERN stack, Dart, and Flutter, he focuses on building efficient and well-designed applications.',
              'assets/abhradeep.jpg',
              'abhradeep.email@example.com',
              'https://linkedin.com/in/abhradeep',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    String name,
    String role,
    String tagline,
    String description,
    String imageUrl,
    String email,
    String linkedin,
  ) {
    return Card(
      color: Colors.grey[850],
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(imageUrl), // Placeholder for image
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'AtkinsonHyperlegible', // Heading font style
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    tagline,
                    style: TextStyle(
                      fontFamily: 'OpenDyslexic', // Body text font style
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'OpenDyslexic', // Body text font style
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildLinkButton(email, 'Email'),
                      SizedBox(width: 16),
                      _buildLinkButton(linkedin, 'LinkedIn'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(String url, String label) {
    return ElevatedButton(
      onPressed: () => _launchURL(url),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Updated color property
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'OpenDyslexic', // Body text font style
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
