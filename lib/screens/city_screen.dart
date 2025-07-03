import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utilities/constants.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> with TickerProviderStateMixin {
  String cityName = '';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6B73FF),
              Color(0xFF9A9CE2),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
          image: DecorationImage(
            image: AssetImage('images/city_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.overlay,
            ),
          ),
        ),
        child: SafeArea(
          child: ResponsiveHelper.isDesktop(context)
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Row(
        children: [
          // Left side - Search form
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 40),
                Expanded(
                  child: _buildSearchCard(context),
                ),
              ],
            ),
          ),
          // Right side - Decorative elements
          Expanded(
            flex: 1,
            child: _buildDecorative(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildSearchCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button with enhanced design
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24.0),
                ),
              ),
            ),
          ),
        ),

        // Title
        FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Search City',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28.0),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: ResponsiveHelper.getResponsiveIconSize(context, 48.0)),
      ],
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.isDesktop(context) ? 500 : double.infinity,
            ),
            child: Card(
              elevation: 20,
              color: Colors.white.withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: ResponsiveHelper.getResponsiveIconSize(context, 50.0),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Search instruction
                    Text(
                      'Enter city name to get weather information',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16.0),
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Search TextField
                    TextField(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18.0),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter city name...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                        prefixIcon: Icon(
                          Icons.location_city,
                          color: Color(0xFF667eea),
                          size: ResponsiveHelper.getResponsiveIconSize(context, 24.0),
                        ),
                        suffixIcon: cityName.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    cityName = '';
                                  });
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[400],
                                  size: ResponsiveHelper.getResponsiveIconSize(context, 20.0),
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFF667eea),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          cityName = value;
                        });
                      },
                      onSubmitted: (value) {
                        _handleSearch();
                      },
                    ),

                    const SizedBox(height: 32),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: cityName.isNotEmpty ? _handleSearch : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF667eea),
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: Color(0xFF667eea).withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: ResponsiveHelper.getResponsiveIconSize(context, 24.0),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Get Weather',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18.0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick suggestions
                    if (ResponsiveHelper.isDesktop(context))
                      _buildQuickSuggestions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = ['London', 'New York', 'Tokyo', 'Paris', 'Sydney'];

    return Column(
      children: [
        Text(
          'Quick suggestions:',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14.0),
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((city) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  cityName = city;
                });
                _handleSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF667eea).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFF667eea).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  city,
                  style: TextStyle(
                    color: Color(0xFF667eea),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12.0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDecorative(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud,
              size: ResponsiveHelper.getResponsiveIconSize(context, 100.0),
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Find Weather',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24.0),
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch() {
    if (cityName.isNotEmpty) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context, cityName.trim());
    }
  }
}
