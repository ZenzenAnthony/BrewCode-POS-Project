import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/receipt_screen.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  final String customerName;
  final String orderType;

  const CartScreen({
    super.key,
    required this.customerName,
    required this.orderType,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _paymentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _confirmPayment(double total) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payment = double.tryParse(_paymentController.text);
    if (payment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid payment amount.')),
      );
      return;
    }

    if (payment < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient payment. Please enter at least ₱${total.toStringAsFixed(2)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final change = payment - total;
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Add some items first.')),
      );
      return;
    }

    final itemsSnapshot = List<CartItem>.from(cart.items.values);
    
    // Clear the cart after payment is confirmed
    cart.placeOrder();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          customerName: widget.customerName,
          orderType: widget.orderType,
          total: total,
          payment: payment,
          change: change,
          items: itemsSnapshot,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final total = cart.totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order/s'),
        backgroundColor: Colors.brown,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${widget.orderType} • ${widget.customerName}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text(
                      'Your list is empty.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items.values.elementAt(i);
                      return Dismissible(
                        key: ValueKey(item.product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          cart.removeItem(item.product.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.product.name} removed from cart'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () {
                                  cart.addItem(item.product, quantity: item.quantity);
                                },
                              ),
                            ),
                          );
                        },                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            dense: true,
                            title: Text(
                              item.product.name,
                              style: const TextStyle(fontSize: 14),
                            ),                            subtitle: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () {
                                    cart.decreaseQuantity(item.product.id);
                                  },
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontSize: 14)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () {
                                    cart.increaseQuantity(item.product.id);
                                  },
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₱${item.product.price.toStringAsFixed(2)} each',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '₱${(item.product.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              border: const Border(top: BorderSide(color: Colors.brown)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total: ₱${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _paymentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),                    decoration: const InputDecoration(
                      labelText: 'Amount Paid',
                      border: OutlineInputBorder(),
                      prefixText: '₱',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the payment amount';
                      }
                      final payment = double.tryParse(value);
                      if (payment == null) {
                        return 'Please enter a valid amount';
                      }
                      if (payment < total) {
                        return 'Payment must be at least ₱${total.toStringAsFixed(2)}';
                      }
                      return null;
                    },
                  ),                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: cart.items.isEmpty ? null : () => _confirmPayment(total),                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    child: const Text(
                      'Confirm Payment',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
