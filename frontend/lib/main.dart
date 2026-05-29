import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/admin/admin_home_screen.dart';
import 'presentation/screens/admin/admin_employee_screen.dart';
import 'presentation/screens/admin/admin_shift_screen.dart';
import 'presentation/screens/admin/admin_attendance_screen.dart';
import 'presentation/screens/employee_dashboard_screen.dart';
import 'presentation/screens/admin/employee_form.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Shift Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/employee': (context) => const EmployeeDashboardScreen(),
        '/admin': (context) => const AdminHomeScreen(),
        '/admin/employees': (context) => const AdminEmployeeScreen(),
        '/admin/employees/add': (context) => const EmployeeForm(),
        '/admin/shifts': (context) => const AdminShiftScreen(),
        '/admin/attendance': (context) => const AdminAttendanceScreen(),
      },
    );
  }
}
