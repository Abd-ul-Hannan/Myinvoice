import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/company_controller.dart';
import '../../models/invoice_model.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  final InvoiceController invoiceController = Get.find();
  final CompanyController companyController = Get.find();

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: Obx(() {
        final company = companyController.company.value;
        if (company == null) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await invoiceController.loadInvoices();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  company.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                SizedBox(height: 24),

                // Statistics Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    StatCard(
                      title: 'Total Invoices',
                      value: invoiceController.totalInvoices.toString(),
                      icon: Icons.description,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Paid',
                      value: invoiceController.paidInvoices.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Unpaid',
                      value: invoiceController.unpaidInvoices.toString(),
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Drafts',
                      value: invoiceController.draftInvoices.toString(),
                      icon: Icons.drafts,
                      color: Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Revenue Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildRevenueCard(
                        context,
                        'Total Revenue',
                        invoiceController.totalRevenue,
                        company.currency,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildRevenueCard(
                        context,
                        'Pending',
                        invoiceController.pendingRevenue,
                        company.currency,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/create-invoice'),
                        icon: Icon(Icons.add),
                        label: Text('New Invoice'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.toNamed('/invoices'),
                        icon: Icon(Icons.list),
                        label: Text('View All'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Recent Invoices
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Invoices',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/invoices'),
                      child: Text('See All'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildRecentInvoices(context),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/create-invoice'),
        icon: Icon(Icons.add),
        label: Text('New Invoice'),
      ),
    );
  }

  Widget _buildRevenueCard(
    BuildContext context,
    String title,
    double amount,
    String currency,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '$currency ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInvoices(BuildContext context) {
    final recentInvoices = invoiceController.recentInvoices;

    if (recentInvoices.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No invoices yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: recentInvoices.length,
      separatorBuilder: (context, index) => SizedBox(height: 8),
      itemBuilder: (context, index) {
        final invoice = recentInvoices[index];
        return _buildInvoiceCard(context, invoice);
      },
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Invoice invoice) {
    final company = companyController.company.value!;
    Color statusColor;
    IconData statusIcon;

    switch (invoice.status) {
      case InvoiceStatus.paid:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case InvoiceStatus.unpaid:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case InvoiceStatus.draft:
        statusColor = Colors.grey;
        statusIcon = Icons.drafts;
        break;
    }

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () => Get.toNamed('/invoice-details', arguments: invoice.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.clientName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${company.currency} ${invoice.grandTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(invoice.createdDate ?? DateTime.now()),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
