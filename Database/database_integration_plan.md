# Database Integration Plan for BrewCode POS

This document outlines the plan for integrating the Flutter frontend application with the SQL Server database backend.

## Current State

The BrewCode POS system currently has:

1. **Flutter Frontend**:
   - Using Provider pattern for state management
   - Using hardcoded mock data in providers
   - Has UI screens for ordering, tracking, and receipt generation

2. **SQL Server Database Backend**:
   - Updated database structure with simplified tables
   - Status-based inventory tracking
   - Transaction records only for completed orders
   - Stored procedures for common operations

## Integration Approach

We'll implement a phased approach to connect the frontend with the backend:

### Phase 1: Prepare the Frontend (CURRENT)

1. **Create Placeholder Services**:
   - DatabaseServicePlaceholder
   - OrderServicePlaceholder
   - InventoryServicePlaceholder

2. **Update Models**:
   - Ensure all models match database structure
   - Implement proper JSON serialization/deserialization

3. **Refactor Providers**:
   - Update to use placeholder services
   - Prepare for real API integration

### Phase 2: API Layer (FUTURE)

1. **Create a Backend API**:
   - Implement REST API using ASP.NET or similar
   - Expose endpoints for all required operations
   - Connect API to SQL Server database

2. **API Endpoints to Implement**:
   - GET /api/menu-items
   - GET /api/categories
   - GET /api/inventory
   - PUT /api/inventory/:id
   - POST /api/orders
   - PUT /api/orders/:id/complete
   - GET /api/transactions

### Phase 3: Connect Frontend to API (FUTURE)

1. **Replace Placeholder Services**:
   - Implement real service classes that call API endpoints
   - Use HTTP package for API communication
   - Handle error cases and loading states

2. **Update Providers**:
   - Switch from mock data to real API data
   - Maintain interface compatibility to minimize UI changes

3. **Implement Authentication**:
   - Add staff login functionality
   - Secure API endpoints

### Phase 4: Testing and Optimization (FUTURE)

1. **End-to-End Testing**:
   - Test all user flows with real database
   - Verify data integrity

2. **Performance Optimization**:
   - Implement caching where appropriate
   - Optimize database queries

3. **Offline Support**:
   - Implement local storage for offline operation
   - Sync with server when back online

## Technical Details

### Database Connection

For the actual implementation, we'll need to:

1. Create a .NET Core API project
2. Configure database connection string
3. Create controllers that map to our entities
4. Implement services that use stored procedures

### Flutter HTTP Implementation

Sample implementation of a real service (future):

```dart
class MenuService {
  final String baseUrl = 'https://api.brewcode.com/api';
  final http.Client _client = http.Client();

  Future<List<Product>> getProducts() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/menu-items'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}
```

## Timeline

1. **Phase 1**: Current Sprint
2. **Phase 2**: Next Sprint
3. **Phase 3**: Sprint + 2
4. **Phase 4**: Sprint + 3

## Risks and Mitigation

1. **Network Connectivity**:
   - Implement offline mode
   - Cache frequently used data

2. **Database Performance**:
   - Optimize stored procedures
   - Implement pagination for large datasets

3. **Authentication Security**:
   - Use proper JWT authentication
   - Implement role-based access control

## Conclusion

This phased approach allows us to continue development on the frontend while preparing for database integration. The placeholder services make it easy to swap in real API services later without significant changes to the UI code.
