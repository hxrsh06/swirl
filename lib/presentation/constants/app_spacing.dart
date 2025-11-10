import 'package:flutter/material.dart';

/// App spacing constants for consistent padding and margins throughout the app
class AppSpacing {
  // Small spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double xxxxl = 40.0;
  static const double xxxxxl = 48.0;

  // Padding helpers
  static EdgeInsetsGeometry getPaddingAll(double value) => EdgeInsets.all(value);
  static EdgeInsetsGeometry getPaddingSymmetric({double horizontal = 0, double vertical = 0}) => EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  static EdgeInsetsGeometry getPaddingOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // Common padding values
  static EdgeInsetsGeometry get paddingXs => getPaddingAll(xs);
  static EdgeInsetsGeometry get paddingSm => getPaddingAll(sm);
  static EdgeInsetsGeometry get paddingMd => getPaddingAll(md);
  static EdgeInsetsGeometry get paddingLg => getPaddingAll(lg);
  static EdgeInsetsGeometry get paddingXl => getPaddingAll(xl);
  static EdgeInsetsGeometry get paddingXxl => getPaddingAll(xxl);
  static EdgeInsetsGeometry get paddingXxxl => getPaddingAll(xxxl);

  // Horizontal padding
  static EdgeInsetsGeometry get paddingHorizontalSm => getPaddingSymmetric(horizontal: sm);
  static EdgeInsetsGeometry get paddingHorizontalMd => getPaddingSymmetric(horizontal: md);
  static EdgeInsetsGeometry get paddingHorizontalLg => getPaddingSymmetric(horizontal: lg);
  static EdgeInsetsGeometry get paddingHorizontalXl => getPaddingSymmetric(horizontal: xl);
  static EdgeInsetsGeometry get paddingHorizontalXxl => getPaddingSymmetric(horizontal: xxl);

  // Vertical padding
  static EdgeInsetsGeometry get paddingVerticalSm => getPaddingSymmetric(vertical: sm);
  static EdgeInsetsGeometry get paddingVerticalMd => getPaddingSymmetric(vertical: md);
  static EdgeInsetsGeometry get paddingVerticalLg => getPaddingSymmetric(vertical: lg);
  static EdgeInsetsGeometry get paddingVerticalXl => getPaddingSymmetric(vertical: xl);
  static EdgeInsetsGeometry get paddingVerticalXxl => getPaddingSymmetric(vertical: xxl);

  // Symmetric padding
  static EdgeInsetsGeometry get paddingSymmetricSm => getPaddingSymmetric(horizontal: sm, vertical: sm);
  static EdgeInsetsGeometry get paddingSymmetricMd => getPaddingSymmetric(horizontal: md, vertical: md);
  static EdgeInsetsGeometry get paddingSymmetricLg => getPaddingSymmetric(horizontal: lg, vertical: lg);
  static EdgeInsetsGeometry get paddingSymmetricXl => getPaddingSymmetric(horizontal: xl, vertical: xl);

  // Margin helpers
  static EdgeInsetsGeometry getMarginAll(double value) => EdgeInsets.all(value);
  static EdgeInsetsGeometry getMarginSymmetric({double horizontal = 0, double vertical = 0}) => EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  static EdgeInsetsGeometry getMarginOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // Margins
  static EdgeInsetsGeometry get marginXs => getMarginAll(xs);
  static EdgeInsetsGeometry get marginSm => getMarginAll(sm);
  static EdgeInsetsGeometry get marginMd => getMarginAll(md);
  static EdgeInsetsGeometry get marginLg => getMarginAll(lg);
  static EdgeInsetsGeometry get marginXl => getMarginAll(xl);
  static EdgeInsetsGeometry get marginXxl => getMarginAll(xxl);
  static EdgeInsetsGeometry get marginXxxl => getMarginAll(xxxl);

  // Horizontal margins
  static EdgeInsetsGeometry get marginHorizontalSm => getMarginSymmetric(horizontal: sm);
  static EdgeInsetsGeometry get marginHorizontalMd => getMarginSymmetric(horizontal: md);
  static EdgeInsetsGeometry get marginHorizontalLg => getMarginSymmetric(horizontal: lg);
  static EdgeInsetsGeometry get marginHorizontalXl => getMarginSymmetric(horizontal: xl);
  static EdgeInsetsGeometry get marginHorizontalXxl => getMarginSymmetric(horizontal: xxl);

  // Vertical margins
  static EdgeInsetsGeometry get marginVerticalSm => getMarginSymmetric(vertical: sm);
  static EdgeInsetsGeometry get marginVerticalMd => getMarginSymmetric(vertical: md);
  static EdgeInsetsGeometry get marginVerticalLg => getMarginSymmetric(vertical: lg);
  static EdgeInsetsGeometry get marginVerticalXl => getMarginSymmetric(vertical: xl);
  static EdgeInsetsGeometry get marginVerticalXxl => getMarginSymmetric(vertical: xxl);
}