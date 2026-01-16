import 'package:flutter/material.dart';

/// Utility class for preventing layout overflow issues
class LayoutHelper {
  /// Creates a safe text widget with overflow protection
  static Widget safeText(
    String text, {
    TextStyle? style,
    int? maxLines = 1,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  /// Creates a safe container with constraints to prevent overflow
  static Widget safeContainer({
    required Widget child,
    double? width,
    double? height,
    double? maxWidth,
    double? maxHeight,
    EdgeInsets? padding,
    Decoration? decoration,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
        minWidth: width ?? 0,
        minHeight: height ?? 0,
      ),
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }

  /// Creates a safe column with proper spacing and overflow protection
  static Widget safeColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    double spacing = 0.0,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: List.generate(
        children.length * 2 - 1,
        (index) => index.isEven
            ? children[index ~/ 2]
            : SizedBox(height: spacing),
      ),
    );
  }

  /// Checks if the device screen size is small (likely to cause overflow)
  static bool isSmallScreen(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return height < 700; // Typical threshold for small screens
  }

  /// Gets responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(8.0);
    }
    return const EdgeInsets.all(16.0);
  }

  /// Creates a safe GridView with proper physics and constraints
  static Widget safeGridView({
    required List<Widget> children,
    int crossAxisCount = 2,
    double crossAxisSpacing = 4.0,
    double mainAxisSpacing = 4.0,
    bool shrinkWrap = true,
    EdgeInsets? padding,
  }) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? NeverScrollableScrollPhysics() : null,
      padding: padding,
      children: children,
    );
  }
}
