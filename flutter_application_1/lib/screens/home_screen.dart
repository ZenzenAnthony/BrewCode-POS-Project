import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _navigateToProducts(String orderType) {
    final customerName = _nameController.text.trim();
    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the customer's name")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductScreen(
          customerName: customerName,
          orderType: orderType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('BrewCode POS'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory),
            tooltip: 'Inventory Management',
            onPressed: () {
              Navigator.pushNamed(context, '/inventory');
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Transaction History',
            onPressed: () {
              Navigator.pushNamed(context, '/transactions');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Order Tracking',
            onPressed: () {
              Navigator.pushNamed(context, '/orderTracking');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SvgPicture.asset(
              'assets/logo.svg',
              height: 140,
            ),
            const SizedBox(height: 32),

            // Brand Name
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),

            // Customer Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Dine-In & Take-Out Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToProducts('Dine-In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Dine-In',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToProducts('Take-Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Take-Out',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
