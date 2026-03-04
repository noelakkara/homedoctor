import 'package:flutter/material.dart';
import 'package:homedoctor/constants.dart';
import 'package:homedoctor/login_page.dart';
import 'package:homedoctor/dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Optional
  final _phoneController = TextEditingController(); // Required
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_otpSent) {
      // Step 1: fill info and send OTP logic
      // In a real app, you'd call an API here to send OTP to _phoneController.text
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.otpSentSuccess)),
      );
    } else {
      // Step 2: Verify OTP
      if (_otpController.text == '123456') {
        // Success: Redirect to Login Page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.signupSuccessRedirect)),
        );
        // Wait a small delay to show the snackbar before popping
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context); // Go back to Login Page
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Use 123456 for testing.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_otpSent) ...[
                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: AppStrings.nameLabel,
                  hint: AppStrings.nameHint,
                  icon: Icons.person_outline,
                  validator: (value) => 
                    (value == null || value.isEmpty) ? AppStrings.nameEmptyError : null,
                ),
                const SizedBox(height: 20),

                // Email Field (Optional)
                _buildTextField(
                  controller: _emailController,
                  label: AppStrings.emailLabel,
                  hint: AppStrings.emailHint + ' (Optional)',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                      return AppStrings.emailInvalidError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Field (Required)
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '10-digit mobile number',
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  prefixText: '+91 ',
                  validator: (value) {
                    if (value == null || value.isEmpty) return AppStrings.phoneEmptyError;
                    if (value.length != 10) return AppStrings.phoneInvalidError;
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: AppStrings.passwordLabel,
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) => 
                    (value == null || value.length < 6) ? AppStrings.passwordLengthError : null,
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPasswordLabel,
                  icon: Icons.lock_reset_outlined,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) return AppStrings.passwordMismatchError;
                    return null;
                  },
                ),
              ] else ...[
                // OTP Step
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.blue),
                      const SizedBox(height: 24),
                      Text(
                        'Verify Mobile Number',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter 6-digit OTP sent to +91 ${_phoneController.text}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _otpController,
                  label: AppStrings.otpLabel,
                  hint: AppStrings.otpHint,
                  icon: Icons.lock_clock_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) => 
                    (value == null || value.isEmpty) ? AppStrings.otpEmptyError : null,
                ),
              ],
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  !_otpSent ? 'Sign Up' : 'Verify & Register',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (!_otpSent)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.alreadyHaveAccount),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}
