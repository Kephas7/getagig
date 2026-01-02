import 'package:flutter/material.dart';

class OnboardingNextButton extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onPressed;
  final bool isLargeScreen;
  final double contentPadding;
  final bool isLandscape;

  const OnboardingNextButton({
    super.key,
    required this.isLastPage,
    required this.onPressed,
    required this.isLargeScreen,
    required this.contentPadding,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          onPressed: onPressed,
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
                isLastPage ? "Get Started" : "Next",
                style: TextStyle(
                  fontSize: isLargeScreen ? 18 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isLastPage)
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
    );
  }
}