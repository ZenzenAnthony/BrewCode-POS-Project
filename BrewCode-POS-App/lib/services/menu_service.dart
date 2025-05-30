import '../models/menu_item.dart';

class MenuService {
  // Singleton pattern
  static final MenuService _instance = MenuService._internal();
  factory MenuService() => _instance;
  MenuService._internal();

  // Complete menu items data from CSV menu_items_updated.csv (92 items)
  final List<MenuItem> _menuItems = [
    MenuItem(id: 1, name: 'Teriyaki Chicken', categoryId: 3, price: 139.00, description: 'Chicken with teriyaki sauce served with rice', active: true),
    MenuItem(id: 2, name: 'Sweet Chilli Chicken', categoryId: 3, price: 139.00, description: 'Chicken with sweet chilli sauce served with rice', active: true),
    MenuItem(id: 3, name: 'Barbecue Chicken', categoryId: 3, price: 139.00, description: 'Chicken with barbecue sauce served with rice', active: true),
    MenuItem(id: 4, name: 'Soy Garlic Chicken', categoryId: 3, price: 139.00, description: 'Chicken with soy garlic sauce served with rice', active: true),
    MenuItem(id: 5, name: 'Buttered Chicken', categoryId: 3, price: 125.00, description: 'Chicken in butter sauce served with rice', active: true),
    MenuItem(id: 6, name: 'Parmesan Chicken', categoryId: 3, price: 125.00, description: 'Chicken with parmesan served with rice', active: true),
    MenuItem(id: 7, name: 'Lemon Chicken', categoryId: 3, price: 125.00, description: 'Chicken with lemon sauce served with rice', active: true),
    MenuItem(id: 8, name: 'Buffalo Chicken', categoryId: 3, price: 125.00, description: 'Chicken with buffalo sauce served with rice', active: true),
    MenuItem(id: 9, name: 'Honey Glazed Chicken', categoryId: 3, price: 125.00, description: 'Chicken with honey glaze served with rice', active: true),
    MenuItem(id: 10, name: 'Garlic Beef Mushroom', categoryId: 3, price: 149.00, description: 'Beef and mushroom with garlic sauce served with rice', active: true),
    MenuItem(id: 11, name: 'Burger Steak', categoryId: 3, price: 149.00, description: 'Beef patty with gravy served with rice', active: true),
    MenuItem(id: 12, name: 'Cornsilog', categoryId: 4, price: 80.00, description: 'Corned beef with sinangag (fried rice) and itlog (egg)', active: true),
    MenuItem(id: 13, name: 'Hamsilog', categoryId: 4, price: 80.00, description: 'Ham with sinangag (fried rice) and itlog (egg)', active: true),
    MenuItem(id: 14, name: 'Hotsilog', categoryId: 4, price: 80.00, description: 'Hotdog with sinangag (fried rice) and itlog (egg)', active: true),
    MenuItem(id: 15, name: 'Chosilog', categoryId: 4, price: 80.00, description: 'Chorizo with sinangag (fried rice) and itlog (egg)', active: true),
    MenuItem(id: 16, name: 'Tocilog', categoryId: 4, price: 80.00, description: 'Tocino with sinangag (fried rice) and itlog (egg)', active: true),
    MenuItem(id: 17, name: 'Spamsilog', categoryId: 4, price: 110.00, description: 'Spam with sinangag (fried rice) and itlog (egg)', active: true),
    MenuItem(id: 18, name: 'Bacsilog', categoryId: 4, price: 110.00, description: 'Bacon with sinangag (fried rice) and itlog (egg)', active: true),    MenuItem(id: 19, name: 'Club Sandwich', categoryId: 9, price: 145.00, description: 'Triple-decker sandwich with chicken, bacon, lettuce, tomato', active: true),
    MenuItem(id: 20, name: 'Cheeseburger', categoryId: 9, price: 130.00, description: 'Beef patty with cheese in a bun', active: true),
    MenuItem(id: 21, name: 'Nacho Overload', categoryId: 5, price: 150.00, description: 'Tortilla chips loaded with toppings', active: true),
    MenuItem(id: 22, name: 'Fries', categoryId: 5, price: 60.00, description: 'Crispy potato fries', active: true),
    MenuItem(id: 23, name: 'Meaty Fries', categoryId: 5, price: 110.00, description: 'Potato fries topped with meat', active: true),
    MenuItem(id: 24, name: 'Meat Loaded Waffle Pizza', categoryId: 6, price: 199.00, description: 'Waffle base pizza loaded with meat toppings', active: true),
    MenuItem(id: 25, name: 'Ham + Cheese Waffle Pizza', categoryId: 6, price: 159.00, description: 'Waffle base pizza with ham and cheese', active: true),
    MenuItem(id: 26, name: 'Hawaiian Waffle Pizza', categoryId: 6, price: 169.00, description: 'Waffle base pizza with ham and pineapple', active: true),
    MenuItem(id: 27, name: 'Carbonara Solo', categoryId: 7, price: 99.00, description: 'Creamy pasta with bacon bits - solo serving', active: true),
    MenuItem(id: 28, name: 'Carbonara Sharing', categoryId: 7, price: 230.00, description: 'Creamy pasta with bacon bits - sharing size', active: true),
    MenuItem(id: 29, name: 'Strawberry Waffle', categoryId: 8, price: 75.00, description: 'Waffle topped with strawberry', active: true),
    MenuItem(id: 30, name: 'Blueberry Waffle', categoryId: 8, price: 75.00, description: 'Waffle topped with blueberry', active: true),
    MenuItem(id: 31, name: 'Mango Waffle', categoryId: 8, price: 80.00, description: 'Waffle topped with mango', active: true),
    MenuItem(id: 32, name: 'Drizzled Chocochips Waffle', categoryId: 8, price: 75.00, description: 'Waffle with chocolate drizzle and chocochips', active: true),
    MenuItem(id: 33, name: 'Chocomallows Waffle', categoryId: 8, price: 80.00, description: 'Waffle with chocolate and marshmallows', active: true),
    MenuItem(id: 34, name: 'Nutella Waffle', categoryId: 8, price: 90.00, description: 'Waffle topped with Nutella spread', active: true),
    MenuItem(id: 35, name: 'Oreo Nutella Waffle', categoryId: 8, price: 100.00, description: 'Waffle topped with Nutella and Oreo crumbs', active: true),
    MenuItem(id: 36, name: 'Egg + Cheese Sandwich', categoryId: 9, price: 145.00, description: 'Sandwich with egg and cheese', active: true),
    MenuItem(id: 37, name: 'Ham + Cheese Sandwich', categoryId: 9, price: 145.00, description: 'Sandwich with ham and cheese', active: true),
    MenuItem(id: 38, name: 'Ham + Egg Sandwich', categoryId: 9, price: 150.00, description: 'Sandwich with ham and egg', active: true),
    MenuItem(id: 39, name: 'Hot Kōhi', categoryId: 10, price: 90.00, description: 'Hot brewed signature coffee', active: true),
    MenuItem(id: 40, name: 'Cold Kōhi', categoryId: 10, price: 110.00, description: 'Cold brewed signature coffee', active: true),
    MenuItem(id: 41, name: 'Hot Americano', categoryId: 10, price: 55.00, description: 'Hot espresso diluted with water', active: true),
    MenuItem(id: 42, name: 'Cold Americano', categoryId: 10, price: 80.00, description: 'Cold espresso diluted with water', active: true),
    MenuItem(id: 43, name: 'Hot Kōhi Latte', categoryId: 10, price: 75.00, description: 'Hot coffee with steamed milk', active: true),
    MenuItem(id: 44, name: 'Cold Kōhi Latte', categoryId: 10, price: 90.00, description: 'Cold coffee with milk', active: true),
    MenuItem(id: 45, name: 'Hot Cappuccino', categoryId: 10, price: 80.00, description: 'Hot coffee with steamed milk and foam', active: true),
    MenuItem(id: 46, name: 'Cold Cappuccino', categoryId: 10, price: 95.00, description: 'Cold coffee with milk and foam', active: true),
    MenuItem(id: 47, name: 'Hot Mocha', categoryId: 10, price: 80.00, description: 'Hot coffee with chocolate and milk', active: true),
    MenuItem(id: 48, name: 'Cold Mocha', categoryId: 10, price: 95.00, description: 'Cold coffee with chocolate and milk', active: true),
    MenuItem(id: 49, name: 'Hot Caramel Macchiato', categoryId: 10, price: 80.00, description: 'Hot coffee with caramel and milk', active: true),
    MenuItem(id: 50, name: 'Cold Caramel Macchiato', categoryId: 10, price: 95.00, description: 'Cold coffee with caramel and milk', active: true),
    MenuItem(id: 51, name: 'Hot Salted Caramel', categoryId: 10, price: 90.00, description: 'Hot coffee with salted caramel', active: true),
    MenuItem(id: 52, name: 'Cold Salted Caramel', categoryId: 10, price: 120.00, description: 'Cold coffee with salted caramel', active: true),
    MenuItem(id: 53, name: 'Hot Dirty Matcha', categoryId: 10, price: 100.00, description: 'Hot matcha with a shot of espresso', active: true),
    MenuItem(id: 54, name: 'Cold Dirty Matcha', categoryId: 10, price: 125.00, description: 'Cold matcha with a shot of espresso', active: true),
    MenuItem(id: 55, name: 'Hot Spanish Latte', categoryId: 10, price: 110.00, description: 'Hot coffee with condensed milk', active: true),
    MenuItem(id: 56, name: 'Cold Spanish Latte', categoryId: 10, price: 125.00, description: 'Cold coffee with condensed milk', active: true),
    MenuItem(id: 57, name: 'Cold Oreo Kōhi', categoryId: 10, price: 135.00, description: 'Cold coffee with Oreo crumbs', active: true),
    MenuItem(id: 58, name: 'Hot French Vanilla', categoryId: 10, price: 110.00, description: 'Hot coffee with French vanilla flavor', active: true),
    MenuItem(id: 59, name: 'Cold French Vanilla', categoryId: 10, price: 125.00, description: 'Cold coffee with French vanilla flavor', active: true),
    MenuItem(id: 60, name: 'Cold Hazelnut', categoryId: 10, price: 135.00, description: 'Cold coffee with hazelnut flavor', active: true),
    MenuItem(id: 61, name: 'Chocolate Float', categoryId: 11, price: 110.00, description: 'Chocolate beverage with ice cream', active: true),
    MenuItem(id: 62, name: 'Ube Float', categoryId: 11, price: 115.00, description: 'Ube beverage with ice cream', active: true),
    MenuItem(id: 63, name: 'Matcha Float', categoryId: 11, price: 135.00, description: 'Matcha beverage with ice cream', active: true),
    MenuItem(id: 64, name: 'Kōhi Float', categoryId: 11, price: 130.00, description: 'Coffee beverage with ice cream', active: true),
    MenuItem(id: 65, name: 'Mango Icy Blend', categoryId: 12, price: 145.00, description: 'Blended icy mango drink', active: true),
    MenuItem(id: 66, name: 'Blueberry Icy Blend', categoryId: 12, price: 145.00, description: 'Blended icy blueberry drink', active: true),
    MenuItem(id: 67, name: 'Strawberry Icy Blend', categoryId: 12, price: 145.00, description: 'Blended icy strawberry drink', active: true),
    MenuItem(id: 68, name: 'Matcha Icy Blend', categoryId: 12, price: 145.00, description: 'Blended icy matcha drink', active: true),
    MenuItem(id: 69, name: 'Oreo Frappe', categoryId: 13, price: 135.00, description: 'Blended coffee with Oreo crumbs', active: true),
    MenuItem(id: 70, name: 'Caramel Frappe', categoryId: 13, price: 130.00, description: 'Blended coffee with caramel flavor', active: true),
    MenuItem(id: 71, name: 'Mocha Frappe', categoryId: 13, price: 130.00, description: 'Blended coffee with chocolate flavor', active: true),
    MenuItem(id: 72, name: 'Kōhi Crumble Frappe', categoryId: 13, price: 135.00, description: 'Blended coffee with cookie crumble', active: true),
    MenuItem(id: 73, name: 'Chocolate Frappuccino', categoryId: 13, price: 130.00, description: 'Blended coffee with rich chocolate', active: true),
    MenuItem(id: 74, name: 'Ice Cream Add-on', categoryId: 14, price: 25.00, description: 'Add ice cream to your beverage', active: true),
    MenuItem(id: 75, name: 'Strawberry Milk Drink', categoryId: 15, price: 99.00, description: 'Milk with strawberry flavor', active: true),
    MenuItem(id: 76, name: 'Blueberry Milk Drink', categoryId: 15, price: 99.00, description: 'Milk with blueberry flavor', active: true),
    MenuItem(id: 77, name: 'Mango Milk Drink', categoryId: 15, price: 99.00, description: 'Milk with mango flavor', active: true),
    MenuItem(id: 78, name: 'Cherry Milk Drink', categoryId: 15, price: 99.00, description: 'Milk with cherry flavor', active: true),
    MenuItem(id: 79, name: 'Ube Milk Drink', categoryId: 15, price: 99.00, description: 'Milk with ube flavor', active: true),
    MenuItem(id: 80, name: 'Caramel Milk Drink', categoryId: 15, price: 99.00, description: 'Milk with caramel flavor', active: true),
    MenuItem(id: 81, name: 'Chocolate Milk Drink', categoryId: 15, price: 99.00, description: 'Milk with chocolate flavor', active: true),
    MenuItem(id: 82, name: 'Matcha Milk Drink', categoryId: 15, price: 120.00, description: 'Milk with matcha flavor', active: true),
    MenuItem(id: 83, name: 'Oreo Milk Drink', categoryId: 15, price: 120.00, description: 'Milk with Oreo crumbs', active: true),
    MenuItem(id: 84, name: 'Strawberry Matcha Milk Drink', categoryId: 15, price: 139.00, description: 'Milk with strawberry and matcha flavor', active: true),
    MenuItem(id: 85, name: 'Hot Chocolate', categoryId: 15, price: 85.00, description: 'Hot milk with chocolate', active: true),
    MenuItem(id: 86, name: 'Lemon Fruity Soda', categoryId: 16, price: 90.00, description: 'Soda with lemon flavor', active: true),
    MenuItem(id: 87, name: 'Lychee Fruity Soda', categoryId: 16, price: 90.00, description: 'Soda with lychee flavor', active: true),
    MenuItem(id: 88, name: 'Green Apple Fruity Soda', categoryId: 16, price: 90.00, description: 'Soda with green apple flavor', active: true),
    MenuItem(id: 89, name: 'Strawberry Fruity Soda', categoryId: 16, price: 90.00, description: 'Soda with strawberry flavor', active: true),
    MenuItem(id: 90, name: 'Mixed Berries Fruity Soda', categoryId: 16, price: 90.00, description: 'Soda with mixed berries flavor', active: true),
    MenuItem(id: 91, name: 'Wintermelon Fruity Soda', categoryId: 16, price: 90.00, description: 'Soda with wintermelon flavor', active: true),
    MenuItem(id: 92, name: 'Passionfruit Fruity Soda', categoryId: 16, price: 90.00, description: 'Soda with passionfruit flavor', active: true),
  ];

