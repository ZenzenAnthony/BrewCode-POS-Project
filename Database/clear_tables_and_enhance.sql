-- Script to clear tables and enhance the menu-inventory relationship
-- For BrewCode POS Project - May 22, 2025

USE KohiDB;
GO

-- 1. CLEAR TABLES BUT KEEP ONE STAFF MEMBER
-- ----------------------------------------

-- Clear Transactions
TRUNCATE TABLE Transactions;
PRINT 'Transactions table cleared';

-- Clear OrderItems and Orders (due to foreign key relationship)
DELETE FROM OrderItems;
DELETE FROM Orders;
PRINT 'OrderItems and Orders tables cleared';

-- Clear Customers
DELETE FROM Customers;
PRINT 'Customers table cleared';

-- Keep only one staff member (keep ID 1 or lowest ID)
DECLARE @StaffToKeep INT;
SELECT TOP 1 @StaffToKeep = StaffID FROM Staff ORDER BY StaffID;
DELETE FROM Staff WHERE StaffID != @StaffToKeep;
PRINT 'Kept staff with ID: ' + CAST(@StaffToKeep AS VARCHAR(10)) + ', removed others';

-- 2. ADD MENU-INVENTORY RELATIONSHIP
-- ---------------------------------

-- Check if MenuItemIngredients table already exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'MenuItemIngredients')
BEGIN
    -- Create a junction table to link MenuItems with Inventory items
    CREATE TABLE MenuItemIngredients (
        MenuItemIngredientID INT PRIMARY KEY IDENTITY(1,1),
        MenuItemID INT NOT NULL,
        InventoryID INT NOT NULL,
        -- No quantity tracking as requested
        FOREIGN KEY (MenuItemID) REFERENCES MenuItems(ItemID),
        FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID),
        -- Ensure a menu item doesn't link to the same inventory item twice
        CONSTRAINT UC_MenuItem_Inventory UNIQUE (MenuItemID, InventoryID)
    );
    PRINT 'MenuItemIngredients table created';
END
ELSE
BEGIN
    PRINT 'MenuItemIngredients table already exists';
END

-- 3. CREATE IMPROVED STORED PROCEDURE FOR MENU AVAILABILITY
-- ------------------------------------------------------

-- Drop the procedure if it exists
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_UpdateMenuAvailabilityByIngredients')
BEGIN
    DROP PROCEDURE sp_UpdateMenuAvailabilityByIngredients;
END
GO

-- Create a new procedure that uses the junction table
CREATE PROCEDURE sp_UpdateMenuAvailabilityByIngredients
AS
BEGIN
    -- First, set all menu items as active (default state)
    UPDATE MenuItems SET Active = 1;
    
    -- Then, mark menu items as inactive if ANY of their required ingredients
    -- are not available
    UPDATE MenuItems
    SET Active = 0
    WHERE ItemID IN (
        -- Find menu items that have at least one unavailable ingredient
        SELECT DISTINCT mi.MenuItemID
        FROM MenuItemIngredients mi
        JOIN Inventory i ON mi.InventoryID = i.InventoryID
        WHERE i.Status = 'Not Available'
    );
    
    PRINT 'Menu item availability updated based on ingredient status';
END;
GO

-- 4. CREATE A HELPER PROCEDURE TO LINK MENU ITEMS TO INGREDIENTS
-- -----------------------------------------------------------

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_LinkMenuItemToIngredient')
BEGIN
    DROP PROCEDURE sp_LinkMenuItemToIngredient;
END
GO

CREATE PROCEDURE sp_LinkMenuItemToIngredient
    @MenuItemID INT,
    @InventoryID INT
AS
BEGIN
    -- Check if both IDs exist
    IF NOT EXISTS (SELECT 1 FROM MenuItems WHERE ItemID = @MenuItemID)
    BEGIN
        PRINT 'Error: Menu item ID ' + CAST(@MenuItemID AS VARCHAR(10)) + ' does not exist';
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM Inventory WHERE InventoryID = @InventoryID)
    BEGIN
        PRINT 'Error: Inventory item ID ' + CAST(@InventoryID AS VARCHAR(10)) + ' does not exist';
        RETURN;
    END
    
    -- Check if relationship already exists
    IF EXISTS (SELECT 1 FROM MenuItemIngredients 
                WHERE MenuItemID = @MenuItemID AND InventoryID = @InventoryID)
    BEGIN
        -- Relationship already exists, do nothing
        PRINT 'Relationship already exists, no changes made';
    END
    ELSE
    BEGIN
        -- Insert new relationship
        INSERT INTO MenuItemIngredients (MenuItemID, InventoryID)
        VALUES (@MenuItemID, @InventoryID);
        
        PRINT 'Created new menu item-ingredient relationship';
    END
END;
GO

-- 5. EXAMPLE USAGE (commented out)
-- -----------------------------

/*
-- Example: Link a coffee menu item to coffee beans inventory
EXEC sp_LinkMenuItemToIngredient 
    @MenuItemID = 1,   -- Assuming Espresso has ID 1
    @InventoryID = 1;  -- Assuming Coffee Beans has ID 1
    
-- Update menu availability based on ingredients
EXEC sp_UpdateMenuAvailabilityByIngredients;
*/

PRINT 'Script completed successfully';
GO