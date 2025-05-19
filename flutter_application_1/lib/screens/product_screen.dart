import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class ProductScreen extends StatefulWidget {
  final String customerName;
  final String orderType;

  const ProductScreen({
    super.key,
    required this.customerName,
    required this.orderType,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final products = productProvider.products;

    // Filter and group products by category
    final Map<String, List<Product>> categorized = {};
    for (var product in products) {
      if (product.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        categorized.putIfAbsent(product.category, () => []).add(product);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.orderType} • ${widget.customerName}'),
        backgroundColor: Colors.brown,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Text(
                'BrewCode POS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Track Orders'),
              onTap: () {
                Navigator.pushNamed(context, '/orderTracking');
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Back to Home'),
              onTap: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search item...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Schedule the setState for the next frame to avoid build-time state changes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      searchQuery = value;
                    });
                  }
                });
              },
            ),
          ),
          Expanded(
            child: categorized.isEmpty
                ? const Center(child: Text('No items found.'))
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: categorized.entries.map((entry) {
                      return _buildCategory(entry.key, entry.value, cartProvider);
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CartScreen(
                customerName: widget.customerName,
                orderType: widget.orderType,
              ),
            ),
          );
        },
        label: const Text('Your Order/s'),
        icon: const Icon(Icons.list_alt),
        backgroundColor: Colors.brown,
      ),
    );
  }

  Widget _buildCategory(String title, List<Product> items, CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[100],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  int quantity = 1;
                  showDialog(
                    context: context,
                    builder: (_) => StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text(item.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Price: ₱${item.price.toStringAsFixed(2)}'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      if (quantity > 1) {
                                        setState(() => quantity--);
                                      }
                                    },
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() => quantity++);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                              ),
                              child: const Text('Add to Order'),
                              onPressed: () {
                                cartProvider.addItem(item, quantity: quantity);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.name} x$quantity added to order'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name),
                    Text('₱${item.price.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
