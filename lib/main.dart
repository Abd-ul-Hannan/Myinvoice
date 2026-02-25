import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/invoice_controller.dart';
import 'controllers/company_controller.dart';
import 'routes/app_routes.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(CompanyController());
  Get.put(InvoiceController());

  runApp(MyInvoiceApp());
}

class MyInvoiceApp extends StatelessWidget {
  const MyInvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final companyController = Get.find<CompanyController>();

    return Obx(() {
      final isDarkMode = companyController.company.value?.isDarkMode ?? false;

      return GetMaterialApp(
        title: 'My Invoice',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.dashboard,
        getPages: AppRoutes.routes,
      );
    });
  }
}
