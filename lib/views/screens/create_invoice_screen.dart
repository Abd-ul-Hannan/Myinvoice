import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/company_controller.dart';
import '../../models/invoice_model.dart';
import '../../models/invoice_item_model.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final InvoiceController invoiceController = Get.find();
  final CompanyController companyController = Get.find();
  final _formKey = GlobalKey<FormState>();

  late Invoice invoice;
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    final invoiceId = Get.arguments as int?;

    if (invoiceId != null) {
      _loadInvoice(invoiceId);
    } else {
      invoice = Invoice(
        invoiceNumber: invoiceController.generateInvoiceNumber(),
        items: [InvoiceItem()],
      );
    }
  }

  Future<void> _loadInvoice(int id) async {
    final loadedInvoice = await invoiceController.getInvoiceById(id);
    if (loadedInvoice != null) {
      setState(() {
        invoice = loadedInvoice;
        if (invoice.items.isEmpty) {
          invoice.items = [InvoiceItem()];
        }
      });
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final company = companyController.company.value;
    if (company == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(Get.arguments == null ? 'Create Invoice' : 'Edit Invoice'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Invoice Number
            TextFormField(
              initialValue: invoice.invoiceNumber,
              decoration: InputDecoration(
                labelText: 'Invoice Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => invoice.invoiceNumber = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter invoice number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Client Details Section
            Text(
              'Client Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: invoice.clientName,
              decoration: InputDecoration(
                labelText: 'Client Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) => invoice.clientName = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter client name';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: invoice.clientEmail,
              decoration: InputDecoration(
                labelText: 'Client Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => invoice.clientEmail = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: invoice.clientPhone,
              decoration: InputDecoration(
                labelText: 'Client Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => invoice.clientPhone = value,
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: invoice.clientAddress,
              decoration: InputDecoration(
                labelText: 'Client Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              onChanged: (value) => invoice.clientAddress = value,
            ),
            SizedBox(height: 24),

            // Invoice Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice Items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () {
                    setState(() {
                      invoice.items.add(InvoiceItem());
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            ...List.generate(invoice.items.length, (index) {
              return _buildItemCard(index);
            }),
            SizedBox(height: 24),

            // Tax and Discount
            Text(
              'Tax & Discount',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: invoice.taxPercentage.toString(),
              decoration: InputDecoration(
                labelText: 'Tax Percentage (%)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.percent),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                invoice.taxPercentage = double.tryParse(value) ?? 0;
                _calculateTotals();
              },
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DiscountType>(
                    value: invoice.discountType,
                    decoration: InputDecoration(
                      labelText: 'Discount Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: DiscountType.flat,
                        child: Text('Flat Amount'),
                      ),
                      DropdownMenuItem(
                        value: DiscountType.percentage,
                        child: Text('Percentage'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        invoice.discountType = value!;
                        _calculateTotals();
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: invoice.discountValue.toString(),
                    decoration: InputDecoration(
                      labelText: 'Discount Value',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      invoice.discountValue = double.tryParse(value) ?? 0;
                      _calculateTotals();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Totals
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalRow('Subtotal', invoice.subtotal, company.currency),
                    Divider(),
                    _buildTotalRow('Tax', invoice.taxAmount, company.currency),
                    Divider(),
                    _buildTotalRow('Discount', invoice.discountAmount, company.currency, isNegative: true),
                    Divider(thickness: 2),
                    _buildTotalRow(
                      'Grand Total',
                      invoice.grandTotal,
                      company.currency,
                      isGrandTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Signature
            Text(
              'Signature',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _signatureController.clear();
                  },
                  icon: Icon(Icons.clear),
                  label: Text('Clear Signature'),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Status
            DropdownButtonFormField<InvoiceStatus>(
              value: invoice.status,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: InvoiceStatus.draft,
                  child: Text('Draft'),
                ),
                DropdownMenuItem(
                  value: InvoiceStatus.unpaid,
                  child: Text('Unpaid'),
                ),
                DropdownMenuItem(
                  value: InvoiceStatus.paid,
                  child: Text('Paid'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  invoice.status = value!;
                });
              },
            ),
            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saveDraft,
                    child: Text('Save Draft'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAndGeneratePdf,
                    child: Text('Generate PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = invoice.items[index];

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                if (invoice.items.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        invoice.items.removeAt(index);
                        _calculateTotals();
                      });
                    },
                  ),
              ],
            ),
            SizedBox(height: 8),
            TextFormField(
              initialValue: item.name,
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => item.name = value,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      item.quantity = int.tryParse(value) ?? 1;
                      _calculateTotals();
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.price.toString(),
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      item.price = double.tryParse(value) ?? 0;
                      _calculateTotals();
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.total.toStringAsFixed(2),
                    decoration: InputDecoration(
                      labelText: 'Total',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    enabled: false,
                  ),
                ),
              ],
            ),
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

  void _calculateTotals() {
    setState(() {
      invoice.calculateTotals();
    });
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await _saveSignature();
    invoice.status = InvoiceStatus.draft;
    await invoiceController.saveInvoice(invoice);

    Get.snackbar(
      'Success',
      'Invoice saved as draft',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    Get.back();
  }

  Future<void> _saveAndGeneratePdf() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await _saveSignature();
      await invoiceController.saveInvoice(invoice);
      final pdfPath = await invoiceController.generatePdf(invoice);

      Get.back(); // Close loading

      Get.snackbar(
        'Success',
        'Invoice PDF generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offNamed('/invoice-details', arguments: invoice.id);
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveSignature() async {
    if (_signatureController.isNotEmpty) {
      final signature = await _signatureController.toPngBytes();
      if (signature != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File(
            '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(signature);
        invoice.signaturePath = file.path;
      }
    }
  }
}
