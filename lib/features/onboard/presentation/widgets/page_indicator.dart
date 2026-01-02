import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;
  final bool isSmallScreen;
  final Color activeColor;
  final Color inactiveColor;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
    required this.isSmallScreen,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).orientation == Orientation.landscape
            ? 10
            : 20,
        top: MediaQuery.of(context).orientation == Orientation.landscape
            ? 10
            : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          itemCount,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 3 : 6,
              vertical: 4,
            ),
            width: currentPage == index
                ? (isSmallScreen ? 16 : 20)
                : (isSmallScreen ? 6 : 8),
            height: isSmallScreen ? 6 : 8,
            decoration: BoxDecoration(
              color: currentPage == index ? activeColor : inactiveColor,
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
    );
  }
}