// lib/screens/edit_transaction_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'package:intl/intl.dart';

class EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionDialog({super.key, required this.transaction});

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  late TextEditingController _customerNameController;
  late TextEditingController _amountReceivedController;
  late String _selectedOrderType;
  late List<TransactionItem> _items;
  late double _totalAmount;
  
  final List<String> _orderTypes = ['Dine-In', 'Take-Out'];

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: widget.transaction.customerName ?? '');
    _selectedOrderType = widget.transaction.orderType ?? 'Dine-In';
    _items = List.from(widget.transaction.items);
    _totalAmount = widget.transaction.totalAmount;
    _amountReceivedController = TextEditingController(
      text: widget.transaction.amountReceived?.toStringAsFixed(2) ?? '',
    );
    
    // Load products for adding new items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _amountReceivedController.dispose();
    super.dispose();
  }

  void _updateTotalAmount() {
    setState(() {
      _totalAmount = _items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
    });
  }

  void _editItem(int index) {
    final item = _items[index];
    int quantity = item.quantity;
    double price = item.unitPrice;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${item.productName}', style: const TextStyle(fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(fontSize: 12),
                  prefixText: '₱',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
                controller: TextEditingController(text: price.toStringAsFixed(2)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  price = double.tryParse(value) ?? price;
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: quantity > 1 ? () {
                      setDialogState(() => quantity--);
                    } : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () {
                      setDialogState(() => quantity++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Subtotal: ₱${(quantity * price).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteItemConfirmation(index);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _items[index] = TransactionItem(
                    productId: item.productId,
                    productName: item.productName,
                    quantity: quantity,
                    unitPrice: price,
                  );
                });
                _updateTotalAmount();
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteItemConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item', style: TextStyle(fontSize: 14)),
        content: Text(
          'Are you sure you want to remove "${_items[index].productName}" from this transaction?',
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
              _updateTotalAmount();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _addNewItem() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final products = productProvider.products.where((p) => p.isAvailable).toList();

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No products available to add')),
      );
      return;
    }

    Product? selectedProduct;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Item', style: TextStyle(fontSize: 14)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Product>(
                  decoration: const InputDecoration(
                    labelText: 'Select Product',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    isDense: true,
                  ),
                  items: products.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text(
                        '${product.name} - ₱${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (product) {
                    setDialogState(() {
                      selectedProduct = product;
                    });
                  },
                ),
                if (selectedProduct != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        onPressed: quantity > 1 ? () {
                          setDialogState(() => quantity--);
                        } : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () {
                          setDialogState(() => quantity++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Subtotal: ₱${(quantity * selectedProduct!.price).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: selectedProduct != null ? () {
                setState(() {
                  _items.add(TransactionItem(
                    productId: int.tryParse(selectedProduct!.id) ?? 0,
                    productName: selectedProduct!.name,
                    quantity: quantity,
                    unitPrice: selectedProduct!.price,
                  ));
                });
                _updateTotalAmount();
                Navigator.pop(context);
              } : null,
              child: const Text('Add', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Transaction', style: TextStyle(fontSize: 16)),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Customer and Order Type
              TextField(
                controller: _customerNameController,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  labelStyle: TextStyle(fontSize: 12),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedOrderType,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Order Type',
                  labelStyle: TextStyle(fontSize: 12),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  isDense: true,
                ),
                items: _orderTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedOrderType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              
              // Amount Received
              TextField(
                controller: _amountReceivedController,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'Amount Received',
                  labelStyle: TextStyle(fontSize: 12),
                  prefixText: '₱',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              
              // Items Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Items:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addNewItem,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Item', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Items List
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _items.isEmpty 
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No items in transaction', style: TextStyle(fontSize: 12)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            item.productName,
                            style: const TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            'Qty: ${item.quantity} × ₱${item.unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₱${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 16),
                                onPressed: () => _editItem(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
              const SizedBox(height: 12),
              
              // Transaction Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt: ${widget.transaction.receiptNumber ?? "N/A"}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      'Date: ${DateFormat('MMM d, yyyy h:mm a').format(widget.transaction.orderDate)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('₱${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (_amountReceivedController.text.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Received:', style: TextStyle(fontSize: 10)),
                          Text('₱${_amountReceivedController.text}', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                      if (double.tryParse(_amountReceivedController.text) != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Change:', style: TextStyle(fontSize: 10)),
                            Text(
                              '₱${(double.parse(_amountReceivedController.text) - _totalAmount).toStringAsFixed(2)}', 
                              style: const TextStyle(fontSize: 10, color: Colors.blue),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontSize: 12)),
        ),
        ElevatedButton(
          onPressed: () {
            final amountReceived = double.tryParse(_amountReceivedController.text);
            
            // Create updated transaction
            final updatedTransaction = widget.transaction.copyWith(
              customerName: _customerNameController.text.trim(),
              orderType: _selectedOrderType,
              paymentMethod: 'Cash',
              items: _items,
              totalAmount: _totalAmount,
              amountPaid: amountReceived,
            );
            
            Navigator.of(context).pop(updatedTransaction);
          },
          child: const Text('Save', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
