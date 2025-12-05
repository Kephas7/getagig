import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboard1.jpg",
      "title": "Find a Stage for your Talents",
      "subtitle": "Find gigs and opportunities that match your talent.",
    },
    {
      "image": "assets/images/onboard2.jpg",
      "title": "Find Musicians for your events",
      "subtitle":
          "Discover artists, bands, and professionals for your venue or events.",
    },
    {
      "image": "assets/images/onboard3.jpg",
      "title": "Grow Your Career",
      "subtitle": "Get discovered and build your music journey.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final orientation = mediaQuery.orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isSmallScreen = size.width < 350;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double contentPadding = isLargeScreen
                ? 60
                : isLandscape
                ? 40
                : 20;

            return Column(
              children: [
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
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) =>
                        setState(() => currentPage = index),
                    itemCount: onboardingData.length,
                    itemBuilder: (_, index) {
                      return SingleChildScrollView(
                        // Only enable scrolling in landscape or on very small screens
                        physics: isLandscape || isSmallScreen
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: contentPadding,
                          ),
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image container - responsive sizing
                              Container(
                                height: isLandscape
                                    ? size.height * 0.4
                                    : size.height * 0.35,
                                margin: EdgeInsets.only(
                                  bottom: isLandscape ? 20 : 40,
                                  top: isLandscape ? 10 : 30,
                                ),
                                child: Image.asset(
                                  onboardingData[index]["image"]!,
                                  fit: BoxFit.contain,
                                  // Use scale-down for very small images
                                  filterQuality: FilterQuality.high,
                                ),
                              ),

                              // Title - responsive font size
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 10 : 0,
                                ),
                                child: Text(
                                  onboardingData[index]["title"]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLargeScreen
                                        ? 32
                                        : isLandscape
                                        ? 24
                                        : isSmallScreen
                                        ? 22
                                        : 28,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen
                                      ? 10
                                      : isLandscape
                                      ? 40
                                      : 30,
                                ),
                                child: Text(
                                  onboardingData[index]["subtitle"]!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLargeScreen
                                        ? 18
                                        : isSmallScreen
                                        ? 14
                                        : 16,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: isLandscape
                                    ? 40
                                    : isLargeScreen
                                    ? 60
                                    : 30,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(
                    bottom: isLandscape ? 10 : 20,
                    top: isLandscape ? 10 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 3 : 6,
                          vertical: 4,
                        ),
                        width: currentPage == index
                            ? isSmallScreen
                                  ? 16
                                  : 20
                            : isSmallScreen
                            ? 6
                            : 8,
                        height: isSmallScreen ? 6 : 8,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? Colors.black
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: currentPage == index
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    contentPadding,
                    0,
                    contentPadding,
                    isLandscape
                        ? 16
                        : isLargeScreen
                        ? 40
                        : 30,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentPage == onboardingData.length - 1) {
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isLargeScreen ? 18 : 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isLargeScreen ? 12 : 8,
                          ),
                        ),
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentPage == onboardingData.length - 1
                                ? "Get Started"
                                : "Next",
                            style: TextStyle(
                              fontSize: isLargeScreen ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (currentPage < onboardingData.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.arrow_forward,
                                size: isLargeScreen ? 20 : 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
