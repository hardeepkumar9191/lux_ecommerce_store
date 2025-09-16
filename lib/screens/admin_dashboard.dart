// screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool isSyncing = false;
  String syncStatus = '';

  @override
  Widget build(BuildContext context) {
    final inventoryService = Provider.of<InventoryService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            SizedBox(height: 24),
            _buildQuickStats(),
            SizedBox(height: 24),
            _buildPlatformIntegrations(inventoryService),
            SizedBox(height: 24),
            _buildRecentOrders(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.amber.shade300],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Admin Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Manage your jewelry store and integrations',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Orders', '142', Icons.shopping_bag, Colors.blue)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard('Revenue', '\$12,450', Icons.attach_money, Colors.green)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Products', '28', Icons.inventory, Colors.orange)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard('Customers', '89', Icons.people, Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformIntegrations(InventoryService inventoryService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform Integrations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildIntegrationTile(
                  'Shopify',
                  'Sync products and orders with Shopify store',
                  Icons.store,
                  Colors.green,
                  () => _syncWithPlatform('Shopify', inventoryService.syncWithShopify),
                ),
                Divider(),
                _buildIntegrationTile(
                  'Etsy',
                  'Import handcrafted jewelry listings from Etsy',
                  Icons.handyman,
                  Colors.orange,
                  () => _syncWithPlatform('Etsy', inventoryService.syncWithEtsy),
                ),
                Divider(),
                _buildIntegrationTile(
                  'WooCommerce',
                  'Connect with your WordPress WooCommerce store',
                  Icons.web,
                  Colors.blue,
                  () => _syncWithPlatform('WooCommerce', inventoryService.syncWithWooCommerce),
                ),
              ],
            ),
          ),
        ),
        if (syncStatus.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(child: Text(syncStatus)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIntegrationTile(String name, String description, IconData icon, Color color, VoidCallback onSync) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      trailing: ElevatedButton(
        onPressed: isSyncing ? null : onSync,
        child: isSyncing 
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text('Sync'),
      ),
    );
  }

  Future<void> _syncWithPlatform(String platformName, Future<List<Product>> Function() syncFunction) async {
    setState(() {
      isSyncing = true;
      syncStatus = 'Syncing with $platformName...';
    });

    try {
      final products = await syncFunction();
      setState(() {
        syncStatus = 'Successfully synced ${products.length} products from $platformName';
        isSyncing = false;
      });
      
      // Clear status after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            syncStatus = '';
          });
        }
      });
    } catch (e) {
      setState(() {
        syncStatus = 'Failed to sync with $platformName: $e';
        isSyncing = false;
      });
    }
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildOrderTile('Order #1001', 'Diamond Ring', '\$2,500', 'Completed'),
              Divider(),
              _buildOrderTile('Order #1002', 'Pearl Necklace', '\$350', 'Processing'),
              Divider(),
              _buildOrderTile('Order #1003', 'Custom Bracelet', '\$180', 'Pending'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTile(String orderNumber, String productName, String amount, String status) {
    Color statusColor = status == 'Completed' ? Colors.green : 
                       status == 'Processing' ? Colors.orange : Colors.grey;
    
    return ListTile(
      title: Text(orderNumber, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(productName),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
        ],
      ),
    );
  }
}