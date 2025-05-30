// lib/models/category.dart
// Category model for organizing menu items and inventory

class Category {
  final int categoryId;
  final String categoryName;
  final String description;
  final int? parentCategoryId;
  final bool active;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.description,
    this.parentCategoryId,
    required this.active,
  });

  // Factory constructor for creating from JSON/Map
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? json['CategoryID'] ?? 0,
      categoryName: json['categoryName'] ?? json['CategoryName'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      parentCategoryId: json['parentCategoryId'] ?? json['ParentCategoryID'],
      active: json['active'] ?? json['Active'] ?? true,
    );
  }

  // Convert to JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'parentCategoryId': parentCategoryId,
      'active': active,
    };
  }

  // Convert to Map with database column names
  Map<String, dynamic> toDatabase() {
    return {
      'CategoryID': categoryId,
      'CategoryName': categoryName,
      'Description': description,
      'ParentCategoryID': parentCategoryId,
      'Active': active,
    };
  }

  // Copy with method for immutable updates
  Category copyWith({
    int? categoryId,
    String? categoryName,
    String? description,
    int? parentCategoryId,
    bool? active,
  }) {
    return Category(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      active: active ?? this.active,
    );
  }

  // Helper methods
  bool get isMainCategory => parentCategoryId == null;
  bool get isSubCategory => parentCategoryId != null;
  bool get isFoodCategory => parentCategoryId == 1 || categoryId == 1;
  bool get isDrinkCategory => parentCategoryId == 2 || categoryId == 2;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && 
           other.categoryId == categoryId &&
           other.categoryName == categoryName &&
           other.description == description &&
           other.parentCategoryId == parentCategoryId &&
           other.active == active;
  }

  @override
  int get hashCode {
    return categoryId.hashCode ^
           categoryName.hashCode ^
           description.hashCode ^
           (parentCategoryId?.hashCode ?? 0) ^
           active.hashCode;
  }

  @override
  String toString() {
    return 'Category(id: $categoryId, name: $categoryName, parent: $parentCategoryId, active: $active)';
  }
}
