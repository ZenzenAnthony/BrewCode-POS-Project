# Menu-Inventory Relationship Update

## Updates Completed on May 22, 2025

This document outlines the updates made to the menu-inventory relationship data in the BrewCode POS Project.

### Changes Made

1. **Corrected Cornsilog Ingredient**:
   - Replaced incorrect ingredient "Condensed Milk" (ID: 30) with "Corned Beef" (ID: 51)
   - Updated relationship in `menu_item_ingredients.csv`
   - Updated reference documentation

2. **Added Drink Menu Items**:
   - Added relationships for all coffee drinks (Menu Items 39-50)
   - Connected coffee items with appropriate ingredients:
     - Coffee Beans (ID: 29)
     - Milk (ID: 28)
     - Caramel (ID: 22) - for Caramel Macchiato
     - Chocolate (ID: 23) - for Mocha drinks

### Drink Menu Items Relationships

| Menu Item ID | Menu Item Name | Ingredients |
|--------------|---------------|-------------|
| 39 | Hot Kōhi | Coffee Beans |
| 40 | Cold Kōhi | Coffee Beans |
| 41 | Hot Americano | Coffee Beans |
| 42 | Cold Americano | Coffee Beans |
| 43 | Hot Kōhi Latte | Coffee Beans, Milk |
| 44 | Cold Kōhi Latte | Coffee Beans, Milk |
| 45 | Hot Cappuccino | Coffee Beans, Milk |
| 46 | Cold Cappuccino | Coffee Beans, Milk |
| 47 | Hot Mocha | Coffee Beans, Chocolate, Milk |
| 48 | Cold Mocha | Coffee Beans, Chocolate, Milk |
| 49 | Hot Caramel Macchiato | Coffee Beans, Caramel, Milk |
| 50 | Cold Caramel Macchiato | Coffee Beans, Caramel, Milk |

### Implementation Details

- Added 24 new records to the `menu_item_ingredients.csv` file
- Updated SAMPLE_DATA_REFERENCE.md to reflect the changes
- Import scripts will automatically load these new relationships into the database

### Next Steps

The updated menu-inventory relationships will enable:

1. Better inventory management for coffee products
2. Accurate availability tracking for drinks based on inventory status
3. Proper connection between coffee menu items and their required ingredients

All changes have been documented and properly integrated with the existing database structure, maintaining the same principles of the menu-inventory relationship design.
