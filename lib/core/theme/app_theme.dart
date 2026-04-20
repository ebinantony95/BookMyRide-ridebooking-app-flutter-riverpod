import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppRadius {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double full = 999.0;

  static BorderRadius get cardRadius => BorderRadius.circular(md);
  static BorderRadius get buttonRadius => BorderRadius.circular(md);
  static BorderRadius get inputRadius => BorderRadius.circular(md);
  static BorderRadius get chipRadius => BorderRadius.circular(full);
  static BorderRadius get bottomSheetRadius =>
      const BorderRadius.vertical(top: Radius.circular(xxl));
}

abstract final class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: AppColors.isDarkMode ? 22 : 12,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: AppColors.isDarkMode ? 28 : 20,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.primary.withValues(
            alpha: AppColors.isDarkMode ? 0.18 : 0.25,
          ),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get bottomSheet => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: AppColors.isDarkMode ? 30 : 24,
          offset: const Offset(0, -4),
        ),
      ];
}

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final background = AppColors.backgroundFor(brightness);
    final cardBackground = AppColors.cardBackgroundFor(brightness);
    final textPrimary = AppColors.textPrimaryFor(brightness);
    final textSecondary = AppColors.textSecondaryFor(brightness);
    final textHint = AppColors.textHintFor(brightness);
    final border = AppColors.borderFor(brightness);
    final divider = AppColors.dividerFor(brightness);
    final shadowColor = AppColors.shadowMediumFor(brightness);

    final overlayStyle = brightness == Brightness.dark
        ? const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: _colorScheme(brightness),
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: cardBackground,
      dividerColor: divider,
      hintColor: textHint,
      shadowColor: shadowColor,
      splashColor: AppColors.primary.withValues(alpha: 0.10),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        systemOverlayStyle: overlayStyle.copyWith(
          systemNavigationBarColor: background,
        ),
        titleTextStyle: AppTextStyles.subheadingBold.copyWith(
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actionsIconTheme: IconThemeData(color: textPrimary),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primaryDisabledFor(brightness),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.textOnPrimary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.body.copyWith(color: textHint),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
        floatingLabelStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        helperStyle: AppTextStyles.caption.copyWith(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: border,
        dragHandleSize: const Size(40, 4),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardBackground,
        selectedColor: AppColors.primaryLightFor(brightness),
        labelStyle: AppTextStyles.caption.copyWith(color: textPrimary),
        side: BorderSide(color: border, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: textHint,
        selectedLabelStyle:
            AppTextStyles.label.copyWith(color: AppColors.primary),
        unselectedLabelStyle: AppTextStyles.label.copyWith(color: textHint),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFFF2F6F3)
            : textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: brightness == Brightness.dark ? background : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: textPrimary,
        textColor: textPrimary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        titleTextStyle: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
        subtitleTextStyle: AppTextStyles.caption.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLightFor(brightness);
          }
          return border;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLightFor(brightness),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.25),
        selectionHandleColor: AppColors.primary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
      textTheme: _buildTextTheme(brightness),
    );
  }

  static ColorScheme _colorScheme(Brightness brightness) {
    final background = AppColors.backgroundFor(brightness);
    final cardBackground = AppColors.cardBackgroundFor(brightness);
    final surfaceVariant = AppColors.surfaceVariantFor(brightness);
    final textPrimary = AppColors.textPrimaryFor(brightness);
    final textSecondary = AppColors.textSecondaryFor(brightness);
    final border = AppColors.borderFor(brightness);

    if (brightness == Brightness.dark) {
      return ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLightFor(brightness),
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.info,
        onSecondary: AppColors.textOnPrimary,
        secondaryContainer: AppColors.infoLightFor(brightness),
        onSecondaryContainer: AppColors.info,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorLightFor(brightness),
        onErrorContainer: AppColors.error,
        surface: background,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: textSecondary,
        outline: border,
        shadow: AppColors.shadowMediumFor(brightness),
      );
    }

    return ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryLightFor(brightness),
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryDark,
      onSecondary: AppColors.textOnPrimary,
      secondaryContainer: AppColors.infoLightFor(brightness),
      onSecondaryContainer: AppColors.info,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorLightFor(brightness),
      onErrorContainer: AppColors.error,
      surface: background,
      onSurface: textPrimary,
      surfaceContainerHighest: cardBackground,
      onSurfaceVariant: textSecondary,
      outline: border,
      shadow: AppColors.shadowMediumFor(brightness),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final textPrimary = AppColors.textPrimaryFor(brightness);
    final textSecondary = AppColors.textSecondaryFor(brightness);
    final textHint = AppColors.textHintFor(brightness);

    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: textPrimary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: textPrimary),
      headlineLarge: AppTextStyles.headingLarge.copyWith(color: textPrimary),
      headlineMedium: AppTextStyles.heading.copyWith(color: textPrimary),
      headlineSmall: AppTextStyles.headingSmall.copyWith(color: textPrimary),
      titleLarge: AppTextStyles.subheadingBold.copyWith(color: textPrimary),
      titleMedium: AppTextStyles.subheading.copyWith(color: textPrimary),
      titleSmall: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textPrimary),
      bodyMedium: AppTextStyles.body.copyWith(color: textPrimary),
      bodySmall: AppTextStyles.caption.copyWith(color: textSecondary),
      labelLarge: AppTextStyles.button.copyWith(color: AppColors.textOnPrimary),
      labelMedium: AppTextStyles.label.copyWith(color: textSecondary),
      labelSmall: AppTextStyles.label.copyWith(color: textHint),
    );
  }
}
