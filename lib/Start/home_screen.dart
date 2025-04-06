import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Luna/aboutus.dart';
import 'package:Luna/contact.dart';
import 'package:Luna/quiz.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  int _currentIndex = 0;

  final List<String> _routes = [
    '/home',
    '/forum',
    '/search',
    '/chatbot',
    '/profile',
  ];

  void _onNavTapped(int index) async {
    if (index == 0) {
      setState(() {
        _currentIndex = 0;
      });
    } else {
      await Navigator.pushNamed(context, _routes[index]);
      
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildNavIcon(IconData iconData, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration:
          isSelected
              ? BoxDecoration(
                border: Border.all(color: Colors.amber, width: 2),
                borderRadius: BorderRadius.circular(8),
              )
              : null,
      child: Icon(iconData, color: isSelected ? Colors.amber : Colors.grey),
    );
  }

  Widget _buildDynamicBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1E1E1E),
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: _onNavTapped,
      showSelectedLabels: true,
      showUnselectedLabels: true, 
      selectedLabelStyle: const TextStyle(fontFamily: 'OpenDyslexic'),
      items: [
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.home, _currentIndex == 0),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.people_outline, _currentIndex == 1),
          label: 'Forum',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.search, _currentIndex == 2),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.chat_bubble_outline, _currentIndex == 3),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.person_outline, _currentIndex == 4),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String imagePath,
    String title,
    String routeName,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.shade700, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'OpenDyslexic',
                fontSize: 18,
                color: Color(0xFFF5F5DC),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFFF5F5DC)),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_outlined, color: Color(0xFFF5F5DC)),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizPage()),
                ),
          ),
        ],
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/luna.png',
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Luna',
              style: TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                color: Color(0xFFF5F5DC),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.amber, blurRadius: 4)],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.black26),
              child: Text(
                'Luna Menu',
                style: TextStyle(color: Color(0xFFF5F5DC), fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFF5F5DC)),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Color(0xFFF5F5DC)),
              ),
              onTap: _signOut,
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFFF5F5DC)),
              title: const Text(
                'About Us',
                style: TextStyle(color: Color(0xFFF5F5DC)),
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutUsPage(),
                    ),
                  ),
            ),
            ListTile(
              leading: const Icon(
                Icons.contact_mail_outlined,
                color: Color(0xFFF5F5DC),
              ),
              title: const Text(
                'Contact',
                style: TextStyle(color: Color(0xFFF5F5DC)),
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactPage(),
                    ),
                  ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback:
                      (bounds) => const LinearGradient(
                        colors: [Colors.amber, Colors.orangeAccent],
                      ).createShader(bounds),
                  child: const Text(
                    "Welcome to Luna! We’re here to make your journey fun, interactive, and supportive.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OpenDyslexic',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome, ${user?.displayName ?? 'User'}!',
                  style: const TextStyle(
                    fontFamily: 'OpenDyslexic',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF5F5DC),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFeatureCard(
                  context,
                  'assets/images/Journal.png',
                  'Journal',
                  '/journal',
                ),
                _buildFeatureCard(
                  context,
                  'assets/images/FINAL_speech therapy.png',
                  'Speech Therapy',
                  '/speech-therapy',
                ),
                _buildFeatureCard(
                  context,
                  'assets/images/toDo.gif',
                  'To-Do List',
                  '/todo',
                ),
                _buildFeatureCard(
                  context,
                  'assets/images/visuals.jpg',
                  'Calming Visuals',
                  '/visual',
                ),
                _buildFeatureCard(
                  context,
                  'assets/images/activities.png',
                  'Activities',
                  '/activities',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildDynamicBottomNavBar(),
    );
  }
}
