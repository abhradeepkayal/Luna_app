import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  final List<String> _images = [
    'assets/images/Journal.png',
    'assets/images/FINAL_speech therapy.png', // Second image triggers Speech Therapy
    'assets/images/activities.png',
    'assets/images/codeforces.png',
    'assets/images/fouram.png',
  ];

  @override
  void initState() {
    super.initState();
    // Start the slideshow timer: every 5 seconds, advance to the next image.
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _images.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFFF5F5DC)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/Luna_f (2) (1).jpg',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'Luna',
              style: TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                color: Color(0xFFF5F5DC),
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 60,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: const Text(
                    "Welcome to Luna! We're here to make your journey fun, "
                    "interactive, and supportive. Enjoy a personalized experience "
                    "designed to fit your unique needs.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      fontSize: 16,
                      color: Color(0xFFF5F5DC),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome, ${user?.displayName ?? 'User'}!',
                  style: const TextStyle(
                    fontFamily: 'AtkinsonHyperlegible',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF5F5DC),
                  ),
                ),
                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      Widget imageWidget = Image.asset(
                        _images[index],
                        fit: BoxFit.contain,
                      );

                      if (index == 0) {
                        imageWidget = GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/journal');
                          },
                          child: imageWidget,
                        );
                      } else if (index == 1) {
                        imageWidget = GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/speech-therapy');
                          },
                          child: imageWidget,
                        );
                      } else if (index == 2) {
                        imageWidget = GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/activities');
                          },
                          child: imageWidget,
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: imageWidget,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: _currentPage == index ? 12 : 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index
                                ? const Color(0xFFF5F5DC)
                                : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(user: user),
    );
  }
}

class AppBottomNavBar extends StatefulWidget {
  final User? user;
  const AppBottomNavBar({super.key, this.user});

  @override
  _AppBottomNavBarState createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to Home when Home tab is clicked
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (index == 3) {
      // Navigate to Chatbot when Chatbot tab is clicked
      Navigator.pushNamed(context, '/chatbot');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF121212),
      selectedItemColor: const Color(0xFFF5F5DC),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Forum'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
        BottomNavigationBarItem(
          icon:
              widget.user?.photoURL != null
                  ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.user!.photoURL!),
                    radius: 12,
                  )
                  : const Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
