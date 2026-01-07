import 'package:flutter/material.dart';
import 'package:voyager/content/wave_bar.dart';
import 'package:voyager/static/logo_svg.dart';

class VoyagerSplashScreen extends StatelessWidget {
  final Animation<double> animation;
  final String appVersion;
  const VoyagerSplashScreen({
    super.key,
    required this.animation,
    required this.appVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorDark,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: animation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LogoSvg(size: 100, color: Colors.white),
                    const SizedBox(height: 20),
                    // App name with animation
                    ScaleTransition(
                      scale: animation,
                      child: Column(
                        children: [
                          Text(
                            'Voyager',
                            style:
                                Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ) ??
                                const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'v $appVersion',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (index) => WaveBar(index: index)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
