import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final bool fullWidth;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.fullWidth = true,
    this.width,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.fullWidth = true,
    this.width,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.primary;

  const AppButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.fullWidth = true,
    this.width,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.outline;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.fullWidth = true,
    this.width,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.fullWidth = true,
    this.width,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.danger;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ButtonStyle get _style => _resolveStyle();

  _ButtonStyle _resolveStyle() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _ButtonStyle(
          background: AppColors.primary,
          foreground: AppColors.textOnPrimary,
          pressedBackground: AppColors.primaryDark,
          shadows: AppShadows.button,
          border: null,
        );
      case AppButtonVariant.secondary:
        return _ButtonStyle(
          background: AppColors.primaryLight,
          foreground:
              AppColors.isDarkMode ? AppColors.primary : AppColors.primaryDark,
          pressedBackground: AppColors.primaryLight.withValues(
            alpha: AppColors.isDarkMode ? 0.82 : 1,
          ),
          shadows: null,
          border: null,
        );
      case AppButtonVariant.outline:
        return _ButtonStyle(
          background: Colors.transparent,
          foreground: AppColors.primary,
          pressedBackground: AppColors.primaryLight.withValues(
            alpha: AppColors.isDarkMode ? 0.65 : 1,
          ),
          shadows: AppColors.isDarkMode ? AppShadows.card : null,
          border: BorderSide(color: AppColors.primary, width: 1.5),
        );
      case AppButtonVariant.ghost:
        return _ButtonStyle(
          background: Colors.transparent,
          foreground: AppColors.primary,
          pressedBackground: AppColors.primaryLight.withValues(
            alpha: AppColors.isDarkMode ? 0.65 : 1,
          ),
          shadows: null,
          border: null,
        );
      case AppButtonVariant.danger:
        return _ButtonStyle(
          background: AppColors.error,
          foreground: Colors.white,
          pressedBackground: AppColors.error
              .withValues(alpha: AppColors.isDarkMode ? 0.84 : 1),
          shadows: null,
          border: null,
        );
    }
  }

  double get _height {
    switch (widget.size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 52;
      case AppButtonSize.large:
        return 60;
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppTextStyles.buttonSmall.copyWith(color: _style.foreground);
      case AppButtonSize.medium:
        return AppTextStyles.button.copyWith(color: _style.foreground);
      case AppButtonSize.large:
        return AppTextStyles.button
            .copyWith(color: _style.foreground, fontSize: 17);
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 22;
    }
  }

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _isDisabled ? null : (_) => _controller.forward(),
        onTapUp: _isDisabled ? null : (_) => _controller.reverse(),
        onTapCancel: _isDisabled ? null : () => _controller.reverse(),
        onTap: _isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.fullWidth ? double.infinity : widget.width,
          height: _height,
          decoration: BoxDecoration(
            color: _isDisabled
                ? (widget.variant == AppButtonVariant.primary
                    ? AppColors.primaryDisabled
                    : _style.background.withValues(alpha: 0.5))
                : _style.background,
            borderRadius: AppRadius.buttonRadius,
            border: _style.border != null
                ? Border.fromBorderSide(_style.border!)
                : null,
            boxShadow: (!_isDisabled && _style.shadows != null)
                ? _style.shadows
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: _iconSize,
                    height: _iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _style.foreground,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.prefixIcon != null) ...[
                        IconTheme(
                          data: IconThemeData(
                              color: _style.foreground, size: _iconSize),
                          child: widget.prefixIcon!,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.label, style: _textStyle),
                      if (widget.suffixIcon != null) ...[
                        const SizedBox(width: 8),
                        IconTheme(
                          data: IconThemeData(
                              color: _style.foreground, size: _iconSize),
                          child: widget.suffixIcon!,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ButtonStyle {
  final Color background;
  final Color foreground;
  final Color pressedBackground;
  final List<BoxShadow>? shadows;
  final BorderSide? border;

  _ButtonStyle({
    required this.background,
    required this.foreground,
    required this.pressedBackground,
    required this.shadows,
    required this.border,
  });
}
