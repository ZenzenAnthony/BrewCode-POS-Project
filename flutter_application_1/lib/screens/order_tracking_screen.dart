import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final pendingOrders = orderProvider.pendingOrders;
    final completedOrders = orderProvider.completedOrders;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending Orders'),
            Tab(text: 'Completed Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Orders Tab
          pendingOrders.isEmpty
              ? const Center(child: Text('No pending orders.'))
              : ListView.builder(
                  itemCount: pendingOrders.length,
                  itemBuilder: (ctx, index) {
                    return OrderCard(
                      order: pendingOrders[index],
                      isPending: true,
                    );
                  },
                ),
                
          // Completed Orders Tab
          completedOrders.isEmpty
              ? const Center(child: Text('No completed orders.'))
              : ListView.builder(
                  itemCount: completedOrders.length,
                  itemBuilder: (ctx, index) {
                    return OrderCard(
                      order: completedOrders[index],
                      isPending: false,
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isPending;
  final DateFormat dateFormatter = DateFormat('MMM d, yyyy h:mm a');

  OrderCard({
    super.key,
    required this.order,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
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
              children: [
                Text(
                  'Order #${order.id}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '₱${order.totalAmount.toStringAsFixed(2)}',
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
                Text('Date: ${dateFormatter.format(order.orderDate)}'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.orderStatus == 'Pending'
                        ? Colors.orange
                        : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.orderStatus,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Customer: ${order.customerId ?? "Walk-in"}'),
            Text('Staff: ${order.staffId}'),
            Text('Type: ${order.orderType}'),
            const SizedBox(height: 8),
            Text('Items: ${order.items.length}'),
            const SizedBox(height: 16),
            if (isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Show dialog to enter customer initials
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
                              if (value.isNotEmpty) {
                                Navigator.of(ctx).pop();
                                // Check if order.id is not null before using it
                                if (order.id != null) {
                                  await orderProvider.completeOrder(
                                    order.id!,
                                    value,
                                  );
                                  
                                  // Show success message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Order completed successfully'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Complete order with default initials
                                Navigator.of(ctx).pop();
                                if (order.id != null) {
                                  orderProvider.completeOrder(
                                    order.id!,
                                    'CUST',
                                  );
                                  
                                  // Show success message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Order completed successfully'),
                                        duration: Duration(seconds: 2),
                                      ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
