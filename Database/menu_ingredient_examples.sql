-- Examples for connecting menu items with ingredients
-- For BrewCode POS Project - May 22, 2025

USE KohiDB;
GO

-- This script provides examples of:
-- 1. Creating sample menu items and inventory
-- 2. Linking them using our new relationship table
-- 3. Testing the availability update procedure

-- 1. SAMPLE DATA (if you don't already have data)
-- ------------------------------------------

-- Sample categories
IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryName = 'Coffee')
INSERT INTO Categories (CategoryName, Description) VALUES ('Coffee', 'Coffee drinks');

IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryName = 'Tea')
INSERT INTO Categories (CategoryName, Description) VALUES ('Tea', 'Tea drinks');

IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryName = 'Ingredients')
INSERT INTO Categories (CategoryName, Description) VALUES ('Ingredients', 'Raw ingredients');

-- Sample inventory items
IF NOT EXISTS (SELECT 1 FROM Inventory WHERE ItemName = 'Coffee Beans')
INSERT INTO Inventory (ItemName, CategoryID, Unit, Status)
SELECT 'Coffee Beans', CategoryID, 'grams', 'Available' 
FROM Categories WHERE CategoryName = 'Ingredients';

IF NOT EXISTS (SELECT 1 FROM Inventory WHERE ItemName = 'Milk')
INSERT INTO Inventory (ItemName, CategoryID, Unit, Status)
SELECT 'Milk', CategoryID, 'ml', 'Available' 
FROM Categories WHERE CategoryName = 'Ingredients';

IF NOT EXISTS (SELECT 1 FROM Inventory WHERE ItemName = 'Tea Leaves')
INSERT INTO Inventory (ItemName, CategoryID, Unit, Status)
SELECT 'Tea Leaves', CategoryID, 'grams', 'Available' 
FROM Categories WHERE CategoryName = 'Ingredients';

-- Sample menu items
IF NOT EXISTS (SELECT 1 FROM MenuItems WHERE ItemName = 'Espresso')
INSERT INTO MenuItems (ItemName, CategoryID, Price, Active)
SELECT 'Espresso', CategoryID, 2.50, 1
FROM Categories WHERE CategoryName = 'Coffee';

IF NOT EXISTS (SELECT 1 FROM MenuItems WHERE ItemName = 'Cappuccino')
INSERT INTO MenuItems (ItemName, CategoryID, Price, Active)
SELECT 'Cappuccino', CategoryID, 3.50, 1
FROM Categories WHERE CategoryName = 'Coffee';

IF NOT EXISTS (SELECT 1 FROM MenuItems WHERE ItemName = 'Earl Grey')
INSERT INTO MenuItems (ItemName, CategoryID, Price, Active)
SELECT 'Earl Grey', CategoryID, 2.75, 1
FROM Categories WHERE CategoryName = 'Tea';

-- 2. LINK MENU ITEMS TO INGREDIENTS
-- -----------------------------

-- First, get IDs for our reference
DECLARE @EspressoID INT, @CappuccinoID INT, @EarlGreyID INT;
DECLARE @CoffeeBeansID INT, @MilkID INT, @TeaLeavesID INT;

SELECT @EspressoID = ItemID FROM MenuItems WHERE ItemName = 'Espresso';
SELECT @CappuccinoID = ItemID FROM MenuItems WHERE ItemName = 'Cappuccino';
SELECT @EarlGreyID = ItemID FROM MenuItems WHERE ItemName = 'Earl Grey';

SELECT @CoffeeBeansID = InventoryID FROM Inventory WHERE ItemName = 'Coffee Beans';
SELECT @MilkID = InventoryID FROM Inventory WHERE ItemName = 'Milk';
SELECT @TeaLeavesID = InventoryID FROM Inventory WHERE ItemName = 'Tea Leaves';

-- Link espresso to coffee beans (no quantity tracking)
IF @EspressoID IS NOT NULL AND @CoffeeBeansID IS NOT NULL
    EXEC sp_LinkMenuItemToIngredient @EspressoID, @CoffeeBeansID;

-- Link cappuccino to coffee beans and milk
IF @CappuccinoID IS NOT NULL AND @CoffeeBeansID IS NOT NULL
    EXEC sp_LinkMenuItemToIngredient @CappuccinoID, @CoffeeBeansID;
    
IF @CappuccinoID IS NOT NULL AND @MilkID IS NOT NULL
    EXEC sp_LinkMenuItemToIngredient @CappuccinoID, @MilkID;

-- Link Earl Grey to tea leaves
IF @EarlGreyID IS NOT NULL AND @TeaLeavesID IS NOT NULL
    EXEC sp_LinkMenuItemToIngredient @EarlGreyID, @TeaLeavesID;

-- 3. TEST AVAILABILITY UPDATES
-- ------------------------

PRINT '---- Initial state ----';
SELECT m.ItemName, m.Active 
FROM MenuItems m
WHERE m.ItemName IN ('Espresso', 'Cappuccino', 'Earl Grey');

-- Test: Mark coffee beans as Not Available
PRINT '---- After marking Coffee Beans as Not Available ----';
UPDATE Inventory SET Status = 'Not Available' WHERE ItemName = 'Coffee Beans';
EXEC sp_UpdateMenuAvailabilityByIngredients;

-- Check which items are affected
SELECT m.ItemName, m.Active 
FROM MenuItems m
WHERE m.ItemName IN ('Espresso', 'Cappuccino', 'Earl Grey');

-- Test: Restore coffee beans but mark milk as Not Available
PRINT '---- After marking Milk as Not Available (Coffee Beans available) ----';
UPDATE Inventory SET Status = 'Available' WHERE ItemName = 'Coffee Beans';
UPDATE Inventory SET Status = 'Not Available' WHERE ItemName = 'Milk';
EXEC sp_UpdateMenuAvailabilityByIngredients;

-- Check which items are affected
SELECT m.ItemName, m.Active 
FROM MenuItems m
WHERE m.ItemName IN ('Espresso', 'Cappuccino', 'Earl Grey');

-- Restore everything to Available for normal operations
UPDATE Inventory SET Status = 'Available';
EXEC sp_UpdateMenuAvailabilityByIngredients;

PRINT 'Script completed successfully';
GO
