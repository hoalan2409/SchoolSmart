import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../constants/app_constants.dart';
import 'students_screen.dart';
import 'attendance_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    DashboardTab(),
    StudentsScreen(),
    AttendanceScreen(),
    ReportsTab(),
    ProfileTab(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 900;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation Drawer for Tablet/Desktop
          if (!isMobile)
            NavigationRail(
              extended: isTablet,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Students'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.check_circle),
                  label: Text('Attendance'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics),
                  label: Text('Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          
          // Main Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      // Bottom Navigation for Mobile
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Students',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle),
                  label: 'Attendance',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Dashboard Tab
class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);
  
  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 24),
          
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                context,
                'Total Students',
                '156',
                Icons.people,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'Present Today',
                '142',
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Absent Today',
                '14',
                Icons.cancel,
                Colors.red,
              ),
              _buildStatCard(
                context,
                'Attendance Rate',
                '91%',
                Icons.trending_up,
                Colors.orange,
              ),
            ],
          ),
          
          SizedBox(height: 32),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionCard(
                context,
                'Mark Attendance',
                Icons.check_circle,
                Colors.green,
                () => _navigateToAttendance(),
              ),
              _buildActionCard(
                context,
                'Add Student',
                Icons.person_add,
                Colors.blue,
                () => _navigateToAddStudent(),
              ),
              _buildActionCard(
                context,
                'View Reports',
                Icons.analytics,
                Colors.orange,
                () {},
              ),
              _buildActionCard(
                context,
                'Face Recognition',
                Icons.face,
                Colors.purple,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _navigateToAttendance() {
    // Navigate to attendance tab
    final homeScreen = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeScreen != null) {
      homeScreen.setState(() {
        homeScreen._selectedIndex = 2; // Attendance tab index
      });
    }
  }
  
  void _navigateToAddStudent() {
    // Navigate to students tab
    final homeScreen = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeScreen != null) {
      homeScreen.setState(() {
        homeScreen._selectedIndex = 1; // Students tab index
      });
    }
  }
  
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Container(
          width: 100,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              SizedBox(height: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reports Tab
class ReportsTab extends StatelessWidget {
  const ReportsTab({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Reports & Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Tab
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'User Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
