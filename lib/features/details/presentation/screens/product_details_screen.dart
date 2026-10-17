import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';

/// Product details. Opened from the home list (with [initialProduct]) or
/// from a deep link like `humavolve://huma-volve.com/product/5` (only the
/// [productId] is known, so the product is loaded from the API).
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  final int productId;

  /// The product already loaded in the home list, so it shows at once.
  final ProductEntity? initialProduct;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Injection.productDetailsCubit(
        productId: productId,
        initialProduct: initialProduct,
      )..loadIfNeeded(),
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoaded) {
            return _ProductDetailsView(product: state.product);
          }
          if (state is ProductDetailsError) {
            return _MessageScaffold(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppTheme.error,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  TextButton(
                    onPressed: context.read<ProductDetailsCubit>().loadProduct,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }
          return const _MessageScaffold(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        },
      ),
    );
  }
}

/// A page with a back button and [child] in the center
/// (used for the loading and error states).
class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: const _CircleIconButton(
          icon: Icons.arrow_back_ios_new,
          iconSize: 16,
        ),
      ),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    );
  }
}

/// The white round buttons on top of the product image.
/// Without [onPressed] the button goes back.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    this.onPressed,
    this.iconSize = 18,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: iconSize),
      ),
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}

class _ProductDetailsView extends StatefulWidget {
  const _ProductDetailsView({required this.product});

  final ProductEntity product;

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<_ProductDetailsView> {
  int _currentImage = 0;

  /// Copies the deep link of this product so it can be shared. Opening it
  /// on a phone with the app installed shows this product in the app.
  Future<void> _copyProductLink() async {
    final link = DeepLinks.product(widget.product.id).toString();
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    showAppSnackBar(context, 'Product link copied: $link', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images.isNotEmpty ? product.images : [''];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: const _CircleIconButton(
              icon: Icons.arrow_back_ios_new,
              iconSize: 16,
            ),
            actions: [
              _CircleIconButton(icon: Icons.link, onPressed: _copyProductLink),
              _CircleIconButton(icon: Icons.favorite_border, onPressed: () {}),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Swipe between the product images from the API.
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => _currentImage = index);
                    },
                    itemBuilder: (context, index) {
                      final image = NetworkImageBox(
                        url: images[index],
                        width: double.infinity,
                        height: double.infinity,
                      );
                      return index == 0
                          ? Hero(tag: 'product-${product.id}', child: image)
                          : image;
                    },
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 48,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          final isActive = index == _currentImage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.primary
                                  : Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              transform: Matrix4.translationValues(0.0, -32.0, 0.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category!.name,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(fontSize: 28, height: 1.2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: AppTheme.primary, fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Add to Cart',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to cart'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: AppTheme.primary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
