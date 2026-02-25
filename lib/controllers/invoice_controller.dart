import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../models/invoice_model.dart';
import '../services/isar_service.dart';
import '../services/pdf_service.dart';
import 'company_controller.dart';

class InvoiceController extends GetxController {
  final RxList<Invoice> invoices = <Invoice>[].obs;
  final RxList<Invoice> filteredInvoices = <Invoice>[].obs;
  final Rx<InvoiceStatus?> filterStatus = Rx<InvoiceStatus?>(null);
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    final isar = await IsarService.isar;
    final allInvoices = await isar.invoices
        .where()
        .sortByCreatedDate()
        .findAll();
    invoices.value = allInvoices.reversed.toList();
    applyFilters();
  }

  void applyFilters() {
    var filtered = invoices.toList();

    if (filterStatus.value != null) {
      filtered = filtered
          .where((invoice) => invoice.status == filterStatus.value)
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((invoice) {
        return invoice.clientName.toLowerCase().contains(query) ||
            invoice.invoiceNumber.toLowerCase().contains(query);
      }).toList();
    }

    filteredInvoices.value = filtered;
  }

  void setFilter(InvoiceStatus? status) {
    filterStatus.value = status;
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  Future<void> saveInvoice(Invoice invoice) async {
    final isar = await IsarService.isar;
    await isar.writeTxn(() async {
      await isar.invoices.put(invoice);
    });
    await loadInvoices();
  }

  Future<void> deleteInvoice(int id) async {
    final isar = await IsarService.isar;
    await isar.writeTxn(() async {
      await isar.invoices.delete(id);
    });
    await loadInvoices();
  }

  Future<Invoice?> getInvoiceById(int id) async {
    final isar = await IsarService.isar;
    return await isar.invoices.get(id);
  }

  Future<String> generatePdf(Invoice invoice) async {
    final companyController = Get.find<CompanyController>();
    final company = companyController.company.value!;

    final pdfPath = await PdfService.generateInvoicePdf(invoice, company);

    // Update invoice with PDF path
    invoice.pdfPath = pdfPath;
    await saveInvoice(invoice);

    return pdfPath;
  }

  String generateInvoiceNumber() {
    final now = DateTime.now();
    final number = invoices.length + 1;
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${number.toString().padLeft(4, '0')}';
  }

  int get totalInvoices => invoices.length;

  int get paidInvoices =>
      invoices.where((invoice) => invoice.status == InvoiceStatus.paid).length;

  int get unpaidInvoices =>
      invoices.where((invoice) => invoice.status == InvoiceStatus.unpaid).length;

  int get draftInvoices =>
      invoices.where((invoice) => invoice.status == InvoiceStatus.draft).length;

  double get totalRevenue => invoices
      .where((invoice) => invoice.status == InvoiceStatus.paid)
      .fold(0.0, (sum, invoice) => sum + invoice.grandTotal);

  double get pendingRevenue => invoices
      .where((invoice) => invoice.status == InvoiceStatus.unpaid)
      .fold(0.0, (sum, invoice) => sum + invoice.grandTotal);

  List<Invoice> get recentInvoices {
    final sorted = invoices.where((invoice) => invoice.createdDate != null).toList()
      ..sort((a, b) => b.createdDate!.compareTo(a.createdDate!));
    return sorted.take(5).toList();
  }
}
