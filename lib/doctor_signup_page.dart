import 'package:flutter/material.dart';
import 'package:homedoctor/constants.dart';
import 'package:homedoctor/doctor_verification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorSignUpPage extends StatefulWidget {
  const DoctorSignUpPage({super.key});

  @override
  State<DoctorSignUpPage> createState() => _DoctorSignUpPageState();
}

class _DoctorSignUpPageState extends State<DoctorSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _obscurePassword = true;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_otpSent) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent to mobile!')),
      );
    } else {
      if (_otpController.text == '123456') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool('isDoctor', true);
        await prefs.setBool('doctorVerified', false); // Needs verification

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DoctorVerificationPage(),
            ),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Doctor Registration',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_otpSent) ...[
                _buildField(
                  _nameController,
                  AppStrings.nameLabel,
                  Icons.person_outline,
                ),
                const SizedBox(height: 20),
                _buildField(
                  _emailController,
                  'Email Address (Required)',
                  Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                  required: true,
                ),
                const SizedBox(height: 20),
                _buildField(
                  _phoneController,
                  'Mobile Number (Required)',
                  Icons.phone_android_outlined,
                  keyboard: TextInputType.phone,
                  prefix: '+91 ',
                  required: true,
                ),
                const SizedBox(height: 20),
                _buildField(
                  _passwordController,
                  'Password',
                  Icons.lock_outline,
                  obscure: _obscurePassword,
                  required: true,
                ),
                const SizedBox(height: 20),
                _buildField(
                  _confirmPasswordController,
                  'Confirm Password',
                  Icons.lock_reset,
                  required: true,
                ),
              ] else ...[
                const Text(
                  'Verify your mobile number to complete registration',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildField(
                  _otpController,
                  'Enter 6-digit OTP',
                  Icons.security,
                  keyboard: TextInputType.number,
                  required: true,
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _otpSent ? 'Verify' : 'Sign Up',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    String? prefix,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty))
          return 'This field is required';
        if (label.contains('Confirm') && value != _passwordController.text)
          return 'Passwords do not match';
        return null;
      },
    );
  }
}
