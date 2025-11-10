import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/data/models/cart_item_model.dart';
import 'package:shopping_swipe_app/presentation/providers/swipe_provider.dart';
import 'package:shopping_swipe_app/data/services/payment_service.dart';
import 'package:shopping_swipe_app/presentation/utils/page_transitions.dart';
import 'package:shopping_swipe_app/presentation/constants/app_spacing.dart';
import 'package:shopping_swipe_app/presentation/widgets/animated_empty_state.dart';

class CartPage extends ConsumerWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swipeState = ref.watch(swipeProvider);
    final cartItems = swipeState.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'LOGO.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? EmptyCartState(
              onStartShopping: () {
                Navigator.pop(context);
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildCartItem(item, context, ref).animate().slide().then().fadeIn();
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cart summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${cartItems.length} item${cartItems.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Total: \$${ref.read(swipeProvider.notifier).getCartTotal().toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Checkout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Process checkout
                          _processCheckout(context, cartItems, ref);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCartItem(CartItemModel cartItem, BuildContext context, WidgetRef ref) {
    final product = cartItem.product;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                ),
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls[0],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                            child: const Icon(Icons.image_not_supported, size: 30),
                          );
                        },
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                        child: const Icon(Icons.image_not_supported, size: 30),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${product.currency} ${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'x ${cartItem.quantity}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.currency} ${cartItem.totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Quantity selector and remove button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: () {
                          // Haptic feedback
                          HapticFeedback.selectionClick();
                          // Decrease quantity
                          ref.read(swipeProvider.notifier).decrementCartItemQuantity(
                            product.id,
                            selectedSize: cartItem.selectedSize,
                            selectedColor: cartItem.selectedColor,
                          );
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${cartItem.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () {
                          // Haptic feedback
                          HapticFeedback.selectionClick();
                          // Increase quantity
                          ref.read(swipeProvider.notifier).incrementCartItemQuantity(
                            product.id,
                            selectedSize: cartItem.selectedSize,
                            selectedColor: cartItem.selectedColor,
                          );
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    // Haptic feedback
                    HapticFeedback.mediumImpact();
                    // Remove item from cart
                    ref.read(swipeProvider.notifier).removeFromCart(
                      product.id,
                      selectedSize: cartItem.selectedSize,
                      selectedColor: cartItem.selectedColor,
                    );
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 void _processCheckout(BuildContext context, List<CartItemModel> items, WidgetRef ref) {
    // Navigate to checkout page with smooth transition
    Navigator.push(
      context,
      PageTransitions.slideFromRightTransition(page: CheckoutPage(
        cartItems: items,
        total: ref.read(swipeProvider.notifier).getCartTotal(),
      )),
    );
 }
}

class CheckoutPage extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double total;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.total,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();
  String _email = '';
  String _address = '';
  String _city = '';
  String _postalCode = '';
  String _cardNumber = '';
  String _expiryMonth = '';
  String _expiryYear = '';
  String _cvv = '';
  bool _isProcessing = false;

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'LOGO.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Section header with icon
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Delivery Information',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Email field with improved styling
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'your.email@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: false, // Remove fill since we're using container
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // SECURITY FIX: Proper email validation
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
            ),
            const SizedBox(height: 16),
            
            // Address field with improved styling
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: '123 Main Street, Apt 4B',
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: false, // Remove fill since we're using container
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) => _address = value!,
              ),
            ),
            const SizedBox(height: 16),
            
            // City and Postal Code row with improved styling
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'City',
                        hintText: 'New York',
                        prefixIcon: const Icon(Icons.location_city_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: false, // Remove fill since we're using container
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                      onSaved: (value) => _city = value!,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'ZIP/Postal Code',
                        hintText: '10001',
                        prefixIcon: const Icon(Icons.numbers_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: false, // Remove fill since we're using container
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your postal code';
                        }
                        return null;
                      },
                      onSaved: (value) => _postalCode = value!,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Payment method section with improved styling
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.payment, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Icon(Icons.credit_card, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Credit/Debit Card', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Card Number with improved styling
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).inputDecorationTheme.fillColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Card Number',
                              hintText: '1234 5678 9012 3456',
                              prefixIcon: const Icon(Icons.credit_card_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: false, // Remove fill since we're using container
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter card number';
                              }
                              if (!_paymentService.validateCardNumber(value)) {
                                return 'Please enter a valid card number';
                              }
                              return null;
                            },
                            onChanged: (value) => _cardNumber = value,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Expiry and CVV row with improved styling
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).inputDecorationTheme.fillColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'MM',
                                    hintText: '01',
                                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: false, // Remove fill since we're using container
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Month required';
                                    }
                                    final month = int.tryParse(value);
                                    if (month == null || month < 1 || month > 12) {
                                      return 'Invalid month';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => _expiryMonth = value,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).inputDecorationTheme.fillColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'YY',
                                    hintText: '24',
                                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: false, // Remove fill since we're using container
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Year required';
                                  }
                                  final year = int.tryParse(value);
                                  final currentYear = DateTime.now().year % 100;
                                  if (year == null || year < currentYear) {
                                    return 'Invalid year';
                                  }
                                  return null;
                                },
                                onChanged: (value) => _expiryYear = value,
                              ),
                            ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).inputDecorationTheme.fillColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'CVV',
                                    hintText: '123',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: false, // Remove fill since we're using container
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  ),
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'CVV required';
                                    }
                                    if (!_paymentService.validateCvv(value, _cardNumber)) {
                                      return 'Invalid CVV';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => _cvv = value,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Order summary section with improved styling
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildOrderSummaryRow('Subtotal', '\$${widget.total.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildOrderSummaryRow('Shipping', '\$5.00'),
                    const Divider(height: 24),
                    _buildOrderSummaryRow('Tax', '\$${(widget.total * 0.08).toStringAsFixed(2)}', isTotal: false),
                    const Divider(height: 24),
                    _buildOrderSummaryRow('Total', '\$${(widget.total * 1.08 + 5).toStringAsFixed(2)}', isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Place order button with enhanced styling
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Process payment securely
                    _processSecurePayment();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isProcessing ? Colors.grey : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Place Order',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

  // Helper method to build order summary rows
  Widget _buildOrderSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  void _processSecurePayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // In a real app, we would tokenize the card info and send it to our server
      // which would then communicate with the payment processor
      final token = await _paymentService.tokenizePaymentInfo(
        cardNumber: _cardNumber,
        expiryMonth: _expiryMonth,
        expiryYear: _expiryYear,
        cvv: _cvv,
      );

      // Process the payment using the token
      final success = await _paymentService.processPayment(
        paymentMethod: token,
        amount: widget.total + 5, // total + shipping
        currency: 'USD',
        userId: 'user_id_placeholder', // Would get from auth
        productIds: widget.cartItems.map((item) => item.product.id).toList(),
      );

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Payment processed successfully!'),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          );
          // Navigate back to home
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Payment failed: ${e.toString()}'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

// Empty state widget for cart
class CartEmptyState extends StatelessWidget {
  const CartEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add items by swiping down on product cards',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to home to start shopping
                Navigator.pop(context);
              },
              child: Text('Start Shopping', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// SECURITY: Insecure card handling code removed
// In production, use PCI-compliant payment processors like Stripe, PayPal, or Square
// NEVER handle card details directly in the app