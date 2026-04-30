import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../cart/domain/cart_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../home/domain/home_models.dart';
import '../../../../shared/widgets/rive_animation_widget.dart';
import '../../data/openai_service.dart';

const _kAiConsentKey = 'aiStylistConsent';

// Returns true when the device region is China mainland (CN).
// OpenAI (GPT-4o) lacks the MIIT permit required under China's DST regulations,
// so the AI feature must be suppressed for CN devices. Also deselect China in
// App Store Connect → Pricing & Availability to prevent distribution entirely.
bool get _isChina {
  final locale = Platform.localeName; // e.g. "zh_CN", "en_US"
  final parts = locale.split('_');
  return parts.length >= 2 && parts.last.toUpperCase() == 'CN';
}

enum _MirrorState { idle, scanning, revealed }

class StylistScreen extends ConsumerStatefulWidget {
  const StylistScreen({super.key});
  @override
  ConsumerState<StylistScreen> createState() => _StylistScreenState();
}

class _StylistScreenState extends ConsumerState<StylistScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final OpenAIService _openAIService = OpenAIService();
  File? _outfitImage;
  _MirrorState _state = _MirrorState.idle;
  HomeProduct? _recommendation;
  bool _addedToCart = false;
  bool _consentGiven = false;
  late AnimationController _scanCtrl;
  late AnimationController _sparkleCtrl;
  late AnimationController _deckCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _sparkleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _deckCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _consentGiven = Hive.box('profile').get(_kAiConsentKey, defaultValue: false) as bool;
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _sparkleCtrl.dispose();
    _deckCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source, maxWidth: 1080, imageQuality: 85);
    if (file == null) return;
    setState(() {
      _outfitImage = File(file.path);
      _state = _MirrorState.scanning;
      _addedToCart = false;
    });
    _scanCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Try to get AI recommendation
    final productId = await _openAIService.getStylingRecommendation(
      _outfitImage!,
      HomeData.allProducts.where((p) => p.isExpressAvailable).toList(),
    );

    if (!mounted) return;

    if (productId != null) {
      // Find the product from the ID
      final product = HomeData.allProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => _pickInStockProduct(),
      );
      _recommendation = product;
    } else {
      // Fallback to random pick if AI fails
      _recommendation = _pickInStockProduct();
      // Show error toast
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI is sleeping, showing staff pick',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.terraCotta,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    setState(() => _state = _MirrorState.revealed);
    _sparkleCtrl.forward(from: 0);
    _deckCtrl.forward(from: 0);
  }

  HomeProduct _pickInStockProduct() {
    final inStock = HomeData.allProducts.where((p) => p.isExpressAvailable).toList();
    inStock.shuffle(math.Random());
    return inStock.first;
  }

  void _reset() {
    setState(() {
      _outfitImage = null;
      _state = _MirrorState.idle;
      _recommendation = null;
      _addedToCart = false;
    });
    _scanCtrl.reset();
    _sparkleCtrl.reset();
    _deckCtrl.reset();
  }

  void _onUploadTapped() {
    if (_consentGiven) {
      _showPickerSheet();
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AiConsentSheet(
        onAccept: () {
          Navigator.pop(context);
          Hive.box('profile').put(_kAiConsentKey, true);
          setState(() => _consentGiven = true);
          _showPickerSheet();
        },
        onDecline: () => Navigator.pop(context),
      ),
    );
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        onGallery: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
        onCamera: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
      ),
    );
  }

  void _onShopLook() {
    if (_recommendation == null) return;
    
    // Add item to cart
    final cartItem = CartItem(
      id: 'ci_stylist_${_recommendation!.id}_${DateTime.now().millisecondsSinceEpoch}',
      productId: _recommendation!.id,
      brandName: _recommendation!.brandName,
      productName: _recommendation!.productName,
      price: _recommendation!.price,
      material: _recommendation!.material,
      isExpressAvailable: _recommendation!.isExpressAvailable,
    );
    
    ref.read(cartProvider.notifier).addItem(cartItem);
    
    setState(() => _addedToCart = true);
    
    // Navigate to checkout after a short delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) context.push(AppRoutes.checkout);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChina) return const _ChinaRegionGate();
    final screenH = MediaQuery.of(context).size.height;
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: screenH * 0.52,
            child: _OutfitImageArea(
              image: _outfitImage,
              state: _state,
              scanCtrl: _scanCtrl,
              topPad: topPad,
              onUpload: _onUploadTapped,
              onReset: _reset,
            ),
          ),
          Expanded(
            child: _state == _MirrorState.revealed && _recommendation != null
                ? _SuggestionDeck(
                    product: _recommendation!,
                    deckCtrl: _deckCtrl,
                    sparkleCtrl: _sparkleCtrl,
                    addedToCart: _addedToCart,
                    onShopLook: _onShopLook,
                    onTryAnother: _reset,
                  )
                : _BottomPlaceholder(state: _state),
          ),
        ],
      ),
    );
  }
}

