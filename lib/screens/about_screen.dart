import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voyager/static/logo_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScaffold extends StatefulWidget {
  const AboutScaffold({super.key});

  @override
  State<AboutScaffold> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScaffold> {
  String appVersion = 'Loading...';
  String appName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appVersion = packageInfo.version;
      appName = packageInfo.appName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About'), backgroundColor: Colors.blue),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints(maxWidth: 650, minWidth: 345),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: _buildCard(
                  context,
                  _buildVoyagerLabel(context),
                  _buildVoyagerContent(context),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    _buildBackgroundFill(context),
                    ListView(
                      padding: EdgeInsets.all(16),
                      children: [
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
              ),
            ],
          ),
        ),
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

  Widget _buildBackgroundFill(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 10, top: 38),
        child: FittedBox(
          fit: BoxFit.contain,
          child: LogoSvg(
            size: 420,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).primaryColor
                : Colors.blue.withAlpha(10),
          ),
        ),
      ),
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
        Text(
          'v $appVersion',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Beta',
            style: TextStyle(
              color: Colors.white,
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
      'Enhancing the flight search experience with exhaustive route paths and nearby airport suggestions.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
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
        _buildTechChip('AWS EC2', context),
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
          'https://maxinefonua.com/',
        ),
        _buildTileItem(
          context,
          'Voyager API',
          'Backend Services',
          Icons.api_rounded,
          'https://api.voyagerapp.org/',
        ),
        _buildTileItem(
          context,
          'GitHub Repository',
          'Flutter Source Code',
          FontAwesomeIcons.github,
          'https://github.com/maxinefonua/voyager-app',
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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(20),
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Material(
            color: isDarkMode ? Colors.grey[50] : Theme.of(context).cardColor,
            child: InkWell(
              onTap: () async {
                await Future.delayed(Duration(milliseconds: 150));
                final Uri url = Uri.parse(urlToLaunch);
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  throw Exception('Could not launch $url');
                }
              },
              splashColor: Colors.blue.withAlpha(50),
              child: Icon(iconData, color: Colors.blue),
            ),
          ),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
