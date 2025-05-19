// lib/providers/product_provider.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/database_service_placeholder.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseServicePlaceholder _databaseService = DatabaseServicePlaceholder();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  ProductProvider() {
    // Load the mock data on initialization - in the future, this will use the database service
    _loadMockProducts();
  }

  // Getters
  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Get all categories
  List<String> get categories {
    final Set<String> categoriesSet = _products.map((product) => product.category).toSet();
    return categoriesSet.toList();
  }

  // Prepare for real database integration later
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use the database service placeholder to simulate a future API call
      final futureProducts = await _databaseService.getProducts();
      
      // If we get empty results from the service (which we will for now),
      // we'll continue using our mock data
      if (futureProducts.isNotEmpty) {
        _products = futureProducts;
      }
      
      notifyListeners();
    } catch (error) {
      _error = 'Failed to fetch products: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mock data loader - this will eventually be replaced with database calls
  void _loadMockProducts() {
    _products = [
      // Rice Meal
      Product(id: '1', name: 'Teriyaki Chicken', price: 139.0, category: 'Rice Meal'),
      Product(id: '2', name: 'Sweet Chilli Chicken', price: 139.0, category: 'Rice Meal'),
      Product(id: '3', name: 'Barbecue Chicken', price: 139.0, category: 'Rice Meal'),
      Product(id: '4', name: 'Soy Garlic Chicken', price: 139.0, category: 'Rice Meal'),
      Product(id: '5', name: 'Buttered Chicken', price: 125.0, category: 'Rice Meal'),
      Product(id: '6', name: 'Parmesan Chicken', price: 125.0, category: 'Rice Meal'),
      Product(id: '7', name: 'Lemon Chicken', price: 125.0, category: 'Rice Meal'),
      Product(id: '8', name: 'Buffalo Chicken', price: 125.0, category: 'Rice Meal'),
      Product(id: '9', name: 'Honey Glazed Chicken', price: 125.0, category: 'Rice Meal'),
      Product(id: '10', name: 'Garlic Beef Mushroom', price: 149.0, category: 'Rice Meal'),
      Product(id: '11', name: 'Burger Steak', price: 149.0, category: 'Rice Meal'),

      // Silog Meals
      Product(id: '12', name: 'Cornsilog', price: 80.0, category: 'Silog Meals'),
      Product(id: '13', name: 'Hamsilog', price: 80.0, category: 'Silog Meals'),
      Product(id: '14', name: 'Hotsilog', price: 80.0, category: 'Silog Meals'),
      Product(id: '15', name: 'Chosilog', price: 80.0, category: 'Silog Meals'),
      Product(id: '16', name: 'Tocilog', price: 80.0, category: 'Silog Meals'),
      Product(id: '17', name: 'Spamsilog', price: 110.0, category: 'Silog Meals'),
      Product(id: '18', name: 'Bacsilog', price: 110.0, category: 'Silog Meals'),

      // Snacks
      Product(id: '19', name: 'Club Sandwich', price: 145.0, category: 'Snacks'),
      Product(id: '20', name: 'Cheeseburger', price: 130.0, category: 'Snacks'),
      Product(id: '21', name: 'Nacho Overload', price: 150.0, category: 'Snacks'),
      Product(id: '22', name: 'Fries', price: 60.0, category: 'Snacks'),
      Product(id: '23', name: 'Meaty Fries', price: 110.0, category: 'Snacks'),

      // Waffle Pizza
      Product(id: '24', name: 'Meat Loaded', price: 199.0, category: 'Waffle Pizza'),
      Product(id: '25', name: 'Ham + Cheese Pizza', price: 159.0, category: 'Waffle Pizza'),
      Product(id: '26', name: 'Hawaiian Pizza', price: 169.0, category: 'Waffle Pizza'),

      // Waffles
      Product(id: '27', name: 'Strawberry Waffle', price: 75.0, category: 'Waffles'),
      Product(id: '28', name: 'Blueberry Waffle', price: 75.0, category: 'Waffles'),
      Product(id: '29', name: 'Mango Waffle', price: 80.0, category: 'Waffles'),
      Product(id: '30', name: 'Drizzled Chocochips', price: 75.0, category: 'Waffles'),
      Product(id: '31', name: 'Chocomallows', price: 80.0, category: 'Waffles'),
      Product(id: '32', name: 'Nutella Waffle', price: 90.0, category: 'Waffles'),
      Product(id: '33', name: 'Oreo Nutella Waffle', price: 100.0, category: 'Waffles'),
      Product(id: '34', name: 'Egg + Cheese Sandwich', price: 145.0, category: 'Waffles'),
      Product(id: '35', name: 'Ham + Cheese Sandwich', price: 145.0, category: 'Waffles'),

      // Pasta
      Product(id: '36', name: 'Carbonara', price: 125.0, category: 'Pasta'),
      Product(id: '37', name: 'Bolognese', price: 125.0, category: 'Pasta'),
      Product(id: '38', name: 'Sweet & Spicy Pasta', price: 125.0, category: 'Pasta'),
      Product(id: '39', name: 'Truffle Carbonara', price: 145.0, category: 'Pasta'),
      Product(id: '40', name: 'Mushroom Truffle', price: 145.0, category: 'Pasta'),
      Product(id: '41', name: 'Aglio Olio', price: 145.0, category: 'Pasta'),
      Product(id: '42', name: 'Garlic Mushroom', price: 125.0, category: 'Pasta'),

      // Sandwich
      Product(id: '43', name: 'Cheese Sandwich', price: 55.0, category: 'Sandwich'),
      Product(id: '44', name: 'Egg & Cheese Sandwich', price: 80.0, category: 'Sandwich'),
      Product(id: '45', name: 'Ham & Cheese Sandwich', price: 80.0, category: 'Sandwich'),
      
      // Coffee Based
      Product(id: '46', name: 'Americano', price: 95.0, category: 'Kōhi Based'),
      Product(id: '47', name: 'Latte', price: 105.0, category: 'Kōhi Based'),
      Product(id: '48', name: 'Cappuccino', price: 105.0, category: 'Kōhi Based'),
      Product(id: '49', name: 'Spanish Latte', price: 115.0, category: 'Kōhi Based'),
      Product(id: '50', name: 'Caramel Latte', price: 115.0, category: 'Kōhi Based'),
      Product(id: '51', name: 'Matcha Latte', price: 115.0, category: 'Kōhi Based'),
      Product(id: '52', name: 'Vanilla Latte', price: 115.0, category: 'Kōhi Based'),
      Product(id: '53', name: 'Mocha', price: 115.0, category: 'Kōhi Based'),
      Product(id: '54', name: 'White Mocha', price: 130.0, category: 'Kōhi Based'),
      Product(id: '55', name: 'Double White Mocha', price: 140.0, category: 'Kōhi Based'),
      Product(id: '56', name: 'Brewed Coffee (Solo)', price: 85.0, category: 'Kōhi Based'),
      Product(id: '57', name: 'Brewed Coffee (Unlimited)', price: 145.0, category: 'Kōhi Based'),
    ];
  }
}
