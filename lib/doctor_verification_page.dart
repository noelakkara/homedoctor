import 'package:flutter/material.dart';
import 'package:homedoctor/doctor_dashboard_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DoctorVerificationPage extends StatefulWidget {
  const DoctorVerificationPage({super.key});

  @override
  State<DoctorVerificationPage> createState() => _DoctorVerificationPageState();
}

class _DoctorVerificationPageState extends State<DoctorVerificationPage> {
  int _currentStep = 0;

  // Step 1 State (Docs)
  final Map<String, File?> _uploadedDocs = {};
  final ImagePicker _picker = ImagePicker();

  // Step 2 Controllers (Bank)
  final _accNoController = TextEditingController();
  final _ifscController = TextEditingController();
  final _holderController = TextEditingController();
  final _panController = TextEditingController();

  Future<void> _pickDocument(String label) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      setState(() {
        _uploadedDocs[label] = File(image.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label uploaded successfully!')),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    } else {
      // Complete Verification simulation
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documents submitted for review!')));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DoctorDashboardPage(isVerified: false)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Verification')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: () => _currentStep > 0 ? setState(() => _currentStep--) : Navigator.pop(context),
        steps: [
          Step(
            title: const Text('Documents'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                _buildUploadField('Doctor Licence (Required)'),
                _buildUploadField('ID Proof (Aadhar/Passport)'),
                _buildUploadField('Education Qualifications'),
                _buildUploadField('Other Documents (Optional)'),
              ],
            ),
          ),
          Step(
            title: const Text('Banking'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                _buildTextField(_accNoController, 'Account Number'),
                _buildTextField(_ifscController, 'IFSC Code'),
                _buildTextField(_holderController, 'Account Holder Name'),
                _buildTextField(_panController, 'PAN Number'),
                const SizedBox(height: 20),
                _buildUploadField('Passbook or Cancelled Check Photo'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadField(String label) {
    final hasFile = _uploadedDocs.containsKey(label);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: Text(label),
        subtitle: hasFile 
          ? Text(_uploadedDocs[label]!.path.split('/').last, style: const TextStyle(color: Colors.green)) 
          : null,
        trailing: Icon(
          hasFile ? Icons.check_circle : Icons.upload_file, 
          color: hasFile ? Colors.green : Colors.blue
        ),
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () => _pickDocument(label),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
