import 'package:isar/isar.dart';

part 'invoice_item_model.g.dart';

@embedded
class InvoiceItem {
  late String name;
  late int quantity;
  late double price;

  double get total => quantity * price;

  InvoiceItem({
    this.name = '',
    this.quantity = 1,
    this.price = 0.0,
  });
}
