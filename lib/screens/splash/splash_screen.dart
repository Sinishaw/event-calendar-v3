import 'package:event_calendar_v2/firebase/dynamicLink/dynamicLink.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/main.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _startInitialization();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startInitialization() async {
    final startTime = DateTime.now();

    try {
      // 1. Run core app initialization & dynamic links with a global 3.5s timeout safety gate
      await Future.any([
        Future.wait([
          initializeApp(),
          if (mounted) FirebaseDynamicLink.configureAppFromDynamicLinkV2(context),
        ]),
        Future.delayed(const Duration(milliseconds: 3500)),
      ]);
    } catch (e) {
      debugPrint("------ Splash Initialization Error or Timeout: $e");
    }

    // 2. Ensure splash is visible for at least 2.0 seconds for smooth user experience
    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(seconds: 2) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });

      // 3. Smooth transition to ContainerPage
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ContainerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    
    // Choose clean solid neutral background to avoid startup flashes
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final onBackgroundColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Center content: Pulse Icon & Progress
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing custom glassmorphic calendar icon (shrunk for cleaner aesthetic)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.15 + (0.10 * _animationController.value)),
                              blurRadius: 16 + (8 * _animationController.value),
                              spreadRadius: 1 + (1.5 * _animationController.value),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: 44,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                // Smooth linear progress indicator
                SizedBox(
                  width: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _isInitializing ? null : 1.0,
                      backgroundColor: primaryColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom aligned localized opening text
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Text(
                AppLocalizations.of(context)!.opening,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: onBackgroundColor.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
