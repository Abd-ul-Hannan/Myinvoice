import 'package:get/get.dart';
import '../views/screens/dashboard_screen.dart';
import '../views/screens/create_invoice_screen.dart';
import '../views/screens/invoice_list_screen.dart';
import '../views/screens/invoice_details_screen.dart';
import '../views/screens/settings_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String createInvoice = '/create-invoice';
  static const String invoices = '/invoices';
  static const String invoiceDetails = '/invoice-details';
  static const String settings = '/settings';

  static List<GetPage> routes = [
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createInvoice,
      page: () => CreateInvoiceScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: invoices,
      page: () => InvoiceListScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: invoiceDetails,
      page: () => InvoiceDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
