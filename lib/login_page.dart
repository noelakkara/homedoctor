import 'package:flutter/material.dart';
import 'package:homedocter/constants.dart';
import 'package:homedocter/dashboard_page.dart';
import 'package:homedocter/signup_page.dart';
import 'package:homedocter/forgot_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isOtpMode = false; // Toggle between Password and OTP login
  bool _otpSent = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isOtpMode = !_isOtpMode;
      _otpSent = false;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final identifier = _identifierController.text.trim();
    
    if (!_isOtpMode) {
      // Password Login Logic
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userIdentifier', identifier);
      await prefs.setString('loginMode', 'password');
      _navigateToDashboard(identifier);
    } else {
      if (!_otpSent) {
        // Send OTP Simulation
        setState(() {
          _otpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.otpSentSuccess)),
        );
      } else {
        // Verify OTP Simulation (Accept 123456)
        if (_otpController.text == '123456') {
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userIdentifier', identifier);
          await prefs.setString('loginMode', 'otp');
          _navigateToDashboard(identifier);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid OTP. Use 123456 for testing.')),
          );
        }
      }
    }
  }

  void _navigateToDashboard(String identifier) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.loginSuccess)),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardPage(email: identifier),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo Section
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_hospital_rounded,
                      size: 60,
                      color: Colors.blue.shade700,
                    );
                  },
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isOtpMode ? 'Login with OTP' : AppStrings.welcomeBack,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isOtpMode 
                        ? 'We will send a verification code to your phone or email' 
                        : AppStrings.signInContinue,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Unified Identifier Field
                    TextFormField(
                      controller: _identifierController,
                      enabled: !_otpSent,
                      onChanged: (value) {
                        setState(() {}); // Trigger rebuild to show/hide prefix
                      },
                      decoration: InputDecoration(
                        labelText: AppStrings.identifierLabel,
                        hintText: AppStrings.identifierHint,
                        prefixIcon: const Icon(Icons.person_outline),
                        prefixText: _identifierController.text.isNotEmpty && 
                                  RegExp(r'^[0-9]').hasMatch(_identifierController.text)
                            ? '+91 '
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return AppStrings.identifierEmptyError;
                        // If it starts with a digit, it must be exactly 10 digits
                        if (RegExp(r'^[0-9]').hasMatch(value)) {
                          if (value.length != 10) return AppStrings.phoneInvalidError;
                        } else {
                          // If it's email, check for @
                          if (!value.contains('@')) return AppStrings.emailInvalidError;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),

                    if (!_isOtpMode) ...[
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: AppStrings.passwordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppStrings.passwordEmptyError;
                          if (value.length < 6) return AppStrings.passwordLengthError;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                            );
                          },
                          child: const Text(AppStrings.forgotPassword),
                        ),
                      ),
                    ] else if (_otpSent) ...[
                      // OTP Field (Only if OTP is sent)
                      TextFormField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: AppStrings.otpLabel,
                          hintText: AppStrings.otpHint,
                          prefixIcon: const Icon(Icons.lock_clock_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return AppStrings.otpEmptyError;
                          if (value.length != 6) return AppStrings.otpInvalidError;
                          return null;
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Main Action Button
                    ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        !_isOtpMode 
                          ? AppStrings.loginButton 
                          : (_otpSent ? AppStrings.verifyOTP : AppStrings.sendOTP),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Switch Auth Mode Button (Password <-> OTP)
                    TextButton(
                      onPressed: _toggleAuthMode,
                      child: Text(
                        _isOtpMode ? AppStrings.usePasswordInstead : AppStrings.useOTPInstead,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.noAccount,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpPage()),
                            );
                          },
                          child: const Text(
                            AppStrings.signUp,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
