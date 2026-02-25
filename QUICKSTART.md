# Quick Start Guide - My Invoice

Get up and running with My Invoice in just a few minutes!

## ⚡ Quick Setup (3 Steps)

### Step 1: Install Dependencies
```bash
cd my_invoice
flutter pub get
```

### Step 2: Run the App
```bash
flutter run
```

### Step 3: Configure Company Info
1. Open the app
2. Tap Settings (gear icon) in Dashboard
3. Enter your company name
4. Tap "Save Changes"

**That's it! You're ready to create invoices! 🎉**

---

## 📱 First Invoice in 60 Seconds

### 1. Create Invoice (15 seconds)
- Tap "New Invoice" button
- Enter client name (e.g., "John Doe")

### 2. Add Item (15 seconds)
- Enter item name (e.g., "Web Design")
- Enter quantity (e.g., "1")
- Enter price (e.g., "500")

### 3. Add Signature (15 seconds)
- Scroll to signature pad
- Draw your signature with finger

### 4. Generate PDF (15 seconds)
- Tap "Generate PDF" button
- Wait for success message
- Done!

---

## 🎯 Common Actions

### View All Invoices
- Tap "View All" from Dashboard
- Or tap "All Invoices" from menu

### Filter Invoices
- Open Invoice List
- Tap filter chips: All, Paid, Unpaid, Draft

### Search Invoice
- Open Invoice List
- Type in search bar
- Search by client name or invoice number

### Share Invoice
- Open invoice from list
- Swipe left → Tap "Share"
- Choose app (WhatsApp, Email, etc.)

### Edit Invoice
- Open invoice from list
- Swipe left → Tap "Edit"
- Make changes → Tap "Generate PDF"

### Delete Invoice
- Open invoice from list
- Swipe left → Tap "Delete"
- Confirm deletion

### Toggle Dark Mode
- Go to Settings
- Toggle "Dark Mode" switch
- Theme changes instantly

---

## 💡 Pro Tips

### Tip 1: Auto-Calculate Everything
All calculations are automatic:
- Item totals = Quantity × Price
- Subtotal = Sum of all items
- Tax = Subtotal × Tax%
- Discount = Based on type selected
- Grand Total = Subtotal + Tax - Discount

Just enter the numbers, app does the math!

### Tip 2: Save as Draft
Not ready to finalize?
- Tap "Save Draft" instead of "Generate PDF"
- Invoice saved with Draft status
- Edit anytime later

### Tip 3: Quick Client Info
Only client name is required!
- Email, phone, address are optional
- Add them if you need them
- Skip if you don't

### Tip 4: Multiple Items
Add unlimited items:
- Tap + button to add more
- Tap delete icon to remove
- At least 1 item required

### Tip 5: Clear Signature
Made a mistake?
- Tap "Clear Signature" button
- Draw again

---

## 🔧 Troubleshooting

### App won't start?
```bash
flutter clean
flutter pub get
flutter run
```

### Build errors?
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### PDF not generating?
- Check storage permissions
- Try restarting the app

### Can't share PDF?
- Generate PDF first
- Ensure you have sharing apps installed

---

## 📖 Need More Help?

- **Full Setup**: Read `SETUP_GUIDE.md`
- **All Features**: Read `FEATURES.md`
- **Project Info**: Read `README.md`

---

## ✅ Quick Checklist

Before creating your first invoice:
- [ ] Run `flutter pub get`
- [ ] Run the app
- [ ] Go to Settings
- [ ] Enter company name
- [ ] Save settings

Now you can:
- [x] Create invoices
- [x] Generate PDFs
- [x] Share invoices
- [x] Manage clients
- [x] Track payments

---

## 🚀 You're All Set!

Start creating professional invoices now!

**Next Action**: Tap the "New Invoice" button and create your first invoice! 🎊
