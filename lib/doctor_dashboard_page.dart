import 'package:flutter/material.dart';
import 'package:homedoctor/constants.dart';
import 'package:homedoctor/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboardPage extends StatefulWidget {
  final bool isVerified;
  const DoctorDashboardPage({super.key, this.isVerified = true});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _AppointmentsTab(isVerified: widget.isVerified),
      const _SlotsTab(),
      const _WalletTab(),
      const _ProfileTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: AppStrings.appointments),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: AppStrings.slots),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: AppStrings.wallet),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: AppStrings.profile),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0: return AppStrings.appointments;
      case 1: return AppStrings.slots;
      case 2: return AppStrings.wallet;
      case 3: return AppStrings.profile;
      default: return 'Dashboard';
    }
  }
}

class _AppointmentsTab extends StatelessWidget {
  final bool isVerified;
  const _AppointmentsTab({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    if (!isVerified) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pending_actions, size: 100, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Verification Pending',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Our team is reviewing your documents. You will start seeing appointments once verified.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    // Mock Appointments
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('John Doe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Confirmed', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('123 Health Ave, Medical City', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('+91 9876543210', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Today, 10:30 AM', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SlotsTab extends StatefulWidget {
  const _SlotsTab();

  @override
  State<_SlotsTab> createState() => _SlotsTabState();
}

class _SlotsTabState extends State<_SlotsTab> {
  final List<Map<String, String>> _slots = [
    {'day': 'Monday', 'time': '09:00 AM - 12:00 PM'},
    {'day': 'Monday', 'time': '02:00 PM - 05:00 PM'},
    {'day': 'Wednesday', 'time': '10:00 AM - 01:00 PM'},
  ];

  void _showSlotDialog({int? index}) {
    String selectedDay = index != null ? _slots[index]['day']! : 'Monday';
    final timeController = TextEditingController(
      text: index != null ? _slots[index]['time']! : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Create New Slot' : 'Edit Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                  .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                  .toList(),
              onChanged: (value) => selectedDay = value!,
              decoration: const InputDecoration(labelText: 'Day'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Time (e.g., 09:00 AM - 12:00 PM)',
                hintText: 'HH:MM AM - HH:MM PM',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (index == null) {
                  _slots.add({'day': selectedDay, 'time': timeController.text});
                } else {
                  _slots[index] = {'day': selectedDay, 'time': timeController.text};
                }
              });
              Navigator.pop(context);
            },
            child: Text(index == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showSlotDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create New Slot'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _slots.length,
            itemBuilder: (context, index) => _buildSlotItem(index),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotItem(int index) {
    final slot = _slots[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(slot['day']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(slot['time']!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showSlotDialog(index: index),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() => _slots.removeAt(index));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletTab extends StatelessWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: Colors.blue.shade50,
          child: Column(
            children: [
              const Text('Total Professional Earnings', style: TextStyle(color: Colors.blueGrey)),
              const SizedBox(height: 8),
              Text('₹ 12,450', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(alignment: Alignment.centerLeft, child: Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: const Text('Consultation Fee: Jane Smith'),
                subtitle: const Text('Feb 19, 2026 • 03:45 PM'),
                trailing: const Text('+ ₹ 500', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _isEditing = false;
  
  final _nameController = TextEditingController(text: 'Dr. Arjun Varma');
  final _specController = TextEditingController(text: 'Neurologist');
  final _emailController = TextEditingController(text: 'drarjun@homedoctor.in');
  final _phoneController = TextEditingController(text: '+91 9988776655');

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('doctor_name') ?? 'Dr. Arjun Varma';
      _specController.text = prefs.getString('doctor_specialization') ?? 'Neurologist';
      _emailController.text = prefs.getString('doctor_email') ?? 'drarjun@homedoctor.in';
      _phoneController.text = prefs.getString('doctor_phone') ?? '+91 9988776655';
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_name', _nameController.text);
    await prefs.setString('doctor_specialization', _specController.text);
    await prefs.setString('doctor_email', _emailController.text);
    await prefs.setString('doctor_phone', _phoneController.text);
    
    setState(() => _isEditing = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: Stack(
            children: [
              CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
              Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 18, child: Icon(Icons.camera_alt, size: 18))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildEditableItem('Name', _nameController),
        _buildEditableItem('Specialization', _specController),
        _buildEditableItem('Email', _emailController),
        _buildEditableItem('Phone', _phoneController),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isEditing ? _saveProfileData : () => setState(() => _isEditing = true),
          child: Text(_isEditing ? 'Save Changes' : 'Edit Professional Details'),
        ),
        const SizedBox(height: 12),
        if (!_isEditing)
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
      ],
    );
  }

  Widget _buildEditableItem(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          if (_isEditing)
            TextField(
              controller: controller,
              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
            )
          else
            Text(controller.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}
