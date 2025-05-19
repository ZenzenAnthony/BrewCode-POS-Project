// lib/providers/order_provider.dart

import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';
import '../services/order_service_placeholder.dart';

class OrderProvider with ChangeNotifier {
  final OrderServicePlaceholder _orderService = OrderServicePlaceholder();
  List<Order> _pendingOrders = [];
  List<Order> _completedOrders = [];
  List<TransactionRecord> _transactions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Order> get pendingOrders => [..._pendingOrders];
  List<Order> get completedOrders => [..._completedOrders];
  List<TransactionRecord> get transactions => [..._transactions];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Create a new order from cart items
  Future<String?> createOrder({
    String? customerId,
    required String staffId,
    required String orderType,
    required List<CartItem> items,
    required double totalAmount,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderId = await _orderService.createOrder(
        customerId: customerId,
        staffId: staffId,
        orderType: orderType,
        items: items,
        totalAmount: totalAmount,
        notes: notes,
      );

      if (orderId != null) {
        // Create a local Order object and add it to pending orders
        final newOrder = Order(
          id: orderId,
          customerId: customerId,
          staffId: staffId,
          orderDate: DateTime.now(),
          orderType: orderType,
          orderStatus: 'Pending',
          totalAmount: totalAmount,
          items: items,
          notes: notes,
        );

        _pendingOrders.add(newOrder);
        notifyListeners();
      }

      return orderId;
    } catch (e) {
      _error = 'Failed to create order: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete an order
  Future<bool> completeOrder(String orderId, String customerInitials) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderService.completeOrder(orderId, customerInitials);

      if (result['success'] == true) {
        // Move the order from pending to completed
        final orderIndex = _pendingOrders.indexWhere((order) => order.id == orderId);
        
        if (orderIndex != -1) {
          final completedOrder = Order(
            id: _pendingOrders[orderIndex].id,
            customerId: _pendingOrders[orderIndex].customerId,
            staffId: _pendingOrders[orderIndex].staffId,
            orderDate: _pendingOrders[orderIndex].orderDate,
            orderType: _pendingOrders[orderIndex].orderType,
            orderStatus: 'Completed',
            totalAmount: _pendingOrders[orderIndex].totalAmount,
            items: _pendingOrders[orderIndex].items,
            notes: _pendingOrders[orderIndex].notes,
          );
          
          _completedOrders.add(completedOrder);
          _pendingOrders.removeAt(orderIndex);
          
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      _error = 'Failed to complete order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load transaction history
  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final transactionList = await _orderService.getTransactionHistory();
      _transactions = transactionList;
    } catch (e) {
      _error = 'Failed to load transactions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get order by ID
  Order? getOrderById(String orderId) {
    final pendingOrder = _pendingOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => _completedOrders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => Order(
          id: '-1',
          staffId: '0',
          orderDate: DateTime.now(),
          orderType: 'Unknown',
          orderStatus: 'Unknown',
          totalAmount: 0,
          items: [],
        ),
      ),
    );

    return pendingOrder.id != '-1' ? pendingOrder : null;
  }

  // Clear orders (for testing purposes)
  void clearOrders() {
    _pendingOrders = [];
    _completedOrders = [];
    notifyListeners();
  }
}
