import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';

const List<String> kCategories = [
  'Earrings', 'Necklaces', 'Bracelets', 'Rings', 'Bangles',
  'Anklets', 'Pendants', 'Sets', 'Hair Accessories', 'Nose Pins',
];

const List<String> kVibes = [
  'Daily Minimalist', 'Party / Glam', 'Old Money', 'Bohemian',
  'Street Wear', 'Bridal', 'Festive', 'Office Wear', 'Casual Chic', 'Y2K / Retro',
];

const List<String> kMaterials = [
  'Gold Plated', '925 Sterling Silver', 'Rose Gold Plated', 'Oxidised Silver',
  'Brass', 'Copper', 'Stainless Steel', 'Platinum Plated', 'White Gold',
  'Kundan', 'Meenakari', 'Panchdhatu', 'Terracotta', 'Thread / Fabric',
  'Acrylic / Resin', 'Mixed Metal',
];

class ProductFormScreen extends HookConsumerWidget {
  final String? productId;
  const ProductFormScreen({super.key, this.productId});

  bool get isEditing => productId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final product = isEditing
        ? productsAsync.value?.firstWhere((p) => p.id == productId,
            orElse: () => throw StateError('not found'))
        : null;

    final nameCtrl      = useTextEditingController(text: product?.productName ?? '');
    final brandCtrl     = useTextEditingController(text: product?.brandName ?? '');
    final descCtrl      = useTextEditingController(text: product?.description ?? '');
    final priceCtrl     = useTextEditingController(text: product?.price.toStringAsFixed(0) ?? '');
    final origPriceCtrl = useTextEditingController(text: product?.originalPrice?.toStringAsFixed(0) ?? '');
    final urlCtrl       = useTextEditingController();

    final selectedCategory = useState<String?>(product?.category);
    final selectedVibe     = useState<String?>(product?.vibe);
    final selectedMaterial = useState<String?>(
      product?.material != null && kMaterials.contains(product!.material)
          ? product.material : null,
    );
    final inStock      = useState(product?.inStock ?? true);
    final isExpress    = useState(product?.isExpress ?? false);
    // Existing network URLs (from saved product or URL paste)
    final imageUrls    = useState<List<String>>(product?.imageUrls ?? []);
    // Locally picked files — shown with Image.file, uploaded on save
    final localFiles   = useState<List<File>>([]);
    final saving       = useState(false);

