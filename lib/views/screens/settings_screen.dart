import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/company_controller.dart';
import '../../models/company_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CompanyController companyController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController taxInfoController;
  String? logoPath;
  String selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    final company = companyController.company.value;
    nameController = TextEditingController(text: company?.name ?? '');
    emailController = TextEditingController(text: company?.email ?? '');
    phoneController = TextEditingController(text: company?.phone ?? '');
    addressController = TextEditingController(text: company?.address ?? '');
    taxInfoController = TextEditingController(text: company?.taxInfo ?? '');
    logoPath = company?.logoPath;
    selectedCurrency = company?.currency ?? 'USD';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    taxInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickLogo,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: logoPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.file(
                                  File(logoPath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.business, size: 60, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _pickLogo,
                      icon: Icon(Icons.camera_alt),
                      label: Text('Change Logo'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Company Details
              Text(
                'Company Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Company Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: taxInfoController,
                decoration: InputDecoration(
                  labelText: 'Tax ID / VAT Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                items: [
                  'USD',
                  'EUR',
                  'GBP',
                  'INR',
                  'AUD',
                  'CAD',
                  'JPY',
                  'CNY'
                ].map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCurrency = value!;
                  });
                },
              ),
              SizedBox(height: 24),

              // Theme Settings
              Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Obx(() {
                final company = companyController.company.value;
                return Card(
                  child: SwitchListTile(
                    title: Text('Dark Mode'),
                    subtitle: Text('Toggle dark theme'),
                    value: company?.isDarkMode ?? false,
                    onChanged: (value) {
                      companyController.updateTheme(value);
                    },
                    secondary: Icon(
                      company?.isDarkMode ?? false
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  ),
                );
              }),
              SizedBox(height: 24),

              // About Section
              Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text('Version'),
                      trailing: Text('1.0.0'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.description),
                      title: Text('App Name'),
                      trailing: Text('My Invoice'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  child: Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        setState(() {
          logoPath = image.path;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final company = Company(
      name: nameController.text,
      email: emailController.text.isEmpty ? null : emailController.text,
      phone: phoneController.text.isEmpty ? null : phoneController.text,
      address: addressController.text.isEmpty ? null : addressController.text,
      taxInfo: taxInfoController.text.isEmpty ? null : taxInfoController.text,
      logoPath: logoPath,
      currency: selectedCurrency,
      isDarkMode: companyController.company.value?.isDarkMode ?? false,
    );

    await companyController.saveCompany(company);

    Get.snackbar(
      'Success',
      'Settings saved successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
