import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:voyager/controllers/expansion_state_controller.dart';
import 'package:voyager/core/flight_search_state.dart';
import 'package:voyager/layout/responsive_layout.dart';
import 'package:voyager/screens/splash_screen.dart';
import 'package:voyager/screens/unavailable_screen.dart';
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
  bool _initializationFailed = false;
  String? _failedService;
  String? _errorMessage;
  Map<String, dynamic>? _servicesData;
  String appVersion = 'Loading...';
  String appName = 'Loading...';

  late DateTime _initStartTime;

  @override
  void initState() {
    super.initState();
    _initStartTime = DateTime.now();
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
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          appVersion = packageInfo.version;
          appName = packageInfo.appName;
        });
      }
    } catch (e) {
      // Non-critical error, just log it
      debugPrint('Failed to get package info: $e');
    }
  }

  Future<void> _initializeServices() async {
    final startTime = DateTime.now();

    try {
      // Initialize each service with individual error handling

      // 1. Country Service
      CountryService? countryService;
      try {
        countryService = CountryService();
        await countryService.initialize().timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw Exception('Country service initialization timed out'),
        );
        debugPrint('✓ CountryService initialized');
      } catch (e) {
        _handleInitializationError('Country Service', e.toString());
        return;
      }

      // 2. Airport Cache
      AirportCache? airportCache;
      try {
        airportCache = AirportCache();
        await airportCache.initialize().timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw Exception('Airport cache initialization timed out'),
        );
        debugPrint('✓ AirportCache initialized');
      } catch (e) {
        _handleInitializationError('Airport Cache', e.toString());
        return;
      }

      // 3. Timezone Service
      TimezoneService? timezoneService;
      try {
        timezoneService = createTimezoneService();
        await timezoneService.initialize().timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw Exception('Timezone service initialization timed out'),
        );
        debugPrint('✓ TimezoneService initialized');
      } catch (e) {
        _handleInitializationError('Timezone Service', e.toString());
        return;
      }

      // 4. Path Service
      try {
        PathService.init(timezoneService);
        debugPrint('✓ PathService initialized');
      } catch (e) {
        _handleInitializationError('Path Service', e.toString());
        return;
      }

      // All services initialized successfully
      await _ensureMinimumSplashTime();

      if (mounted) {
        setState(() {
          _servicesData = {
            'countryService': countryService,
            'airportCache': airportCache,
            'timezoneService': timezoneService,
          };
          _servicesReady = true;
          _initializationFailed = false;
        });
      }
    } catch (e) {
      // Catch any unexpected errors
      _handleInitializationError('Unknown Service', e.toString());
    }
  }

  void _handleInitializationError(String serviceName, String error) async {
    debugPrint('❌ Failed to initialize $serviceName: $error');

    await _ensureMinimumSplashTime();

    if (mounted) {
      setState(() {
        _initializationFailed = true;
        _failedService = serviceName;
        _errorMessage = error;
      });
    }
  }

  Future<void> _ensureMinimumSplashTime() async {
    const minimumSplashDuration = Duration(seconds: 3);
    final elapsed = DateTime.now().difference(_initStartTime);

    if (elapsed < minimumSplashDuration) {
      await Future.delayed(minimumSplashDuration - elapsed);
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _initializationFailed = false;
      _failedService = null;
      _errorMessage = null;
      _initStartTime = DateTime.now(); // Reset timer for retry
    });
    await _initializeServices();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error screen if initialization failed
    if (_initializationFailed) {
      return UnavailableScreen(
        serviceName: _failedService ?? 'Unknown Service',
        errorMessage: _errorMessage ?? 'An unknown error occurred',
        onRetry: _retryInitialization,
      );
    }

    // Navigate to main app when services are ready
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

    // Show splash screen during initialization
    return VoyagerSplashScreen(animation: _animation, appVersion: appVersion);
  }
}
