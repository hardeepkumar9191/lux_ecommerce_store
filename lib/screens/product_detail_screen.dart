// screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedImageIndex = 0;
  Map<String, dynamic> customizations = {};

  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(product),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(product),
                  SizedBox(height: 20),
                  if (product.isCustomizable) _buildCustomizationOptions(product),
                  SizedBox(height: 20),
                  _buildMaterials(product),
                  SizedBox(height: 30),
                  _buildAddToCartButton(product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(Product product) {
    return Container(
      height: 300,
      child: PageView.builder(
        itemCount: product.images.length,
        onPageChanged: (index) => setState(() => selectedImageIndex = index),
        itemBuilder: (context, index) {
          return Image.network(
            product.images[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.image_not_supported, size: 50),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < product.rating.floor() ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
            SizedBox(width: 8),
            Text('${product.rating} (Reviews)'),
          ],
        ),
        SizedBox(height: 12),
        Text(
          '\${product.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 16),
        Text(
          product.description,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        SizedBox(height: 12),
        if (product.stockQuantity <= 5)
          Text(
            'Only ${product.stockQuantity} left in stock!',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Widget _buildCustomizationOptions(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customization Options',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        
        // Metal Type Selection
        _buildOptionSection(
          'Metal Type',
          ['Gold', 'Silver', 'Platinum', 'Rose Gold'],
          'metal',
        ),
        
        // Size Selection (for rings/bracelets)
        if (product.category == 'Rings' || product.category == 'Bracelets')
          _buildOptionSection(
            'Size',
            ['6', '7', '8', '9', '10'],
            'size',
          ),
        
        // Engraving option
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Custom Engraving (+\$25)', 
                   style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter text for engraving (max 15 chars)',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 15,
                onChanged: (value) {
                  customizations['engraving'] = value;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionSection(String title, List<String> options, String key) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options.map((option) {
              final isSelected = customizations[key] == option;
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      customizations[key] = option;
                    } else {
                      customizations.remove(key);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterials(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Materials',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: product.materials.map((material) {
            return Chip(
              label: Text(material),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(Product product) {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: product.stockQuantity > 0 ? () {
          Provider.of<Cart>(context, listen: false).addItem(
            product,
            customizations: customizations,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to cart!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } : null,
        child: Text(
          product.stockQuantity > 0 ? 'Add to Cart' : 'Out of Stock',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}