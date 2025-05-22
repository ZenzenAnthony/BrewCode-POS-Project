# Sample Data Reference for Menu-Inventory Relationships

This document provides a reference for the sample data in the CSV files and shows how menu items and inventory items are related.

## Menu Items (menu_items_updated.csv) - Partial List

| ItemID | ItemName           | CategoryID | Description                                      | Price  | Active |
|--------|-------------------|------------|--------------------------------------------------|--------|--------|
| 1      | Teriyaki Chicken  | 3          | Chicken with teriyaki sauce served with rice      | 139.00 | 1      |
| 2      | Sweet Chilli Chicken | 3       | Chicken with sweet chilli sauce served with rice  | 139.00 | 1      |
| 3      | Barbecue Chicken  | 3          | Chicken with barbecue sauce served with rice      | 139.00 | 1      |
| 10     | Garlic Beef Mushroom | 3       | Beef and mushroom with garlic sauce served with rice | 149.00 | 1  |
| 12     | Cornsilog         | 4          | Corned beef with sinangag (fried rice) and itlog (egg) | 80.00 | 1 |
| 19     | Club Sandwich     | 5          | Triple-decker sandwich with chicken, bacon, lettuce, tomato | 145.00 | 1 |
| 20     | Cheeseburger      | 5          | Beef patty with cheese in a bun                   | 130.00 | 1     |

## Inventory Items (inventory_updated.csv) - Partial List

| InventoryID | ItemName       | CategoryID | Unit   | Status     | Notes            |
|-------------|---------------|------------|--------|------------|------------------|
| 1           | Chicken       | 1          | kilo   | Available  |                  |
| 2           | Sugar         | 1          | kilo   | Available  |                  |
| 3           | Black Pepper  | 1          | kilo   | Available  |                  |
| 4           | Garlic        | 1          | kilo   | Available  |                  |
| 6           | Egg           | 1          | tray   | Available  |                  |
| 11          | Ground Beef   | 1          | kilo   | Available  |                  |
| 12          | Onion         | 1          | kilo   | Available  |                  |
| 13          | All Purpose Flour | 1      | kilo   | Available  |                  |
| 28          | Milk          | 2          | liter  | Available  |                  |
| 30          | Condensed Milk | 2         | can    | Available  |                  |

## Categories (categories_updated.csv)

| CategoryID | CategoryName     | Description                                | ParentCategoryID |
|------------|-----------------|-------------------------------------------|------------------|
| 1          | Food            | Main food category                         | NULL             |
| 2          | Drinks          | Main drinks category                       | NULL             |
| 3          | Rice Meal       | Rice meals with various toppings           | 1                |
| 4          | Silog Meals     | Filipino breakfast meals with rice, egg, and meat | 1         |
| 5          | Snacks          | Light food items and finger foods          | 1                |
| 10         | Kōhi Based      | Coffee-based beverages                     | 2                |

## Menu-Item-Ingredient Relationships (menu_item_ingredients.csv) - Examples

| MenuItemIngredientID | MenuItemID | InventoryID | Explanation                         |
|----------------------|------------|-------------|-------------------------------------|
| 1                    | 1          | 1           | Teriyaki Chicken needs Chicken      |
| 2                    | 1          | 3           | Teriyaki Chicken needs Black Pepper |
| 3                    | 1          | 4           | Teriyaki Chicken needs Garlic       |
| 10                   | 3          | 1           | Barbecue Chicken needs Chicken      |
| 31                   | 10         | 11          | Garlic Beef Mushroom needs Ground Beef |
| 32                   | 10         | 12          | Garlic Beef Mushroom needs Onion    |
| 33                   | 10         | 4           | Garlic Beef Mushroom needs Garlic   |
| 37                   | 12         | 6           | Cornsilog needs Egg                 |
| 38                   | 12         | 51          | Cornsilog needs Corned Beef         |
| 48                   | 20         | 11          | Cheeseburger needs Ground Beef      |
| 49                   | 20         | 13          | Cheeseburger needs All Purpose Flour|
| 50                   | 39         | 29          | Hot Kōhi needs Coffee Beans         |
| 51                   | 40         | 29          | Cold Kōhi needs Coffee Beans        |
| 54                   | 43         | 29          | Hot Kōhi Latte needs Coffee Beans   |
| 55                   | 43         | 28          | Hot Kōhi Latte needs Milk           |
| 62                   | 47         | 29          | Hot Mocha needs Coffee Beans        |
| 63                   | 47         | 23          | Hot Mocha needs Chocolate           |
| 64                   | 47         | 28          | Hot Mocha needs Milk                |
| 68                   | 49         | 29          | Hot Caramel Macchiato needs Coffee Beans|
| 69                   | 49         | 22          | Hot Caramel Macchiato needs Caramel |
| 70                   | 49         | 28          | Hot Caramel Macchiato needs Milk    |
| 123                  | 24         | 65          | Meat Loaded Waffle Pizza needs Waffle Mix |
| 124                  | 24         | 1           | Meat Loaded Waffle Pizza needs Chicken |
| 125                  | 24         | 52          | Meat Loaded Waffle Pizza needs Ham |
| 140                  | 29         | 65          | Strawberry Waffle needs Waffle Mix |
| 141                  | 29         | 40          | Strawberry Waffle needs Strawberry Jam |
| 166                  | 61         | 23          | Chocolate Float needs Chocolate |
| 167                  | 61         | 75          | Chocolate Float needs Ice Cream |
| 198                  | 75         | 28          | Strawberry Milk Drink needs Milk |
| 199                  | 75         | 31          | Strawberry Milk Drink needs Strawberry Syrup |
| 221                  | 86         | 72          | Lemon Fruity Soda needs Soda |
| 222                  | 86         | 33          | Lemon Fruity Soda needs Lemon Syrup |

## How It Works

When the availability of inventory items changes, the menu items are automatically updated:

1. If "Coffee Beans" (ID: 1) becomes "Not Available":
   - Both "Espresso" and "Cappuccino" will be marked as inactive (unavailable)

2. If "Low-Fat Milk" (ID: 3) becomes "Not Available":
   - It doesn't make Cappuccino unavailable because it can still be made with Whole Milk
   - But if both milk options are unavailable, Cappuccino would become unavailable

3. If "Flour" (ID: 5) becomes "Not Available":
   - Both "Blueberry Muffin" and "Croissant" will become unavailable

This direct relationship allows for much more precise control over menu item availability based on your inventory status.
