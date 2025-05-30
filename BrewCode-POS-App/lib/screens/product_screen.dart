import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/inventory_provider.dart';
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
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Load products when screen initializes
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      _isInit = false;
    }
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, InventoryProvider>(
      builder: (context, productProvider, inventoryProvider, child) {
        if (productProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${widget.orderType} • ${widget.customerName}'),
              backgroundColor: Colors.brown,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (productProvider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${widget.orderType} • ${widget.customerName}'),
              backgroundColor: Colors.brown,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${productProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      productProvider.loadProducts();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final cartProvider = Provider.of<CartProvider>(context);
        final products = productProvider.products;
        final Map<String, List<Product>> categorized = {};
        for (var product in products) {
          if (product.name.toLowerCase().contains(searchQuery.toLowerCase())) {
            categorized.putIfAbsent(product.category, () => []).add(product);
          }
        }        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.orderType} • ${widget.customerName}'),
            backgroundColor: Colors.brown,
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.brown,
                  ),
                  child: Text(
                    'BrewCode POS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),                ),                ListTile(
                  leading: const Icon(Icons.inventory),
                  title: const Text('Inventory Management'),
                  onTap: () {
                    Navigator.pushNamed(context, '/inventory');
                  },
                ),
              ],
            ),
          ),          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search item...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        padding: const EdgeInsets.all(12.0),
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
      },
    );
  }
  Widget _buildCategory(String title, List<Product> items, CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 6),        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.isAvailable ? Colors.brown[100] : Colors.grey[300],
                  foregroundColor: item.isAvailable ? Colors.black : Colors.grey[600],
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: item.isAvailable ? () {
                  int quantity = 1;
                  showDialog(
                    context: context,
                    builder: (_) => StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text(item.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,                            children: [
                              Text('Price: ₱${item.price.toStringAsFixed(2)}'),
                              if (!item.isAvailable) 
                                const Text(
                                  'Currently Unavailable',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              if (item.isAvailable && item.hasLowStockIngredients)
                                const Text(
                                  '⚠️ Some ingredients are running low',
                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: item.isAvailable ? () {
                                      if (quantity > 1) {
                                        setState(() => quantity--);
                                      }
                                    } : null,
                                  ),                                  Text(
                                    quantity.toString(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: item.isAvailable ? () {
                                      setState(() => quantity++);
                                    } : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: item.isAvailable ? Colors.brown : Colors.grey,
                              ),                              onPressed: item.isAvailable ? () {
                                cartProvider.addItem(item, quantity: quantity);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.name} x$quantity added to order'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              } : null,
                              child: Text(item.isAvailable ? 'Add to Order' : 'Currently Unavailable'),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                } : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [                        // Availability indicator dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: !item.isAvailable 
                                ? Colors.red 
                                : item.hasLowStockIngredients 
                                    ? Colors.orange 
                                    : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.name,
                          style: TextStyle(
                            color: item.isAvailable ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₱${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: item.isAvailable ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
