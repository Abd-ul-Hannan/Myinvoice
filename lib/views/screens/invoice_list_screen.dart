import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/company_controller.dart';
import '../../models/invoice_model.dart';

class InvoiceListScreen extends StatelessWidget {
  final InvoiceController invoiceController = Get.find();
  final CompanyController companyController = Get.find();

  InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Invoices'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search invoices...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => invoiceController.setSearchQuery(value),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() {
                return Row(
                  children: [
                    _buildFilterChip(
                      'All',
                      invoiceController.filterStatus.value == null,
                      () => invoiceController.setFilter(null),
                    ),
                    SizedBox(width: 8),
                    _buildFilterChip(
                      'Paid',
                      invoiceController.filterStatus.value == InvoiceStatus.paid,
                      () => invoiceController.setFilter(InvoiceStatus.paid),
                    ),
                    SizedBox(width: 8),
                    _buildFilterChip(
                      'Unpaid',
                      invoiceController.filterStatus.value == InvoiceStatus.unpaid,
                      () => invoiceController.setFilter(InvoiceStatus.unpaid),
                    ),
                    SizedBox(width: 8),
                    _buildFilterChip(
                      'Draft',
                      invoiceController.filterStatus.value == InvoiceStatus.draft,
                      () => invoiceController.setFilter(InvoiceStatus.draft),
                    ),
                  ],
                );
              }),
            ),
          ),

          // Invoice List
          Expanded(
            child: Obx(() {
              final invoices = invoiceController.filteredInvoices;

              if (invoices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'No invoices found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/create-invoice'),
                        icon: Icon(Icons.add),
                        label: Text('Create New Invoice'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => invoiceController.loadInvoices(),
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return _buildInvoiceCard(context, invoice);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/create-invoice'),
        icon: Icon(Icons.add),
        label: Text('New Invoice'),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Invoice invoice) {
    final company = companyController.company.value!;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (invoice.status) {
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

    return Slidable(
      key: Key(invoice.id.toString()),
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Get.toNamed('/create-invoice', arguments: invoice.id);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) async {
              if (invoice.pdfPath != null) {
                await Share.shareXFiles([XFile(invoice.pdfPath!)],
                    text: 'Invoice ${invoice.invoiceNumber}');
              } else {
                Get.snackbar(
                  'Info',
                  'Please generate PDF first',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
          SlidableAction(
            onPressed: (context) {
              _showDeleteDialog(context, invoice);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: InkWell(
          onTap: () => Get.toNamed('/invoice-details', arguments: invoice.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.clientName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            invoice.invoiceNumber,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${company.currency} ${invoice.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(invoice.createdDate ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Invoice invoice) {
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
              await invoiceController.deleteInvoice(invoice.id);
              Get.back();
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