class _OutfitImageArea extends StatelessWidget {
  final File? image;
  final _MirrorState state;
  final AnimationController scanCtrl;
  final double topPad;
  final VoidCallback onUpload;
  final VoidCallback onReset;
  const _OutfitImageArea({required this.image, required this.state, required this.scanCtrl, required this.topPad, required this.onUpload, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      if (image == null) _UploadPlaceholder(onUpload: onUpload, topPad: topPad)
      else _ImageDisplay(image: image!, topPad: topPad, onReset: onReset),
      if (state == _MirrorState.scanning) _ScanOverlay(controller: scanCtrl),
    ]);
  }
}

class _UploadPlaceholder extends StatelessWidget {
  final VoidCallback onUpload;
  final double topPad;
  const _UploadPlaceholder({required this.onUpload, required this.topPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.forestGreen,
      child: Stack(children: [
        CustomPaint(painter: _DiagonalPatternPainter(), size: Size.infinite),
        Padding(
          padding: EdgeInsets.only(top: topPad),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: AppConstants.paddingM),
              child: Row(children: [
                const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
                const SizedBox(width: AppConstants.paddingS),
                Text('MAGIC MIRROR', style: AppTextStyles.categoryChip.copyWith(color: AppColors.white, letterSpacing: 3.0, fontSize: 12)),
              ]),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onUpload,
              child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 1.5),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.gold, size: 36),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.05, duration: const Duration(milliseconds: 1200), curve: Curves.easeInOut),
                const SizedBox(height: AppConstants.paddingM),
                Text('UPLOAD YOUR OUTFIT', style: AppTextStyles.categoryChip.copyWith(color: AppColors.white, letterSpacing: 3.0, fontSize: 11)),
                const SizedBox(height: AppConstants.paddingS),
                Text('AI will match jewelry to your vibe', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withValues(alpha: 0.6), fontSize: 11)),
              ]),
            ),
            const Spacer(),
          ]),
        ),
      ]),
    );
  }
}

class _ImageDisplay extends StatelessWidget {
  final File image;
  final double topPad;
  final VoidCallback onReset;
  const _ImageDisplay({required this.image, required this.topPad, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Image.file(image, fit: BoxFit.cover),
      Container(color: Colors.black.withValues(alpha: 0.25)),
      Positioned(
        top: topPad + 8, right: AppConstants.paddingM,
        child: GestureDetector(
          onTap: onReset,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(AppConstants.radiusS)),
            child: const Icon(Icons.close_rounded, size: 18),
          ),
        ),
      ),
      Positioned(
        top: topPad + 8, left: AppConstants.paddingM,
        child: Row(children: [
          const Icon(Icons.auto_awesome, color: AppColors.gold, size: 14),
          const SizedBox(width: 6),
          Text('MAGIC MIRROR', style: AppTextStyles.categoryChip.copyWith(color: AppColors.white, fontSize: 11, letterSpacing: 2.5)),
        ]),
      ),
    ]);
  }
}

