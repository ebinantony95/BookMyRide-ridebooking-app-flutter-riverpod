import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:make_my_ride/features/auth/presentation/view/widgets/otp%20verification/otp_bottom_hint_card.dart';
import 'package:make_my_ride/features/auth/presentation/view/widgets/otp%20verification/otp_head_title.dart';
import 'package:make_my_ride/features/auth/presentation/view/widgets/otp%20verification/otp_pin_filed.dart';
import 'package:make_my_ride/features/auth/presentation/view/widgets/otp%20verification/otp_resend_widget.dart';
import 'package:make_my_ride/features/auth/presentation/view/widgets/otp%20verification/otpscreen_topicon.dart';

import 'package:make_my_ride/core/theme/app_colors.dart';
import 'package:make_my_ride/core/constants/app_spacing.dart';
import 'package:make_my_ride/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_my_ride/shared/widgets/app_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _otpCode = '';

  // ─── Resend timer
  late Timer _timer;
  int _resendSeconds = 60;
  bool _canResend = false;

  // ─── Entry animations
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  Future<void> _onVerify() async {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        _errorSnackBar('Please enter the complete 6-digit OTP.'),
      );
      return;
    }

    final success =
        await ref.read(authViewModelProvider.notifier).verifyOtp(_otpCode);

    if (!mounted) return; // ✅ IMPORTANT

    if (!success) {
      // handled by listener
    }
  }

  Future<void> _onResend() async {
    if (!_canResend) return;
    _timer.cancel();
    _otpController.clear();
    setState(() => _otpCode = '');
    await ref
        .read(authViewModelProvider.notifier)
        .resendOtp(widget.phoneNumber);
    if (!mounted) return;
    _startResendTimer();
  }

  SnackBar _errorSnackBar(String msg) => SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    // Listen for errors & success
    ref.listen(authViewModelProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_errorSnackBar(next.errorMessage!));
        ref.read(authViewModelProvider.notifier).clearError();
      }
    });

    final isLoading = ref.watch(authViewModelProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ─── Icon badge (top icon)
                    OtpscreenTopicon(),

                    const SizedBox(height: 28),

                    // ─── Title
                    OtpHeadTitle(),

                    const SizedBox(height: 44),

                    // ─── OTP Pin Field
                    const SizedBox(height: 32),

                    OtpPinField(
                      otpCode: _otpCode,
                      onChanged: (value) => setState(() => _otpCode = value),
                      onCompleted: _onVerify,
                      formKey: _formKey,
                    ),

                    // ─── Verify button
                    AppButton.primary(
                      label: 'Verify OTP',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _onVerify,
                      suffixIcon: const Icon(Icons.verified_outlined),
                    ),

                    const SizedBox(height: 28),

                    OtpResendWidget(
                      canResend: _canResend,
                      resendSeconds: _resendSeconds,
                      onResend: _onResend,
                    ),

                    const SizedBox(height: 30),

                    // ─── Bottom hint card
                    OtpBottomHintCard()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
