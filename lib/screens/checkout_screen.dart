// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../services/payment_service.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String selectedPaymentMethod = 'stripe';
  bool isProcessing = false;
  
  // Form controllers
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<Cart>(
        builder: (context, cart, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(cart),
                  SizedBox(height: 24),
                  _buildShippingForm(),
                  SizedBox(height: 24),
                  _buildPaymentMethodSelection(),
                  SizedBox(height: 32),
                  _buildPlaceOrderButton(cart),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(Cart cart) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ...cart.items.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${item.product.name} x${item.quantity}'),
                  ),
                  Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                ],
              ),
            )).toList(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('\$${cart.totalAmount.toStringAsFixed(2)}', 
                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shipping Information', 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!value.contains('@')) return 'Please enter a valid email';
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your address' : null,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: zipController,
                    decoration: InputDecoration(
                      labelText: 'ZIP Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Method', 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildPaymentOption('stripe', 'Credit Card (Stripe)', Icons.credit_card),
            _buildPaymentOption('paypal', 'PayPal', Icons.payment),
            _buildPaymentOption('apple_pay', 'Apple Pay', Icons.phone_iphone),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: selectedPaymentMethod,
      onChanged: (String? value) {
        setState(() {
          selectedPaymentMethod = value!;
        });
      },
      title: Row(
        children: [
          Icon(icon),
          SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(Cart cart) {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: isProcessing ? null : () => _processOrder(cart),
        child: isProcessing 
          ? CircularProgressIndicator(color: Colors.white)
          : Text('Place Order - \$${cart.totalAmount.toStringAsFixed(2)}', 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _processOrder(Cart cart) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      
      Map<String, dynamic> result;
      
      switch (selectedPaymentMethod) {
        case 'stripe':
          result = await paymentService.processStripePayment(
            amount: cart.totalAmount,
            currency: 'USD',
            customerInfo: {
              'email': emailController.text,
              'name': '${firstNameController.text} ${lastNameController.text}',
            },
          );
          break;
        case 'paypal':
          result = await paymentService.processPayPalPayment(
            amount: cart.totalAmount,
            currency: 'USD',
          );
          break;
        case 'apple_pay':
          result = await paymentService.processApplePayPayment(
            amount: cart.totalAmount,
            currency: 'USD',
          );
          break;
        default:
          result = {'success': false, 'error': 'Invalid payment method'};
      }

      if (result['success']) {
        // Clear cart
        cart.clear();
        
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Order Successful!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 50),
                SizedBox(height: 16),
                Text('Transaction ID: ${result['transactionId']}'),
                SizedBox(height: 8),
                Text('Your order has been placed successfully!'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
                child: Text('Continue Shopping'),
              ),
            ],
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    zipController.dispose();
    super.dispose();
  }
}