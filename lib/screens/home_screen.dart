// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  String selectedCategory = 'All';
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    // Mock product data - in real app, this would come from your backend/APIs
    products = [
      Product(
        id: '1',
        name: 'Diamond Solitaire Ring',
        description: 'Classic 1ct diamond engagement ring in 14k gold',
        price: 2500.00,
        images: ['https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400'],
        category: 'Rings',
        stockQuantity: 3,
        rating: 4.8,
        materials: ['14k Gold', 'Diamond'],
        isCustomizable: true,
      ),
      Product(
        id: '2',
        name: 'Pearl Necklace',
        description: 'Elegant freshwater pearl necklace',
        price: 350.00,
        images: ['https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400'],
        category: 'Necklaces',
        stockQuantity: 8,
        rating: 4.6,
        materials: ['Freshwater Pearls', 'Silver'],
      ),
      Product(
        id: '3',
        name: 'Custom Name Bracelet',
        description: 'Personalized gold bracelet with custom engraving',
        price: 180.00,
        images: ['https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=400'],
        category: 'Bracelets',
        stockQuantity: 15,
        rating: 4.9,
        materials: ['18k Gold'],
        isCustomizable: true,
      ),
    ];
    
    filteredProducts = products;
    setState(() {});
  }

  void _filterProducts(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((p) => p.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Luxe Jewelry Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          Consumer<Cart>(
            builder: (context, cart, child) => Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.itemCount}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildHeroSection(),
          _buildCategoryFilter(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              'Luxe Jewelry',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cart');
            },
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text('Admin Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Colors.amber.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Exquisite Custom Jewelry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Crafted with love, designed for you',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
  final categories = ['All', 'Rings', 'Necklaces', 'Bracelets', 'Earrings'];
  
  return Container(
    height: 60,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category == selectedCategory;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
              foregroundColor: isSelected ? Colors.white : Colors.black,
            ),
            onPressed: () => _filterProducts(category),
            child: Text(category),
          ),
        );
      },
    ),
  );
}

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/product',
            arguments: product,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  image: DecorationImage(
                    image: NetworkImage(product.images.first),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    if (product.isCustomizable)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Custom',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text('${product.rating}', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}