import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers to capture input data
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Variables for dropdowns (Renel Ghana demographic data)
  String? _selectedRegion;
  String? _selectedMaritalStatus;
  String _selectedGender = "Woman";

  final List<String> _regions = [
    "Greater Accra",
    "Ashanti",
    "Northern",
    "Western",
    "Volta",
    "Eastern",
  ];
  final List<String> _maritalStatuses = [
    "Single",
    "Married",
    "Divorced",
    "Widowed",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Safety Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to SilentGuard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D40),
              ),
            ),
            const Text(
              "Please provide your details below to support Renel Ghana services.",
            ),
            const SizedBox(height: 30),

            // Name Fields
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Region Dropdown (Local Context)
            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: "Region",
                border: OutlineInputBorder(),
              ),
              items: _regions
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedRegion = val as String?),
            ),
            const SizedBox(height: 15),

            // Gender Selection (From your Figma)
            const Text(
              "Biological Gender",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio(
                  value: "Man",
                  groupValue: _selectedGender,
                  onChanged: (v) => setState(() => _selectedGender = v!),
                ),
                const Text("Man"),
                Radio(
                  value: "Woman",
                  groupValue: _selectedGender,
                  onChanged: (v) => setState(() => _selectedGender = v!),
                ),
                const Text("Woman"),
              ],
            ),
            const SizedBox(height: 15),

            // Marital Status
            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: "Marital Status",
                border: OutlineInputBorder(),
              ),
              items: _maritalStatuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _selectedMaritalStatus = val as String?),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Logic to save data would go here
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Next >", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
