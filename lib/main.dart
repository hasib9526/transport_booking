import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'login/login_screen.dart';
import 'model/user_model.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userData = prefs.getString('user');
  User? user;
  if (userData != null) {
    user = User.fromJson(json.decode(userData));
  }
  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User? user;

  const MyApp({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Transport Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: user != null ? TransportBookingApp() : LoginScreen(),
    );
  }
}






class Employee {
  final String id;
  final String name;
  final String department;
  final String phone;

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.phone,
  });
}

class Booking {
  final String from;
  final String to;
  final String dateTime;
  final String persons;
  final String purpose;
  final String name;
  final String department;
  final String phone;

  Booking({
    required this.from,
    required this.to,
    required this.dateTime,
    required this.persons,
    required this.purpose,
    required this.name,
    required this.department,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'dateTime': dateTime,
      'persons': persons,
      'purpose': purpose,
      'name': name,
      'department': department,
      'phone': phone,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      from: map['from'] ?? '',
      to: map['to'] ?? '',
      dateTime: map['dateTime'] ?? '',
      persons: map['persons'] ?? '',
      purpose: map['purpose'] ?? '',
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}

class TransportBookingApp extends StatelessWidget {
  const TransportBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transport Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.blue.withOpacity(0.05),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: const BookingScreen(),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _employeeIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _personsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _purposeController = TextEditingController();

  String? _fromLocation;
  String? _toLocation;
  String? _department;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _locations = ['MGL', 'TAL', 'RHL', 'BGL', 'MISAMI'];
  final List<String> _departments = [
    'ERP & IT',
    'MIS & Audit',
    'HR',
    'Civil',
    'Supply Chain',
    'Marketing & Merchandising'
  ];

  final List<Employee> _employees = [
    Employee(id: '101', name: 'S M Munsurul Hassan', department: 'ERP & IT', phone: '01700000000'),
    Employee(id: '102', name: 'Md. Mahmudul Hasan', department: 'MIS & Audit', phone: '01800000000'),
    Employee(id: '103', name: 'Mr. X', department: 'HR', phone: '01900000000'),
  ];

  @override
  void initState() {
    super.initState();
    _employeeIdController.addListener(_onEmployeeIdChanged);
  }

  @override
  void dispose() {
    _employeeIdController.removeListener(_onEmployeeIdChanged);
    _employeeIdController.dispose();
    _nameController.dispose();
    _personsController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _onEmployeeIdChanged() {
    final employee = _findEmployeeById(_employeeIdController.text);
    if (employee != null) {
      setState(() {
        _nameController.text = employee.name;
        _department = employee.department;
        _phoneController.text = employee.phone;
      });
    } else {
      setState(() {
        _nameController.clear();
        _department = null;
        _phoneController.clear();
      });
    }
  }

  Employee? _findEmployeeById(String id) {
    try {
      return _employees.firstWhere((employee) => employee.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveBooking(Booking booking) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookings = prefs.getStringList('bookings') ?? [];
    bookings.add(jsonEncode(booking.toMap()));
    await prefs.setStringList('bookings', bookings);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null &&
        _department != null) {
      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final booking = Booking(
        name: _nameController.text,
        department: _department!,
        persons: _personsController.text,
        phone: _phoneController.text,
        purpose: _purposeController.text,
        from: _fromLocation!,
        to: _toLocation!,
        dateTime: DateFormat('dd/MM/yyyy hh:mm a').format(selectedDateTime),
      );

      final String subject =
          'Transport Request: ${booking.from} to ${booking.to} on ${booking.dateTime}';
      final String body = '''
Dear Transport Authority,

Please arrange transport with the following details:

From: ${booking.from}
To: ${booking.to}
Date & Time: ${booking.dateTime}
Number of Persons: ${booking.persons}
Purpose of Travel: ${booking.purpose}

Requester Details:
Name: ${booking.name}
Department: ${booking.department}
Phone: ${booking.phone}

Best regards,
${booking.name}
''';

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'mh.islam@bitopibd.com',
        query:
        'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
      );

      try {
        await launchUrl(emailLaunchUri);
        await _saveBooking(booking);
        _showSuccessDialog();
        _formKey.currentState?.reset();
        _employeeIdController.clear();
        _nameController.clear();
        _personsController.clear();
        _phoneController.clear();
        _purposeController.clear();
        setState(() {
          _fromLocation = null;
          _toLocation = null;
          _department = null;
          _selectedDate = null;
          _selectedTime = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open email client: $e')),
        );
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
    } else if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time')),
      );
    } else if (_department == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Transport request sent successfully!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Booking Request'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user');
              Get.offAll(() => LoginScreen());
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildTextFormField(
                  controller: _employeeIdController,
                  label: 'Employee ID',
                  icon: Icons.badge,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                    label: 'From',
                    value: _fromLocation,
                    items: _locations,
                    onChanged: (value) {
                      setState(() {
                        _fromLocation = value;
                      });
                    },
                    validator: (value) =>
                    value == null ? 'Please select a location' : null,
                    icon: Icons.location_on),
                const SizedBox(height: 16),
                _buildDropdown(
                    label: 'To',
                    value: _toLocation,
                    items: _locations,
                    onChanged: (value) {
                      setState(() {
                        _toLocation = value;
                      });
                    },
                    validator: (value) =>
                    value == null ? 'Please select a destination' : null,
                    icon: Icons.location_on),
                const SizedBox(height: 16),
                _buildDateTimePicker(context),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _personsController,
                  label: 'Number of Persons',
                  icon: Icons.people,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _purposeController,
                  label: 'Purpose of Travel',
                  icon: Icons.article,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _nameController,
                  label: 'Your Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                    label: 'Department',
                    value: _department,
                    items: _departments,
                    onChanged: (value) {
                      setState(() {
                        _department = value;
                      });
                    },
                    validator: (value) =>
                    value == null ? 'Please select a department' : null,
                    icon: Icons.business),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Submit Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String> validator,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date of Travel',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _selectedDate == null
                    ? 'Select a date'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedDate == null
                      ? Theme.of(context).hintColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _selectTime(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Time',
                prefixIcon: Icon(Icons.access_time),
              ),
              child: Text(
                _selectedTime == null
                    ? 'Select a time'
                    : _selectedTime!.format(context),
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedTime == null
                      ? Theme.of(context).hintColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookingsData = prefs.getStringList('bookings') ?? [];
    setState(() {
      _bookings = bookingsData
          .map((data) => Booking.fromMap(jsonDecode(data)))
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookings');
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear History',
            onPressed: _bookings.isEmpty
                ? null
                : () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm'),
                    content: const Text(
                        'Are you sure you want to clear all booking history?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Clear'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _clearHistory();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _bookings.isEmpty
          ? const Center(
        child: Text(
          'No booking history found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                '${booking.from} to ${booking.to}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Date & Time: ${booking.dateTime}'),
                  Text('Persons: ${booking.persons}'),
                  Text('Purpose: ${booking.purpose}'),
                  const Divider(height: 20),
                  Text(
                      'Booked by: ${booking.name} (${booking.department})'),
                  Text('Contact: ${booking.phone}'),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}