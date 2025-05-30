// lib/models/order.dart
import 'cart_item.dart';

class Order {
  final String? id;
  final String? customerId;  // Changed from int to String to be more flexible
  final DateTime orderDate;
  final String orderType;    // Limited to 'Dine-in', 'Takeout'
  final String orderStatus;  // Limited to 'Pending', 'Completed'
  final double totalAmount;
  final List<CartItem> items;
  final String? notes;

  Order({
    this.id,
    this.customerId,
    required this.orderDate,
    required this.orderType,
    required this.orderStatus,
    required this.totalAmount,
    required this.items,
    this.notes,
  });
  // Create from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['OrderID'].toString(),
      customerId: json['CustomerID']?.toString(),
      orderDate: DateTime.parse(json['OrderDate']),
      orderType: json['OrderType'],
      orderStatus: json['OrderStatus'],
      totalAmount: double.parse(json['TotalAmount'].toString()),
      items: [], // Items would be loaded separately
      notes: json['Notes'],
    );
  }
  // Convert to JSON for sending to API
  Map<String, dynamic> toJson() {
    return {
      'CustomerID': customerId,
      'OrderType': orderType,
      'OrderStatus': orderStatus, // Added OrderStatus to match our database
      'TotalAmount': totalAmount,
      'Notes': notes,
    };
  }
}
