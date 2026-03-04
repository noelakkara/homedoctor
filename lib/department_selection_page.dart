
import 'package:flutter/material.dart';
import 'package:homedoctor/data.dart';
import 'package:homedoctor/doctor_search_page.dart';

class DepartmentSelectionPage extends StatelessWidget {
  const DepartmentSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract unique departments
    final Set<String> departments = doctors.map((d) => d['department']!).toSet();
    final List<String> departmentList = departments.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Department'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Which specialist do you need?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: departmentList.length,
                itemBuilder: (context, index) {
                  final dept = departmentList[index];
                  return _buildDepartmentCard(context, dept);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(BuildContext context, String department) {
    IconData icon;
    Color color;

    // Simple mapping for icons/colors based on department name
    switch (department) {
      case 'Cardiology':
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case 'Orthopedics':
        icon = Icons.accessibility_new;
        color = Colors.orange;
        break;
      case 'Pediatrics':
        icon = Icons.child_care;
        color = Colors.green;
        break;
      case 'General Medicine':
        icon = Icons.medical_services;
        color = Colors.blue;
        break;
      case 'Ayurveda':
        icon = Icons.spa;
        color = Colors.green.shade800; // Nature green
        break;
      case 'Physiotherapy':
        icon = Icons.accessibility_new; // Or accessibility
        color = Colors.purple;
        break;
      case 'Homeopathy':
        icon = Icons.bubble_chart; // Resembles pills/granules
        color = Colors.teal;
        break;
      default:
        icon = Icons.local_hospital;
        color = Colors.grey;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorSearchPage(departmentName: department),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              department,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
