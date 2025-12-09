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
          _buildBackgroundFill(),
          ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildCard(
                context,
                _buildVoyagerLabel(context),
                _buildVoyagerContent(context),
              ),
              _buildCard(
                context,
                _buildTitleLabel(context, 'Development'),
                _buildDevelopmentContent(context),
              ),
              _buildCard(
                context,
                _buildTitleLabel(context, 'Built With'),
                _buildTechContent(context),
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
      backgroundColor: Theme.of(context).cardColor,
      elevation: 1,
    );
  }

  Widget _buildBackgroundFill() {
    return Positioned.fill(
      child: LogoSvg(size: 240, color: Colors.blue.withAlpha(10)),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Widget cardLabel,
    Widget cardContent,
  ) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [cardLabel, SizedBox(height: 8), cardContent],
        ),
      ),
    );
  }

  Widget _buildVoyagerLabel(BuildContext context) {
    return Row(
      children: [
        Text(
          'Voyager',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Text('v0.0.1', style: TextStyle(fontSize: 12, color: Colors.grey)),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    );
  }

  Widget _buildVoyagerContent(BuildContext context) {
    return Text(
      'Enhances airline employee flight search with exhaustive route paths via interairline travel and nearby airport suggestions.',
      style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
    );
  }

  Widget _buildTitleLabel(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTechContent(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTechChip('Flutter', context),
        _buildTechChip('Dart', context),
        _buildTechChip('Material Design', context),
        _buildTechChip('Visual Studio', context),
        _buildTechChip('Voyager API', context),
        _buildTechChip('GeoNames', context),
        _buildTechChip('FlightRadar', context),
      ],
    );
  }

  Widget _buildDevelopmentContent(BuildContext context) {
    return Column(
      children: [
        _buildTileItem(
          context,
          'Maxine Fonua',
          'Developer',
          Icons.person,
          'https://www.linkedin.com/in/maxfonua',
        ),
        _buildTileItem(
          context,
          'Contact',
          'maxinefonua@gmail.com',
          Icons.mail,
          'https://maxinefonua.com/',
        ),
        _buildTileItem(
          context,
          'Source Code',
          'GitHub Repository',
          Icons.code,
          'https://github.com/maxinefonua/voyager-ui',
        ),
      ],
    );
  }

  Widget _buildTileItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData iconData,
    String urlToLaunch,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(40),
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
                await Future.delayed(Duration(milliseconds: 150));
                final Uri url = Uri.parse(urlToLaunch);
                if (!await launchUrl(
                  url,
                  mode: LaunchMode
                      .externalApplication, // This opens in default browser
                )) {
                  throw Exception('Could not launch $url');
                }
              },
              splashColor: Theme.of(context).primaryColor.withAlpha(50),
              child: Icon(iconData, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
