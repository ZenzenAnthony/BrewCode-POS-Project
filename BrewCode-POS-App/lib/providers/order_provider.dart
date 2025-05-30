// lib/providers/order_provider.dart

import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/order.dart';
import '../services/local_data_service.dart';

class OrderProvider with ChangeNotifier {
  final LocalDataService _localDataService;
  List<Transaction> _orders = [];
  List<Transaction> _transactions = [];

  OrderProvider(this._localDataService);

  List<Transaction> get orders => [..._orders];
  List<Transaction> get transactions => [..._transactions];
  
  List<Transaction> get pendingOrders => 
    _orders.where((order) => !order.isCompleted).toList();
  
  List<Transaction> get completedOrders => 
    _orders.where((order) => order.isCompleted).toList();
  // Fetch orders from local data service
  Future<void> fetchOrders() async {
    try {
      // Get orders from local data service and convert to transactions
      final orders = _localDataService.orders;
      _orders = orders.map((order) => _convertOrderToTransaction(order)).toList();
      // Notify only if not in build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  // Helper method to convert Order to Transaction
  Transaction _convertOrderToTransaction(Order order) {
    return Transaction(
      id: order.id != null ? int.tryParse(order.id!) : null,
      orderDate: order.orderDate,
      totalAmount: order.totalAmount,
      items: [], // Would need to convert CartItems to TransactionItems if needed
      isCompleted: order.orderStatus == 'Completed',
      customerName: order.customerId,
      orderType: order.orderType,
    );
  }
  // Create a new order using local data service
  Future<bool> createOrder(Transaction transaction) async {
    try {
      // Add to local data service
      final updatedTransaction = transaction.copyWith(id: DateTime.now().millisecondsSinceEpoch);
      _localDataService.addOrder(updatedTransaction);
      _orders.add(updatedTransaction);
      // Notify only if not in build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      
      return true;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return false;
    }
  }
  
  // Alias for updateOrderStatus
  Future<bool> completeOrder(String orderId) async {
    return updateOrderStatus(orderId, true);
  }
    // Update order status using local data service
  Future<bool> updateOrderStatus(String orderId, bool isCompleted) async {
    try {
      // Update local state
      final index = _orders.indexWhere((order) => order.id?.toString() == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(isCompleted: isCompleted);
        // Notify only if not in build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  // Add payment to an order
  Future<bool> addPayment(String orderId, double amountPaid, String paymentMethod) async {
    try {
      // Update local state
      final index = _orders.indexWhere((order) => order.id?.toString() == orderId);
      if (index >= 0) {        _orders[index] = _orders[index].copyWith(
          isCompleted: true,
          paymentMethod: paymentMethod
        );
        // Notify only if not in build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error adding payment: $e');
      return false;
    }
  }
  
  // Alias for fetchTransactionHistory
  Future<void> loadTransactions() async {
    return fetchTransactionHistory();
  }
  // Get transaction history from local data service
  Future<void> fetchTransactionHistory() async {
    try {
      // Get transactions from local data service
      _transactions = _localDataService.transactions;
      // Notify only if not in build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
    }
  }

  // Update an existing transaction
  Future<bool> updateTransaction(Transaction updatedTransaction) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
      if (index >= 0) {
        _transactions[index] = updatedTransaction;
        // Update in local data service
        _localDataService.updateTransaction(updatedTransaction);
        
        // Notify only if not in build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  // Delete a transaction
  Future<bool> deleteTransaction(int transactionId) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index >= 0) {
        _transactions.removeAt(index);
        // Delete from local data service
        _localDataService.deleteTransaction(transactionId);
        
        // Notify only if not in build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }
}
