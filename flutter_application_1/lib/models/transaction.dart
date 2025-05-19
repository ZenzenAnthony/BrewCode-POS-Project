// lib/models/transaction.dart

class TransactionRecord {
  final String id;
  final String orderId;
  final DateTime date;
  final double amount;
  final String transactionStatus; // Added to match database (Completed, Refunded)
  final String receiptNumber;
  final String orderType;
  final String customerName;
  final String staffName;
  final String? notes;

  TransactionRecord({
    required this.id,
    required this.orderId,
    required this.date,
    required this.amount,
    required this.transactionStatus,
    required this.receiptNumber,
    required this.orderType,
    required this.customerName,
    required this.staffName,
    this.notes,
  });

  // Create from JSON
  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['TransactionID'].toString(),
      orderId: json['OrderID'].toString(),
      date: DateTime.parse(json['TransactionDate']),
      amount: double.parse(json['Amount'].toString()),
      transactionStatus: json['TransactionStatus'],
      receiptNumber: json['ReceiptNumber'],
      orderType: json['OrderType'],
      customerName: json['CustomerName'] ?? 'Walk-in',
      staffName: json['StaffName'],
      notes: json['Notes'],
    );
  }
  
  // Convert to JSON for sending to API
  Map<String, dynamic> toJson() {
    return {
      'OrderID': orderId,
      'TransactionDate': date.toIso8601String(),
      'Amount': amount,
      'TransactionStatus': transactionStatus,
      'ReceiptNumber': receiptNumber,
      'Notes': notes,
    };
  }
}
