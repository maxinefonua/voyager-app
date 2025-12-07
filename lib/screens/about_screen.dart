import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voyager/static/logo_svg.dart';

class AboutScaffold extends StatelessWidget {
  const AboutScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: LogoSvg(size: 240, color: Colors.blue.withAlpha(10)),
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                color: Colors.transparent,
                elevation: 0,
                margin: EdgeInsets.all(12),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Voyager',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'v0.0.1',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Beta',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enhances airline employee flight search with exhaustive route paths via interairline travel and nearby airport suggestions.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Developer Info Card
              Card(
                color: Colors.transparent,
                elevation: 0,
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Development',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).shadowColor.withAlpha(40),
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Material(
                              color: Theme.of(context).cardColor,
                              child: InkWell(
                                onTap: () async {
                                  await Future.delayed(
                                    Duration(milliseconds: 150),
                                  );
                                  final Uri url = Uri.parse(
                                    'https://www.linkedin.com/in/maxfonua',
                                  );
                                  if (!await launchUrl(
                                    url,
                                    mode: LaunchMode
                                        .externalApplication, // This opens in default browser
                                  )) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                                splashColor: Theme.of(
                                  context,
                                ).primaryColor.withAlpha(50),
                                child: Icon(
                                  Icons.person,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text('Maxine Fonua'),
                        subtitle: Text('Developer'),
                      ),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).shadowColor.withAlpha(40),
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Material(
                              color: Theme.of(context).cardColor,
                              child: InkWell(
                                onTap: () async {
                                  await Future.delayed(
                                    Duration(milliseconds: 150),
                                  );
                                  final Uri url = Uri.parse(
                                    'https://maxinefonua.com/',
                                  );
                                  if (!await launchUrl(
                                    url,
                                    mode: LaunchMode
                                        .externalApplication, // This opens in default browser
                                  )) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                                splashColor: Theme.of(
                                  context,
                                ).primaryColor.withAlpha(50),
                                child: Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text('Contact'),
                        subtitle: Text('maxinefonua@gmail.com'),
                        onTap: () async {
                          final Uri url = Uri.parse('https://maxinefonua.com/');
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode
                                .externalApplication, // This opens in default browser
                          )) {
                            throw Exception('Could not launch $url');
                          }
                        },
                      ),
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).shadowColor.withAlpha(40),
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Material(
                              color: Theme.of(context).cardColor,
                              child: InkWell(
                                onTap: () async {
                                  await Future.delayed(
                                    Duration(milliseconds: 150),
                                  );
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
                                splashColor: Theme.of(
                                  context,
                                ).primaryColor.withAlpha(50),
                                child: Icon(
                                  Icons.code_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text('Source Code'),
                        subtitle: Text('GitHub Repository'),
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
                          _buildTechChip('Voyager API', context),
                          _buildTechChip('GeoNames', context),
                          _buildTechChip('FlightRadar', context),
                          _buildTechChip('Visual Studio', context),
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
