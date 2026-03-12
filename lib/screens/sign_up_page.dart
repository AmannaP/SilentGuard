import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // Controllers to capture input data
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();
  final TextEditingController _emergencyNameController =
      TextEditingController();

  // Variables for dropdowns (Renel Ghana demographic data)
  String? _selectedRegion;
  String? _selectedMaritalStatus;
  String? _selectedGender;

  final List<String> _ghanaRegions = [
    "Ahafo",
    "Ashanti",
    "Bono",
    "Bono East",
    "Central",
    "Eastern",
    "Greater Accra",
    "Northern",
    "North East",
    "Oti",
    "Savannah",
    "Upper East",
    "Upper West",
    "Volta",
    "Western",
    "Western North",
  ];

  final Color _themeOrange = const Color(
    0xFFD4833B,
  ); // Matching your Figma background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo Placeholder (Replace with your Image.asset)
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black,
              child: Icon(Icons.shield, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 10),
            const Text(
              "Welcome to SilentGuard",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Please Provide your details below.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) =>
                    setState(() => _currentPage = page),
                children: [_buildPageOne(), _buildPageTwo()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PAGE 1: Personal Info & Password ---
  Widget _buildPageOne() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          _buildTextField("First Name", _firstNameController),
          _buildTextField("Last Name", _lastNameController),
          _buildTextField("Email", _emailController),
          _buildTextField("Contact Number", _phoneController),
          _buildTextField("Password", _passwordController, isPassword: true),
          _buildTextField(
            "Confirm Password",
            _confirmPasswordController,
            isPassword: true,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text(
                "Next >",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- PAGE 2: Demographics & Emergency ---
  Widget _buildPageTwo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Occupation", _occupationController),
          _buildRegionDropdown(),
          _buildTextField("Emergency Contact", _emergencyContactController),
          _buildTextField("Emergency Contact Name", _emergencyNameController),

          const SizedBox(height: 15),
          const Text(
            "Marital Status",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              _buildRadioButton(
                "Single",
                _selectedMaritalStatus,
                (v) => setState(() => _selectedMaritalStatus = v),
              ),
              _buildRadioButton(
                "Married",
                _selectedMaritalStatus,
                (v) => setState(() => _selectedMaritalStatus = v),
              ),
            ],
          ),

          const SizedBox(height: 15),
          const Text(
            "Biological Gender",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              _buildRadioButton(
                "Man",
                _selectedGender,
                (v) => setState(() => _selectedGender = v),
              ),
              _buildRadioButton(
                "Woman",
                _selectedGender,
                (v) => setState(() => _selectedGender = v),
              ),
            ],
          ),

          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle Finish Logic
                Navigator.pushNamed(context, '/login_page');
              },
              child: const Text(
                "Finish >",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Component for White Fields
  Widget _buildTextField(
    String label,
    TextEditingController? controller, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // 2. SPECIFIC REGION DROPDOWN
  Widget _buildRegionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Region",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _selectedRegion,
          items: _ghanaRegions.map((String region) {
            return DropdownMenuItem(value: region, child: Text(region));
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedRegion = newValue),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          dropdownColor: Colors.white,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Custom Radio Button for that Figma look
  Widget _buildRadioButton(
    String value,
    String? groupValue,
    Function(String?) onChanged,
  ) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          activeColor: Colors.white,
          onChanged: onChanged,
        ),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
