# BrewCode POS Project

A Point of Sale (POS) system for coffee shops and cafés, developed using Flutter.

## Project Structure

This repository contains:

- **`flutter_application_1/`**: The Flutter application for the POS system
- **`Database/`**: SQL schema, stored procedures, and database documentation
- **`CSV/`**: CSV data files for import into the database
- **`Documentations/`**: Project documentation and design documents

## Flutter Application

The Flutter application is a modern POS system designed specifically for coffee shops and café operations. Key features include:

- Product catalog management
- Order processing
- Inventory tracking
- Transaction history
- Receipt generation

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- An IDE (VS Code recommended with Flutter extension)
- SQL Server for database integration

### Running the Application

1. Navigate to the Flutter application directory:

```bash
cd flutter_application_1
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the application:

```bash
flutter run
```

## Database Integration

The application is designed to connect to a SQL Server or MySQL database. The following resources provide details on database structure and integration:

- **Database Structure**: See `Database/FINAL_IMPLEMENTATION_SUMMARY.md` for the complete database structure
- **Menu-Inventory Relationship**: See `Database/COMPLETE_MENU_INVENTORY_RELATIONSHIPS.md` for details on how menu items are linked to inventory items
- **CSV Data Files**: The `CSV` folder contains all data ready for import into the database
- **Import Scripts**: 
  - SQL Server: `CSV/import_csv_to_sql_with_menu_inventory.sql`
  - MySQL: `Database/mysql_import_script_with_menu_inventory.sql`

## Recent Updates (May 22, 2025)

- Complete menu-inventory relationships implemented for all 92 menu items
- Fixed ingredients for the Cornsilog menu item
- Added relationships for all drink menu items
- Project files cleaned up and reorganized for better maintainability
- See `Database/MENU_INVENTORY_ENHANCEMENT_SUMMARY.md` for complete update details

## Documentation Guide

For a comprehensive guide to project documentation, see `DOCUMENTATION_GUIDE.md` in the root directory.

## Status & Improvements

- Current status: See `flutter_application_1/STATUS_REPORT.md`
- Planned improvements: See `flutter_application_1/IMPROVEMENTS_SUMMARY.md`

## License

[Your license type here]