class _ScanOverlay extends StatelessWidget {
  final AnimationController controller;
  const _ScanOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Stack(fit: StackFit.expand, children: [
        Container(color: Colors.black.withValues(alpha: 0.45)),
        // Rive scan beam (falls back to Flutter gradient line)
        Positioned.fill(child: const RiveScanBeam()),
        // Fallback scan line (shown when Rive not loaded)
        Positioned(
          top: controller.value * (MediaQuery.of(context).size.height * 0.52),
          left: 0, right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, AppColors.gold.withValues(alpha: 0.8), AppColors.gold, AppColors.gold.withValues(alpha: 0.8), Colors.transparent]),
              boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)],
            ),
          ),
        ),
        CustomPaint(painter: _HolographicGridPainter(progress: controller.value)),
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.auto_awesome, color: AppColors.gold, size: 32)
                .animate(onPlay: (c) => c.repeat()).rotate(duration: const Duration(seconds: 2)),
            const SizedBox(height: AppConstants.paddingM),
            Text('SCANNING YOUR VIBE...', style: AppTextStyles.categoryChip.copyWith(color: AppColors.white, letterSpacing: 3.0, fontSize: 11)),
            const SizedBox(height: AppConstants.paddingS),
            Text('Matching jewelry to your style', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withValues(alpha: 0.6), fontSize: 10)),
          ]),
        ),
      ]),
    );
  }
}

class _HolographicGridPainter extends CustomPainter {
  final double progress;
  const _HolographicGridPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.gold.withValues(alpha: 0.06 + progress * 0.04)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _HolographicGridPainter old) => old.progress != progress;
}

class _BottomPlaceholder extends StatelessWidget {
  final _MirrorState state;
  const _BottomPlaceholder({required this.state});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (state == _MirrorState.scanning) ...[
              const RiveLoadingRing(size: 48),
              const SizedBox(height: AppConstants.paddingM),
              Text('Analyzing your style...', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
            ] else ...[
              const Icon(Icons.style_outlined, size: 40, color: AppColors.textMuted),
              const SizedBox(height: AppConstants.paddingM),
              Text('Your AI recommendations\nwill appear here', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, height: 1.6), textAlign: TextAlign.center),
            ],
          ]),
        ),
      ),
    );
  }
}

class _SuggestionDeck extends StatelessWidget {
  final HomeProduct product;
  final AnimationController deckCtrl;
  final AnimationController sparkleCtrl;
  final bool addedToCart;
  final VoidCallback onShopLook;
  final VoidCallback onTryAnother;
  const _SuggestionDeck({required this.product, required this.deckCtrl, required this.sparkleCtrl, required this.addedToCart, required this.onShopLook, required this.onTryAnother});

