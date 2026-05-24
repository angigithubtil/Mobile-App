import 'package:flutter/material.dart';

const Color kPrimaryGreen = Color(0xFF0F766E);

class AdminNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AdminNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildNavItem(context, icon: Icons.dashboard_outlined, label: 'Dashboard', index: 0, route: '/admin'),
          _buildNavItem(context, icon: Icons.people_alt_outlined, label: 'Employees', index: 1, route: '/admin/employees'),
          _buildNavItem(context, icon: Icons.schedule_outlined, label: 'Shifts', index: 2, route: '/admin/shifts'),
          _buildNavItem(context, icon: Icons.fact_check_outlined, label: 'Attendance', index: 3, route: '/admin/attendance'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index, required String route}) {
    final isSelected = currentIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryGreen.withOpacity(0.12) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isSelected ? kPrimaryGreen.withOpacity(0.3) : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? kPrimaryGreen : const Color(0xFF6B7280), size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? kPrimaryGreen : const Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
