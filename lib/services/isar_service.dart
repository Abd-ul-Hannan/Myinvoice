import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/invoice_model.dart';
import '../models/company_model.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> get isar async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [InvoiceSchema, CompanySchema],
      directory: dir.path,
    );
    return _isar!;
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
