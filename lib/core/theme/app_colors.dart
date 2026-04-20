import 'package:flutter/material.dart';

abstract final class AppColors {
  static Brightness _brightness = Brightness.light;

  static const Color primary = Color(0xFF37D058);
  static const Color primaryDark = Color(0xFF2AB548);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFFF4D4F);
  static const Color warning = Color(0xFFFFA940);
  static const Color success = Color(0xFF10D83A);
  static const Color info = Color(0xFF4096FF);

  static const Color routeColor = Color(0xFF10D83A);
  static const Color markerPrimary = Color(0xFF10D83A);
  static const Color markerDestination = Color(0xFFFF4D4F);

  static const Color statusPending = Color(0xFFFFA940);
  static const Color statusActive = Color(0xFF10D83A);
  static const Color statusCompleted = Color(0xFF4096FF);
  static const Color statusCancelled = Color(0xFFFF4D4F);

  static const Color _lightPrimaryLight = Color(0xFFEAF9EE);
  static const Color _darkPrimaryLight = Color(0xFF173721);
  static const Color _lightPrimaryDisabled = Color(0xFFAADFB8);
  static const Color _darkPrimaryDisabled = Color(0xFF355642);

  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _darkBackground = Color(0xFF08110D);
  static const Color _lightCardBackground = Color(0xFFF8F9FA);
  static const Color _darkCardBackground = Color(0xFF101B16);
  static const Color _lightSurfaceVariant = Color(0xFFF1F3F5);
  static const Color _darkSurfaceVariant = Color(0xFF18251E);

  static const Color _lightTextPrimary = Color(0xFF1A1A1A);
  static const Color _darkTextPrimary = Color(0xFFF2F6F3);
  static const Color _lightTextSecondary = Color(0xFF6B6B6B);
  static const Color _darkTextSecondary = Color(0xFFA9B6AE);
  static const Color _lightTextHint = Color(0xFFADB5BD);
  static const Color _darkTextHint = Color(0xFF738078);

  static const Color _lightBorder = Color(0xFFE5E7EB);
  static const Color _darkBorder = Color(0xFF26342D);
  static const Color _lightDivider = Color(0xFFF1F3F5);
  static const Color _darkDivider = Color(0xFF17211C);

  static const Color _lightErrorLight = Color(0xFFFFF1F0);
  static const Color _darkErrorLight = Color(0xFF341517);
  static const Color _lightWarningLight = Color(0xFFFFF7E6);
  static const Color _darkWarningLight = Color(0xFF33230D);
  static const Color _lightSuccessLight = Color(0xFFE6FCEB);
  static const Color _darkSuccessLight = Color(0xFF112F18);
  static const Color _lightInfoLight = Color(0xFFE6F4FF);
  static const Color _darkInfoLight = Color(0xFF10263D);

  static const Color _lightMapOverlay = Color(0x1A000000);
  static const Color _darkMapOverlay = Color(0x66000000);
  static const Color _lightShadowLight = Color(0x0D000000);
  static const Color _darkShadowLight = Color(0x40000000);
  static const Color _lightShadowMedium = Color(0x1A000000);
  static const Color _darkShadowMedium = Color(0x66000000);

  static void syncBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  static Brightness get brightness => _brightness;
  static bool get isDarkMode => _brightness == Brightness.dark;

  static T _resolveFor<T>(Brightness brightness, T light, T dark) {
    return brightness == Brightness.dark ? dark : light;
  }

  static T _resolve<T>(T light, T dark) {
    return _resolveFor(_brightness, light, dark);
  }

  static Color primaryLightFor(Brightness brightness) =>
      _resolveFor(brightness, _lightPrimaryLight, _darkPrimaryLight);

  static Color primaryDisabledFor(Brightness brightness) =>
      _resolveFor(brightness, _lightPrimaryDisabled, _darkPrimaryDisabled);

  static Color backgroundFor(Brightness brightness) =>
      _resolveFor(brightness, _lightBackground, _darkBackground);

  static Color cardBackgroundFor(Brightness brightness) =>
      _resolveFor(brightness, _lightCardBackground, _darkCardBackground);

  static Color surfaceVariantFor(Brightness brightness) =>
      _resolveFor(brightness, _lightSurfaceVariant, _darkSurfaceVariant);

  static Color textPrimaryFor(Brightness brightness) =>
      _resolveFor(brightness, _lightTextPrimary, _darkTextPrimary);

  static Color textSecondaryFor(Brightness brightness) =>
      _resolveFor(brightness, _lightTextSecondary, _darkTextSecondary);

  static Color textHintFor(Brightness brightness) =>
      _resolveFor(brightness, _lightTextHint, _darkTextHint);

  static Color borderFor(Brightness brightness) =>
      _resolveFor(brightness, _lightBorder, _darkBorder);

  static Color dividerFor(Brightness brightness) =>
      _resolveFor(brightness, _lightDivider, _darkDivider);

  static Color errorLightFor(Brightness brightness) =>
      _resolveFor(brightness, _lightErrorLight, _darkErrorLight);

  static Color warningLightFor(Brightness brightness) =>
      _resolveFor(brightness, _lightWarningLight, _darkWarningLight);

  static Color successLightFor(Brightness brightness) =>
      _resolveFor(brightness, _lightSuccessLight, _darkSuccessLight);

  static Color infoLightFor(Brightness brightness) =>
      _resolveFor(brightness, _lightInfoLight, _darkInfoLight);

  static Color mapOverlayFor(Brightness brightness) =>
      _resolveFor(brightness, _lightMapOverlay, _darkMapOverlay);

  static Color shadowLightFor(Brightness brightness) =>
      _resolveFor(brightness, _lightShadowLight, _darkShadowLight);

  static Color shadowMediumFor(Brightness brightness) =>
      _resolveFor(brightness, _lightShadowMedium, _darkShadowMedium);

  static Color get primaryLight =>
      _resolve(_lightPrimaryLight, _darkPrimaryLight);
  static Color get primaryDisabled =>
      _resolve(_lightPrimaryDisabled, _darkPrimaryDisabled);

  static Color get background => _resolve(_lightBackground, _darkBackground);
  static Color get cardBackground =>
      _resolve(_lightCardBackground, _darkCardBackground);
  static Color get surfaceVariant =>
      _resolve(_lightSurfaceVariant, _darkSurfaceVariant);

  static Color get textPrimary => _resolve(_lightTextPrimary, _darkTextPrimary);
  static Color get textSecondary =>
      _resolve(_lightTextSecondary, _darkTextSecondary);
  static Color get textHint => _resolve(_lightTextHint, _darkTextHint);

  static Color get border => _resolve(_lightBorder, _darkBorder);
  static Color get divider => _resolve(_lightDivider, _darkDivider);

  static Color get errorLight => _resolve(_lightErrorLight, _darkErrorLight);
  static Color get warningLight =>
      _resolve(_lightWarningLight, _darkWarningLight);
  static Color get successLight =>
      _resolve(_lightSuccessLight, _darkSuccessLight);
  static Color get infoLight => _resolve(_lightInfoLight, _darkInfoLight);

  static Color get mapOverlay => _resolve(_lightMapOverlay, _darkMapOverlay);
  static Color get shadowLight => _resolve(_lightShadowLight, _darkShadowLight);
  static Color get shadowMedium =>
      _resolve(_lightShadowMedium, _darkShadowMedium);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF37D058), Color(0xFF2AB548)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFEAF9EE)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
  );
}
