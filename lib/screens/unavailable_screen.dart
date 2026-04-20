import 'package:flutter/material.dart';

class UnavailableScreen extends StatefulWidget {
  final String serviceName;
  final String errorMessage;
  final VoidCallback onRetry;

  const UnavailableScreen({
    super.key,
    required this.serviceName,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  State<UnavailableScreen> createState() => _AnimatedUnavailableScreenState();
}

class _AnimatedUnavailableScreenState extends State<UnavailableScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(15),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withAlpha(10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Oops! Service Unavailable',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'We\'re having trouble connecting to ${widget.serviceName}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again later.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {});
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                          widget.onRetry();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh),
                            SizedBox(width: 8),
                            Text('Refresh', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showHelpDialog(context),
                          icon: const Icon(Icons.help_outline, size: 18),
                          label: const Text('Help'),
                        ),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () => _showDiagnostics(context),
                          icon: const Icon(Icons.bug_report, size: 18),
                          label: const Text('Diagnostics'),
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Try these quick fixes:'),
            SizedBox(height: 12),
            Text('1. Turn Airplane mode on/off'),
            Text('2. Switch between Wi-Fi and mobile data'),
            Text('3. Restart the app'),
            Text('4. Check for system updates'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDiagnostics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Connection Diagnostics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _DiagnosticItem(label: 'Service', value: widget.serviceName),
            _DiagnosticItem(label: 'Error', value: widget.errorMessage),
            _DiagnosticItem(label: 'Time', value: DateTime.now().toString()),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onRetry();
              },
              child: const Text('Run Diagnostics & Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticItem extends StatelessWidget {
  final String label;
  final String value;

  const _DiagnosticItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
