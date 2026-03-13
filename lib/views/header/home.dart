// Placeholder widgets for header pages
import 'package:flutter/material.dart';
import 'package:multifleet/theme/app_theme.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final flexCount = isMobile ? 1 : (isTablet ? 2 : 4);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to MultiFleet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Your comprehensive fleet management solution',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: flexCount,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 2.5 : 1,
              children: [
                _featureCard(
                  'Vehicle Management',
                  Icons.directions_car,
                  'Track and manage all your fleet vehicles in one place',
                ),
                _featureCard(
                  'Assignment Tracking',
                  Icons.assignment_ind,
                  'Monitor vehicle assignments and driver details',
                ),
                _featureCard(
                  'Maintenance Alerts',
                  Icons.build,
                  'Stay updated with service and maintenance schedules',
                ),
                _featureCard(
                  'Expiry Reminders',
                  Icons.event,
                  'Never miss insurance and registration renewal dates',
                ),
                _featureCard(
                  'Fine Management',
                  Icons.warning,
                  'Record and track vehicle fines and violations',
                ),
                _featureCard(
                  'Comprehensive Reports',
                  Icons.bar_chart,
                  'Generate detailed reports on vehicle performance',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(String title, IconData icon, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.accent,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