  // Getters
  List<MenuItem> get menuItems => List.unmodifiable(_menuItems);

  // Menu operations
  List<MenuItem> getMenuItemsByCategory(int categoryId) {
    return _menuItems.where((item) => item.categoryId == categoryId && item.active).toList();
  }

  MenuItem? getMenuItemById(int id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  MenuItem? getMenuItemByName(String itemName) {
    try {
      return _menuItems.firstWhere((item) => item.name == itemName);
    } catch (e) {
      return null;
    }
  }

  List<MenuItem> searchMenuItems(String query) {
    final lowerQuery = query.toLowerCase();
    return _menuItems.where((item) =>
        item.name.toLowerCase().contains(lowerQuery) ||
        (item.description?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  List<MenuItem> getMenuItemsByPriceRange(double minPrice, double maxPrice) {
    return _menuItems.where((item) =>
        item.price >= minPrice && item.price <= maxPrice
    ).toList();
  }

  // Get all active menu items
  List<MenuItem> getActiveMenuItems() {
    return _menuItems.where((item) => item.active).toList();
  }
  // Get menu items by category name
  List<MenuItem> getMenuItemsByCategoryName(String categoryName) {
    // This would need CategoryService to get categoryId by name
    // For now, we'll just return all items
    return _menuItems;
  }

  // Find menu item by exact name match
  MenuItem? findMenuItemByName(String itemName) {
    try {
      return _menuItems.firstWhere((item) => item.name.toLowerCase() == itemName.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Analytics
  Map<String, dynamic> getMenuStatistics() {
    final totalItems = _menuItems.length;
    final activeItems = _menuItems.where((item) => item.active).length;
    final averagePrice = _menuItems.fold<double>(0.0, (sum, item) => sum + item.price) / totalItems;
    
    final categoryCount = <int, int>{};
    for (final item in _menuItems) {
      categoryCount[item.categoryId] = (categoryCount[item.categoryId] ?? 0) + 1;
    }

    return {
      'totalItems': totalItems,
      'activeItems': activeItems,
      'averagePrice': averagePrice,
      'itemsByCategory': categoryCount,
    };
  }
}
