import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/order_provider.dart';
import 'services/local_data_service.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/transaction_history_screen.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run the app after binding is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Create a single instance of LocalDataService to share among providers
    final localDataService = LocalDataService();
    
    return MultiProvider( 
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProductProvider(localDataService),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => InventoryProvider(localDataService),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(localDataService),
        ),
        Provider<LocalDataService>.value(value: localDataService),
      ],
      child: MaterialApp(
        title: 'BrewCode POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.brown,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',        routes: {
          '/': (context) => const HomeScreen(),
          '/inventory': (context) => const InventoryScreen(),          '/transactions': (context) => const TransactionHistoryScreen(),
        },
      ),
    );
  }
}

