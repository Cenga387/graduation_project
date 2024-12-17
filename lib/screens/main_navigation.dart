// import 'package:flutter/material.dart';
// import '../widgets/nav_bar.dart';
// import 'home.dart';

// class MainNavigation extends StatefulWidget {
//   const MainNavigation({super.key});

//   @override
//   _MainNavigationState createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   int _selectedIndex = 0;

//   final _homeScreen = const HomeScreen();
//   final _mapScreen = const MapScreen();
//   final _createMatchScreen = CreateMatchSessionScreen();
//   final _myGamesScreen = const MyGamesScreen();
//   final _profileScreen = const ProfileScreen();

//   late final List<Widget> _screens;

//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       _homeScreen,
//       _mapScreen,
//       _createMatchScreen,
//       _myGamesScreen,
//       _profileScreen,
//     ];
//   }

//   final List<String> _titles = [
//     'Home',
//     'Map',
//     'Create Match',
//     'My Games',
//     'Profile',
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
//     return Scaffold(
//       appBar: AppBar(
//         scrolledUnderElevation: 0.0,
//         title: Text(_titles[_selectedIndex]),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Container(
//         color: Colors.white,
//         child: _screens[_selectedIndex],
//       ),
//       bottomNavigationBar: NavBar(
//         currentIndex: _selectedIndex,
//         onItemSelected: _onItemTapped,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: 
//       Visibility(
//         visible: !isKeyboardVisible,
//         child: GestureDetector(
//         onTap: () => _onItemTapped(2),
//         child: Container(
//           height: 70,
//           width: 70,
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5),
//                 spreadRadius: 1,
//                 blurRadius: 2,
//               ),
//             ],
//             shape: BoxShape.circle,
//             color: const Color(0xFF51DB88),
//             border: Border.all(
//               color: const Color(0xFF51DB88),
//               width: 4,
//             ),
//           ),
//           child: const Icon(
//             Icons.add,
//             color: Colors.black,
//             size: 30,
//           ),
//         ),
//       ),
//       ),
//     );
//   }
// }
