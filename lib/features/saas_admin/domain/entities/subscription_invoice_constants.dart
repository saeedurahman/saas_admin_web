abstract final class SubscriptionInvoiceConstants {
  SubscriptionInvoiceConstants._();

  static const invoiceStatuses = [
    ('unpaid', 'Unpaid'),
    ('paid', 'Paid'),
    ('overdue', 'Overdue'),
  ];

  static const paymentMethods = [
    ('cash', 'Cash'),
    ('bank_transfer', 'Bank transfer'),
    ('jazzcash', 'JazzCash'),
    ('easypaisa', 'Easypaisa'),
    ('cheque', 'Cheque'),
    ('other', 'Other'),
  ];

  static String statusLabel(String value) {
    for (final item in invoiceStatuses) {
      if (item.$1 == value) return item.$2;
    }
    return value;
  }

  static String paymentMethodLabel(String value) {
    for (final item in paymentMethods) {
      if (item.$1 == value) return item.$2;
    }
    return value;
  }
}
