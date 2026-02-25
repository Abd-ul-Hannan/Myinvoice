import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../models/company_model.dart';
import '../services/isar_service.dart';

class CompanyController extends GetxController {
  final Rx<Company?> company = Rx<Company?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCompany();
  }

  Future<void> loadCompany() async {
    final isar = await IsarService.isar;
    final companies = await isar.companys.where().findAll();

    if (companies.isEmpty) {
      // Create default company
      final defaultCompany = Company(
        name: 'My Company',
        currency: 'USD',
        isDarkMode: false,
      );
      await saveCompany(defaultCompany);
    } else {
      company.value = companies.first;
    }
  }

  Future<void> saveCompany(Company updatedCompany) async {
    final isar = await IsarService.isar;
    await isar.writeTxn(() async {
      if (company.value != null) {
        updatedCompany.id = company.value!.id;
      }
      await isar.companys.put(updatedCompany);
    });
    await loadCompany();
  }

  Future<void> updateTheme(bool isDark) async {
    if (company.value != null) {
      final updatedCompany = Company(
        name: company.value!.name,
        email: company.value!.email,
        phone: company.value!.phone,
        address: company.value!.address,
        logoPath: company.value!.logoPath,
        taxInfo: company.value!.taxInfo,
        currency: company.value!.currency,
        isDarkMode: isDark,
      );
      updatedCompany.id = company.value!.id;
      await saveCompany(updatedCompany);
    }
  }
}
