import 'package:flutter/material.dart';
import 'package:dreamforge/screens/generation_screen.dart';
import 'package:dreamforge/screens/voice_generation_screen.dart';
import 'package:dreamforge/screens/gallery_screen.dart';
import 'package:dreamforge/screens/storyboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const GenerationScreen(),
    const VoiceGenerationScreen(),
    const GalleryScreen(),
    const StoryboardScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: "Générer",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: "Voix",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: "Galerie",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: "Storyboard",
          ),
        ],
      ),
    );
  }
}