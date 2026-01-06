import 'package:flutter/material.dart';
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
      home: SplashScreen(
        duration: const Duration(seconds: 2),
        child: FutureBuilder(
          future: _initializeServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return MyApp(
                countryService: snapshot.data!['countryService'],
                airportCache: snapshot.data!['airportCache'],
                timezoneService: snapshot.data!['timezoneService'],
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          },
        ),
      ),
    ),
  );
}

Future<Map<String, dynamic>> _initializeServices() async {
  final countryService = CountryService();
  await countryService.initialize();
  final airportCache = AirportCache();
  await airportCache.initialize();
  final timezoneService = createTimezoneService();
  await timezoneService.initialize();
  PathService.init(timezoneService);

  return {
    'countryService': countryService,
    'airportCache': airportCache,
    'timezoneService': timezoneService,
  };
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
