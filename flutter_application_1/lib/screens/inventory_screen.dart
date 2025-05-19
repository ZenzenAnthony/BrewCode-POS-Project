// lib/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory.dart';

class InventoryScreen extends StatefulWidget {
  static const routeName = '/inventory';

  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      
      // Load inventory data when screen initializes
      Provider.of<InventoryProvider>(context, listen: false)
          .loadInventory()
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
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final inventoryItems = inventoryProvider.inventoryItems;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              
              await inventoryProvider.loadInventory();
              
              setState(() {
                _isLoading = false;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : inventoryItems.isEmpty
              ? const Center(child: Text('No inventory items found.'))
              : ListView.builder(
                  itemCount: inventoryItems.length,
                  itemBuilder: (ctx, index) {
                    return InventoryItemCard(item: inventoryItems[index]);
                  },
                ),
    );
  }
}

class InventoryItemCard extends StatelessWidget {
  final Inventory item;

  const InventoryItemCard({
    super.key,
    required this.item,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Not Available':
        return Colors.red;
      case 'Low Stock':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

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
              children: [                Expanded(
                  child: Text(
                    item.itemName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.unit != null) Text('Unit: ${item.unit}'),
            if (item.notes != null && item.notes!.isNotEmpty)
              Text('Notes: ${item.notes}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: item.status == 'Available'
                      ? null
                      : () async {
                          await inventoryProvider.updateInventoryStatus(
                              item.id, 'Available');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Available'),
                ),
                ElevatedButton(
                  onPressed: item.status == 'Low Stock'
                      ? null
                      : () async {
                          await inventoryProvider.updateInventoryStatus(
                              item.id, 'Low Stock');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Low Stock'),
                ),
                ElevatedButton(
                  onPressed: item.status == 'Not Available'
                      ? null
                      : () async {
                          await inventoryProvider.updateInventoryStatus(
                              item.id, 'Not Available');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Not Available'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