  @override
  Widget build(BuildContext context) {
    final matColor = product.material == 'Brass' ? AppColors.brass : AppColors.copper;
    return AnimatedBuilder(
      animation: deckCtrl,
      builder: (_, child) => Transform.translate(offset: Offset(0, (1.0 - deckCtrl.value) * 60.0), child: Opacity(opacity: deckCtrl.value, child: child)),
      child: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingM, AppConstants.paddingM, MediaQuery.of(context).padding.bottom + AppConstants.paddingM),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              AnimatedBuilder(
                animation: sparkleCtrl,
                builder: (_, child) => Transform.rotate(angle: sparkleCtrl.value * 2 * math.pi, child: child),
                child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Text('STYLED FOR YOU', style: AppTextStyles.categoryChip.copyWith(fontSize: 11, letterSpacing: 3.0)),
            ]),
            const SizedBox(height: 4),
            Text('Based on your outfit vibe', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 10)),
            const SizedBox(height: AppConstants.paddingM),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusS), border: Border.all(color: AppColors.divider, width: 0.5)),
              child: Row(children: [
                Container(
                  width: 90, height: 110,
                  decoration: BoxDecoration(
                    color: matColor.withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppConstants.radiusS), bottomLeft: Radius.circular(AppConstants.radiusS)),
                  ),
                  child: Center(child: Icon(Icons.diamond_outlined, color: matColor, size: 36)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (product.isExpressAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.forestGreen, borderRadius: BorderRadius.circular(AppConstants.radiusXS)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.bolt, size: 10, color: AppColors.gold),
                            const SizedBox(width: 3),
                            const Text('GET IT IN 2 HOURS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.white, letterSpacing: 0.8)),
                          ]),
                        ),
                      const SizedBox(height: 6),
                      Text(product.productName, style: AppTextStyles.titleSmall.copyWith(fontSize: 13), maxLines: 2),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: matColor, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(product.material.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: matColor, letterSpacing: 1.2)),
                        const SizedBox(width: 8),
                        Text(product.vibe, style: AppTextStyles.bodySmall.copyWith(fontSize: 9, color: AppColors.textMuted)),
                      ]),
                      const SizedBox(height: 6),
                      Text('₹${product.price.toInt()}', style: AppTextStyles.priceTag.copyWith(fontSize: 18)),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: AppConstants.paddingM),
            GestureDetector(
              onTap: addedToCart ? null : onShopLook,
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                height: 52,
                decoration: BoxDecoration(
                  color: addedToCart ? AppColors.forestGreen.withValues(alpha: 0.7) : AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(addedToCart ? Icons.check_circle_outline_rounded : Icons.shopping_bag_outlined, size: 18, color: AppColors.white),
                  const SizedBox(width: AppConstants.paddingS),
                  Text(addedToCart ? 'ADDED TO BAG' : 'SHOP THIS LOOK', style: AppTextStyles.categoryChip.copyWith(color: AppColors.white, fontSize: 12, letterSpacing: 1.5)),
                ]),
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            GestureDetector(
              onTap: onTryAnother,
              child: Container(
                height: 44,
                decoration: BoxDecoration(border: Border.all(color: AppColors.divider, width: 0.8), borderRadius: BorderRadius.circular(AppConstants.radiusS)),
                child: Center(child: Text('TRY ANOTHER OUTFIT', style: AppTextStyles.categoryChip.copyWith(fontSize: 11, letterSpacing: 1.5, color: AppColors.textMuted))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  const _PickerSheet({required this.onGallery, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppConstants.radiusL)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: AppConstants.paddingL),
        Text('UPLOAD YOUR OUTFIT', style: AppTextStyles.titleMedium.copyWith(letterSpacing: 2.0)),
        const SizedBox(height: AppConstants.paddingS),
        Text('Choose how to add your photo', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: AppConstants.paddingL),
        Row(children: [
          Expanded(child: _PickerOption(icon: Icons.photo_library_outlined, label: 'Gallery', onTap: onGallery)),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(child: _PickerOption(icon: Icons.camera_alt_outlined, label: 'Camera', onTap: onCamera)),
        ]),
        const SizedBox(height: AppConstants.paddingM),
      ]),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingL),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusS), border: Border.all(color: AppColors.divider, width: 0.8)),
        child: Column(children: [
          Icon(icon, size: 28, color: AppColors.forestGreen),
          const SizedBox(height: AppConstants.paddingS),
          Text(label.toUpperCase(), style: AppTextStyles.categoryChip.copyWith(fontSize: 10, letterSpacing: 1.5)),
        ]),
      ),
    );
  }
}

class _ChinaRegionGate extends StatelessWidget {
  const _ChinaRegionGate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: AppConstants.paddingL),
              Text(
                'Not Available',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                'The AI Stylist feature is not available in your region.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiagonalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.gold.withValues(alpha: 0.06)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    const spacing = 28.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _AiConsentSheet extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _AiConsentSheet({required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: AppConstants.paddingL),
        const Icon(Icons.auto_awesome, color: AppColors.gold, size: 28),
        const SizedBox(height: AppConstants.paddingM),
        Text('AI Styling Uses Your Photo', style: AppTextStyles.titleMedium.copyWith(letterSpacing: 0.5)),
        const SizedBox(height: AppConstants.paddingM),
        Text(
          'To match jewelry to your outfit, your photo will be sent to an AI service for analysis. '
          'The photo is not stored on our servers and is used solely to generate your styling recommendation.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingS),
        Text(
          'By continuing, you consent to this one-time data transfer.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingL),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: onAccept,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
              decoration: BoxDecoration(color: AppColors.forestGreen, borderRadius: BorderRadius.circular(AppConstants.radiusS)),
              child: Center(child: Text('I UNDERSTAND — CONTINUE', style: AppTextStyles.categoryChip.copyWith(color: AppColors.white, fontSize: 11, letterSpacing: 1.5))),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingS),
        GestureDetector(
          onTap: onDecline,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
            child: Text('No thanks', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12)),
          ),
        ),
        const SizedBox(height: AppConstants.paddingS),
      ]),
    );
  }
}
