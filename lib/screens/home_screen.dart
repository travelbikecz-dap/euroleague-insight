import 'package:flutter/material.dart';
import 'games_screen.dart';
import 'standings_screen.dart';
import 'teams_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    GamesScreen(),
    StandingsScreen(),
    TeamsScreen(),
  ];

  final List<String> _titles = ['Games', 'Standings', 'Teams'];

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,

      duration: const Duration(milliseconds: 300),

      curve: Curves.easeInOut,
    );

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.black,
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),

      body: PageView(
        controller: _pageController,

        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_basketball),
            label: 'Games',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Standings',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Teams'),
        ],
      ),
    );
  }
}
