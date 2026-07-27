import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_mail_app/open_mail_app.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/clearable_text_field.dart';
import '../services/migration_service.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _friendlyAuthError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before signing in. Check your inbox.';
    }
    if (msg.contains('user not found') || msg.contains('no user found')) {
      return 'No account found with that email. Try creating an account.';
    }
    if (msg.contains('email rate limit') || msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('weak password') || msg.contains('password should be')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (msg.contains('already registered') || msg.contains('user already exists')) {
      return 'An account with this email already exists. Try signing in instead.';
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
      return 'Connection error. Please check your internet and try again.';
    }
    return 'Authentication error. Please check your details and try again.';
  }

  Future<void> _openEmailApp() async {
    final result = await OpenMailApp.openMailApp();
    
    if (!result.didOpen && !result.canOpen) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: 'No mail apps installed',
          isError: true,
        );
      }
    } else if (!result.didOpen && result.canOpen) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => MailAppPickerDialog(
            mailApps: result.options,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showCustomSnackBar(
        context,
        message: 'Please fill in all fields',
        isError: true,
      );
      return;
    }

    if (_isSignUp && password != _confirmPasswordController.text.trim()) {
      showCustomSnackBar(
        context,
        message: 'Passwords do not match',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      if (_isSignUp) {
        final response = await authService.signUp(email, password);
        final needsConfirmation = response.session == null || response.user?.newEmail != null;
        if (needsConfirmation) {
          if (mounted) {
            showCustomSnackBar(
              context,
              message: 'Verification email sent! Please check your inbox.',
              isSuccess: true,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Open Email',
                textColor: AppTheme.accentPrimary,
                onPressed: _openEmailApp,
              ),
            );
            setState(() => _isSignUp = false);
            return;
          }
        }
      } else {
        await authService.signInWithEmailPassword(email, password);
        
        // Ask to perform migration of local data to Supabase on Sign In if local data exists
        if (mounted) {
          final history = HiveService.getSwipeHistoryList();
          final profile = HiveService.getProfile();
          final hasLocalData = history.isNotEmpty ||
              profile.tasteSeedMovieIds.isNotEmpty ||
              profile.tasteSeedTvIds.isNotEmpty;

          if (hasLocalData) {
            final shouldSync = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.bgSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Merge Guest Watchlist?', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Syne', fontWeight: FontWeight.bold)),
                content: const Text(
                  'We found local swipes and watchlists on this device. Would you like to sync them into your account?',
                  style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Inter'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Skip', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Merge & Sync', style: TextStyle(color: AppTheme.accentPrimary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );

            if (shouldSync == true) {
              await ref.read(migrationServiceProvider).migrateGuestDataToSupabase();
            }
          }
        }
      }

      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: _friendlyAuthError(e),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showCustomSnackBar(
        context,
        message: 'Please enter your email address above first',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).resetPasswordForEmail(email);
      if (mounted) {
        showCustomSnackBar(
          context,
          message: 'Password reset email sent to $email!',
          isSuccess: true,
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Open Email',
            textColor: AppTheme.accentPrimary,
            onPressed: _openEmailApp,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: _friendlyAuthError(e),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/swipe');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSignUp ? 'Create Account' : 'Welcome Back',
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  suffixIcon: ClearSuffixIcon(controller: _emailController),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppTheme.bgMuted),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppTheme.accentPrimary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppTheme.bgMuted),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppTheme.accentPrimary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
                onSubmitted: _isSignUp ? null : (_) => _submit(),
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppTheme.bgMuted),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppTheme.accentPrimary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ],
              if (!_isSignUp) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.accentPrimary)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textInverse),
                        ),
                      )
                    : Text(
                        _isSignUp ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textInverse,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : 'Don\'t have an account? Sign Up',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
