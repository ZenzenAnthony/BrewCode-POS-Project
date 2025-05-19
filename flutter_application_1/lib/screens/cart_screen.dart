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

  void _confirmPayment(double total) {
    final payment = double.tryParse(_paymentController.text);
    if (payment == null || payment < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or insufficient payment.')),
      );
      return;
    }

    final change = payment - total;
    final cart = Provider.of<CartProvider>(context, listen: false);
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final item = cart.items.values.elementAt(i);
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(item.product.name),
                          subtitle: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  cart.decreaseQuantity(item.product.id);
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  cart.increaseQuantity(item.product.id);
                                },
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '₱${item.product.price.toStringAsFixed(2)} each',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '₱${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              border: const Border(top: BorderSide(color: Colors.brown)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: ₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _paymentController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount Paid',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _confirmPayment(total),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Confirm Payment',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
