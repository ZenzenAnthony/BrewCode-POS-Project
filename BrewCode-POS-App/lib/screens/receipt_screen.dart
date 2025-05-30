import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';
import '../providers/order_provider.dart';
import 'package:intl/intl.dart';

class ReceiptScreen extends StatelessWidget {
  final String customerName;
  final String orderType;
  final double total;
  final double payment;
  final double change;
  final List<CartItem> items;
  final String receiptNumber;

  ReceiptScreen({
    super.key,
    required this.customerName,
    required this.orderType,
    required this.total,
    required this.payment,
    required this.change,
    required this.items,
  }) : receiptNumber = _generateReceiptNumber(customerName);

  // Generate a receipt number using the current timestamp and customer initials
  static String _generateReceiptNumber(String customerName) {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyyMMdd-HHmmss');
    final timestamp = dateFormat.format(now);
    
    // Get customer initials (first letter of each word)
    final nameWords = customerName.split(' ');
    String initials = '';
    for (var word in nameWords) {
      if (word.isNotEmpty) {
        initials += word[0].toUpperCase();
      }
    }
    
    return '$timestamp-$initials';
  }
  // Save transaction to history and start new order
  Future<void> _saveTransactionAndStartNewOrder(BuildContext context) async {
    try {
      // Create transaction items from cart items
      final transactionItems = items.map((cartItem) => TransactionItem(
        productId: int.tryParse(cartItem.product.id) ?? 0,
        productName: cartItem.product.name,
        quantity: cartItem.quantity,
        unitPrice: cartItem.product.price,
      )).toList();      // Create transaction object
      final transaction = Transaction(
        orderDate: DateTime.now(),
        totalAmount: total,
        paymentMethod: 'Cash', // Default to cash, could be passed as parameter
        items: transactionItems,
        isCompleted: true,
        receiptNumber: receiptNumber,
        customerName: customerName,
        orderType: orderType,
        total: total,
        amountReceived: payment,
      );

      // Save to transaction history
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final success = await orderProvider.createOrder(transaction);

      if (success) {
        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction saved to history'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to home for new order
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save transaction'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: Colors.brown,
      ),      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            const Center(
              child: Text(
                'BrewCode POS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Thank you for your purchase!',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            
            // Receipt Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReceiptRow('Receipt #:', receiptNumber),
                  _buildReceiptRow('Date:', DateFormat('MMM dd, yyyy').format(now)),
                  _buildReceiptRow('Time:', DateFormat('hh:mm a').format(now)),
                  _buildReceiptRow('Customer:', customerName),
                  _buildReceiptRow('Order Type:', orderType),
                ],
              ),
            ),            const SizedBox(height: 16),
            
            // Items
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.brown.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(),                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} x ${item.quantity}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            '₱${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  _buildTotalRow('Subtotal:', total),
                  _buildTotalRow('Amount Paid:', payment),
                  _buildTotalRow('Change:', change, bold: true),
                ],
              ),
            ),            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveTransactionAndStartNewOrder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 48),
              ),              child: const Text(
                'Order Complete',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            '₱${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
