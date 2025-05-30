# BrewCode POS System Documentation

## Project Overview
The BrewCode POS System is a comprehensive Point-of-Sale application designed for cafes and restaurants. It provides an intuitive interface for managing transactions, inventory, and staff, while ensuring seamless operations and accurate record-keeping.

## Features

### Transaction Management
- **Edit Transactions**: Modify existing transactions, including items and payment details.
- **Dynamic Totals**: Automatically update transaction totals based on changes.
- **Amount Received**: Display the amount received and calculate change.

### Inventory Management
- **Item Management**: Add, edit, and delete inventory items.
- **Category Management**: Organize items into categories for easy navigation.

### Reporting
- **Transaction History**: View detailed transaction history with payment details.
- **CSV Export**: Export transaction and inventory data for external analysis.

### User Management
- **Staff Accounts**: Manage staff accounts and permissions.
- **Customer Profiles**: Maintain customer profiles for loyalty programs.

### Backup and Restore
- **CSV Backup**: Regular backups of inventory, transactions, and other data.
- **Restore**: Restore data from CSV files.

## How It Works

### Architecture
The BrewCode POS System is built using Flutter, a cross-platform framework, ensuring compatibility across Android, iOS, Windows, macOS, Linux, and web platforms. The application follows a Model-View-Provider (MVP) architecture for scalability and maintainability.

### Key Components

#### Models
- Represent the data structure for transactions, inventory items, categories, and more.
- Example: `Transaction`, `InventoryItem`, `CartItem`.

#### Providers
- Manage state and business logic.
- Example: `TransactionProvider`, `InventoryProvider`.

#### Screens
- UI components for user interaction.
- Example: `TransactionHistoryScreen`, `EditTransactionDialog`.

#### Services
- Handle external operations like CSV export/import.
- Example: `CSVService`.

#### Widgets
- Reusable UI components.
- Example: `TransactionCard`, `InventoryItemTile`.

### Workflow
1. **Transaction Creation**: Users create transactions by adding items and entering payment details.
2. **Inventory Updates**: Inventory is updated based on items sold.
3. **Reporting**: Transaction history is displayed with detailed payment information.
4. **Backup**: Data is regularly backed up to CSV files.

### Dynamic Features
- **EditTransactionDialog**: Allows users to edit items and payment details within transactions.
- **Transaction Totals**: Automatically recalculated when items or payment details are modified.

## Future Improvements
Refer to `FUTURE_IMPROVEMENTS.md` for planned enhancements.

## Getting Started

### Prerequisites
- Flutter SDK
- Dart

### Installation
1. Clone the repository:
   ```
   git clone https://github.com/your-repo/BrewCode-POS-Project.git
   ```
2. Navigate to the project directory:
   ```
   cd BrewCode-POS-Project
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```

### Running the Application
1. Run the application:
   ```
   flutter run
   ```
2. Select the target platform (e.g., Android, iOS, web).

## Contributing
Contributions are welcome! Please refer to `CONTRIBUTING.md` for guidelines.

## License
This project is licensed under the MIT License. See `LICENSE` for details.

## Contact
For inquiries, please contact [support@brewcode-pos.com](mailto:support@brewcode-pos.com).
