import '../models/category.dart';

class CategoryService {
  // Singleton pattern
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  // Categories data from CSV categories_updated.csv
  final List<Category> _categories = [
    Category(categoryId: 1, categoryName: 'Food', description: 'Main food category', parentCategoryId: null, active: true),
    Category(categoryId: 2, categoryName: 'Drinks', description: 'Main drinks category', parentCategoryId: null, active: true),
    Category(categoryId: 3, categoryName: 'Rice Meal', description: 'Rice meals with various toppings', parentCategoryId: 1, active: true),
    Category(categoryId: 4, categoryName: 'Silog Meals', description: 'Filipino breakfast meals with rice, egg, and meat', parentCategoryId: 1, active: true),
    Category(categoryId: 5, categoryName: 'Snacks', description: 'Light food items and finger foods', parentCategoryId: 1, active: true),
    Category(categoryId: 6, categoryName: 'Waffle Pizza', description: 'Pizza made with waffle base', parentCategoryId: 1, active: true),
    Category(categoryId: 7, categoryName: 'Pasta', description: 'Pasta dishes', parentCategoryId: 1, active: true),
    Category(categoryId: 8, categoryName: 'Waffles', description: 'Sweet waffle dishes', parentCategoryId: 1, active: true),
    Category(categoryId: 9, categoryName: 'Sandwich', description: 'Sandwich items', parentCategoryId: 1, active: true),
    Category(categoryId: 10, categoryName: 'Kōhi Based', description: 'Coffee-based beverages', parentCategoryId: 2, active: true),
    Category(categoryId: 11, categoryName: 'Floats', description: 'Ice cream float beverages', parentCategoryId: 2, active: true),
    Category(categoryId: 12, categoryName: 'Icy Blends', description: 'Blended icy fruit beverages', parentCategoryId: 2, active: true),
    Category(categoryId: 13, categoryName: 'Frappes', description: 'Blended coffee and cream beverages', parentCategoryId: 2, active: true),
    Category(categoryId: 14, categoryName: 'Add-ons', description: 'Additional items to customize drinks', parentCategoryId: 2, active: true),
    Category(categoryId: 15, categoryName: 'Milk Drink', description: 'Flavored milk beverages', parentCategoryId: 2, active: true),
    Category(categoryId: 16, categoryName: 'Fruity Soda', description: 'Fruit-flavored soda beverages', parentCategoryId: 2, active: true),
  ];

  // Getters
  List<Category> get categories => List.unmodifiable(_categories);

  // Category operations
  Category? getCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  String? getCategoryNameById(int categoryId) {
    final category = getCategoryById(categoryId);
    return category?.categoryName;
  }

  List<Category> getFoodCategories() {
    return _categories.where((cat) => cat.parentCategoryId == 1).toList();
  }

  List<Category> getDrinkCategories() {
    return _categories.where((cat) => cat.parentCategoryId == 2).toList();
  }

  List<Category> getMainCategories() {
    return _categories.where((cat) => cat.parentCategoryId == null).toList();
  }

  List<Category> getSubCategories(int parentCategoryId) {
    return _categories.where((cat) => cat.parentCategoryId == parentCategoryId).toList();
  }

  bool isFoodCategory(int categoryId) {
    final category = getCategoryById(categoryId);
    return category?.parentCategoryId == 1 || categoryId == 1;
  }

  bool isDrinkCategory(int categoryId) {
    final category = getCategoryById(categoryId);
    return category?.parentCategoryId == 2 || categoryId == 2;
  }
}
