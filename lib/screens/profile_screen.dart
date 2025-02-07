import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'Guest User',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 32),
        ListTile(
          leading: Icon(Icons.shopping_bag),
          title: Text('My Listings'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.help),
          title: Text('Help & Support'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}
