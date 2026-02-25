import 'package:isar/isar.dart';

part 'company_model.g.dart';

@collection
class Company {
  Id id = Isar.autoIncrement;

  late String name;
  String? email;
  String? phone;
  String? address;
  String? logoPath;
  String? taxInfo;
  String currency;
  bool isDarkMode;

  Company({
    this.name = '',
    this.email,
    this.phone,
    this.address,
    this.logoPath,
    this.taxInfo,
    this.currency = 'USD',
    this.isDarkMode = false,
  });
}
