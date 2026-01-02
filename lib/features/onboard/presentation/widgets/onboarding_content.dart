import 'package:flutter/material.dart';
import 'package:getagig/features/onboard/domain/entities/onboarding_items.dart';


class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;
  final Orientation orientation;
  final bool isLargeScreen;
  final bool isSmallScreen;
  final double contentPadding;

  const OnboardingContent({
    super.key,
    required this.item,
    required this.orientation,
    required this.isLargeScreen,
    required this.isSmallScreen,
    required this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = orientation == Orientation.landscape;

    return SingleChildScrollView(
      physics: isLandscape || isSmallScreen
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: contentPadding),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Container
            Container(
              height: isLandscape
                  ? size.height * 0.4
                  : size.height * 0.35,
              margin: EdgeInsets.only(
                bottom: isLandscape ? 20 : 40,
                top: isLandscape ? 10 : 30,
              ),
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10 : 0,
              ),
              child: Text(
                item.title,
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
                  fontFamily: 'Urbanist-Bold',
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen
                    ? 10
                    : isLandscape
                        ? 40
                        : 30,
              ),
              child: Text(
                item.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLargeScreen
                      ? 18
                      : isSmallScreen
                          ? 14
                          : 16,
                  fontFamily: 'Urbanist-Medium',
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
  }
}