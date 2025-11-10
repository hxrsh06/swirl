import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/presentation/constants/app_spacing.dart';
import 'package:shopping_swipe_app/presentation/providers/swipe_provider.dart';
import 'package:shopping_swipe_app/data/services/payment_service.dart';
import 'package:shopping_swipe_app/presentation/utils/page_transitions.dart';
import 'package:shopping_swipe_app/presentation/widgets/success_animation.dart';

// Modern checkout flow with contemporary UI/UX patterns
class CheckoutFlow extends StatefulWidget {
  final List<ProductModel> cartItems;
  final double total;

  const CheckoutFlow({
    Key? key,
    required this.cartItems,
    required this.total,
  }) : super(key: key);

  @override
  State<CheckoutFlow> createState() => _CheckoutFlowState();
}

class _CheckoutFlowState extends State<CheckoutFlow> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PaymentService _paymentService = PaymentService();
  
  // Form controllers for progressive validation
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cardNumberController = TextEditingController();
 final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
 final _cvvController = TextEditingController();
  
  // Form focus nodes for progressive validation
  final _emailFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _postalCodeFocus = FocusNode();
  final _cardNumberFocus = FocusNode();
  final _expiryMonthFocus = FocusNode();
  final _expiryYearFocus = FocusNode();
  final _cvvFocus = FocusNode();
  
  // Step tracking
  int _currentStep = 0;
  bool _isProcessing = false;
  bool _isCardValid = false;
  String _cardType = '';
  
  // Validation states for progressive validation
  bool _emailValid = false;
  bool _addressValid = false;
  bool _cityValid = false;
  bool _postalCodeValid = false;
  bool _cardNumberValid = false;
  bool _expiryValid = false;
  bool _cvvValid = false;
  
  // Animation controllers
  late AnimationController _stepAnimationController;
  late Animation<double> _stepAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _stepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Set up focus listeners for progressive validation
    _emailFocus.addListener(_onEmailFocusChange);
    _addressFocus.addListener(_onAddressFocusChange);
    _cityFocus.addListener(_onCityFocusChange);
    _postalCodeFocus.addListener(_onPostalCodeFocusChange);
    _cardNumberFocus.addListener(_onCardNumberFocusChange);
    _expiryMonthFocus.addListener(_onExpiryFocusChange);
    _expiryYearFocus.addListener(_onExpiryFocusChange);
    _cvvFocus.addListener(_onCvvFocusChange);
  }
  
  @override
  void dispose() {
    // Dispose controllers and focus nodes
    _stepAnimationController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    
    _emailFocus.removeListener(_onEmailFocusChange);
    _addressFocus.removeListener(_onAddressFocusChange);
    _cityFocus.removeListener(_onCityFocusChange);
    _postalCodeFocus.removeListener(_onPostalCodeFocusChange);
    _cardNumberFocus.removeListener(_onCardNumberFocusChange);
    _expiryMonthFocus.removeListener(_onExpiryFocusChange);
    _expiryYearFocus.removeListener(_onExpiryFocusChange);
    _cvvFocus.removeListener(_onCvvFocusChange);
    
    _emailFocus.dispose();
    _addressFocus.dispose();
    _cityFocus.dispose();
    _postalCodeFocus.dispose();
    _cardNumberFocus.dispose();
    _expiryMonthFocus.dispose();
    _expiryYearFocus.dispose();
    _cvvFocus.dispose();
    
    super.dispose();
  }
  
  void _onEmailFocusChange() {
    if (!_emailFocus.hasFocus && _emailController.text.isNotEmpty) {
      setState(() {
        _emailValid = _validateEmail(_emailController.text);
      });
    }
  }
  
  void _onAddressFocusChange() {
    if (!_addressFocus.hasFocus && _addressController.text.isNotEmpty) {
      setState(() {
        _addressValid = _addressController.text.length >= 5;
      });
    }
  }
  
  void _onCityFocusChange() {
    if (!_cityFocus.hasFocus && _cityController.text.isNotEmpty) {
      setState(() {
        _cityValid = _cityController.text.length >= 2;
      });
    }
  }
  
  void _onPostalCodeFocusChange() {
    if (!_postalCodeFocus.hasFocus && _postalCodeController.text.isNotEmpty) {
      setState(() {
        _postalCodeValid = _postalCodeController.text.length >= 3;
      });
    }
  }
  
  void _onCardNumberFocusChange() {
    if (!_cardNumberFocus.hasFocus && _cardNumberController.text.isNotEmpty) {
      final cleanNumber = _cardNumberController.text.replaceAll(RegExp(r'\s+'), '');
      setState(() {
        _cardNumberValid = _paymentService.validateCardNumber(cleanNumber);
        _cardType = _getCardType(cleanNumber);
      });
    }
  }
  
  void _onExpiryFocusChange() {
    if ((!_expiryMonthFocus.hasFocus || !_expiryYearFocus.hasFocus) && 
        _expiryMonthController.text.isNotEmpty && 
        _expiryYearController.text.isNotEmpty) {
      setState(() {
        _expiryValid = _paymentService.validateExpiryDate(
          _expiryMonthController.text,
          _expiryYearController.text,
        );
      });
    }
  }
  
  void _onCvvFocusChange() {
    if (!_cvvFocus.hasFocus && _cvvController.text.isNotEmpty) {
      setState(() {
        _cvvValid = _paymentService.validateCvv(
          _cvvController.text,
          _cardNumberController.text,
        );
      });
    }
  }
  
  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  String _getCardType(String cardNumber) {
    if (cardNumber.startsWith(RegExp(r'^(4)'))) {
      return 'Visa';
    } else if (cardNumber.startsWith(RegExp(r'^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[0-1]|2720)'))) {
      return 'Mastercard';
    } else if (cardNumber.startsWith(RegExp(r'^(3[47])'))) {
      return 'Amex';
    } else if (cardNumber.startsWith(RegExp(r'^(35)'))) {
      return 'JCB';
    } else if (cardNumber.startsWith(RegExp(r'^(6011|622|64|65)'))) {
      return 'Discover';
    }
    return 'Card';
  }
  
  void _nextStep() {
    if (_currentStep < 3) {
      _stepAnimationController.forward().then((_) {
        setState(() {
          _currentStep++;
        });
        _stepAnimationController.reset();
      });
    } else {
      _processCheckout();
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      _stepAnimationController.reverse().then((_) {
        setState(() {
          _currentStep--;
        });
        _stepAnimationController.forward();
      });
    }
  }
  
 void _processCheckout() async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final token = await _paymentService.tokenizePaymentInfo(
        cardNumber: _cardNumberController.text.replaceAll(RegExp(r'\s+'), ''),
        expiryMonth: _expiryMonthController.text,
        expiryYear: _expiryYearController.text,
        cvv: _cvvController.text,
      );
      
      final success = await _paymentService.processPayment(
        paymentMethod: token,
        amount: widget.total + 5, // total + shipping
        currency: 'USD',
        userId: 'user_id_placeholder',
        productIds: widget.cartItems.map((item) => item.id).toList(),
      );
      
      if (success) {
        if (mounted) {
          _showSuccessAnimation();
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Payment failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  void _showSuccessAnimation() {
    Navigator.pushReplacement(
      context,
      PageTransitions.slideFromRightTransition(
        page: const OrderSuccessPage(),
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
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
        leading: _currentStep > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _stepAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  (_currentStep - 0) * MediaQuery.of(context).size.width * _stepAnimation.value,
                  0,
                ),
                child: child,
              );
            },
            child: _buildStepContent(0),
          ),
          if (_currentStep >= 1)
            AnimatedBuilder(
              animation: _stepAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    (_currentStep - 1) * MediaQuery.of(context).size.width * _stepAnimation.value,
                    0,
                  ),
                  child: child,
                );
              },
              child: _buildStepContent(1),
            ),
          if (_currentStep >= 2)
            AnimatedBuilder(
              animation: _stepAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    (_currentStep - 2) * MediaQuery.of(context).size.width * _stepAnimation.value,
                    0,
                  ),
                  child: child,
                );
              },
              child: _buildStepContent(2),
            ),
          if (_currentStep >= 3)
            AnimatedBuilder(
              animation: _stepAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    (_currentStep - 3) * MediaQuery.of(context).size.width * _stepAnimation.value,
                    0,
                  ),
                  child: child,
                );
              },
              child: _buildStepContent(3),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
  
  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildDeliveryInfoStep();
      case 1:
        return _buildPaymentInfoStep();
      case 2:
        return _buildOrderSummaryStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return const SizedBox.shrink();
    }
 }
  
  Widget _buildDeliveryInfoStep() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingXxl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('1', 'Delivery Information'),
          const SizedBox(height: 24),
          
          // Email field with progressive validation
          _buildValidatedTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            label: 'Email Address',
            hint: 'your.email@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            isValid: _emailValid,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 16),
          
          // Address field with progressive validation
          _buildValidatedTextField(
            controller: _addressController,
            focusNode: _addressFocus,
            label: 'Delivery Address',
            hint: '123 Main Street, Apt 4B',
            icon: Icons.home_outlined,
            validator: (value) => value.length >= 5,
            isValid: _addressValid,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // City field with progressive validation
              Expanded(
                child: _buildValidatedTextField(
                  controller: _cityController,
                  focusNode: _cityFocus,
                  label: 'City',
                  hint: 'New York',
                  icon: Icons.location_city_outlined,
                  validator: (value) => value.length >= 2,
                  isValid: _cityValid,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                ),
              ),
              const SizedBox(width: 16),
              // Postal Code field with progressive validation
              Expanded(
                child: _buildValidatedTextField(
                  controller: _postalCodeController,
                  focusNode: _postalCodeFocus,
                  label: 'ZIP/Postal Code',
                  hint: '10001',
                  icon: Icons.numbers_outlined,
                  validator: (value) => value.length >= 3,
                  isValid: _postalCodeValid,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentInfoStep() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingXxl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('2', 'Payment Method'),
          const SizedBox(height: 24),
          
          // Card Number with progressive validation and card type indicator
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _cardNumberValid 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).dividerColor.withOpacity(0.2),
                width: _cardNumberValid ? 2 : 0.5,
              ),
            ),
            child: TextFormField(
              controller: _cardNumberController,
              focusNode: _cardNumberFocus,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                prefixIcon: Icon(
                  _cardType == 'Visa' ? Icons.credit_card : 
                  _cardType == 'Mastercard' ? Icons.credit_card : 
                  _cardType == 'Amex' ? Icons.credit_card : 
                  Icons.credit_card_outlined,
                  color: _cardNumberValid 
                      ? Theme.of(context).colorScheme.primary 
                      : null,
                ),
                suffixIcon: _cardNumberController.text.isNotEmpty
                    ? Icon(
                        _cardType == 'Visa' ? Icons.account_balance 
                        : _cardType == 'Mastercard' ? Icons.account_balance 
                        : _cardType == 'Amex' ? Icons.account_balance 
                        : Icons.account_balance,
                        color: _cardNumberValid 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).dividerColor,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Format card number as user types
                String formattedValue = value.replaceAll(RegExp(r'\s+'), '');
                if (formattedValue.length > 4 && formattedValue.length <= 8) {
                  formattedValue = '${formattedValue.substring(0, 4)} ${formattedValue.substring(4)}';
                } else if (formattedValue.length > 8 && formattedValue.length <= 12) {
                  formattedValue = '${formattedValue.substring(0, 4)} ${formattedValue.substring(4, 8)} ${formattedValue.substring(8)}';
                } else if (formattedValue.length > 12) {
                  formattedValue = '${formattedValue.substring(0, 4)} ${formattedValue.substring(4, 8)} ${formattedValue.substring(8, 12)} ${formattedValue.substring(12)}';
                }
                if (formattedValue != value) {
                  _cardNumberController.value = TextEditingValue(
                    text: formattedValue,
                    selection: TextSelection.collapsed(offset: formattedValue.length),
                  );
                }
              },
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
          ),
          if (_cardNumberController.text.isNotEmpty && !_cardNumberValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please enter a valid card number',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Expiry and CVV row with progressive validation
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _expiryValid 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).dividerColor.withOpacity(0.2),
                      width: _expiryValid ? 2 : 0.5,
                    ),
                  ),
                  child: TextFormField(
                    controller: _expiryMonthController,
                    focusNode: _expiryMonthFocus,
                    decoration: InputDecoration(
                      labelText: 'MM',
                      hintText: '01',
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
                      color: _expiryValid 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).dividerColor.withOpacity(0.2),
                      width: _expiryValid ? 2 : 0.5,
                    ),
                  ),
                  child: TextFormField(
                    controller: _expiryYearController,
                    focusNode: _expiryYearFocus,
                    decoration: InputDecoration(
                      labelText: 'YY',
                      hintText: '24',
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
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
                      color: _cvvValid 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).dividerColor.withOpacity(0.2),
                      width: _cvvValid ? 2 : 0.5,
                    ),
                  ),
                  child: TextFormField(
                    controller: _cvvController,
                    focusNode: _cvvFocus,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) => _nextStep(),
                  ),
                ),
              ),
            ],
          ),
          if (_expiryMonthController.text.isNotEmpty && !_expiryValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please enter a valid expiry date',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          if (_cvvController.text.isNotEmpty && !_cvvValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please enter a valid CVV',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
 Widget _buildOrderSummaryStep() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingXxl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('3', 'Order Summary'),
          const SizedBox(height: 24),
          
          // Cart items summary with skeleton loading
          if (widget.cartItems.isEmpty)
            _buildSkeletonCartItems()
          else
            ...widget.cartItems.map((item) => _buildCartItemSummary(item)).toList(),
          
          const SizedBox(height: 24),
          
          // Order totals
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Padding(
              padding: AppSpacing.paddingXl,
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
        ],
      ),
    );
  }
  
  Widget _buildConfirmationStep() {
    return Container(
      padding: AppSpacing.paddingXxl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isProcessing)
            Column(
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Processing Payment...',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we process your order',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else
            Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Successful!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order has been placed successfully',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildValidatedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool Function(String) validator,
    required bool isValid,
    required Function(String) onFieldSubmitted,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).dividerColor.withOpacity(0.2),
          width: isValid ? 2 : 0.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: controller.text.isNotEmpty
              ? Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.error,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (!validator(value)) {
            return 'Please enter a valid value';
          }
          return null;
        },
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }
  
  Widget _buildStepHeader(String stepNumber, String title) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCartItemSummary(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
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
                            child: const Icon(Icons.image_not_supported, size: 20),
                          );
                        },
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                        child: const Icon(Icons.image_not_supported, size: 20),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${product.currency} ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkeletonCartItems() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
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
  
  Widget _buildBottomNavigation() {
    if (_currentStep == 3) return const SizedBox.shrink(); // Hide for confirmation step
    
    return Container(
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
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              flex: _currentStep > 0 ? 2 : 3,
              child: ElevatedButton(
                onPressed: _getStepAction(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _currentStep < 3
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 2 ? 'Place Order' : 'Continue',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentStep == 2 ? Icons.shopping_bag : Icons.arrow_forward,
                            size: 18,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Processing...',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
  
  VoidCallback? _getStepAction() {
    if (_isProcessing) return null;
    
    switch (_currentStep) {
      case 0:
        // Validate delivery info
        if (!_emailValid || !_addressValid || !_cityValid || !_postalCodeValid) {
          return null;
        }
        return _nextStep;
      case 1:
        // Validate payment info
        if (!_cardNumberValid || !_expiryValid || !_cvvValid) {
          return null;
        }
        return _nextStep;
      case 2:
        // Place order
        return _nextStep;
      default:
        return null;
    }
  }
}

// Success page for order confirmation
class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({Key? key}) : super(key: key);

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
      body: Container(
        padding: AppSpacing.paddingXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success animation with confetti
            const SizedBox(
              height: 200,
              child: SuccessAnimationWidget(),
            ),
            const SizedBox(height: 32),
            Text(
              'Order Placed Successfully!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Thank you for your order. A confirmation email has been sent to your inbox.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to home
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue Shopping',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty state widget for cart with illustration
class CartEmptyState extends StatelessWidget {
  const CartEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingXxl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
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
              child: Text(
                'Start Shopping',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}