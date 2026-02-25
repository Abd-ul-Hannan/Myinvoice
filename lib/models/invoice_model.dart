import 'package:isar/isar.dart';
import 'invoice_item_model.dart';

part 'invoice_model.g.dart';

enum InvoiceStatus {
  draft,
  unpaid,
  paid,
}

enum DiscountType {
  flat,
  percentage,
}

@collection
class Invoice {
  Id id = Isar.autoIncrement;

  late String invoiceNumber;

  @Index()
  DateTime? createdDate;

  DateTime? dueDate;

  // Client Details
  late String clientName;
  String? clientEmail;
  String? clientPhone;
  String? clientAddress;

  // Items
  List<InvoiceItem> items = [];

  // Calculations
  late double subtotal;
  late double taxPercentage;
  late double taxAmount;

  @enumerated
  late DiscountType discountType;
  late double discountValue;
  late double discountAmount;

  late double grandTotal;

  // Status
  @enumerated
  late InvoiceStatus status;

  // Signature
  String? signaturePath;

  // PDF Path
  String? pdfPath;

  Invoice({
    this.invoiceNumber = '',
    DateTime? createdDate,
    this.dueDate,
    this.clientName = '',
    this.clientEmail,
    this.clientPhone,
    this.clientAddress,
    this.items = const [],
    this.subtotal = 0.0,
    this.taxPercentage = 0.0,
    this.taxAmount = 0.0,
    this.discountType = DiscountType.flat,
    this.discountValue = 0.0,
    this.discountAmount = 0.0,
    this.grandTotal = 0.0,
    this.status = InvoiceStatus.draft,
    this.signaturePath,
    this.pdfPath,
  }) : createdDate = createdDate ?? DateTime.now();

  void calculateTotals() {
    subtotal = items.fold(0.0, (sum, item) => sum + item.total);

    taxAmount = subtotal * (taxPercentage / 100);

    if (discountType == DiscountType.percentage) {
      discountAmount = subtotal * (discountValue / 100);
    } else {
      discountAmount = discountValue;
    }

    grandTotal = subtotal + taxAmount - discountAmount;
    if (grandTotal < 0) grandTotal = 0;
  }
}
