// lib/screens/transaction_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import 'edit_transaction_dialog.dart';

class TransactionHistoryScreen extends StatefulWidget {
  static const routeName = '/transactions';

  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Schedule the loading for after the initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<OrderProvider>(context, listen: false).loadTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Future<void> _editTransaction(Transaction transaction) async {
    // Show edit dialog
    final result = await showDialog<Transaction>(
      context: context,
      builder: (context) => EditTransactionDialog(transaction: transaction),
    );

    if (result != null && mounted) {
      // Update transaction in provider
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final success = await orderProvider.updateTransaction(result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Transaction updated successfully' : 'Failed to update transaction'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction', style: TextStyle(fontSize: 16)),
        content: Text(
          'Are you sure you want to delete this transaction?\n\n'
          'Receipt: ${transaction.receiptNumber ?? "N/A"}\n'
          'Customer: ${transaction.customerName ?? "N/A"}\n'
          'Amount: ₱${transaction.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );    if (confirmed == true && transaction.id != null && mounted) {
      // Delete transaction
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final success = await orderProvider.deleteTransaction(transaction.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Transaction deleted' : 'Failed to delete transaction'),
            backgroundColor: success ? Colors.red : Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final allTransactions = orderProvider.transactions;
    
    // Filter transactions based on search query
    final transactions = _searchQuery.isEmpty
        ? allTransactions
        : allTransactions.where((transaction) {
            return transaction.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
                   transaction.receiptNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
                   transaction.orderType?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
          }).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by customer, receipt #, or order type...',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Transaction List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty ? 'No transactions found.' : 'No matching transactions found.',
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (ctx, index) {
                          return TransactionCard(
                            transaction: transactions[index],
                            onEdit: () => _editTransaction(transactions[index]),
                            onDelete: () => _deleteTransaction(transactions[index]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final DateFormat dateFormatter = DateFormat('MMM d, yyyy h:mm a');

  TransactionCard({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Receipt: ${transaction.receiptNumber ?? "Pending"}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '₱${transaction.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Date: ${dateFormatter.format(transaction.orderDate)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: transaction.isCompleted ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    transaction.isCompleted ? 'Completed' : 'Pending',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Customer: ${transaction.customerName ?? "N/A"}',
              style: const TextStyle(fontSize: 10),
            ),            Text(
              'Order ID: ${transaction.id ?? "N/A"}',
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              'Order Type: ${transaction.orderType ?? "N/A"}',
              style: const TextStyle(fontSize: 10),
            ),            if (transaction.isCompleted) ...[
              Text(
                'Payment Method: Cash Only',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),              Text(
                'Total Amount: ₱${transaction.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
              if (transaction.amountReceived != null) ...[
                Text(
                  'Amount Received: ₱${transaction.amountReceived!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Change: ₱${(transaction.amountReceived! - transaction.totalAmount).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 10, color: Colors.blue),
                ),
              ],
            ],
            const SizedBox(height: 4),
            const Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
            ),
            ...transaction.items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} x${item.quantity}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Text(
                    '₱${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Edit', style: TextStyle(fontSize: 10)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                const SizedBox(width: 6),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 14),
                    label: const Text('Delete', style: TextStyle(fontSize: 10)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ],
        ),      ),
    );
  }
}
