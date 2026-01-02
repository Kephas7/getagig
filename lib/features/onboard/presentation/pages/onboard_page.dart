import 'package:flutter/material.dart';
import 'package:getagig/app/routes/app_routes.dart';
import 'package:getagig/features/auth/presentation/pages/login_page.dart';
import 'package:getagig/features/onboard/domain/entities/onboarding_items.dart';
import 'package:getagig/features/onboard/presentation/widgets/next_button.dart';
import 'package:getagig/features/onboard/presentation/widgets/onboarding_content.dart';
import 'package:getagig/features/onboard/presentation/widgets/page_indicator.dart';

class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = const [
    OnboardingItem(
      imagePath: "assets/images/onboard1.jpg",
      title: "Find a Stage for your Talents",
      subtitle: "Find gigs and opportunities that match your talent.",
    ),
    OnboardingItem(
      imagePath: "assets/images/onboard2.jpg",
      title: "Find Musicians for your events",
      subtitle:
          "Discover artists, bands, and professionals for your venue or events.",
    ),
    OnboardingItem(
      imagePath: "assets/images/onboard3.jpg",
      title: "Grow Your Career",
      subtitle: "Get discovered and build your music journey.",
    ),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skipOnboarding() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    AppRoutes.pushReplacement(context,LoginPage());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final orientation = mediaQuery.orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isSmallScreen = size.width < 350;
    final isLargeScreen = size.width > 600;

    final double contentPadding = isLargeScreen
        ? 60
        : isLandscape
        ? 40
        : 20;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Top Bar with Skip Button
                Padding(
                  padding: EdgeInsets.only(
                    top: isLandscape ? 10 : 16,
                    right: contentPadding,
                    left: contentPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isLargeScreen)
                        Image.asset("assets/images/mylogo.png", height: 40),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Urbanist-Medium',
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page View Content
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: _onPageChanged,
                    itemCount: _onboardingItems.length,
                    itemBuilder: (context, index) {
                      return OnboardingContent(
                        item: _onboardingItems[index],
                        orientation: orientation,
                        isLargeScreen: isLargeScreen,
                        isSmallScreen: isSmallScreen,
                        contentPadding: contentPadding,
                      );
                    },
                  ),
                ),

                // Page Indicator
                PageIndicator(
                  itemCount: _onboardingItems.length,
                  currentPage: _currentPage,
                  isSmallScreen: isSmallScreen,
                ),

                // Next Button
                OnboardingNextButton(
                  isLastPage: _currentPage == _onboardingItems.length - 1,
                  onPressed: _nextPage,
                  isLargeScreen: isLargeScreen,
                  contentPadding: contentPadding,
                  isLandscape: isLandscape,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
