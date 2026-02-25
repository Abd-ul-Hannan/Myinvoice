# My Invoice - Complete Invoice Management Flutter App

A production-ready, feature-rich invoice management application built with Flutter, GetX, and Isar local database.

## Features

### Core Functionalities

- **Dashboard**
  - Total invoices count with visual statistics
  - Paid/Unpaid/Draft invoice counts
  - Revenue tracking (total and pending)
  - Recent invoices list
  - Quick actions for creating invoices

- **Create/Edit Invoice**
  - Client details management (name, email, phone, address)
  - Company information integration
  - Multiple invoice items with quantity, price, and auto-calculated totals
  - Tax calculation (percentage-based)
  - Discount options (flat amount or percentage)
  - Digital signature pad
  - Invoice status management (Draft, Unpaid, Paid)
  - Form validation

- **Invoice List**
  - Display all invoices with detailed information
  - Filter by status (All, Paid, Unpaid, Draft)
  - Search by client name or invoice number
  - Swipe actions: Edit, Share, Delete
  - Pull to refresh

- **Invoice Details**
  - Complete invoice information display
  - Company and client details
  - Itemized list with totals
  - Digital signature display
  - Generate PDF action
  - Share PDF via WhatsApp, Email, etc.
  - Edit and Delete options

- **PDF Generation**
  - Professional invoice PDF layout
  - Company logo and details
  - Client information
  - Itemized table with calculations
  - Tax, discount, and grand total
  - Digital signature inclusion
  - Auto-save to device storage

- **Settings**
  - Company profile management
  - Logo upload
  - Contact information
  - Tax ID/VAT number
  - Currency selection (USD, EUR, GBP, INR, AUD, CAD, JPY, CNY)
  - Dark/Light theme toggle

### Technical Features

- **State Management**: GetX for reactive state management
- **Local Database**: Isar for fast, local data persistence
- **PDF Generation**: pdf package with professional templates
- **File Sharing**: share_plus for sharing invoices
- **Digital Signatures**: signature package for capturing signatures
- **Image Management**: image_picker for company logos
- **Modern UI**: Material 3 design with smooth animations
- **Dark Mode**: Complete theme support

## Tech Stack

- **Framework**: Flutter 3.x+
- **State Management**: GetX
- **Local Database**: Isar
- **PDF Generation**: pdf, printing packages
- **Signature**: signature package
- **Sharing**: share_plus
- **Image Picking**: image_picker
- **Charts**: fl_chart
- **UI Components**: flutter_slidable, intl

## Project Structure

```
lib/
├── controllers/          # GetX controllers
│   ├── company_controller.dart
│   └── invoice_controller.dart
├── models/              # Data models
│   ├── company_model.dart
│   ├── invoice_model.dart
│   └── invoice_item_model.dart
├── services/            # Business logic services
│   ├── isar_service.dart
│   └── pdf_service.dart
├── views/
│   ├── screens/        # App screens
│   │   ├── dashboard_screen.dart
│   │   ├── create_invoice_screen.dart
│   │   ├── invoice_list_screen.dart
│   │   ├── invoice_details_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/        # Reusable widgets
│       └── stat_card.dart
├── routes/             # App routing
│   └── app_routes.dart
├── utils/              # Utilities
│   └── theme.dart
└── main.dart           # App entry point
```

## Installation

1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd my_invoice
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Generate Isar schema (if needed):
   ```bash
   flutter pub run build_runner build
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Usage

### First Time Setup

1. Open the app and navigate to Settings (gear icon in Dashboard)
2. Configure your company information:
   - Company name
   - Email, phone, address
   - Tax ID/VAT number
   - Upload company logo (optional)
   - Select currency
3. Save changes

### Creating an Invoice

1. From Dashboard, tap "New Invoice" or "Create New Invoice"
2. Fill in client details (name is required)
3. Add invoice items:
   - Item name, quantity, and price
   - Add more items using the + button
   - Remove items with the delete icon
4. Set tax percentage and discount (optional)
5. Add digital signature using the signature pad
6. Choose invoice status (Draft, Unpaid, or Paid)
7. Tap "Save Draft" or "Generate PDF"

### Managing Invoices

- **View All**: Access invoice list from Dashboard
- **Filter**: Use filter chips (All, Paid, Unpaid, Draft)
- **Search**: Type client name or invoice number in search bar
- **Edit**: Swipe left on an invoice and tap Edit
- **Share**: Swipe left and tap Share (PDF must be generated)
- **Delete**: Swipe left and tap Delete

### Generating and Sharing PDFs

1. Open an invoice from the list
2. Tap "Generate PDF" button
3. PDF is automatically saved to device storage
4. Tap "Share" to send via WhatsApp, Email, etc.

## Features Highlights

### Real-World Implementation
- No dummy data - all features are fully functional
- Actual local database storage with Isar
- Real PDF generation with professional layout
- Working file sharing across apps
- Complete CRUD operations

### Modern UI/UX
- Material 3 design
- Smooth page transitions
- Animated cards and statistics
- Responsive layouts
- Dark mode support
- Intuitive navigation

### Production Ready
- Input validation
- Error handling
- Loading states
- Success/error notifications
- Data persistence
- Clean architecture

## Requirements

- Flutter SDK: >=3.0.0 <4.0.0
- Dart SDK: Compatible with Flutter version
- iOS: 11.0 or higher
- Android: API level 21 (Android 5.0) or higher

## Permissions

The app requires the following permissions:

### Android
- Storage access (for saving and reading PDFs)
- Camera (for company logo upload)

### iOS
- Photo library access (for company logo upload)
- Files access (for PDF storage)

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or contributions, please contact the development team.

## Version

Current Version: 1.0.0

---

Built with Flutter ❤️
