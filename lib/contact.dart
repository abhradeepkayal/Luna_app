import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFBF00), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            offset: const Offset(3, 3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            offset: const Offset(-3, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFBF00), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFFF5E1),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFFFFBF00),
          size: 18,
        ),
        onTap: () => _launchURL(context, url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Theme.of(context).platform == TargetPlatform.iOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
            color: const Color(0xFFFFF5E1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Contact Us',
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Color(0xFFFFBF00),
          ),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We’d love to hear from you!',
              style: TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFF5E1),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Have a question, feedback, or just want to say hello? '
              'Choose any of the options below and we’ll get back to you as soon as possible.',
              style: TextStyle(
                fontFamily: 'OpenDyslexic',
                fontSize: 16,
                color: Color(0xFFCCCCCC),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _buildContactCard(
              context: context,
              icon: Icons.email,
              label: 'lunabeyondsolutions@gmail.com',
              url: 'mailto:lunabeyondsolutions@gmail.com',
              color: Colors.redAccent,
            ),
            _buildContactCard(
              context: context,
              icon: Icons.facebook,
              label: 'Luna on Facebook',
              url: 'https://www.facebook.com/yourpage',
              color: const Color(0xFF4267B2),
            ),
            _buildContactCard(
              context: context,
              icon: Icons.camera_alt,
              label: '@luna_app on Instagram',
              url: 'https://www.instagram.com/yourpage',
              color: const Color(0xFFC13584),
            ),
            _buildContactCard(
              context: context,
              icon: Icons.business_center,
              label: 'Luna on LinkedIn',
              url: 'https://www.linkedin.com/in/yourprofile',
              color: const Color(0xFF0077B5),
            ),
          ],
        ),
      ),
    );
  }
}
