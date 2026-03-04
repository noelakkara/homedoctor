import 'package:flutter/material.dart';
import 'package:homedoctor/booking_page.dart';
import 'package:homedoctor/data.dart'; // Import shared data

class DoctorSearchPage extends StatefulWidget {
  final String? departmentName; // Optional department filter

  const DoctorSearchPage({super.key, this.departmentName});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  // Hardcoded list removed, using 'doctors' from data.dart

  List<Map<String, String>> filteredDoctors = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial filter based on department if provided
    if (widget.departmentName != null) {
      filteredDoctors = doctors.where((doc) => doc['department'] == widget.departmentName).toList();
    } else {
      filteredDoctors = doctors;
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      filteredDoctors = doctors.where((doc) {
        final name = doc['name']!.toLowerCase();
        final dept = doc['department']!.toLowerCase();
        final hospital = doc['hospital']!.toLowerCase();
        final input = query.toLowerCase();
        
        // If a department is selected, only search within that department
        if (widget.departmentName != null && doc['department'] != widget.departmentName) {
           return false;
        }

        return name.contains(input) ||
            dept.contains(input) ||
            hospital.contains(input);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.departmentName != null ? '${widget.departmentName} Doctors' : 'Find a Doctor'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterDoctors,
              decoration: InputDecoration(
                hintText: 'Search doctor, department, or hospital',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDoctors.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final doc = filteredDoctors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person,
                              size: 40, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['name']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${doc['department']} • ${doc['education']}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.local_hospital,
                                      size: 16, color: Colors.blue.shade300),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      doc['hospital']!,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigate to Booking Page with doc details
                                    _navigateToBooking(context, doc);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Book Visit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  void _navigateToBooking(BuildContext context, Map<String, String> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(doctor: doctor),
      ),
    );
  }
}
