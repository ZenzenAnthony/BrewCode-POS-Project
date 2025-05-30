import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/local_data_service.dart';

class ProductProvider with ChangeNotifier {
  final LocalDataService _localDataService;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;  ProductProvider(this._localDataService) {
    // Register for menu availability changes
    _localDataService.setMenuAvailabilityChangeCallback(() {
      refreshProductAvailability();
    });
  }

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> getProductsByCategory(int categoryId) {
    return _products.where((product) => product.categoryId == categoryId).toList();
  }
  Future<void> loadProducts() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    // Notify only if not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final menuItems = _localDataService.menuItems;
      _products = menuItems.map((item) => Product(
        id: item.id.toString(),  // Convert int to String
        name: item.name,
        price: item.price,
        category: _getCategoryName(item.categoryId),
        categoryId: item.categoryId,
        description: item.description ?? '',
        isAvailable: item.active && _localDataService.isMenuItemAvailable(item.id.toString()),
        hasLowStockIngredients: _localDataService.hasMenuItemLowStockIngredients(item.id.toString()),
      )).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Notify only if not in build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }  String _getCategoryName(int categoryId) {
    final categories = {
      1: 'Food',
      2: 'Drinks', 
      3: 'Rice Meals',
      4: 'Silog Meals',
      5: 'Snacks',
      6: 'Waffle Pizza',
      7: 'Pasta',
      8: 'Waffles',
      9: 'Sandwich',
      10: 'Kōhi Based',
      11: 'Floats',
      12: 'Icy Blends',
      13: 'Frappes',
      14: 'Add-ons',
      15: 'Milk Drink',
      16: 'Fruity Soda',
    };
    return categories[categoryId] ?? 'Other';
  }// Method to refresh product availability after inventory changes
  void refreshProductAvailability() {
    final menuItems = _localDataService.menuItems;
    
    _products = menuItems.map((item) => Product(
      id: item.id.toString(),
      name: item.name,
      price: item.price,
      category: _getCategoryName(item.categoryId),
      categoryId: item.categoryId,
      description: item.description ?? '',
      isAvailable: item.active && _localDataService.isMenuItemAvailable(item.id.toString()),
      hasLowStockIngredients: _localDataService.hasMenuItemLowStockIngredients(item.id.toString()),
    )).toList();
    
    notifyListeners();
  }
}