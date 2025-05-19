// lib/screens/transaction_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  static const routeName = '/transactions';

  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      
      // Load transaction data when screen initializes
      Provider.of<OrderProvider>(context, listen: false)
          .loadTransactions()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final transactions = orderProvider.transactions;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              
              await orderProvider.loadTransactions();
              
              setState(() {
                _isLoading = false;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text('No transactions found.'))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (ctx, index) {
                    return TransactionCard(transaction: transactions[index]);
                  },
                ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionRecord transaction;
  final DateFormat dateFormatter = DateFormat('MMM d, yyyy h:mm a');

  TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [                Text(
                  'Receipt: ${transaction.receiptNumber}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '₱${transaction.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: ${dateFormatter.format(transaction.date)}'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: transaction.transactionStatus == 'Completed'
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.transactionStatus,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Order ID: ${transaction.orderId}'),
            Text('Customer: ${transaction.customerName}'),
            Text('Staff: ${transaction.staffName}'),
            Text('Order Type: ${transaction.orderType}'),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text('Notes: ${transaction.notes}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // This would print a receipt in a real implementation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Printing receipt...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print Receipt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
