import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const AnimatedEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 100,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  duration: const Duration(seconds: 2),
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  curve: Curves.easeInOut,
                )
                .then()
                .shimmer(
                  duration: const Duration(milliseconds: 800),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),

            const SizedBox(height: 32),

            // Title with fade-in animation
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(
                  begin: 0.3,
                  end: 0,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: 16),

            // Subtitle with fade-in animation
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(
                  begin: 0.3,
                  end: 0,
                  curve: Curves.easeOut,
                ),

            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),

              // Animated button
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(buttonText!),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.elasticOut,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specific empty states for different contexts

class NoProductsEmptyState extends StatelessWidget {
  final VoidCallback? onExplore;

  const NoProductsEmptyState({Key? key, this.onExplore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.shopping_bag_outlined,
      title: 'No Products Found',
      subtitle: 'Swipe through more items to discover amazing products!',
      buttonText: 'Explore Recommendations',
      onButtonPressed: onExplore,
    );
  }
}

class EmptyCartState extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const EmptyCartState({Key? key, this.onStartShopping}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Your Cart is Empty',
      subtitle: 'Add items by swiping down on product cards',
      buttonText: 'Start Shopping',
      onButtonPressed: onStartShopping,
    );
  }
}

class EmptyFavoritesState extends StatelessWidget {
  final VoidCallback? onDiscover;

  const EmptyFavoritesState({Key? key, this.onDiscover}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedEmptyState(
      icon: Icons.favorite_border,
      title: 'No Favorites Yet',
      subtitle: 'Swipe right on products you love to add them to your favorites',
      buttonText: 'Discover Products',
      onButtonPressed: onDiscover,
    );
  }
}
