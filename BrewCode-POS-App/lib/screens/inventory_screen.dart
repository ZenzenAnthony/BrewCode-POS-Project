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
  String _searchQuery = '';
  String _selectedCategory = 'All';  String _sortBy = 'name'; // 'name', 'category', or 'status'
  String? _selectedStatus; // For filtering by status

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
    }    super.didChangeDependencies();
  }

  void _filterByStatus(String status) {
    setState(() {
      _sortBy = 'status';
      _selectedCategory = 'All';
      _searchQuery = '';
      // Store selected status for filtering
      _selectedStatus = status;
    });
  }
  List<Inventory> _filterAndSortInventory(List<Inventory> items) {
    // Filter by search query
    var filteredItems = items.where((item) {
      final nameMatch = item.itemName.toLowerCase().contains(_searchQuery.toLowerCase());
      final categoryMatch = item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || categoryMatch;
    }).toList();

    // Filter by category
    if (_selectedCategory != 'All') {
      filteredItems = filteredItems.where((item) => item.category == _selectedCategory).toList();
    }

    // Filter by status if selected
    if (_selectedStatus != null) {
      filteredItems = filteredItems.where((item) {
        if (_selectedStatus == 'Available') {
          return item.status == 'Available' || item.status == 'In Stock';
        } else if (_selectedStatus == 'Not Available') {
          return item.status == 'Not Available' || item.status == 'Out of Stock';
        } else {
          return item.status == _selectedStatus;
        }
      }).toList();
    }

    // Sort items
    filteredItems.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.itemName.compareTo(b.itemName);
        case 'category':
          return a.category.compareTo(b.category);
        case 'status':
          return a.status.compareTo(b.status);
        default:
          return 0;
      }
    });

    return filteredItems;
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final allItems = inventoryProvider.inventoryItems;
    final filteredItems = _filterAndSortInventory(allItems);
    
    // Get unique categories
    final categories = ['All', ...{...allItems.map((item) => item.category)}.toList()..sort()];

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
          : Column(
              children: [                // Search and Filter Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.brown.shade50,
                  child: Column(
                    children: [
                      // Search Field
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search inventory...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Category Filter
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: categories.map((String category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Sort By Dropdown
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _sortBy,
                              decoration: const InputDecoration(
                                labelText: 'Sort by',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'name',
                                  child: Text('Name'),
                                ),
                                DropdownMenuItem(
                                  value: 'category',
                                  child: Text('Category'),
                                ),
                                DropdownMenuItem(
                                  value: 'status',
                                  child: Text('Status'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _sortBy = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),                ),                // Show current filter if any
                if (_selectedStatus != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Chip(
                          label: Text('Filtering by: $_selectedStatus', style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedStatus = null;
                              _sortBy = 'name';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                // Inventory Status Summary
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,children: [
                      _buildStatusCounter(
                        'Available',
                        filteredItems.where((item) => 
                            item.status == 'Available' || item.status == 'In Stock').length,
                        Colors.green,
                        () => _filterByStatus('Available'),
                      ),
                      _buildStatusCounter(
                        'Low Stock',
                        filteredItems.where((item) => item.status == 'Low Stock').length,
                        Colors.orange,
                        () => _filterByStatus('Low Stock'),
                      ),
                      _buildStatusCounter(
                        'Not Available',
                        filteredItems.where((item) => 
                            item.status == 'Not Available' || item.status == 'Out of Stock').length,
                        Colors.red,
                        () => _filterByStatus('Not Available'),
                      ),
                    ],
                  ),
                ),
                // Inventory Items List
                Expanded(
                  child: filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No items found.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (ctx, index) {
                            return InventoryItemCard(item: filteredItems[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
  Widget _buildStatusCounter(String status, int count, Color color, [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(50),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
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
      case 'In Stock':
        return Colors.green;
      case 'Not Available':
      case 'Out of Stock':
        return Colors.red;
      case 'Low Stock':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        item.category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
            if (item.unit != null) ...[
              const SizedBox(height: 8),
              Text('Unit: ${item.unit}'),
            ],
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Notes: ${item.notes}'),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [                ElevatedButton(
                  onPressed: (item.status == 'Available' || item.status == 'In Stock')
                      ? null
                      : () async {
                          final success = await inventoryProvider.updateInventoryStatus(
                              item.id, 'Available');
                          if (success) {
                            // Show feedback to user
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.itemName} status updated to Available'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (item.status == 'Available' || item.status == 'In Stock') 
                        ? Colors.green : Colors.green.withValues(alpha: 0.7),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    (item.status == 'Available' || item.status == 'In Stock') 
                        ? '✓ Available' : 'Available',
                    style: TextStyle(
                      fontWeight: (item.status == 'Available' || item.status == 'In Stock') 
                          ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),ElevatedButton(
                  onPressed: item.status == 'Low Stock'
                      ? null
                      : () async {
                          final success = await inventoryProvider.updateInventoryStatus(
                              item.id, 'Low Stock');
                          if (success) {
                            // Show feedback to user
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.itemName} status updated to Low Stock'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.status == 'Low Stock' ? Colors.orange : Colors.orange.withValues(alpha: 0.7),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    item.status == 'Low Stock' ? '✓ Low Stock' : 'Low Stock',
                    style: TextStyle(
                      fontWeight: item.status == 'Low Stock' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),                ElevatedButton(
                  onPressed: item.status == 'Not Available'
                      ? null
                      : () async {
                          final success = await inventoryProvider.updateInventoryStatus(
                              item.id, 'Not Available');
                          if (success) {
                            // Show feedback to user
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.itemName} status updated to Not Available'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update inventory status'),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.status == 'Not Available' ? Colors.red : Colors.red.withValues(alpha: 0.7),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    item.status == 'Not Available' ? '✓ Not Available' : 'Not Available',
                    style: TextStyle(
                      fontWeight: item.status == 'Not Available' ? FontWeight.bold : FontWeight.normal,
                    ),
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
