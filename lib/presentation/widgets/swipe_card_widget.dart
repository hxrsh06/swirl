import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class SwipeCardWidget extends StatefulWidget {
  final List<ProductModel> products;
  final Function(ProductModel, bool) onSwipe; // true for like, false for dislike
  final Function(ProductModel) onUpSwipe; // for details
  final Function(ProductModel) onDownSwipe; // for add to cart

 const SwipeCardWidget({
    Key? key,
    required this.products,
    required this.onSwipe,
    required this.onUpSwipe,
    required this.onDownSwipe,
  }) : super(key: key);

  @override
  SwipeCardWidgetState createState() => SwipeCardWidgetState();
}

class SwipeCardWidgetState extends State<SwipeCardWidget> with TickerProviderStateMixin {
  // CRITICAL FIX: Removed _currentIndex to prevent index mismatch issues
  // Always display from index 0; provider removes swiped items from the list
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _backgroundScaleController; // Separate controller for background cards
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _backgroundScaleAnimation;

  Offset _dragPosition = Offset.zero;
  bool _isDragging = false;
  bool _isAnimating = false; // Track if swipe animation is in progress

 @override
 void initState() {
    super.initState();

    // Preload images for smooth transitions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });

    // Ultra-smooth position controller with extended duration
    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Scale controller for swipe animations
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Background scale controller for background cards - separate from swipe animations
    _backgroundScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Dedicated rotation controller for smoother rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutQuint, // Ultra-smooth ease out
    ));

    // Background scale animation with default values
    _backgroundScaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundScaleController,
      curve: Curves.easeOutCubic,
    ));
    
    // Trigger the initial background animation
    _backgroundScaleController.forward();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void didUpdateWidget(SwipeCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload images when products list changes
    if (oldWidget.products != widget.products) {
      _preloadImages();
    }
  }

  /// Preload images for the next 3 cards to ensure smooth transitions
  void _preloadImages() {
    if (!mounted) return;

    final int preloadCount = 3;
    for (int i = 0; i < preloadCount && i < widget.products.length; i++) {
      final product = widget.products[i];
      if (product.imageUrls.isNotEmpty) {
        try {
          precacheImage(
            CachedNetworkImageProvider(product.imageUrls[0]),
            context,
            onError: (exception, stackTrace) {
              // Silently fail - image will load normally when card is shown
            },
          );
        } catch (e) {
          // Ignore preload errors
        }
      }
    }
  }

 @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    _backgroundScaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
 Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'No more products to show',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Check back later for new items',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Third card (if exists) - for extra depth
            if (widget.products.length > 2)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _backgroundScaleController, // Use the dedicated background controller
                  builder: (context, child) {
                    // Animate opacity from 0.4 to 0.75 as card moves forward
                    final thirdCardScale = _backgroundScaleAnimation.value * 0.85;
                    final baseThirdOpacity = 0.4;
                    final targetThirdOpacity = 0.75;
                    final opacityRange = targetThirdOpacity - baseThirdOpacity;
                    final thirdAnimatedOpacity = baseThirdOpacity + (_backgroundScaleAnimation.value - 0.92) * (opacityRange / 0.08);
                    final thirdFinalOpacity = thirdAnimatedOpacity.clamp(0.4, 0.75);

                    return Transform.scale(
                      scale: thirdCardScale,
                      child: Opacity(
                        opacity: thirdFinalOpacity,
                        child: _buildCard(
                          widget.products[2], // Always show 3rd card from list
                          isBackground: true,
                          depth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Second card (if exists) - behind current
            if (widget.products.length > 1)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _backgroundScaleController, // Use the dedicated background controller
                  builder: (context, child) {
                    // Animate opacity from 0.75 to 1.0 as scale animation progresses
                    // This prevents translucent tint when card moves to front
                    final animatedOpacity = 0.75 + (_backgroundScaleAnimation.value - 0.92) * 3.125; // Maps 0.92->1.0 to 0.75->1.0
                    final finalOpacity = animatedOpacity.clamp(0.75, 1.0);

                    return Transform.scale(
                      scale: _backgroundScaleAnimation.value,
                      child: Opacity(
                        opacity: finalOpacity,
                        child: _buildCard(
                          widget.products[1], // Always show 2nd card from list
                          isBackground: true,
                          depth: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Current card - draggable with ultra-smooth animations
            Positioned.fill(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onLongPress: () {
                  // Long-press for quick preview
                  HapticFeedback.heavyImpact();
                  widget.onUpSwipe(widget.products[0]);
                },
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _positionController,
                    _scaleController,
                    _rotationController,
                  ]),
                  builder: (context, child) {
                    // Calculate effective position
                    final position = _isDragging
                        ? _dragPosition
                        : _positionAnimation.value;

                    // ULTRA-SMOOTH rotation calculation
                    // Use sigmoid-like curve for natural feel
                    final normalizedX = (position.dx / constraints.maxWidth).clamp(-1.0, 1.0);
                    final rotation = _isDragging
                        ? normalizedX * 0.25 // Reduced max rotation for smoother feel
                        : _rotationAnimation.value;

                    // Dynamic scale based on drag distance (subtle effect)
                    final dragDistance = position.distance;
                    final maxDistance = 400.0;
                    final dragProgress = (dragDistance / maxDistance).clamp(0.0, 1.0);
                    final scale = 1.0 - (dragProgress * 0.03); // Subtle scale down

                    // Opacity fade on extreme swipes - minimal change to prevent dark hover effect
                    final opacity = 1.0 - (dragProgress * 0.1).clamp(0.0, 0.1); // Minimal opacity change

                    return Transform.translate(
                      offset: position,
                      child: Transform.rotate(
                        angle: rotation,
                        alignment: Alignment.bottomCenter,
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: _buildCard(widget.products[0]), // Always show first card
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Swipe indicators
            if (_isDragging && _dragPosition.distance > 50)
              Positioned.fill(
                child: IgnorePointer(
                  child: _buildSwipeIndicators(constraints),
                ),
              ),
          ],
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    // Prevent new swipes while animation is in progress
    if (_isAnimating) return;

    // Stop any running animations to prevent conflicts
    _positionController.stop();
    _rotationController.stop();

    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _dragPosition += details.delta;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.25; // More sensitive threshold

    // Velocity-based swipe detection
    final velocity = details.velocity.pixelsPerSecond;
    final velocityThreshold = 400.0;
    final hasVelocity = velocity.dx.abs() > velocityThreshold;

    // Check if swiped far enough horizontally OR with enough velocity
    if (_dragPosition.dx.abs() > threshold || (hasVelocity && _dragPosition.dx.abs() > 50)) {
      HapticFeedback.lightImpact(); // Haptic feedback
      _animateSwipeOut(_dragPosition.dx > 0, details.velocity);
    }
    // Check for vertical swipes
    else if (_dragPosition.dy.abs() > 80) {
      HapticFeedback.selectionClick();
      if (_dragPosition.dy < 0) {
        // Up swipe - show details
        widget.onUpSwipe(widget.products[0]);
        _animateSpringBack();
      } else {
        // Down swipe - add to cart and advance to next card
        widget.onDownSwipe(widget.products[0]);
        _animateDownSwipeOut(details.velocity);
      }
    }
    // Not enough movement - ultra-smooth spring back
    else {
      _animateSpringBack();
    }
  }

  void _animateSwipeOut(bool isLiked, Velocity velocity) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use velocity to calculate end position for natural physics
    final velocityX = velocity.pixelsPerSecond.dx;
    final baseEndX = isLiked ? screenWidth * 1.8 : -screenWidth * 1.8;
    final velocityBoost = velocityX.clamp(-800.0, 800.0) * 0.5;
    final endX = baseEndX + velocityBoost;

    // Natural arc based on current position and velocity
    final endY = _dragPosition.dy + (_dragPosition.dx * 0.3);

    _positionAnimation = Tween<Offset>(
      begin: _dragPosition,
      end: Offset(endX, endY),
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutQuart, // Smooth ease out
    ));

    // Animate rotation to final state
    final normalizedX = (_dragPosition.dx / screenWidth).clamp(-1.0, 1.0);
    final finalRotation = normalizedX * 0.4;
    _rotationAnimation = Tween<double>(
      begin: normalizedX * 0.25,
      end: finalRotation,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutQuart,
    ));

    _positionController.reset();
    _rotationController.reset();

    // Start scale animation immediately for next card - ultra fast timing
    _scaleController.reset();
    _scaleController.duration = const Duration(milliseconds: 120); // Ultra fast
    _scaleController.forward();

    // Trigger background scale animation for the next card to come into view
    _backgroundScaleController.reset();
    _backgroundScaleController.duration = const Duration(milliseconds: 120); // Ultra fast
    _backgroundScaleController.forward();

    // Use then() instead of addStatusListener to avoid listener accumulation
    _positionController.forward().then((_) async {
      if (mounted) {
        // CRITICAL FIX: Store the product reference before state changes
        // Always use index 0 since provider will remove swiped items
        final swipedProduct = widget.products[0];

        // Mark animation as in progress to prevent gesture conflicts
        setState(() {
          _isAnimating = true;
          _dragPosition = Offset.zero;
        });

        // Minimal delay for smooth state transition
        await Future.delayed(const Duration(milliseconds: 5));

        if (mounted) {
          // Reset animations to initial state
          _positionAnimation = Tween<Offset>(
            begin: Offset.zero,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _positionController,
            curve: Curves.easeOutQuint,
          ));

          _rotationAnimation = Tween<double>(
            begin: 0.0,
            end: 0.0,
          ).animate(CurvedAnimation(
            parent: _rotationController,
            curve: Curves.easeOutQuart,
          ));

          // Reset scale controller duration to default
          _scaleController.duration = const Duration(milliseconds: 250);

          // NOW notify the parent widget AFTER all state updates are done
          // Provider will remove the swiped product from list, making index 1 → index 0
          widget.onSwipe(swipedProduct, isLiked);

          // Reset animation flag
          setState(() {
            _isAnimating = false;
          });
        }
      }
    });
    _rotationController.forward();
  }

  void _animateDownSwipeOut(Velocity velocity) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Use velocity to calculate end position for natural physics
    final velocityY = velocity.pixelsPerSecond.dy;
    final velocityBoost = velocityY.clamp(-800.0, 800.0) * 0.5;
    final endY = screenHeight * 1.5 + velocityBoost;

    _positionAnimation = Tween<Offset>(
      begin: _dragPosition,
      end: Offset(_dragPosition.dx, endY),
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutQuart,
    ));

    // Slight rotation as it goes down
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutQuart,
    ));

    _positionController.reset();
    _rotationController.reset();

    // Start scale animation for next card
    _scaleController.reset();
    _scaleController.duration = const Duration(milliseconds: 120);
    _scaleController.forward();

    // Trigger background scale animation
    _backgroundScaleController.reset();
    _backgroundScaleController.duration = const Duration(milliseconds: 120);
    _backgroundScaleController.forward();

    // Animate out and advance to next card
    _positionController.forward().then((_) async {
      if (mounted) {
        final swipedProduct = widget.products[0];

        setState(() {
          _isAnimating = true;
          _dragPosition = Offset.zero;
        });

        await Future.delayed(const Duration(milliseconds: 5));

        if (mounted) {
          _positionAnimation = Tween<Offset>(
            begin: Offset.zero,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _positionController,
            curve: Curves.easeOutQuint,
          ));

          _rotationAnimation = Tween<double>(
            begin: 0.0,
            end: 0.0,
          ).animate(CurvedAnimation(
            parent: _rotationController,
            curve: Curves.easeOutQuart,
          ));

          _scaleController.duration = const Duration(milliseconds: 250);

          // Notify parent to advance to next card
          // Note: onDownSwipe was already called, this just advances the card
          widget.onSwipe(swipedProduct, false); // Mark as not liked (neutral)

          setState(() {
            _isAnimating = false;
          });
        }
      }
    });
    _rotationController.forward();
  }

  void _animateSpringBack() {
    _positionAnimation = Tween<Offset>(
      begin: _dragPosition,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutBack, // Smoother spring back
    ));

    _rotationAnimation = Tween<double>(
      begin: (_dragPosition.dx / MediaQuery.of(context).size.width) * 0.25,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutBack,
    ));

    _positionController.reset();
    _rotationController.reset();

    // Use then() instead of addStatusListener to avoid listener accumulation
    _positionController.forward().then((_) {
      if (mounted) {
        setState(() {
          _dragPosition = Offset.zero;
        });
      }
    });
    _rotationController.forward();

    // Trigger background scale animation to maintain smooth transitions
    _backgroundScaleController.reset();
    _backgroundScaleController.duration = const Duration(milliseconds: 250);
    _backgroundScaleController.forward();
  }

  /// Quick like animation for double-tap gesture
  void _quickLike() {
    if (_isAnimating || widget.products.isEmpty) return;

    // Create a quick swipe right animation
    final screenWidth = MediaQuery.of(context).size.width;
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(screenWidth * 1.5, -50),
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutCubic,
    ));

    _positionController.reset();
    _rotationController.reset();
    _scaleController.reset();
    _backgroundScaleController.reset();

    _positionController.duration = const Duration(milliseconds: 300);
    _scaleController.duration = const Duration(milliseconds: 200);
    _backgroundScaleController.duration = const Duration(milliseconds: 250);

    _scaleController.forward();
    _backgroundScaleController.forward();

    _positionController.forward().then((_) async {
      if (mounted) {
        final swipedProduct = widget.products[0];

        setState(() {
          _isAnimating = true;
          _dragPosition = Offset.zero;
        });

        await Future.delayed(const Duration(milliseconds: 20));

        if (mounted) {
          _positionAnimation = Tween<Offset>(
            begin: Offset.zero,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _positionController,
            curve: Curves.easeOutQuint,
          ));

          _rotationAnimation = Tween<double>(
            begin: 0.0,
            end: 0.0,
          ).animate(CurvedAnimation(
            parent: _rotationController,
            curve: Curves.easeOutQuart,
          ));

          _positionController.duration = const Duration(milliseconds: 400);
          _scaleController.duration = const Duration(milliseconds: 250);

          widget.onSwipe(swipedProduct, true); // true = liked

          setState(() {
            _isAnimating = false;
          });
        }
      }
    });
    _rotationController.forward();
  }


  Widget _buildSwipeIndicators(BoxConstraints constraints) {
   final opacity = (_dragPosition.dx.abs() / (constraints.maxWidth * 0.5)).clamp(0.0, 1.0);

   return Stack(
     children: [
       // Like indicator (right swipe)
       if (_dragPosition.dx > 50)
         Positioned(
           top: 100,
           right: 40,
           child: Transform.rotate(
             angle: -0.2,
             child: Opacity(
               opacity: opacity,
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.primary.withOpacity(0.95),
                   borderRadius: BorderRadius.circular(30),
                   boxShadow: [
                     BoxShadow(
                       color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                       blurRadius: 20,
                       spreadRadius: 2,
                       offset: const Offset(0, 4),
                     ),
                   ],
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Icon(Icons.favorite, color: Colors.white, size: 24),
                     const SizedBox(width: 8),
                     Text(
                       'LIKE',
                       style: Theme.of(context).textTheme.labelLarge?.copyWith(
                         color: Colors.white,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         ),

       // Dislike indicator (left swipe)
       if (_dragPosition.dx < -50)
         Positioned(
           top: 100,
           left: 40,
           child: Transform.rotate(
             angle: 0.2,
             child: Opacity(
               opacity: opacity,
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.error.withOpacity(0.95),
                   borderRadius: BorderRadius.circular(30),
                   boxShadow: [
                     BoxShadow(
                       color: Theme.of(context).colorScheme.error.withOpacity(0.4),
                       blurRadius: 20,
                       spreadRadius: 2,
                       offset: const Offset(0, 4),
                     ),
                   ],
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Icon(Icons.close, color: Colors.white, size: 24),
                     const SizedBox(width: 8),
                     Text(
                       'NOPE',
                       style: Theme.of(context).textTheme.labelLarge?.copyWith(
                         color: Colors.white,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
         ),
     ],
   );
 }

  Widget _buildCard(ProductModel product, {bool isBackground = false, int depth = 0}) {
   final marginOffset = isBackground ? (depth * 4.0 + 16.0) : 10.0;

   return Container(
     margin: EdgeInsets.all(marginOffset),
     decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(20.0),
       color: Theme.of(context).cardColor,
       boxShadow: [
         BoxShadow(
           color: Colors.grey.withOpacity(isBackground ? 0.1 : 0.15),
           spreadRadius: isBackground ? 0 : 1,
           blurRadius: isBackground ? 8 : 12,
           offset: Offset(0, isBackground ? 2 : 4),
         ),
       ],
     ),
     child: ClipRRect(
       borderRadius: BorderRadius.circular(20.0),
       child: Column(
         children: [
           // Product Image - OPTIMIZED with pre-caching
           Expanded(
             flex: 3,
             child: Stack(
               fit: StackFit.expand,
               children: [
                 _buildOptimizedImage(product),
                 // Gradient overlay for better text readability
                 Positioned(
                   bottom: 0,
                   left: 0,
                   right: 0,
                   child: Container(
                     height: 40,
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [
                           Colors.transparent,
                           Colors.black.withOpacity(0.6),
                         ],
                       ),
                     ),
                   ),
                 ),
                 // Like button in top right corner
                 Positioned(
                   top: 12,
                   right: 12,
                   child: Container(
                     width: 36,
                     height: 36,
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.9),
                       borderRadius: BorderRadius.circular(18),
                     ),
                     child: Icon(
                       Icons.favorite_border,
                       size: 18,
                       color: Colors.grey.shade600,
                     ),
                   ),
                 ),
               ],
             ),
           ),

           // Product Info
           Expanded(
             flex: 1,
             child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: [
                   // Brand and Name
                   Text(
                     product.brand,
                     style: Theme.of(context).textTheme.labelMedium?.copyWith(
                       color: Theme.of(context).colorScheme.primary,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                   const SizedBox(height: 4),
                   Text(
                     product.name,
                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: Theme.of(context).textTheme.bodyLarge?.color,
                     ),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                   const SizedBox(height: 8),
                   // Price and Rating Row
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Text(
                         '${product.currency}${product.price.toStringAsFixed(2)}',
                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                           fontWeight: FontWeight.bold,
                           color: Theme.of(context).colorScheme.primary,
                         ),
                       ),
                       Row(
                         children: [
                           Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                           const SizedBox(width: 4),
                           Text(
                             '${product.rating.toStringAsFixed(1)}',
                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
                               color: Theme.of(context).colorScheme.onSurfaceVariant,
                             ),
                           ),
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

  // PERFORMANCE OPTIMIZED IMAGE LOADING with pre-caching
  Widget _buildOptimizedImage(ProductModel product) {
    final imageUrl = product.imageUrls.isNotEmpty ? product.imageUrls[0] : '';

    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey.shade400),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,

      // PERFORMANCE: Optimized caching parameters
      memCacheHeight: 600, // Reduced memory usage
      memCacheWidth: 400,
      maxHeightDiskCache: 600, // Reduced disk cache
      maxWidthDiskCache: 400,

      // PERFORMANCE: Faster fade animations
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 100),
      fadeInCurve: Curves.easeIn,
      fadeOutCurve: Curves.easeOut,

      // PERFORMANCE: Enhanced shimmer loading placeholder
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.white,
        ),
      ),

      // PERFORMANCE: Optimized error widget
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade100,
        child: const Center(
          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}
