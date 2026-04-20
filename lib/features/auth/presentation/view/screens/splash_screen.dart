import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_my_ride/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_my_ride/core/theme/app_colors.dart';
import 'package:make_my_ride/features/auth/presentation/view/widgets/splash/bottom_circular_indicator.dart';
import 'package:make_my_ride/features/auth/presentation/view/widgets/splash/decorative_circles.dart';
import 'package:make_my_ride/features/auth/presentation/view/widgets/splash/splash_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF2AB548),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // Check auth status then hand off ALL route decisions to the router
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      try {
        await ref.read(authViewModelProvider.notifier).checkCurrentUser();
      } catch (e) {
        debugPrint('Auth check error: $e');
      }

      if (!mounted) return;

      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            AppColors.isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness:
            AppColors.isDarkMode ? Brightness.light : Brightness.dark,
      ));

      // GoRouter handles the navigation automatically once isInitialized is true
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4EE070),
              Color(0xFF37D058),
              Color(0xFF2AB548),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecorativeCircles(
              top: -80,
              right: -60,
              size: 260,
              alpha: 0.08,
            ),
            const DecorativeCircles(
              top: -60,
              right: -40,
              size: 220,
              alpha: 0.06,
            ),

            // ─── Main layout: top 60% center, bottom 40% loader
            Column(
              children: [
                // Centre section — fills most of the screen
                SplashLogo(fadeAnim: _fadeAnim, scaleAnim: _scaleAnim),

                // Bottom loader section
                BottomCircularIndicator(
                    slideAnim: _slideAnim, fadeAnim: _fadeAnim),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
