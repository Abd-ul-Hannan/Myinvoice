import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice_model.dart';
import '../models/company_model.dart';

class PdfService {
  static Future<String> generateInvoicePdf(
    Invoice invoice,
    Company company,
  ) async {
    final pdf = pw.Document();

    // Load signature if exists
    pw.MemoryImage? signatureImage;
    if (invoice.signaturePath != null) {
      try {
        final signatureFile = File(invoice.signaturePath!);
        if (await signatureFile.exists()) {
          final bytes = await signatureFile.readAsBytes();
          signatureImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        print('Error loading signature: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        company.name,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (company.email != null)
                        pw.Text(company.email!, style: pw.TextStyle(fontSize: 10)),
                      if (company.phone != null)
                        pw.Text(company.phone!, style: pw.TextStyle(fontSize: 10)),
                      if (company.address != null)
                        pw.Text(company.address!, style: pw.TextStyle(fontSize: 10)),
                      if (company.taxInfo != null)
                        pw.Text('Tax: ${company.taxInfo}', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('Invoice #: ${invoice.invoiceNumber}'),
                      pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(invoice.createdDate ?? DateTime.now())}'),
                      if (invoice.dueDate != null)
                        pw.Text('Due: ${DateFormat('dd/MM/yyyy').format(invoice.dueDate!)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Client Details
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Bill To:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(invoice.clientName, style: pw.TextStyle(fontSize: 14)),
                    if (invoice.clientEmail != null)
                      pw.Text(invoice.clientEmail!, style: pw.TextStyle(fontSize: 10)),
                    if (invoice.clientPhone != null)
                      pw.Text(invoice.clientPhone!, style: pw.TextStyle(fontSize: 10)),
                    if (invoice.clientAddress != null)
                      pw.Text(invoice.clientAddress!, style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.blue700),
                    children: [
                      _buildTableCell('Item', isHeader: true),
                      _buildTableCell('Quantity', isHeader: true),
                      _buildTableCell('Price', isHeader: true),
                      _buildTableCell('Total', isHeader: true),
                    ],
                  ),
                  // Items
                  ...invoice.items.map((item) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(item.name),
                        _buildTableCell(item.quantity.toString()),
                        _buildTableCell('${company.currency} ${item.price.toStringAsFixed(2)}'),
                        _buildTableCell('${company.currency} ${item.total.toStringAsFixed(2)}'),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 250,
                    child: pw.Column(
                      children: [
                        _buildTotalRow('Subtotal:', '${company.currency} ${invoice.subtotal.toStringAsFixed(2)}'),
                        _buildTotalRow('Tax (${invoice.taxPercentage}%):', '${company.currency} ${invoice.taxAmount.toStringAsFixed(2)}'),
                        _buildTotalRow('Discount:', '- ${company.currency} ${invoice.discountAmount.toStringAsFixed(2)}'),
                        pw.Divider(thickness: 2),
                        _buildTotalRow(
                          'Grand Total:',
                          '${company.currency} ${invoice.grandTotal.toStringAsFixed(2)}',
                          isGrandTotal: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Signature
              if (signatureImage != null) ...[
                pw.Row(
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 200,
                          height: 80,
                          child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                        ),
                        pw.Divider(thickness: 1),
                        pw.Text('Authorized Signature', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );

    // Save PDF
    final output = await getApplicationDocumentsDirectory();
    final fileName = 'invoice_${invoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value, {bool isGrandTotal = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isGrandTotal ? 14 : 12,
              fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isGrandTotal ? 14 : 12,
              fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
