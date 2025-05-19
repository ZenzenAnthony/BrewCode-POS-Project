import 'package:flutter/material.dart';
import '../models/cart_item.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                'BrewCode POS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Receipt #: $receiptNumber',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Center(
              child: Text(
                'Date: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            Text('Customer: $customerName'),
            Text('Order Type: $orderType'),
            const Divider(height: 20, thickness: 1.5),
            const Text(
              'Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${item.product.name} x ${item.quantity} — ₱${(item.product.price * item.quantity).toStringAsFixed(2)}',
                ),
              ),
            ),
            const Divider(height: 20, thickness: 1.5),
            Text(
              'Total: ₱${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Paid: ₱${payment.toStringAsFixed(2)}'),
            Text(
              'Change: ₱${change.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Print Receipt'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Printing receipt...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // This replaces the whole navigation stack and returns to the home screen
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'New Order',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
