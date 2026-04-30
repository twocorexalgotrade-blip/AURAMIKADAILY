import 'dart:async';

import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/cashfree_service.dart';
import '../../../../shared/widgets/rive_animation_widget.dart';
import '../../../profile/domain/orders_controller.dart';
import '../../../profile/domain/user_profile_controller.dart';
import '../controllers/cart_controller.dart';

// ── Checkout Screen ───────────────────────────────────────────────────────────
/// Address → Payment → Order Summary → Pay
/// On "Pay" → navigates to OrderConfirmationScreen
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Address
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _line1Ctrl   = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _pinCtrl     = TextEditingController();

  // Payment
  _PaymentMethod _payment = _PaymentMethod.cashfree;

  // Delivery — user can override; initialised from cart in initState
  bool _isExpress = false;

  // Saved address selection
  int? _selectedAddressIndex;

  // Save address to profile
  bool _saveAddressToProfile = false;
  String _saveAddressLabel = 'Home';

  bool _paying = false;
  bool _pinLookingUp = false;
  bool _locating = false;
  String? _pinError;

  final _cashfreeService = CashfreeService();
  // Holds snapshot data while Cashfree SDK is active
  String? _pendingOrderId;
  String? _pendingProductName;
  double? _pendingTotal;
  int?    _pendingItemCount;
  String? _pendingImageAsset;
  String? _pendingDate;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameCtrl.text = profile.name;
    _phoneCtrl.text = profile.phone.replaceAll(RegExp(r'[^\d]'), '').replaceFirst('91', '', 0);
    _isExpress = ref.read(cartProvider).isAllExpress;
    _pinCtrl.addListener(_onPinChanged);

    // Register Cashfree result callbacks
    CFPaymentGatewayService().setCallback(_onPaymentVerify, _onCashfreeError);
  }

  @override
  void dispose() {
    _pinCtrl.removeListener(_onPinChanged);
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _cityCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _onPinChanged() {
    final pin = _pinCtrl.text;
    if (pin.length == 6) {
      _lookupPinCode(pin);
    } else if (_pinError != null) {
      setState(() => _pinError = null);
    }
  }

  Future<void> _lookupPinCode(String pin) async {
    setState(() { _pinLookingUp = true; _pinError = null; });
    try {
      final res = await Dio().get(
        'https://api.postalpincode.in/pincode/$pin',
        options: Options(receiveTimeout: const Duration(seconds: 8)),
      );
      if (!mounted) return;
      final list = res.data as List?;
      if (list != null && list.isNotEmpty && list[0]['Status'] == 'Success') {
        final offices = list[0]['PostOffice'] as List?;
        if (offices != null && offices.isNotEmpty) {
          final district = offices[0]['District'] as String? ?? '';
          setState(() {
            _cityCtrl.text = district;
            _pinLookingUp = false;
            _pinError = null;
          });
          return;
        }
      }
      setState(() { _pinLookingUp = false; _pinError = 'Invalid PIN code'; });
    } catch (_) {
      if (mounted) setState(() => _pinLookingUp = false);
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _locating = true);
    try {
      // 1. Check GPS is switched on
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) _showLocationSnackBar('Please enable location services on your device.');
        return;
      }

      // 2. Check / request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (mounted) _showLocationSnackBar('Location permission denied. Please allow it to auto-fill your address.');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) _showLocationSnackBar('Location permission permanently denied. Enable it in App Settings.');
        return;
      }

      // 3. Fetch position (15-second native timeout via LocationSettings)
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // 4. Reverse-geocode via OpenStreetMap Nominatim (free, no key required)
      final res = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': pos.latitude,
          'lon': pos.longitude,
          'format': 'json',
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': 'AuramikaApp/1.0 (contact@auramika.in)'},
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      if (!mounted) return;

      final addr = (res.data['address'] as Map<String, dynamic>?) ?? {};
      final road    = [addr['house_number'], addr['road']].whereType<String>().join(' ').trim();
      final suburb  = (addr['suburb'] ?? addr['neighbourhood'] ?? '') as String;
      final line1   = road.isNotEmpty ? road : suburb;
      final city    = (addr['city'] ?? addr['town'] ?? addr['state_district'] ?? addr['village'] ?? '') as String;
      final pinCode = (addr['postcode'] ?? '') as String;

      setState(() {
        if (line1.isNotEmpty)    _line1Ctrl.text = line1;
        if (city.isNotEmpty)     _cityCtrl.text  = city;
        if (pinCode.length == 6) _pinCtrl.text   = pinCode;
      });
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase().contains('timeout')
            ? 'Location timed out. Check your GPS signal and try again.'
            : 'Could not get location: ${e.toString().split('\n').first}';
        _showLocationSnackBar(msg);
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showLocationSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: AppColors.terraCotta,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ));
  }

  bool _validateAddress() {
    final missing = <String>[];
    if (_nameCtrl.text.trim().isEmpty)  missing.add('Full Name');
    if (_phoneCtrl.text.trim().isEmpty) missing.add('Phone');
    if (_line1Ctrl.text.trim().isEmpty) missing.add('Address');
    if (_cityCtrl.text.trim().isEmpty)  missing.add('City');
    if (_pinCtrl.text.trim().length != 6) missing.add('PIN Code');
    if (missing.isEmpty) return true;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Please fill in: ${missing.join(', ')}'),
        backgroundColor: AppColors.terraCotta,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
    return false;
  }

  Future<void> _pay() async {
    if (!_validateAddress()) return;
    setState(() => _paying = true);
    try {
      final cart  = ref.read(cartProvider);
      final now   = DateTime.now();
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
      final firstItem = cart.items.isNotEmpty ? cart.items.first : null;
      final productName = firstItem != null
          ? (cart.items.length > 1
              ? '${firstItem.productName} & ${cart.items.length - 1} more'
              : firstItem.productName)
          : 'Order';

      if (_payment == _PaymentMethod.cashfree) {
        // ── Online payment via Cashfree (routed through backend) ─────
        final backendItems = cart.items.map((i) => {
          'productId': i.productId,
          'productName': i.productName,
          'brandName': i.brandName,
          'price': i.price,
          'quantity': i.quantity,
          if (i.imageUrl != null) 'imageUrl': i.imageUrl!,
        }).toList();

        final address = {
          'name': _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Customer',
          'phone': _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : '9999999999',
          'line1': _line1Ctrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'pincode': _pinCtrl.text.trim(),
        };

        final result = await _cashfreeService.createOrderAndGetSession(
          items: backendItems,
          address: address,
          isExpress: _isExpress,
          customerName: _nameCtrl.text.trim(),
          customerPhone: _phoneCtrl.text.trim(),
        );

        // Snapshot for SDK callbacks; total from backend is the source of truth.
        _pendingOrderId     = result.orderId;
        _pendingProductName = productName;
        _pendingTotal       = result.total;
        _pendingItemCount   = cart.totalItems;
        _pendingImageAsset  = firstItem?.imageUrl;
        _pendingDate        = dateStr;

        final session = CFSessionBuilder()
            .setEnvironment((AppConstants.cashfreeTestMode || result.isTestMode) ? CFEnvironment.SANDBOX : CFEnvironment.PRODUCTION)
            .setPaymentSessionId(result.sessionId)
            .setOrderId(result.orderId)
            .build();

        final theme = CFThemeBuilder()
            .setNavigationBarBackgroundColorColor('#2D6A4F')
            .setNavigationBarTextColor('#FFFFFF')
            .setButtonBackgroundColor('#2D6A4F')
            .setButtonTextColor('#FFFFFF')
            .build();

        final webPayment = CFWebCheckoutPaymentBuilder()
            .setSession(session)
            .setTheme(theme)
            .build();

        CFPaymentGatewayService().doPayment(webPayment);
        // SDK takes over; result handled in _onPaymentVerify / _onCashfreeError.
        return;
      }

      // ── COD ──────────────────────────────────────────────────────
      final orderId = 'AUR${now.millisecondsSinceEpoch.toString().substring(7)}';
      final total = cart.subtotal + (_isExpress ? 0.0 : 49.0);
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      _finalizeOrder(orderId, productName, total, cart.totalItems, firstItem?.imageUrl, dateStr);
    } catch (e) {
      if (mounted) {
        final msg = _friendlyPaymentError(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.terraCotta,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  void _finalizeOrder(
    String orderId,
    String productName,
    double total,
    int itemCount,
    String? imageAsset,
    String date,
  ) {
    ref.read(ordersProvider.notifier).addOrder(OrderModel(
      id:          orderId,
      productName: productName,
      imageAsset:  imageAsset,
      total:       total,
      date:        date,
      status:      OrderStatus.processing,
      itemCount:   itemCount,
    ));

    if (_saveAddressToProfile && _line1Ctrl.text.trim().isNotEmpty) {
      ref.read(userProfileProvider.notifier).addAddress(Address(
        label:   _saveAddressLabel,
        line1:   _line1Ctrl.text.trim(),
        city:    _cityCtrl.text.trim(),
        pinCode: _pinCtrl.text.trim(),
      ));
    }

    ref.read(cartProvider.notifier).clear();
    if (mounted) context.pushReplacement(AppRoutes.orderConfirmation);
  }

  // ── Cashfree SDK callbacks ────────────────────────────────────────────────

  void _onPaymentVerify(String orderId) {
    // Defer to next frame — Cashfree callbacks fire as the native screen unwinds
    // and the Flutter context is not yet fully resumed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _paying = false);
      _finalizeOrder(
        _pendingOrderId     ?? orderId,
        _pendingProductName ?? 'Order',
        _pendingTotal       ?? 0,
        _pendingItemCount   ?? 1,
        _pendingImageAsset,
        _pendingDate        ?? '',
      );
    });
  }

  String _friendlyPaymentError(Object e) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('sign in') || raw.contains('auth')) {
      return 'Please sign in and try again.';
    }
    if (raw.contains('socket') || raw.contains('connection') ||
        raw.contains('network') || raw.contains('no-server') ||
        raw.contains('404') || raw.contains('not found')) {
      return 'Could not reach the payment server. Please check your connection and try again.';
    }
    if (raw.contains('500') || raw.contains('server error')) {
      return 'Payment server error. Please try again in a moment.';
    }
    if (raw.contains('session') || raw.contains('session id')) {
      return 'Could not start payment session. Please try again.';
    }
    return 'Payment could not be processed. Please try again.';
  }

  void _onCashfreeError(CFErrorResponse errorResponse, String orderId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorResponse.getMessage() ?? 'Payment failed'),
        backgroundColor: AppColors.terraCotta,
        behavior: SnackBarBehavior.floating,
      ));
    });
  }

  void _selectSavedAddress(int index, Address addr) {
    setState(() => _selectedAddressIndex = index);
    _line1Ctrl.text = addr.line1;
    _cityCtrl.text  = addr.city;
    _pinCtrl.text   = addr.pinCode;
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    final addresses = ref.watch(userProfileProvider).addresses;

    // Get real cart data from provider
    final cart = ref.watch(cartProvider);
    final subtotal = cart.subtotal;
    final delivery = _isExpress ? 0.0 : 49.0;
    final total = subtotal + delivery;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            padding: EdgeInsets.fromLTRB(
              AppConstants.paddingM, topPad + 8,
              AppConstants.paddingM, AppConstants.paddingM,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Text(
                    'CHECKOUT',
                    style: AppTextStyles.categoryChip.copyWith(
                      fontSize: 11, letterSpacing: 3.0,
                    ),
                  ),
                ),
                if (_isExpress)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, size: 10, color: AppColors.gold),
                        const SizedBox(width: 3),
                        Text(
                          '2 HRS',
                          style: AppTextStyles.expressBadge.copyWith(
                            color: AppColors.white, fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Cashfree sandbox banner ──────────────────────────────────────
          if (AppConstants.cashfreeTestMode) const _SandboxBanner(),

          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Address Section ──────────────────────────────────────
                  _SectionHeader(label: 'DELIVERY ADDRESS', icon: Icons.location_on_outlined),
                  const SizedBox(height: AppConstants.paddingS),

                  // Use current location button
                  GestureDetector(
                    onTap: _locating ? null : _fetchCurrentLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _locating
                              ? const SizedBox(
                                  width: 13, height: 13,
                                  child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.forestGreen),
                                )
                              : const Icon(Icons.my_location_rounded, size: 13, color: AppColors.forestGreen),
                          const SizedBox(width: 6),
                          Text(
                            _locating ? 'Detecting location…' : 'Use my current location',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12, color: AppColors.forestGreen, fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),

                  // Saved address chips
                  if (addresses.isNotEmpty) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...List.generate(addresses.length, (i) {
                            final addr = addresses[i];
                            final sel = _selectedAddressIndex == i;
                            return GestureDetector(
                              onTap: () => _selectSavedAddress(i, addr),
                              child: AnimatedContainer(
                                duration: AppConstants.animFast,
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.forestGreen : AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                  border: Border.all(color: sel ? AppColors.forestGreen : AppColors.divider, width: sel ? 1.5 : 0.8),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(addr.label == 'Work' ? Icons.work_outline_rounded : Icons.home_outlined,
                                      size: 13, color: sel ? AppColors.white : AppColors.forestGreen),
                                  const SizedBox(width: 6),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(addr.label, style: AppTextStyles.labelMedium.copyWith(fontSize: 11, color: sel ? AppColors.white : AppColors.textPrimary)),
                                    Text(addr.city.isNotEmpty ? addr.city : addr.line1,
                                        style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: sel ? AppColors.white.withValues(alpha: 0.7) : AppColors.textMuted)),
                                  ]),
                                ]),
                              ),
                            );
                          }),
                          GestureDetector(
                            onTap: () => setState(() { _selectedAddressIndex = null; _line1Ctrl.clear(); _cityCtrl.clear(); _pinCtrl.clear(); }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppConstants.radiusS), border: Border.all(color: AppColors.divider, width: 0.8)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.add_rounded, size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text('New', style: AppTextStyles.labelMedium.copyWith(fontSize: 11, color: AppColors.textMuted)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                  ],

                  _CheckoutField(controller: _nameCtrl,  label: 'FULL NAME',    hint: 'Priya Sharma',    icon: Icons.person_outline_rounded),
                  const SizedBox(height: AppConstants.paddingS),
                  _CheckoutField(controller: _phoneCtrl, label: 'PHONE',        hint: '9876543210',      icon: Icons.phone_outlined, inputType: TextInputType.phone, formatters: [FilteringTextInputFormatter.digitsOnly]),
                  const SizedBox(height: AppConstants.paddingS),
                  _CheckoutField(controller: _line1Ctrl, label: 'ADDRESS',      hint: 'Flat / Street',   icon: Icons.home_outlined),
                  const SizedBox(height: AppConstants.paddingS),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CheckoutField(
                          controller: _cityCtrl,
                          label: 'CITY',
                          hint: 'Auto-filled from PIN',
                          icon: Icons.location_city_outlined,
                          suffixIcon: _pinLookingUp
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: AppColors.forestGreen,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingS),
                      SizedBox(
                        width: 110,
                        child: _CheckoutField(
                          controller: _pinCtrl,
                          label: 'PIN CODE',
                          hint: '400050',
                          icon: Icons.pin_outlined,
                          inputType: TextInputType.number,
                          formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                        ),
                      ),
                    ],
                  ),
                  if (_pinError != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.error_outline_rounded, size: 12, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(_pinError!, style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.error)),
                    ]),
                  ],

                  const SizedBox(height: AppConstants.paddingS),

                  // ── Save address toggle ──────────────────────────────────
                  GestureDetector(
                    onTap: () => setState(
                        () => _saveAddressToProfile = !_saveAddressToProfile),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM, vertical: 10),
                      decoration: BoxDecoration(
                        color: _saveAddressToProfile
                            ? AppColors.forestGreen.withValues(alpha: 0.06)
                            : AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                        border: Border.all(
                          color: _saveAddressToProfile
                              ? AppColors.forestGreen
                              : AppColors.divider,
                          width: _saveAddressToProfile ? 1.5 : 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: AppConstants.animFast,
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _saveAddressToProfile
                                  ? AppColors.forestGreen
                                  : Colors.transparent,
                              border: Border.all(
                                color: _saveAddressToProfile
                                    ? AppColors.forestGreen
                                    : AppColors.divider,
                                width: 1.5,
                              ),
                            ),
                            child: _saveAddressToProfile
                                ? const Icon(Icons.check,
                                    size: 11, color: AppColors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Save this address to profile',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: _saveAddressToProfile
                                  ? AppColors.forestGreen
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_saveAddressToProfile) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: ['Home', 'Work', 'Other'].map((lbl) {
                        final isSelected = _saveAddressLabel == lbl;
                        final icon = lbl == 'Home'
                            ? Icons.home_outlined
                            : lbl == 'Work'
                                ? Icons.work_outline_rounded
                                : Icons.location_on_outlined;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _saveAddressLabel = lbl),
                          child: AnimatedContainer(
                            duration: AppConstants.animFast,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.forestGreen.withValues(alpha: 0.08)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.forestGreen
                                    : AppColors.divider,
                                width: isSelected ? 1.5 : 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon,
                                    size: 13,
                                    color: isSelected
                                        ? AppColors.forestGreen
                                        : AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  lbl,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: isSelected
                                        ? AppColors.forestGreen
                                        : AppColors.textMuted,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Delivery Type ────────────────────────────────────────
                  _SectionHeader(label: 'DELIVERY TYPE', icon: Icons.local_shipping_outlined),
                  const SizedBox(height: AppConstants.paddingM),
                  _DeliveryToggle(
                    isExpress: _isExpress,
                    onChanged: (v) => setState(() => _isExpress = v),
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Payment Section ──────────────────────────────────────
                  _SectionHeader(label: 'PAYMENT METHOD', icon: Icons.payment_outlined),
                  const SizedBox(height: AppConstants.paddingM),
                  _PaymentSelector(
                    selected: _payment,
                    onChanged: (v) => setState(() => _payment = v),
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Order Summary ────────────────────────────────────────
                  _SectionHeader(label: 'ORDER SUMMARY', icon: Icons.receipt_long_outlined),
                  const SizedBox(height: AppConstants.paddingM),
                  _CheckoutSummary(
                    subtotal: subtotal,
                    delivery: delivery,
                    total: total,
                    isExpress: _isExpress,
                  ),

                  const SizedBox(height: AppConstants.paddingL),

                  // ── Saved Addresses ──────────────────────────────────────
                  _SectionHeader(label: 'SAVED ADDRESSES', icon: Icons.bookmarks_outlined),
                  const SizedBox(height: AppConstants.paddingM),
                  _SavedAddressSection(
                    addresses: addresses,
                    selectedIndex: _selectedAddressIndex,
                    onSelect: _selectSavedAddress,
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // ── Pay Button ───────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            padding: EdgeInsets.fromLTRB(
              AppConstants.paddingM, AppConstants.paddingM,
              AppConstants.paddingM, botPad + AppConstants.paddingM,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text.rich(
                    TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'By placing this order you agree to our '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () => context.push('/terms-conditions'),
                            child: Text(
                              'Terms & Conditions',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.forestGreen,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(AppConstants.urlRefundPolicy);
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            },
                            child: Text(
                              'Refund Policy',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.forestGreen,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.forestGreen,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
              onTap: cart.isEmpty || _paying ? null : _pay,
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                height: 56,
                decoration: BoxDecoration(
                  color: cart.isEmpty || _paying ? AppColors.forestGreen.withValues(alpha: 0.7) : AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _paying
                      ? const RiveLoadingRing(size: 28, color: AppColors.gold)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isExpress) ...[
                              const Icon(Icons.bolt, size: 16, color: AppColors.gold),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              _payment == _PaymentMethod.cod
                                  ? 'PLACE ORDER · ₹${total.toInt()}'
                                  : 'PAY ₹${total.toInt()}',
                              style: AppTextStyles.categoryChip.copyWith(
                                color: AppColors.white,
                                fontSize: 13,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cashfree Sandbox Banner ───────────────────────────────────────────────────
class _SandboxBanner extends StatelessWidget {
  const _SandboxBanner();

  static const _testCard = '4111 1111 1111 1111';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(const ClipboardData(text: '4111111111111111'));
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Test card number copied'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ));
      },
      child: Container(
        width: double.infinity,
        color: const Color(0xFFFFF8E1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.science_outlined, size: 14, color: Color(0xFFF57F17)),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 11, color: Color(0xFFF57F17)),
                  children: [
                    const TextSpan(text: 'SANDBOX MODE · Test card: '),
                    TextSpan(
                      text: _testCard,
                      style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                    const TextSpan(text: ' · Any expiry · CVV 123  '),
                    const TextSpan(
                      text: 'Tap to copy',
                      style: TextStyle(decoration: TextDecoration.underline),
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
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.forestGreen),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.categoryChip.copyWith(
            fontSize: 10, letterSpacing: 2.5, color: AppColors.textPrimary,
          ),
        ),
      ],
    ).animate().fadeIn(duration: AppConstants.animNormal);
  }
}

// ── Checkout Field ────────────────────────────────────────────────────────────
class _CheckoutField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType inputType;
  final List<TextInputFormatter>? formatters;
  final Widget? suffixIcon;

  const _CheckoutField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.inputType = TextInputType.text,
    this.formatters,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.categoryChip.copyWith(
            fontSize: 8, letterSpacing: 2.0, color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          inputFormatters: formatters,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            prefixIcon: Icon(icon, size: 16, color: AppColors.textMuted),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM, vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              borderSide: const BorderSide(color: AppColors.divider, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              borderSide: const BorderSide(color: AppColors.divider, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Delivery Toggle ───────────────────────────────────────────────────────────
class _DeliveryToggle extends StatelessWidget {
  final bool isExpress;
  final ValueChanged<bool> onChanged;
  const _DeliveryToggle({required this.isExpress, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DeliveryOption(
            label: 'EXPRESS',
            sublabel: 'Get it in 2 Hours · FREE',
            icon: Icons.bolt,
            iconColor: AppColors.gold,
            isSelected: isExpress,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: AppConstants.paddingS),
        Expanded(
          child: _DeliveryOption(
            label: 'STANDARD',
            sublabel: '2-3 Days · ₹49',
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.textMuted,
            isSelected: !isExpress,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _DeliveryOption extends StatefulWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryOption({
    required this.label, required this.sublabel, required this.icon,
    required this.iconColor, required this.isSelected, required this.onTap,
  });

  @override
  State<_DeliveryOption> createState() => _DeliveryOptionState();
}

class _DeliveryOptionState extends State<_DeliveryOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.forestGreen.withValues(alpha: 0.06)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            border: Border.all(
              color: widget.isSelected ? AppColors.forestGreen : AppColors.divider,
              width: widget.isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? AppColors.forestGreen
                    : widget.iconColor,
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: AppTextStyles.categoryChip.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: widget.isSelected
                      ? AppColors.forestGreen
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.sublabel,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Payment Method ────────────────────────────────────────────────────────────
enum _PaymentMethod { cashfree, cod }

class _PaymentSelector extends StatelessWidget {
  final _PaymentMethod selected;
  final ValueChanged<_PaymentMethod> onChanged;
  const _PaymentSelector({required this.selected, required this.onChanged});

  static const _options = [
    (_PaymentMethod.cashfree, 'Cashfree', 'UPI · Netbanking · Wallet',        Icons.account_balance_wallet_outlined),
    (_PaymentMethod.cod,      'Cash on Delivery', 'Pay when delivered',        Icons.money_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _options.map((opt) {
        final isSelected = selected == opt.$1;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: AnimatedContainer(
            duration: AppConstants.animFast,
            margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM, vertical: AppConstants.paddingM,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.forestGreen.withValues(alpha: 0.06) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(
                color: isSelected ? AppColors.forestGreen : AppColors.divider,
                width: isSelected ? 1.5 : 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  opt.$4,
                  size: 20,
                  color: isSelected ? AppColors.forestGreen : AppColors.textMuted,
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt.$2,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontSize: 13,
                          color: isSelected ? AppColors.forestGreen : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        opt.$3,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10, color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: AppConstants.animFast,
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.forestGreen : AppColors.divider,
                      width: isSelected ? 5 : 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Checkout Summary ──────────────────────────────────────────────────────────
class _CheckoutSummary extends StatelessWidget {
  final double subtotal;
  final double delivery;
  final double total;
  final bool isExpress;

  const _CheckoutSummary({
    required this.subtotal, required this.delivery,
    required this.total, required this.isExpress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          _Row(label: 'Subtotal', value: '₹${subtotal.toInt()}'),
          const SizedBox(height: AppConstants.paddingS),
          _Row(
            label: isExpress ? 'Express Delivery' : 'Standard Delivery',
            value: delivery == 0 ? 'FREE' : '₹${delivery.toInt()}',
            valueColor: delivery == 0 ? AppColors.forestGreen : null,
          ),
          const SizedBox(height: AppConstants.paddingM),
          Container(height: 0.5, color: AppColors.divider),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: AppTextStyles.categoryChip.copyWith(
                  fontSize: 11, letterSpacing: 2.0,
                ),
              ),
              Text(
                '₹${total.toInt()}',
                style: AppTextStyles.priceTag.copyWith(fontSize: 22),
              ),
            ],
          ),
          if (isExpress) ...[
            const SizedBox(height: AppConstants.paddingS),
            Row(
              children: [
                const Icon(Icons.bolt, size: 12, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  'Estimated delivery: within 2 hours',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.forestGreen, fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        Text(
          value,
          style: AppTextStyles.priceTag.copyWith(
            fontSize: 13,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Saved Address Section ─────────────────────────────────────────────────────
class _SavedAddressSection extends StatelessWidget {
  final List<Address> addresses;
  final int? selectedIndex;
  final void Function(int index, Address addr) onSelect;

  const _SavedAddressSection({
    required this.addresses,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(color: AppColors.divider, width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Save addresses in Profile for quick checkout',
                style: AppTextStyles.bodySmall
                    .copyWith(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: addresses.asMap().entries.map((e) {
        final i = e.key;
        final addr = e.value;
        final isSelected = selectedIndex == i;
        final icon = addr.label == 'Home'
            ? Icons.home_outlined
            : addr.label == 'Work'
                ? Icons.work_outline_rounded
                : Icons.location_on_outlined;

        return GestureDetector(
          onTap: () => onSelect(i, addr),
          child: AnimatedContainer(
            duration: AppConstants.animFast,
            margin: const EdgeInsets.only(bottom: AppConstants.paddingS),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingM,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.forestGreen.withValues(alpha: 0.06)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(
                color: isSelected ? AppColors.forestGreen : AppColors.divider,
                width: isSelected ? 1.5 : 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 20,
                    color: isSelected
                        ? AppColors.forestGreen
                        : AppColors.textMuted),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addr.label,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontSize: 13,
                          color: isSelected
                              ? AppColors.forestGreen
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        [
                          addr.line1,
                          addr.city,
                          if (addr.pinCode.isNotEmpty) addr.pinCode,
                        ].join(', '),
                        style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: AppConstants.animFast,
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.forestGreen
                          : AppColors.divider,
                      width: isSelected ? 5 : 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Order Confirmation Screen ─────────────────────────────────────────────────
/// Shown after successful payment. Full-screen success state.
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _tickCtrl;

  @override
  void initState() {
    super.initState();
    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _tickCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingXL, AppConstants.paddingL,
            AppConstants.paddingXL, AppConstants.paddingM,
          ),
          child: Column(
            children: [
              const Spacer(),

              // ── Rive success tick ──────────────────────────────────────
              RiveSuccessTick(size: 100, fallbackController: _tickCtrl),

              const SizedBox(height: AppConstants.paddingXL),

              Text(
                'ORDER CONFIRMED!',
                style: AppTextStyles.categoryChip.copyWith(
                  fontSize: 14, letterSpacing: 3.5,
                ),
              ).animate(delay: 400.ms).fadeIn(),

              const SizedBox(height: AppConstants.paddingM),

              Text(
                'Your jewelry is on its way.',
                style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ).animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: AppConstants.paddingS),

              Text(
                'Our artisans are preparing your order\nwith care.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted, height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 650.ms).fadeIn(),

              const SizedBox(height: AppConstants.paddingL),

              // ── Express delivery ETA ───────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingL, vertical: AppConstants.paddingM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(
                    color: AppColors.forestGreen.withValues(alpha: 0.2), width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 16, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Express Delivery',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.forestGreen, fontSize: 13,
                          ),
                        ),
                        Text(
                          'Arriving within 2 hours',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted, fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.1, end: 0),

              // ── Order ID ───────────────────────────────────────────────
              const SizedBox(height: AppConstants.paddingM),
              Text(
                'Order #AUR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.0,
                ),
              ).animate(delay: 900.ms).fadeIn(),

              const Spacer(),

              // ── CTAs ───────────────────────────────────────────────────
              GestureDetector(
                onTap: () => context.go(AppRoutes.home),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Center(
                    child: Text(
                      'CONTINUE SHOPPING',
                      style: AppTextStyles.categoryChip.copyWith(
                        color: AppColors.white, fontSize: 12, letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 1000.ms).fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppConstants.paddingM),

              GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider, width: 0.8),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Center(
                    child: Text(
                      'VIEW MY ORDERS',
                      style: AppTextStyles.categoryChip.copyWith(
                        fontSize: 11, letterSpacing: 1.5, color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 1100.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
