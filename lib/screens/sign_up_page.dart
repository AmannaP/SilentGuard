import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/ui_utils.dart';
import '../utils/validators.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Controllers to capture input data
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _emergencyNameController = TextEditingController();

  // Variables for dropdowns
  String? _selectedRegion;
  String? _selectedMaritalStatus;
  String? _selectedGender;

  final List<String> _ghanaRegions = [
    "Ahafo", "Ashanti", "Bono", "Bono East", "Central", "Eastern",
    "Greater Accra", "Northern", "North East", "Oti", "Savannah",
    "Upper East", "Upper West", "Volta", "Western", "Western North",
  ];

  final Color _themeOrange = const Color(0xFFD4833B);

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _occupationController.dispose();
    _emergencyContactController.dispose();
    _emergencyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeOrange,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 5),
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.black,
              child: Icon(Icons.shield, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 5),
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
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildPageOne(), _buildPageTwo()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageOne() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 100),
      child: Column(
        children: [
          _buildTextField("First Name", _firstNameController, validator: (v) => Validators.name(v, 'First Name')),
          _buildTextField("Last Name", _lastNameController, validator: (v) => Validators.name(v, 'Last Name')),
          _buildTextField("Email", _emailController, validator: Validators.email),
          _buildTextField("Contact Number", _phoneController, validator: Validators.phone),
          _buildTextField(
            "Password", 
            _passwordController, 
            isPassword: true, 
            isObscured: !_isPasswordVisible, 
            validator: (v) => Validators.required(v, 'Password'),
            onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible)
          ),
          _buildTextField(
            "Confirm Password", 
            _confirmPasswordController, 
            isPassword: true, 
            isObscured: !_isConfirmPasswordVisible, 
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passwordController.text) return 'Passwords do not match';
              return null;
            },
            onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Pre-validation before paging maybe? Or just paging
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
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

  Widget _buildPageTwo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Occupation", _occupationController, validator: (v) => Validators.required(v, 'Occupation')),
          _buildRegionDropdown(),
          _buildTextField("Emergency Contact", _emergencyContactController, validator: Validators.phone),
          _buildTextField("Emergency Contact Name", _emergencyNameController, validator: (v) => Validators.name(v, 'Emergency Contact Name')),

          const SizedBox(height: 15),
          const Text(
            "Marital Status",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              _buildRadioButton("Single", _selectedMaritalStatus, (v) => setState(() => _selectedMaritalStatus = v)),
              _buildRadioButton("Married", _selectedMaritalStatus, (v) => setState(() => _selectedMaritalStatus = v)),
            ],
          ),

          const SizedBox(height: 15),
          const Text(
            "Biological Gender",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              _buildRadioButton("Man", _selectedGender, (v) => setState(() => _selectedGender = v)),
              _buildRadioButton("Woman", _selectedGender, (v) => setState(() => _selectedGender = v)),
            ],
          ),

          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: const Text("< Back", style: TextStyle(color: Colors.white70, fontSize: 18)),
              ),
              _isLoading ? const CircularProgressIndicator(color: Colors.white) : TextButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  if (_selectedRegion == null || _selectedGender == null || _selectedMaritalStatus == null) {
                    UIUtils.showCustomPopup(
                      context,
                      title: 'Missing Selection',
                      message: 'Please make sure all dropdowns and options are selected.',
                      isSuccess: false,
                    );
                    return;
                  }
                  if (_passwordController.text != _confirmPasswordController.text) {
                    UIUtils.showCustomPopup(
                      context,
                      title: 'Password Mismatch',
                      message: 'The passwords you entered do not match.',
                      isSuccess: false,
                    );
                    return;
                  }
                  
                  setState(() => _isLoading = true);
                  try {
                    await AuthService().signUp(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      fullName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
                      phoneNumber: _phoneController.text.trim(),
                      emergencyName: _emergencyNameController.text.trim(),
                      emergencyPhone: _emergencyContactController.text.trim(),
                    );
                    if (mounted) {
                      UIUtils.showCustomPopup(
                        context,
                        title: 'Sign Up Successful',
                        message: 'Your account was created successfully! Please log in.',
                        isSuccess: true,
                        onOkay: () {
                          if (mounted) Navigator.pushNamed(context, '/login_page');
                        }
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      UIUtils.showCustomPopup(
                        context,
                        title: 'Sign Up Failed',
                        message: e.toString(),
                        isSuccess: false,
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                child: const Text("Finish >", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController? controller, {bool isPassword = false, bool? isObscured, VoidCallback? onToggleVisibility, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isObscured ?? isPassword,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: isPassword && onToggleVisibility != null
                ? IconButton(
                    icon: Icon(
                      (isObscured ?? false) ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildRegionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Region", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: _selectedRegion,
          items: _ghanaRegions.map((String region) => DropdownMenuItem(value: region, child: Text(region))).toList(),
          onChanged: (newValue) => setState(() => _selectedRegion = newValue),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          dropdownColor: Colors.white,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildRadioButton(String value, String? groupValue, Function(String?) onChanged) {
    return Row(
      children: [
        Radio<String>(value: value, groupValue: groupValue, activeColor: Colors.white, onChanged: onChanged),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
