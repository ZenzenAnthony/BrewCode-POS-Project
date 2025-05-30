// lib/models/transaction.dart

class Transaction {
  int? id;  // Changed from final to allow setting in OrderProvider
  final DateTime orderDate;
  final double totalAmount;
  final String? paymentMethod;
  final List<TransactionItem> items;
  final bool isCompleted;
  final String? receiptNumber;
    // Additional fields needed for orders
  final String? customerName;
  final String? orderType;
  final double? subtotal;
  final double? tax;
  final double? serviceCharge;
  final double? total;
  final double? amountReceived;  Transaction({
    this.id,
    required this.orderDate,
    this.totalAmount = 0.0,
    this.paymentMethod,
    required this.items,
    this.isCompleted = false,
    this.receiptNumber,
    this.customerName,
    this.orderType,
    this.subtotal,
    this.tax,
    this.serviceCharge,
    this.total,
    this.amountReceived,
  });/// Creates a Transaction from a database map and list of items
  factory Transaction.fromMap(Map<String, dynamic> map, List<TransactionItem> items) {
    return Transaction(
      id: map['id'] as int,
      orderDate: map['order_date'] is DateTime 
          ? map['order_date'] as DateTime 
          : DateTime.parse(map['order_date'].toString()),
      totalAmount: map['total_amount'] is double 
          ? map['total_amount'] as double 
          : double.parse(map['total_amount'].toString()),
      paymentMethod: map['payment_method'] as String?,
      isCompleted: map['is_completed'] == 1 || map['is_completed'] == true,
      receiptNumber: map['receipt_number'] as String?,
      items: items,      customerName: map['CustomerName'] as String?,
      orderType: map['OrderType'] as String?,
      subtotal: map['SubTotal'] != null ? double.parse(map['SubTotal'].toString()) : null,
      tax: map['Tax'] != null ? double.parse(map['Tax'].toString()) : null,
      serviceCharge: map['ServiceCharge'] != null ? double.parse(map['ServiceCharge'].toString()) : null,
      total: map['Total'] != null ? double.parse(map['Total'].toString()) : null,
      amountReceived: map['AmountReceived'] != null ? double.parse(map['AmountReceived'].toString()) : null,
    );
  }
    /// Creates a Transaction from JSON response
  factory Transaction.fromJson(Map<String, dynamic> json) {
    // In a real app, you would fetch items separately or parse them from the JSON
    // For now, we'll create an empty list
    List<TransactionItem> items = [];
    
    return Transaction(
      id: json['OrderID'] != null ? int.parse(json['OrderID'].toString()) : null,
      orderDate: json['OrderDate'] != null 
          ? DateTime.parse(json['OrderDate'].toString()) 
          : DateTime.now(),
      totalAmount: json['Total'] != null ? double.parse(json['Total'].toString()) : 0.0,
      paymentMethod: json['PaymentMethod'] as String?,
      isCompleted: json['Status'] == 'Completed',
      receiptNumber: json['ReceiptNumber'] as String?,
      items: items,
      customerName: json['CustomerName'] as String?,      orderType: json['OrderType'] as String?,
      subtotal: json['SubTotal'] != null ? double.parse(json['SubTotal'].toString()) : null,
      tax: json['Tax'] != null ? double.parse(json['Tax'].toString()) : null,
      serviceCharge: json['ServiceCharge'] != null ? double.parse(json['ServiceCharge'].toString()) : null,
      total: json['Total'] != null ? double.parse(json['Total'].toString()) : null,
      amountReceived: json['AmountReceived'] != null ? double.parse(json['AmountReceived'].toString()) : null,
    );
  }
  
  /// Converts Transaction to a map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_date': orderDate.toIso8601String(),
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'is_completed': isCompleted ? 1 : 0,
      'receipt_number': receiptNumber,
    };
  }
  /// Creates a copy of this Transaction with the given fields replaced
  Transaction copyWith({
    int? id,
    DateTime? orderDate,
    double? totalAmount,
    String? paymentMethod,
    List<TransactionItem>? items,
    bool? isCompleted,
    String? receiptNumber,
    String? customerName,
    String? orderType,
    double? subtotal,
    double? tax,
    double? serviceCharge,
    double? total,
    double? amountPaid,
  }) {    return Transaction(
      id: id ?? this.id,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      isCompleted: isCompleted ?? this.isCompleted,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      customerName: customerName ?? this.customerName,
      orderType: orderType ?? this.orderType,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      total: total ?? this.total,
      amountReceived: amountPaid ?? this.amountReceived,
    );
  }
}

class TransactionItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String? notes;
  final int? id; // Added for OrderItems.MenuItemID

  TransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
    this.id,
  });
  
  // Helper getter for compatibility with OrderItems schema
  double get price => unitPrice;

  double get totalPrice => quantity * unitPrice;

  /// Create from map
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      productId: map['product_id'] is int 
          ? map['product_id'] as int 
          : int.parse(map['product_id'].toString()),
      productName: map['product_name'] as String,
      quantity: map['quantity'] is int 
          ? map['quantity'] as int 
          : int.parse(map['quantity'].toString()),
      unitPrice: map['unit_price'] is double 
          ? map['unit_price'] as double 
          : double.parse(map['unit_price'].toString()),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
    /// Creates a copy with updated fields
  TransactionItem copyWith({
    int? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    String? notes,
    int? id,
  }) {
    return TransactionItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }
}
