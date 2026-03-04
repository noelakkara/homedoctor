import 'package:flutter/material.dart';
import 'package:homedoctor/constants.dart';
import 'package:homedoctor/doctor_signup_page.dart';
import 'package:homedoctor/doctor_dashboard_page.dart';
import 'package:homedoctor/doctor_verification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorLoginPage extends StatefulWidget {
  const DoctorLoginPage({super.key});

  @override
  State<DoctorLoginPage> createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isOtpMode = false;
  bool _otpSent = false;
  bool _obscurePassword = true;

  void _toggleAuthMode() {
    setState(() {
      _isOtpMode = !_isOtpMode;
      _otpSent = false;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isDoctor', true);
    
    // Check if verified (simulation)
    bool isVerified = prefs.getBool('doctorVerified') ?? false;

    if (mounted) {
      if (isVerified) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DoctorDashboardPage()),
          (route) => false,
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DoctorVerificationPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Doctor Portal', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.medical_services, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                'Welcome, Doctor',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _identifierController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Email or Phone Number',
                  prefixIcon: const Icon(Icons.person_outline),
                  prefixText: _identifierController.text.isNotEmpty && 
                            RegExp(r'^[0-9]').hasMatch(_identifierController.text)
                      ? '+91 ' : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              if (!_isOtpMode)
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              
              const SizedBox(height: 12),
              TextButton(
                onPressed: _toggleAuthMode,
                child: Text(_isOtpMode ? 'Use Password' : 'Login with OTP'),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New here? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DoctorSignUpPage()),
                      );
                    },
                    child: const Text('Register as Doctor', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
