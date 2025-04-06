import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        elevation: 8,
        backgroundColor: const Color(0xFF1A1A1A),
        shadowColor: Colors.black.withAlpha(150),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFBF00), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
              color: const Color(0xFFFFF8DC),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'About Us',
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFBF00),
            shadows: [
              Shadow(
                color: Colors.black.withAlpha(200),
                offset: Offset(1, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildProfileCard(
              'Aditya Shaw',
              'Frontend & Backend Developer',
              'Building seamless experiences, one line of code at a time.',
              'Aditya Shaw is a first-year B.Tech student at IIESTS...',
              'assets/images/aditya.jpg',
              'mailto:adityawcode@gmail.com',
              'https://www.linkedin.com/in/aditya-shaw-809a7b323',
            ),
            _buildProfileCard(
              'Yash Agarwal',
              'Frontend & Backend Developer',
              'Turning ideas into interactive experiences!',
              'Yash Agarwal is a first-year B.Tech student at IIESTS...',
              'assets/images/yash.jpg',
              'mailto:yashagarwal7088@gmail.com',
              'https://www.linkedin.com/in/yash-agarwal-b95630308',
            ),
            _buildProfileCard(
              'Anik Chakraborty',
              'Design & Animation',
              'Bringing ideas to life with creativity and motion!',
              'Anik Chakraborty is a first-year B.Tech student at IIESTS...',
              'assets/images/anik.jpg',
              'mailto:anik.newme@gmail.com',
              'https://www.linkedin.com/in/anik-chakraborty-a2183b277',
            ),
            _buildProfileCard(
              'Abhradeep Kayal',
              'Frontend Developer',
              'Crafting meaningful experiences, one code at a time!',
              'Abhradeep Kayal is a first-year B.Tech student at IIESTS...',
              'assets/images/abhradeep.jpg',
              'mailto:kayal.abhradeep04@gmail.com',
              'https://www.linkedin.com/in/adk47',
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
    String emailUrl,
    String linkedinUrl,
  ) {
    return Card(
      color: const Color(0xFF2A2A2A),
      elevation: 10,
      shadowColor: Colors.black.withAlpha(100),
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFFBF00), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage(imageUrl),
              backgroundColor: Colors.black,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFF8DC),
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tagline,
                    style: const TextStyle(
                      fontFamily: 'OpenDyslexic',
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'OpenDyslexic',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildLinkButton(emailUrl, 'Email'),
                      const SizedBox(width: 12),
                      _buildLinkButton(linkedinUrl, 'LinkedIn'),
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
        backgroundColor: const Color(0xFFFFBF00),
        foregroundColor: Colors.black,
        elevation: 4,
        shadowColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'OpenDyslexic', fontSize: 14),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }
}
