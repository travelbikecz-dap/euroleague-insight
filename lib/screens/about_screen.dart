import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EuroLeague Insight',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Text('Version 0.1', style: TextStyle(fontSize: 18)),

            SizedBox(height: 20),

            Text(
              'Data Source',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text('EuroLeague Official API', style: TextStyle(fontSize: 16)),

            SizedBox(height: 20),

            Text(
              'Developer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text('Daniel Álvarez Pérez', style: TextStyle(fontSize: 16)),

            Spacer(),

            Center(
              child: Text(
                'Built with Flutter',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
