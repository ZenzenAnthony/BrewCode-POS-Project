import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/order_provider.dart';

class OrderCard extends StatelessWidget {
  final Transaction transaction;
  final bool isPending;
  final DateFormat dateFormatter = DateFormat('MMM d, yyyy h:mm a');

  OrderCard({
    super.key,
    required this.transaction,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order ID & Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${transaction.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '₱${transaction.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            // Date & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Date: ${dateFormatter.format(transaction.orderDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: transaction.isCompleted ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.isCompleted ? 'Completed' : 'Pending',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Items:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ...transaction.items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} x${item.quantity}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Text(
                    '₱${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            if (isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Complete Order'),
                          content: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Customer Initials',
                              hintText: 'Enter customer initials for receipt',
                            ),
                            onFieldSubmitted: (value) async {
                              if (value.isNotEmpty && transaction.id != null) {
                                Navigator.of(ctx).pop();
                                await orderProvider.completeOrder(transaction.id.toString());
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Order completed successfully')),
                                  );
                                }
                              }
                            },
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () async {
                                Navigator.of(ctx).pop();
                                if (transaction.id != null) {
                                  await orderProvider.completeOrder(transaction.id.toString());
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order completed successfully')),
                                    );
                                  }
                                }
                              },
                              child: const Text('Complete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Complete Order'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
