import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/company_controller.dart';
import '../../models/invoice_model.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  const InvoiceDetailsScreen({super.key});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final InvoiceController invoiceController = Get.find();
  final CompanyController companyController = Get.find();

  Invoice? invoice;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    final invoiceId = Get.arguments as int;
    final loadedInvoice = await invoiceController.getInvoiceById(invoiceId);
    setState(() {
      invoice = loadedInvoice;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Invoice Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Invoice Details')),
        body: Center(child: Text('Invoice not found')),
      );
    }

    final company = companyController.company.value!;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (invoice!.status) {
      case InvoiceStatus.paid:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'PAID';
        break;
      case InvoiceStatus.unpaid:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'UNPAID';
        break;
      case InvoiceStatus.draft:
        statusColor = Colors.grey;
        statusIcon = Icons.drafts;
        statusText = 'DRAFT';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Details'),
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    Get.toNamed('/create-invoice', arguments: invoice!.id);
                  });
                },
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    _showDeleteDialog(context);
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 24),
                    SizedBox(width: 8),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Invoice Number & Date
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Invoice Number:',
                            style: TextStyle(color: Colors.grey[600])),
                        Text(
                          invoice!.invoiceNumber,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date:', style: TextStyle(color: Colors.grey[600])),
                        Text(
                          DateFormat('dd MMMM yyyy')
                              .format(invoice!.createdDate ?? DateTime.now()),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    if (invoice!.dueDate != null) ...[
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Due Date:',
                              style: TextStyle(color: Colors.grey[600])),
                          Text(
                            DateFormat('dd MMMM yyyy').format(invoice!.dueDate!),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Company Details
            Text(
              'From',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (company.email != null) ...[
                      SizedBox(height: 4),
                      Text(company.email!),
                    ],
                    if (company.phone != null) ...[
                      SizedBox(height: 4),
                      Text(company.phone!),
                    ],
                    if (company.address != null) ...[
                      SizedBox(height: 4),
                      Text(company.address!),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Client Details
            Text(
              'Bill To',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice!.clientName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (invoice!.clientEmail != null) ...[
                      SizedBox(height: 4),
                      Text(invoice!.clientEmail!),
                    ],
                    if (invoice!.clientPhone != null) ...[
                      SizedBox(height: 4),
                      Text(invoice!.clientPhone!),
                    ],
                    if (invoice!.clientAddress != null) ...[
                      SizedBox(height: 4),
                      Text(invoice!.clientAddress!),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Items
            Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text('Item',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('Qty',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center)),
                        Expanded(
                            flex: 2,
                            child: Text('Price',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right)),
                        Expanded(
                            flex: 2,
                            child: Text('Total',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  // Items
                  ...invoice!.items.asMap().entries.map((entry) {
                    final item = entry.value;
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(item.name)),
                          Expanded(
                              child: Text('${item.quantity}',
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  '${company.currency} ${item.price.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right)),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  '${company.currency} ${item.total.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Totals
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalRow('Subtotal', invoice!.subtotal, company.currency),
                    Divider(),
                    _buildTotalRow('Tax (${invoice!.taxPercentage}%)',
                        invoice!.taxAmount, company.currency),
                    Divider(),
                    _buildTotalRow(
                        'Discount', invoice!.discountAmount, company.currency,
                        isNegative: true),
                    Divider(thickness: 2),
                    _buildTotalRow(
                        'Grand Total', invoice!.grandTotal, company.currency,
                        isGrandTotal: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Signature
            if (invoice!.signaturePath != null) ...[
              Text(
                'Signature',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        child: Image.file(
                          File(invoice!.signaturePath!),
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Authorized Signature',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generatePdf,
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('Generate PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: invoice!.pdfPath != null ? _sharePdf : null,
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, String currency,
      {bool isGrandTotal = false, bool isNegative = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 18 : 16,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${isNegative ? '- ' : ''}$currency ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isGrandTotal ? 18 : 16,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf() async {
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await invoiceController.generatePdf(invoice!);
      Get.back();

      Get.snackbar(
        'Success',
        'PDF generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reload invoice to get updated PDF path
      await _loadInvoice();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sharePdf() async {
    if (invoice!.pdfPath != null) {
      try {
        await Share.shareXFiles(
          [XFile(invoice!.pdfPath!)],
          text: 'Invoice ${invoice!.invoiceNumber}',
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to share PDF: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Invoice'),
        content: Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await invoiceController.deleteInvoice(invoice!.id);
              Get.back(); // Close dialog
              Get.back(); // Go back to list
              Get.snackbar(
                'Success',
                'Invoice deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