    Future<void> pickFromGallery() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) return;
      localFiles.value = [...localFiles.value, File(picked.path)];
    }

    void addImageUrl() {
      final url = urlCtrl.text.trim();
      if (url.isEmpty) return;
      imageUrls.value = [...imageUrls.value, url];
      urlCtrl.clear();
    }

    Future<void> save() async {
      if (nameCtrl.text.trim().isEmpty || priceCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Name and price are required'),
          backgroundColor: AppTheme.error,
        ));
        return;
      }
      saving.value = true;

      // Try to upload any locally picked images
      final uploadedUrls = <String>[];
      var uploadFailed = false;
      for (final file in localFiles.value) {
        try {
          final url = await ref.read(productsProvider.notifier).uploadImage(
            file,
            file.path.split('/').last,
          );
          uploadedUrls.add(url);
        } catch (_) {
          uploadFailed = true;
        }
      }

      final allUrls = [...imageUrls.value, ...uploadedUrls];

      try {
        final data = {
          'product_name': nameCtrl.text.trim(),
          'brand_name':   brandCtrl.text.trim(),
          if (descCtrl.text.trim().isNotEmpty) 'description': descCtrl.text.trim(),
          'price': double.parse(priceCtrl.text),
          if (origPriceCtrl.text.isNotEmpty) 'original_price': double.parse(origPriceCtrl.text),
          if (selectedCategory.value != null) 'category': selectedCategory.value,
          if (selectedVibe.value != null)     'vibe':     selectedVibe.value,
          if (selectedMaterial.value != null) 'material': selectedMaterial.value,
          'image_urls': allUrls,
          'is_express': isExpress.value,
          'in_stock':   inStock.value,
          'tags': <String>[],
        };

        if (isEditing) {
          await ref.read(productsProvider.notifier).updateProduct(productId!, data);
        } else {
          await ref.read(productsProvider.notifier).createProduct(data);
        }

        if (context.mounted) {
          if (uploadFailed) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Product saved — some gallery images could not be uploaded. Paste URLs to add images.'),
              backgroundColor: AppTheme.warning,
              duration: Duration(seconds: 4),
            ));
          }
          context.go('/products');
        }
      } catch (e) {
        saving.value = false;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: $e'), backgroundColor: AppTheme.error),
          );
        }
      }
    }

    // Total image count for display
    final totalImages = localFiles.value.length + imageUrls.value.length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(isEditing ? 'Edit Product' : 'New Product'),
        actions: [
          TextButton(
            onPressed: saving.value ? null : () => context.go('/products'),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: saving.value ? null : save,
            child: saving.value
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                : const Text('Save', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Images ────────────────────────────────────────────────────────
          const _SectionLabel('Product Images'),
          const SizedBox(height: 10),

          SizedBox(
            height: 104,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Add from gallery button
                GestureDetector(
                  onTap: pickFromGallery,
                  child: Container(
                    width: 100, height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.secondary.withAlpha(150),
                        width: 1.5,
                      ),
                    ),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primary, size: 28),
                      SizedBox(height: 5),
                      Text('Gallery', style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),

                // Local file previews
                ...localFiles.value.asMap().entries.map((e) => _ImageThumb(
                  child: Image.file(e.value, width: 100, height: 100, fit: BoxFit.cover),
                  onRemove: () {
                    final list = [...localFiles.value]..removeAt(e.key);
                    localFiles.value = list;
                  },
                )),

                // Network URL previews
                ...imageUrls.value.asMap().entries.map((e) => _ImageThumb(
                  child: Image.network(
                    e.value, width: 100, height: 100, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100, height: 100,
                      color: AppTheme.surfaceVariant,
                      child: const Icon(Icons.broken_image_outlined, color: AppTheme.textSecondary),
                    ),
                  ),
                  onRemove: () {
                    final list = [...imageUrls.value]..removeAt(e.key);
                    imageUrls.value = list;
                  },
                )),
              ],
            ),
          ),

          if (totalImages == 0) ...[
            const SizedBox(height: 6),
            Text(
              'Tap "Gallery" to add photos from your phone',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withAlpha(180)),
            ),
          ],

          // URL paste row
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Or paste image URL',
                  hintText: 'https://...',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: addImageUrl,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Basic Info ─────────────────────────────────────────────────────
          const _SectionLabel('Basic Info'),
          const SizedBox(height: 10),
          _Field(controller: nameCtrl, label: 'Product Name *', hint: 'e.g. Gold Hoop Earrings'),
          const SizedBox(height: 12),
          _Field(controller: brandCtrl, label: 'Brand Name', hint: 'e.g. AURAMIKA'),
          const SizedBox(height: 12),
          _Field(controller: descCtrl, label: 'Description', hint: 'Describe the product…', maxLines: 3),
          const SizedBox(height: 20),

          // ── Pricing ────────────────────────────────────────────────────────
          const _SectionLabel('Pricing'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _Field(
              controller: priceCtrl, label: 'Price (₹) *', hint: '499',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            )),
            const SizedBox(width: 12),
            Expanded(child: _Field(
              controller: origPriceCtrl, label: 'Original Price (₹)', hint: '799',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            )),
          ]),
          const SizedBox(height: 20),

          // ── Details ────────────────────────────────────────────────────────
          const _SectionLabel('Details'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _Dropdown(
              label: 'Category',
              value: selectedCategory.value,
              items: kCategories,
              onChanged: (v) => selectedCategory.value = v,
            )),
            const SizedBox(width: 12),
            Expanded(child: _Dropdown(
              label: 'Material',
              value: selectedMaterial.value,
              items: kMaterials,
              onChanged: (v) => selectedMaterial.value = v,
            )),
          ]),
          const SizedBox(height: 12),
          _Dropdown(
            label: 'Vibe / Style',
            value: selectedVibe.value,
            items: kVibes,
            onChanged: (v) => selectedVibe.value = v,
          ),
          const SizedBox(height: 20),

          // ── Options ────────────────────────────────────────────────────────
          const _SectionLabel('Options'),
          const SizedBox(height: 10),
          _Toggle(label: 'In Stock', value: inStock.value, onChanged: (v) => inStock.value = v),
          _Toggle(label: '⚡ Express Delivery (2-hr)', value: isExpress.value, onChanged: (v) => isExpress.value = v),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saving.value ? null : save,
              child: saving.value
                  ? const SizedBox(height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEditing ? 'Update Product' : 'Create Product'),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ── Image thumbnail with remove button ─────────────────────────────────────────

class _ImageThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  const _ImageThumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 8),
    child: Stack(children: [
      ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
      Positioned(
        top: 4, right: 4,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 12, color: Colors.white),
          ),
        ),
      ),
    ]),
  );
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
        color: AppTheme.secondary, letterSpacing: 0.5),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value,
    onChanged: onChanged,
    dropdownColor: AppTheme.surface,
    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
    decoration: InputDecoration(labelText: label),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
  );
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
      Switch(value: value, onChanged: onChanged),
    ]),
  );
}
