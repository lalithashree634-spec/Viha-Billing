import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/bill_item.dart';
import '../theme/app_colors.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Beverages',
    'Bakery',
    'Snacks',
    'Dairy',
    'Spices',
    'Essentials'
  ];

  // Sample Real-world Product Catalog
  final List<Product> _allProducts = [
    const Product(
      id: 'p1',
      name: 'Artisan Filter Coffee (250g)',
      category: 'Beverages',
      barcode: '8901234001',
      price: 180.0,
      costPrice: 120.0,
      gstPercent: 5.0,
      stock: 45,
    ),
    const Product(
      id: 'p2',
      name: 'Roasted Masala Chai (200g)',
      category: 'Beverages',
      barcode: '8901234002',
      price: 120.0,
      costPrice: 80.0,
      gstPercent: 5.0,
      stock: 28,
    ),
    const Product(
      id: 'p3',
      name: 'Whole Wheat Sourdough Loaf',
      category: 'Bakery',
      barcode: '8901234003',
      price: 95.0,
      costPrice: 60.0,
      gstPercent: 0.0,
      stock: 6, // Low stock
    ),
    const Product(
      id: 'p4',
      name: 'Butter Croissant (2 pcs)',
      category: 'Bakery',
      barcode: '8901234004',
      price: 140.0,
      costPrice: 85.0,
      gstPercent: 5.0,
      stock: 4, // Critical stock
    ),
    const Product(
      id: 'p5',
      name: 'Pure Desi A2 Cow Ghee (500ml)',
      category: 'Dairy',
      barcode: '8901234005',
      price: 490.0,
      costPrice: 380.0,
      gstPercent: 12.0,
      stock: 22,
    ),
    const Product(
      id: 'p6',
      name: 'Organic California Almonds (250g)',
      category: 'Snacks',
      barcode: '8901234006',
      price: 320.0,
      costPrice: 240.0,
      gstPercent: 5.0,
      stock: 50,
    ),
    const Product(
      id: 'p7',
      name: 'Dark Cocoa Chunk Cookies',
      category: 'Snacks',
      barcode: '8901234007',
      price: 160.0,
      costPrice: 100.0,
      gstPercent: 18.0,
      stock: 35,
    ),
    const Product(
      id: 'p8',
      name: 'Green Cardamom Extra Bold (50g)',
      category: 'Spices',
      barcode: '8901234008',
      price: 210.0,
      costPrice: 150.0,
      gstPercent: 5.0,
      stock: 40,
    ),
    const Product(
      id: 'p9',
      name: 'Himalayan Pink Rock Salt (1kg)',
      category: 'Essentials',
      barcode: '8901234009',
      price: 85.0,
      costPrice: 50.0,
      gstPercent: 0.0,
      stock: 65,
    ),
    const Product(
      id: 'p10',
      name: 'Cold Pressed Wood Gingelly Oil (1L)',
      category: 'Essentials',
      barcode: '8901234010',
      price: 260.0,
      costPrice: 190.0,
      gstPercent: 5.0,
      stock: 14,
    ),
  ];

  // Active Cart State
  final List<BillItem> _cart = [];
  final List<List<BillItem>> _heldBills = []; // Real cashier hold bill feature
  double _overallDiscountPercent = 0.0;
  String _billNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  @override
  void dispose() {
    _searchController.dispose();
    _customerController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.barcode.contains(query) ||
          p.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _addToCart(Product product) {
    HapticFeedback.lightImpact();
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity += 1;
      } else {
        _cart.add(BillItem(product: product, quantity: 1));
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      }
    });
  }

  void _removeFromCart(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _holdCurrentBill() {
    if (_cart.isEmpty) return;
    setState(() {
      _heldBills.add(List.from(_cart));
      _cart.clear();
      _customerController.clear();
      _overallDiscountPercent = 0.0;
      _billNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.pitchBlack,
        content: Text(
          'Bill held successfully! Total held: ${_heldBills.length}',
          style: const TextStyle(fontFamily: 'Poppins', color: AppColors.white),
        ),
        action: SnackBarAction(
          label: 'RECALL',
          textColor: AppColors.white,
          onPressed: _recallHeldBill,
        ),
      ),
    );
  }

  void _recallHeldBill() {
    if (_heldBills.isEmpty) return;
    setState(() {
      final lastHeld = _heldBills.removeLast();
      _cart.clear();
      _cart.addAll(lastHeld);
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _customerController.clear();
      _overallDiscountPercent = 0.0;
      _billNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    });
  }

  double get _cartSubtotal => _cart.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
  double get _discountAmount => _cartSubtotal * (_overallDiscountPercent / 100);
  double get _cartTax => _cart.fold(0.0, (sum, item) => sum + item.gstAmount);
  double get _grandTotal => (_cartSubtotal - _discountAmount) + _cartTax;

  KeyEventResult _handleKeyInput(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f2) {
        _searchFocusNode.requestFocus();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.f4 && _cart.isNotEmpty) {
        _holdCurrentBill();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.f12 && _cart.isNotEmpty) {
        _showHumanPaymentDialog();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;

    return Focus(
      onKeyEvent: _handleKeyInput,
      autofocus: true,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        body: isDesktop
            ? _buildDesktopLayout()
            : isTablet
                ? _buildTabletLayout()
                : _buildMobileLayout(),
      ),
    );
  }

  // DESKTOP: 3-Column Ergonomic Retail Layout
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Center: Product Catalog & Search (64% width)
        Expanded(
          flex: 64,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHumanHeader(),
                const SizedBox(height: 16),
                _buildSearchAndFilters(),
                const SizedBox(height: 16),
                Expanded(child: _buildProductGrid(crossAxisCount: 3)),
              ],
            ),
          ),
        ),

        // Vertical Hairline Border
        Container(width: 1, color: AppColors.border),

        // Right Register: Live Ticket / Bill Cart (36% width)
        Expanded(
          flex: 36,
          child: Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(24),
            child: _buildCartPanel(),
          ),
        ),
      ],
    );
  }

  // TABLET: 50/50 Split Layout
  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 52,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHumanHeader(),
                const SizedBox(height: 12),
                _buildSearchAndFilters(),
                const SizedBox(height: 12),
                Expanded(child: _buildProductGrid(crossAxisCount: 2)),
              ],
            ),
          ),
        ),
        Container(width: 1, color: AppColors.border),
        Expanded(
          flex: 48,
          child: Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: _buildCartPanel(),
          ),
        ),
      ],
    );
  }

  // MOBILE: Catalog with Bottom Dynamic Checkout Bar
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHumanHeader(),
              const SizedBox(height: 12),
              _buildSearchAndFilters(),
              const SizedBox(height: 12),
              Expanded(child: _buildProductGrid(crossAxisCount: 2)),
            ],
          ),
        ),

        // Mobile Floating Dynamic Pill
        if (_cart.isNotEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Material(
              elevation: 8,
              shadowColor: AppColors.pitchBlack.withAlpha(60),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.pitchBlack,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _openMobileCartBottomSheet,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: AppColors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_cart.fold(0, (sum, item) => sum + item.quantity)} ITEMS IN TICKET',
                            style: const TextStyle(
                              color: AppColors.gray,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(_grandTotal),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Checkout',
                              style: TextStyle(
                                color: AppColors.pitchBlack,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, color: AppColors.pitchBlack, size: 14),
                          ],
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

  // TOP HEADER WITH REAL RETAIL STATUS BADGES
  Widget _buildHumanHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Counter #01',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pitchBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.pitchBlack,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'RETAIL POS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('EEE, d MMM yyyy • hh:mm a').format(DateTime.now()),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Held Bills Button
        if (_heldBills.isNotEmpty)
          OutlinedButton.icon(
            onPressed: _recallHeldBill,
            icon: const Icon(Icons.pause_circle_outline, size: 16, color: AppColors.pitchBlack),
            label: Text(
              'Held (${_heldBills.length})',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.pitchBlack,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.lightGray,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
      ],
    );
  }

  // SEARCH AND CATEGORY FILTER TABS
  Widget _buildSearchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tactile Search Field with Keyboard Hint
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search items or scan barcode...',
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.darkGray, size: 20),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGray,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'F2',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              ],
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.pitchBlack, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Category Pills (Smooth Scroll)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.pitchBlack : AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.pitchBlack : AppColors.border,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.pitchBlack.withAlpha(30),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.white : AppColors.darkGray,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // PRODUCT GRID
  Widget _buildProductGrid({required int crossAxisCount}) {
    final products = _filteredProducts;
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 54, color: AppColors.gray.withAlpha(120)),
            const SizedBox(height: 12),
            const Text(
              'No products found',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.pitchBlack,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try scanning another barcode or clearing your search',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildHumanProductCard(product);
      },
    );
  }

  // HUMAN-TOUCHED PRODUCT CARD
  Widget _buildHumanProductCard(Product product) {
    final isLowStock = product.stock <= 6;
    final isCriticalStock = product.stock <= 4;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _addToCart(product),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCriticalStock ? 'Only ${product.stock} left' : '${product.stock} in stock',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pitchBlack,
                        ),
                      ),
                    )
                  else
                    Text(
                      '${product.stock} pcs',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
              const Spacer(),

              // Product Name
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.pitchBlack,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),

              // Barcode and GST Tag
              Row(
                children: [
                  Text(
                    '#${product.barcode.substring(product.barcode.length - 4)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(color: AppColors.gray, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GST ${product.gstPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Price & Quick Action Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PRICE',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(product.price),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.pitchBlack,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.pitchBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CART PANEL / CASH REGISTER SLIP
  Widget _buildCartPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Register Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Ticket',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                    color: AppColors.pitchBlack,
                  ),
                ),
                Text(
                  _billNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            if (_cart.isNotEmpty)
              Row(
                children: [
                  IconButton(
                    tooltip: 'Hold Bill [F4]',
                    icon: const Icon(Icons.pause_circle_outline, size: 20, color: AppColors.darkGray),
                    onPressed: _holdCurrentBill,
                  ),
                  IconButton(
                    tooltip: 'Clear Cart',
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.gray),
                    onPressed: _clearCart,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Customer Quick Tag
        TextField(
          controller: _customerController,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Customer Phone or Name...',
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.darkGray),
            filled: true,
            fillColor: AppColors.lightGray,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Items List Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'ITEM',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    'QTY',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'TOTAL',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 24),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Scrollable Cart Items
        Expanded(
          child: _cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: AppColors.lightGray,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.receipt_outlined, size: 36, color: AppColors.gray),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Ticket is empty',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.pitchBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Click products or press F2 to scan barcode',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _cart.length,
                  separatorBuilder: (_, index) => const Divider(color: AppColors.border, height: 14),
                  itemBuilder: (context, index) {
                    final item = _cart[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Name and Unit Price
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.pitchBlack,
                                ),
                              ),
                              Text(
                                '${currencyFormatter.format(item.unitPrice)} • GST ${item.product.gstPercent.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Stepper Quantity Pill
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () => _updateQuantity(index, -1),
                                  borderRadius: BorderRadius.circular(4),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.remove, size: 12, color: AppColors.darkGray),
                                  ),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _updateQuantity(index, 1),
                                  borderRadius: BorderRadius.circular(4),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.add, size: 12, color: AppColors.darkGray),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Subtotal
                        Expanded(
                          flex: 3,
                          child: Text(
                            currencyFormatter.format(item.subtotal),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.pitchBlack,
                            ),
                          ),
                        ),

                        // Remove Icon
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.gray),
                          onPressed: () => _removeFromCart(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24),
                        ),
                      ],
                    );
                  },
                ),
        ),

        const Divider(color: AppColors.border, height: 20),

        // Summary Breakdown (Subtotal, Discount, Tax, Round off)
        Column(
          children: [
            _buildTactileSummaryRow('Subtotal', currencyFormatter.format(_cartSubtotal)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Bill Discount',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButton<double>(
                        value: _overallDiscountPercent,
                        underline: const SizedBox(),
                        isDense: true,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pitchBlack,
                        ),
                        items: [0.0, 5.0, 10.0, 15.0].map((disc) {
                          return DropdownMenuItem<double>(
                            value: disc,
                            child: Text('${disc.toStringAsFixed(0)}% OFF'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _overallDiscountPercent = val);
                        },
                      ),
                    ),
                  ],
                ),
                Text(
                  '- ${currencyFormatter.format(_discountAmount)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pitchBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildTactileSummaryRow('Total GST Tax', currencyFormatter.format(_cartTax)),
            const SizedBox(height: 12),

            // Grand Total Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.pitchBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL AMOUNT',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Incl. all taxes',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormatter.format(_grandTotal),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Action Buttons with Cashier Shortcuts
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _cart.isEmpty ? null : _holdCurrentBill,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Hold [F4]',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkGray),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _cart.isEmpty ? null : _showHumanPaymentDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pitchBlack,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payments_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Pay ${currencyFormatter.format(_grandTotal)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTactileSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.pitchBlack,
          ),
        ),
      ],
    );
  }

  // BOTTOM SHEET FOR MOBILE
  void _openMobileCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: _buildCartPanel(),
          );
        },
      ),
    );
  }

  // HUMAN PAYMENT DIALOG WITH CASH TENDER & CHANGE RETURN CALCULATOR
  void _showHumanPaymentDialog() {
    String selectedMethod = 'UPI';
    double cashGiven = _grandTotal.ceilToDouble();
    final cashController = TextEditingController(text: cashGiven.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final double parsedCash = double.tryParse(cashController.text) ?? 0.0;
          final double changeDue = parsedCash - _grandTotal;

          return AlertDialog(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tender Payment',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    Text(
                      'Select payment method & print receipt',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Amount Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.pitchBlack,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'NET AMOUNT PAYABLE',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(_grandTotal),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Method Selector Tabs
                    Row(
                      children: ['UPI', 'Cash', 'Card'].map((method) {
                        final isSelected = selectedMethod == method;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => setDialogState(() => selectedMethod = method),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.pitchBlack : AppColors.lightGray,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.pitchBlack : AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      method == 'UPI'
                                          ? Icons.qr_code_scanner_rounded
                                          : method == 'Cash'
                                              ? Icons.payments_rounded
                                              : Icons.credit_card_rounded,
                                      color: isSelected ? AppColors.white : AppColors.darkGray,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      method,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? AppColors.white : AppColors.darkGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // DYNAMIC CASH TENDER CALCULATOR
                    if (selectedMethod == 'Cash') ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cash Received from Customer',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: cashController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700),
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              prefixStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700),
                              filled: true,
                              fillColor: AppColors.lightGray,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Quick Note Tender Pills
                          Row(
                            children: [
                              _buildQuickTenderChip('Exact', _grandTotal, cashController, setDialogState),
                              _buildQuickTenderChip('₹100', 100, cashController, setDialogState),
                              _buildQuickTenderChip('₹200', 200, cashController, setDialogState),
                              _buildQuickTenderChip('₹500', 500, cashController, setDialogState),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Change Due Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: changeDue >= 0 ? AppColors.lightGray : Colors.red.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: changeDue >= 0 ? AppColors.border : Colors.redAccent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  changeDue >= 0 ? 'Change to Return:' : 'Shortage:',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: changeDue >= 0 ? AppColors.pitchBlack : Colors.red,
                                  ),
                                ),
                                Text(
                                  currencyFormatter.format(changeDue.abs()),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: changeDue >= 0 ? AppColors.pitchBlack : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else if (selectedMethod == 'UPI') ...[
                      // Dynamic UPI QR Visual
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.white,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Center(
                                child: Icon(Icons.qr_code_2_rounded, size: 110, color: AppColors.pitchBlack),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Scan using Google Pay, PhonePe, or Paytm',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const Text(
                              'VPA: biller.store@hdfcbank',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pitchBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Card swipe prompt
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.contactless_rounded, size: 40, color: AppColors.pitchBlack),
                            SizedBox(height: 10),
                            Text(
                              'Insert / Tap Credit or Debit Card',
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              'Waiting for POS Card Terminal response...',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showPrintThermalSlipModal();
                  },
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text('Complete & Print Slip [Enter]'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pitchBlack,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickTenderChip(String label, double amount, TextEditingController controller, StateSetter setDialogState) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          onTap: () {
            setDialogState(() {
              controller.text = amount.toStringAsFixed(0);
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pitchBlack,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // REALISTIC THERMAL PAPER SLIP PREVIEW (80mm)
  void _showPrintThermalSlipModal() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.lightGray,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.pitchBlack, size: 28),
              ),
              const SizedBox(height: 12),
              const Text(
                'Payment Received',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const Text(
                'Sending payload to thermal printer...',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),

              // Realistic Thermal Receipt Rendering
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'VIHA BILLING PRO STORE',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1),
                    ),
                    const Text(
                      'Main Road, T.Nagar, Chennai - 600017',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.textMuted),
                    ),
                    const Text(
                      'GSTIN: 33AAAAA0000A1Z5 | Ph: 044-24345678',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.textMuted),
                    ),
                    const Divider(color: AppColors.border, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_billNumber, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600)),
                        Text(DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10)),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 16),
                    ..._cart.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.name} (x${item.quantity})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 10),
                                ),
                              ),
                              Text(currencyFormatter.format(item.subtotal), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                    const Divider(color: AppColors.border, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Grand Total', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 14)),
                        Text(currencyFormatter.format(_grandTotal), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.pitchBlack)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('*** NO RETURN WITHOUT BILL ***', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.gray)),
                    const Text('THANK YOU VISIT AGAIN!', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.pitchBlack)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('WhatsApp', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _clearCart();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.pitchBlack),
                      child: const Text('Next Bill', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
