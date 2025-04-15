import 'package:flutter/material.dart';

class SettingsPageContent extends StatelessWidget {
  const SettingsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Configure your MultiFleet application',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 24),
          _settingsItem(
            'Account Settings',
            Icons.person,
            'Manage your account information',
          ),
          _settingsItem(
            'Notification Preferences',
            Icons.notifications,
            'Configure alert and notification settings',
          ),
          _settingsItem(
            'Appearance',
            Icons.palette,
            'Customize the application theme',
          ),
          _settingsItem(
            'Data Management',
            Icons.storage,
            'Configure data backup and storage options',
          ),
          _settingsItem(
            'System Preferences',
            Icons.settings,
            'Adjust system-wide settings',
          ),
        ],
      ),
    );
  }

  Widget _settingsItem(String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue[800],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
