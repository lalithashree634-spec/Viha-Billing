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

  final List<Map<String, dynamic>> _categoryData = [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'count': 10},
    {'name': 'Beverages', 'icon': Icons.coffee_rounded, 'count': 2},
    {'name': 'Bakery', 'icon': Icons.bakery_dining_rounded, 'count': 2},
    {'name': 'Dairy', 'icon': Icons.egg_rounded, 'count': 1},
    {'name': 'Snacks', 'icon': Icons.cookie_rounded, 'count': 2},
    {'name': 'Spices', 'icon': Icons.grain_rounded, 'count': 1},
    {'name': 'Essentials', 'icon': Icons.shopping_basket_rounded, 'count': 2},
  ];

  // Modern Real-world Product Catalog
  final List<Product> _allProducts = [
    const Product(
      id: 'p1',
      name: 'Artisan Filter Coffee',
      category: 'Beverages',
      barcode: '8901234001',
      price: 180.0,
      costPrice: 120.0,
      gstPercent: 5.0,
      stock: 45,
    ),
    const Product(
      id: 'p2',
      name: 'Roasted Masala Chai',
      category: 'Beverages',
      barcode: '8901234002',
      price: 120.0,
      costPrice: 80.0,
      gstPercent: 5.0,
      stock: 28,
    ),
    const Product(
      id: 'p3',
      name: 'Sourdough Artisanal Bread',
      category: 'Bakery',
      barcode: '8901234003',
      price: 95.0,
      costPrice: 60.0,
      gstPercent: 0.0,
      stock: 6,
    ),
    const Product(
      id: 'p4',
      name: 'Fresh Butter Croissant (2x)',
      category: 'Bakery',
      barcode: '8901234004',
      price: 140.0,
      costPrice: 85.0,
      gstPercent: 5.0,
      stock: 4,
    ),
    const Product(
      id: 'p5',
      name: 'Desi Cow A2 Ghee (500ml)',
      category: 'Dairy',
      barcode: '8901234005',
      price: 490.0,
      costPrice: 380.0,
      gstPercent: 12.0,
      stock: 22,
    ),
    const Product(
      id: 'p6',
      name: 'Raw California Almonds',
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
      name: 'Cardamom Green Bold (50g)',
      category: 'Spices',
      barcode: '8901234008',
      price: 210.0,
      costPrice: 150.0,
      gstPercent: 5.0,
      stock: 40,
    ),
    const Product(
      id: 'p9',
      name: 'Himalayan Pink Rock Salt',
      category: 'Essentials',
      barcode: '8901234009',
      price: 85.0,
      costPrice: 50.0,
      gstPercent: 0.0,
      stock: 65,
    ),
    const Product(
      id: 'p10',
      name: 'Wood Pressed Gingelly Oil',
      category: 'Essentials',
      barcode: '8901234010',
      price: 260.0,
      costPrice: 190.0,
      gstPercent: 5.0,
      stock: 14,
    ),
  ];

  // Cart & Cashier State
  final List<BillItem> _cart = [];
  final List<List<BillItem>> _heldBills = [];
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Bill held successfully (${_heldBills.length} queued)',
          style: const TextStyle(fontFamily: 'Poppins', color: AppColors.white),
        ),
        action: SnackBarAction(
          label: 'RESTORE',
          textColor: AppColors.zinc300,
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
        _showPaymentModal();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 720 && screenWidth < 1024;

    return Focus(
      onKeyEvent: _handleKeyInput,
      autofocus: true,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: isDesktop
            ? _buildDesktopView()
            : isTablet
                ? _buildTabletView()
                : _buildMobileView(),
      ),
    );
  }

  // DESKTOP: Sleek 2-Section POS (Catalog Left + Modern Receipt Dock Right)
  Widget _buildDesktopView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Catalog Section (62% width)
        Expanded(
          flex: 62,
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBar(),
                const SizedBox(height: 20),
                _buildModernSearchBar(),
                const SizedBox(height: 16),
                _buildCategoryPills(),
                const SizedBox(height: 20),
                Expanded(child: _buildModernProductGrid(crossAxisCount: 3)),
              ],
            ),
          ),
        ),

        // Floating Ticket Dock (38% width)
        Expanded(
          flex: 38,
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 16, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pitchBlack.withAlpha(8),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: _buildReceiptDock(),
          ),
        ),
      ],
    );
  }

  // TABLET VIEW
  Widget _buildTabletView() {
    return Row(
      children: [
        Expanded(
          flex: 54,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeaderBar(),
                const SizedBox(height: 14),
                _buildModernSearchBar(),
                const SizedBox(height: 14),
                _buildCategoryPills(),
                const SizedBox(height: 14),
                Expanded(child: _buildModernProductGrid(crossAxisCount: 2)),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 46,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(18),
            child: _buildReceiptDock(),
          ),
        ),
      ],
    );
  }

  // MOBILE VIEW
  Widget _buildMobileView() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBar(),
              const SizedBox(height: 14),
              _buildModernSearchBar(),
              const SizedBox(height: 14),
              _buildCategoryPills(),
              const SizedBox(height: 14),
              Expanded(child: _buildModernProductGrid(crossAxisCount: 2)),
            ],
          ),
        ),

        // Floating Mobile Checkout Bar
        if (_cart.isNotEmpty)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Material(
              elevation: 12,
              shadowColor: AppColors.pitchBlack.withAlpha(60),
              borderRadius: BorderRadius.circular(20),
              color: AppColors.pitchBlack,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _openMobileBottomSheet,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.zinc800,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_rounded, color: AppColors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_cart.fold(0, (sum, item) => sum + item.quantity)} ITEMS IN CART',
                            style: const TextStyle(
                              color: AppColors.zinc400,
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
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'View Bill',
                              style: TextStyle(
                                color: AppColors.pitchBlack,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 6),
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

  // TOP COMMAND BAR
  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'Cash Register',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: AppColors.pitchBlack,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '• Counter 01',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.zinc500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('EEEE, MMMM d, yyyy • hh:mm a').format(DateTime.now()),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.zinc400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Quick Held Button
        if (_heldBills.isNotEmpty)
          OutlinedButton.icon(
            onPressed: _recallHeldBill,
            icon: const Icon(Icons.history_rounded, size: 16, color: AppColors.pitchBlack),
            label: Text(
              'Held Tickets (${_heldBills.length})',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.pitchBlack,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.zinc100,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
      ],
    );
  }

  // MODERN SEARCH BAR (Apple/Stripe Inspired)
  Widget _buildModernSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.pitchBlack.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search product by name, category, or barcode...',
          hintStyle: const TextStyle(fontFamily: 'Poppins', color: AppColors.zinc400, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.zinc500, size: 22),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.zinc400),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.zinc100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'F2',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.zinc600,
                  ),
                ),
              ),
            ],
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  // CATEGORY PILL SELECTOR (Modern Rounded Horizontal Chips)
  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categoryData.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          final name = cat['name'] as String;
          final icon = cat['icon'] as IconData;
          final count = cat['count'] as int;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = name);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pitchBlack : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.pitchBlack : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.pitchBlack.withAlpha(25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? AppColors.white : AppColors.zinc600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.white : AppColors.zinc700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.zinc800 : AppColors.zinc100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.zinc300 : AppColors.zinc500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // REDESIGNED PRODUCT GRID (Clean, Clickable, High-End Card Surfaces)
  Widget _buildModernProductGrid({required int crossAxisCount}) {
    final products = _filteredProducts;
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.zinc100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 40, color: AppColors.zinc400),
            ),
            const SizedBox(height: 14),
            const Text(
              'No items found',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.pitchBlack,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try searching with another keyword or barcode',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc500),
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
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  // INDIVIDUAL HIGH-END PRODUCT TILE
  Widget _buildProductCard(Product product) {
    final isLowStock = product.stock <= 6;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _addToCart(product),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.pitchBlack.withAlpha(4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category Tag & Price Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.zinc600,
                      ),
                    ),
                  ),
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.pitchBlack,
                      letterSpacing: -0.3,
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
              const SizedBox(height: 6),

              // SKU & Tax info
              Text(
                'SKU: ${product.barcode.substring(product.barcode.length - 4)} • GST ${product.gstPercent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.zinc400,
                ),
              ),
              const Spacer(),

              // Bottom Row: Stock status & Tap-to-Add action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isLowStock ? Colors.orangeAccent : AppColors.zinc400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isLowStock ? '${product.stock} left' : '${product.stock} in stock',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: isLowStock ? FontWeight.w700 : FontWeight.w500,
                          color: isLowStock ? Colors.orange.shade800 : AppColors.zinc500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.pitchBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // THE FLOATING RECEIPT DOCK (Smart POS Register)
  Widget _buildReceiptDock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ticket Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Ticket',
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
                    color: AppColors.zinc500,
                  ),
                ),
              ],
            ),
            if (_cart.isNotEmpty)
              Row(
                children: [
                  IconButton(
                    tooltip: 'Hold Bill [F4]',
                    icon: const Icon(Icons.pause_circle_outline_rounded, size: 20, color: AppColors.zinc600),
                    onPressed: _holdCurrentBill,
                  ),
                  IconButton(
                    tooltip: 'Clear Cart',
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.zinc400),
                    onPressed: _clearCart,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Customer Input Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.zinc100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _customerController,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              hintText: 'Customer phone or name (optional)...',
              hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc400),
              prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: AppColors.zinc600),
              filled: false,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Ticket Items List
        Expanded(
          child: _cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.zinc100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, size: 36, color: AppColors.zinc400),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Ticket is empty',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.pitchBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap items on the left to build the bill',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc500),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _cart.length,
                  separatorBuilder: (_, index) => const Divider(color: AppColors.border, height: 16),
                  itemBuilder: (context, index) {
                    final item = _cart[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Quantity stepper pill
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.zinc100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _updateQuantity(index, -1),
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Icon(Icons.remove, size: 12, color: AppColors.zinc700),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColors.pitchBlack,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _updateQuantity(index, 1),
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Icon(Icons.add, size: 12, color: AppColors.zinc700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Item description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.pitchBlack,
                                ),
                              ),
                              Text(
                                '${currencyFormatter.format(item.unitPrice)} ea • GST ${item.product.gstPercent.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  color: AppColors.zinc400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Item Total
                        Text(
                          currencyFormatter.format(item.subtotal),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.pitchBlack,
                          ),
                        ),

                        // Quick delete
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.zinc400),
                          onPressed: () => _removeFromCart(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28),
                        ),
                      ],
                    );
                  },
                ),
        ),

        const Divider(color: AppColors.border, height: 20),

        // Bill Summary Section
        Column(
          children: [
            _buildSummaryRow('Subtotal', currencyFormatter.format(_cartSubtotal)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Discount',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.zinc600),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pitchBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSummaryRow('GST Tax', currencyFormatter.format(_cartTax)),
            const SizedBox(height: 14),

            // Big High-Contrast Total Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pitchBlack,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GRAND TOTAL',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppColors.zinc400,
                        ),
                      ),
                      Text(
                        'Tax Included',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.zinc500),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormatter.format(_grandTotal),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: AppColors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Action Buttons: Hold [F4] + Big Charge Button [F12]
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _cart.isEmpty ? null : _holdCurrentBill,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hold [F4]', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _cart.isEmpty ? null : _showPaymentModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pitchBlack,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payments_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Charge ${currencyFormatter.format(_grandTotal)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.2,
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.zinc600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.pitchBlack,
          ),
        ),
      ],
    );
  }

  // BOTTOM SHEET FOR MOBILE
  void _openMobileBottomSheet() {
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
            child: _buildReceiptDock(),
          );
        },
      ),
    );
  }

  // REDESIGNED PAYMENT MODAL (Digital POS Register Experience)
  void _showPaymentModal() {
    String selectedMethod = 'UPI';
    double cashReceived = _grandTotal.ceilToDouble();
    final cashController = TextEditingController(text: cashReceived.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final double parsedCash = double.tryParse(cashController.text) ?? 0.0;
          final double changeDue = parsedCash - _grandTotal;

          return AlertDialog(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Terminal',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Choose customer tender & print invoice',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc500),
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
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Amount Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.pitchBlack,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'AMOUNT DUE',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.zinc400,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(_grandTotal),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              color: AppColors.white,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Method Tabs
                    Row(
                      children: ['UPI', 'Cash', 'Card'].map((method) {
                        final isSelected = selectedMethod == method;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => setDialogState(() => selectedMethod = method),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.pitchBlack : AppColors.zinc100,
                                  borderRadius: BorderRadius.circular(14),
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
                                      color: isSelected ? AppColors.white : AppColors.zinc700,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      method,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? AppColors.white : AppColors.zinc700,
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

                    // Method Content
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
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800),
                            onChanged: (_) => setDialogState(() {}),
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              prefixStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800),
                              filled: true,
                              fillColor: AppColors.zinc100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Quick cash tender pills
                          Row(
                            children: [
                              _buildTenderChip('Exact', _grandTotal, cashController, setDialogState),
                              _buildTenderChip('₹100', 100, cashController, setDialogState),
                              _buildTenderChip('₹200', 200, cashController, setDialogState),
                              _buildTenderChip('₹500', 500, cashController, setDialogState),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Change Return Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: changeDue >= 0 ? AppColors.zinc100 : Colors.red.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: changeDue >= 0 ? AppColors.pitchBlack : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else if (selectedMethod == 'UPI') ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.white,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: AppColors.zinc100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Center(
                                child: Icon(Icons.qr_code_2_rounded, size: 110, color: AppColors.pitchBlack),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Scan with Google Pay, PhonePe, or Paytm',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc500),
                            ),
                            const Text(
                              'VPA: vihabiller@icici',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.pitchBlack),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.zinc100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.contactless_rounded, size: 44, color: AppColors.pitchBlack),
                            SizedBox(height: 10),
                            Text(
                              'Tap or Insert Card',
                              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                            Text(
                              'Waiting for card machine PIN confirmation...',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
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
                    _showReceiptCompletedModal();
                  },
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text('Complete & Print Slip [Enter]'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pitchBlack,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTenderChip(String label, double amount, TextEditingController controller, StateSetter setDialogState) {
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
              color: AppColors.zinc100,
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

  // REALISTIC THERMAL PAPER SLIP
  void _showReceiptCompletedModal() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.zinc100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.pitchBlack, size: 30),
              ),
              const SizedBox(height: 12),
              const Text(
                'Payment Approved',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const Text(
                'Receipt sent to 80mm thermal printer',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
              ),
              const SizedBox(height: 16),

              // Authentic Thermal Paper Layout
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.zinc50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'VIHA BILLING STORE',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5),
                    ),
                    const Text(
                      '124, Anna Salai, Chennai - 600002',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.zinc500),
                    ),
                    const Text(
                      'GSTIN: 33AAAAA0000A1Z5 | Ph: 044-28521100',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.zinc500),
                    ),
                    const Divider(color: AppColors.border, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_billNumber, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700)),
                        Text(DateFormat('dd/MM/yy hh:mm a').format(DateTime.now()), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10)),
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
                              Text(currencyFormatter.format(item.subtotal), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        )),
                    const Divider(color: AppColors.border, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Grand Total', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 14)),
                        Text(currencyFormatter.format(_grandTotal), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.pitchBlack)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('*** THANK YOU VISIT AGAIN ***', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.pitchBlack)),
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
                      icon: const Icon(Icons.share_rounded, size: 16),
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
                      child: const Text('New Bill', style: TextStyle(fontSize: 12)),
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
