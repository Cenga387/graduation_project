import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  static const Color _borderColor = Colors.grey;
  static const double _borderWidth = 0.5;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _borderColor,
            width: _borderWidth,
          ),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8, // Increased margin to prevent button cutoff
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onItemSelected(0),
              ),
              _buildNavItem(
                icon: Icons.campaign_outlined,
                label: 'Announcements',
                isSelected: currentIndex == 1,
                onTap: () => onItemSelected(1),
              ),
              _buildNavItem(
                icon: Icons.work_outline,
                label: 'Careers',
                isSelected: currentIndex == 2,
                onTap: () => onItemSelected(2),
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isSelected: currentIndex == 3,
                onTap: () => onItemSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF0071C6) : Colors.black,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0071C6) : Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
