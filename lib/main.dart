import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:voyager/controllers/expansion_state_controller.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/layout/responsive_layout.dart';
import 'package:voyager/screens/splash_screen.dart';
import 'package:voyager/services/airport_cache.dart';
import 'package:voyager/services/country_service.dart';
import 'package:voyager/services/path_service.dart';
import 'package:voyager/services/timezone/timezone_service.dart'
    show TimezoneService, createTimezoneService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const InitializationScreen(),
    ),
  );
}

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _servicesReady = false;
  Map<String, dynamic>? _servicesData;
  String appVersion = 'Loading...';
  String appName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _initPackageInfo();
    _initializeServices();
  }

  Future<void> _initPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appVersion = packageInfo.version;
      appName = packageInfo.appName;
    });
  }

  Future<void> _initializeServices() async {
    final startTime = DateTime.now();
    final countryService = CountryService();
    await countryService.initialize();
    final airportCache = AirportCache();
    await airportCache.initialize();
    final timezoneService = createTimezoneService();
    await timezoneService.initialize();
    PathService.init(timezoneService);

    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < const Duration(seconds: 3)) {
      await Future.delayed(const Duration(seconds: 3) - elapsed);
    }
    if (mounted) {
      setState(() {
        _servicesData = {
          'countryService': countryService,
          'airportCache': airportCache,
          'timezoneService': timezoneService,
        };
        _servicesReady = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_servicesReady && _servicesData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyApp(
              countryService: _servicesData!['countryService'],
              airportCache: _servicesData!['airportCache'],
              timezoneService: _servicesData!['timezoneService'],
            ),
          ),
        );
      });
    }
    return VoyagerSplashScreen(animation: _animation, appVersion: appVersion);
  }
}

class MyApp extends StatelessWidget {
  final CountryService countryService;
  final AirportCache airportCache;
  final TimezoneService timezoneService;

  const MyApp({
    super.key,
    required this.countryService,
    required this.airportCache,
    required this.timezoneService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AirportCache>.value(value: airportCache),
        Provider<CountryService>.value(value: countryService),
        Provider<TimezoneService>.value(value: timezoneService),
        Provider<PathService>(create: (context) => PathService()),
        ChangeNotifierProvider(create: (context) => FlightSearchState()),
        ChangeNotifierProvider(create: (context) => ExpansionState()),
      ],
      child: MaterialApp(
        title: 'Voyager',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          useMaterial3: false,
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: ResponsiveLayout(),
      ),
    );
  }
}
