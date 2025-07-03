import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/weather.dart';
import '../utilities/constants.dart';
import 'location_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _spinAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String loadingMessage = 'Getting your location...';
  bool hasError = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _spinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.linear,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _spinController.repeat();
    _fadeController.forward();
    _scaleController.forward();

    getLocationData();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void getLocationData() async {
    try {
      setState(() {
        loadingMessage = 'Getting your location...';
        hasError = false;
      });

      WeatherModel weatherModel = WeatherModel();
      var weatherData = await weatherModel.getDetailedWeatherData();

      setState(() {
        loadingMessage = 'Loading weather data...';
      });

      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                LocationScreen(weatherData: weatherData),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      setState(() {
        hasError = true;
        loadingMessage = 'Unable to get weather data';
      });

      HapticFeedback.heavyImpact();

      // Show error for 2 seconds then retry
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          loadingMessage = 'Retrying...';
          hasError = false;
        });
        await Future.delayed(const Duration(seconds: 1));
        getLocationData();
      }
    }
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
              Color(0xFF2196F3),
              Color(0xFF21CBF3),
              Color(0xFF2196F3),
              Color(0xFF0D47A1),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: ResponsiveHelper.isDesktop(context)
              ? _buildDesktopLayout()
              : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 20,
          color: Colors.white.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(60.0),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: ResponsiveHelper.getMainPadding(context),
      child: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App Title
        ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  'Clima',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isDesktop(context) ? 72 : 56,
                    fontWeight: FontWeight.w300,
                    color: ResponsiveHelper.isDesktop(context)
                        ? Color(0xFF2196F3)
                        : Colors.white,
                    letterSpacing: 3,
                    shadows: ResponsiveHelper.isDesktop(context)
                        ? []
                        : [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Weather App',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isDesktop(context) ? 24 : 20,
                    fontWeight: FontWeight.w400,
                    color: ResponsiveHelper.isDesktop(context)
                        ? Colors.grey[600]
                        : Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: ResponsiveHelper.isDesktop(context) ? 80 : 60),

        // Loading Animation
        FadeTransition(
          opacity: _fadeAnimation,
          child: _buildLoadingAnimation(),
        ),

        SizedBox(height: ResponsiveHelper.isDesktop(context) ? 60 : 40),

        // Loading Message
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.isDesktop(context) ? 24 : 20,
              fontWeight: FontWeight.w400,
              color: ResponsiveHelper.isDesktop(context)
                  ? Color(0xFF2196F3)
                  : Colors.white,
              height: 1.4,
            ),
          ),
        ),

        if (hasError) ...[
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Icon(
              Icons.error_outline,
              size: ResponsiveHelper.isDesktop(context) ? 40 : 32,
              color: Colors.red[400],
            ),
          ),
        ],

        SizedBox(height: ResponsiveHelper.isDesktop(context) ? 40 : 30),

        // Loading dots
        if (!hasError) _buildLoadingDots(),
      ],
    );
  }

  Widget _buildLoadingAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer rotating circle
        RotationTransition(
          turns: _spinAnimation,
          child: Container(
            width: ResponsiveHelper.isDesktop(context) ? 120 : 100,
            height: ResponsiveHelper.isDesktop(context) ? 120 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ResponsiveHelper.isDesktop(context)
                    ? Color(0xFF2196F3).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
          ),
        ),

        // Center weather icon
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ResponsiveHelper.isDesktop(context)
                  ? Color(0xFF2196F3).withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.2),
            ),
            child: Icon(
              hasError ? Icons.error_outline : Icons.cloud,
              size: ResponsiveHelper.isDesktop(context) ? 48 : 40,
              color: hasError
                  ? Colors.red[400]
                  : ResponsiveHelper.isDesktop(context)
                      ? Color(0xFF2196F3)
                      : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _spinAnimation,
          builder: (context, child) {
            final delay = index * 0.3;
            final opacity = ((_spinAnimation.value + delay) % 1.0) > 0.5 ? 1.0 : 0.3;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: ResponsiveHelper.isDesktop(context) ? 12 : 10,
              height: ResponsiveHelper.isDesktop(context) ? 12 : 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (ResponsiveHelper.isDesktop(context)
                    ? Color(0xFF2196F3)
                    : Colors.white).withValues(alpha: opacity),
              ),
            );
          },
        );
      }),
    );
  }
}
