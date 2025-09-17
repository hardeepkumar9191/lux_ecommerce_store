import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/product.dart';
import 'models/cart.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/admin_dashboard.dart';
import 'services/payment_service.dart';
import 'services/inventory_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Cart()),
        Provider(create: (context) => PaymentService()),
        Provider(create: (context) => InventoryService()),
      ],
      child: MaterialApp(
        title: 'Luxe Jewelry Studio',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          primaryColor: Color(0xFFD4AF37),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: false, // Use Material 2 for compatibility
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/product': (context) => ProductDetailScreen(),
          '/cart': (context) => CartScreen(),
          '/checkout': (context) => CheckoutScreen(),
          '/admin': (context) => AdminDashboard(),
        },
      ),
    );
  }
}