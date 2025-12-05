import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScaffold extends StatelessWidget {
  const AboutScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.apps,
                    size: 64,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Voyager App',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 16),
                  Text(
                    'Voyager seeks to enhance the flight search experience for airline employees by offering exhaustive and alternative route paths, as well as suggesting nearby airports',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Developer Info Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Development',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Icon(Icons.person),
                    ),
                    title: Text('Maxine Fonua'),
                    subtitle: Text('Voyager Developer'),
                    onTap: () async {
                      final Uri url = Uri.parse('https://maxinefonua.com');
                      if (!await launchUrl(
                        url,
                        mode: LaunchMode
                            .externalApplication, // This opens in default browser
                      )) {
                        throw Exception('Could not launch $url');
                      }
                    },
                    // launchUrl(Uri.parse()),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.email)),
                    title: Text('Contact'),
                    subtitle: Text('maxinefonua@gmail.com'),
                    onTap: () => {},
                    // launchUrl(Uri.parse('mailto:maxinefonua@gmail.com')),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.code)),
                    title: Text('Source Code'),
                    subtitle: Text('GitHub Repository'),
                    onTap: () async {
                      final Uri url = Uri.parse(
                        'https://github.com/maxinefonua/voyager-ui',
                      );
                      if (!await launchUrl(
                        url,
                        mode: LaunchMode
                            .externalApplication, // This opens in default browser
                      )) {
                        throw Exception('Could not launch $url');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Technologies Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Built With',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTechChip('Flutter', context),
                      _buildTechChip('Dart', context),
                      _buildTechChip('Material Design', context),
                      _buildTechChip('Responsive UI', context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label, BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).secondaryHeaderColor,
    );
  }
}
