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

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps_outlined},
    {'name': 'Beverages', 'icon': Icons.local_cafe_outlined},
    {'name': 'Bakery', 'icon': Icons.bakery_dining_outlined},
    {'name': 'Dairy', 'icon': Icons.egg_outlined},
    {'name': 'Snacks', 'icon': Icons.cookie_outlined},
    {'name': 'Spices', 'icon': Icons.grain_outlined},
    {'name': 'Essentials', 'icon': Icons.inventory_2_outlined},
  ];

  // Professional Product Catalog
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
      name: 'Roasted Masala Tea (200g)',
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
      stock: 6,
    ),
    const Product(
      id: 'p4',
      name: 'Butter Croissant (2 pcs)',
      category: 'Bakery',
      barcode: '8901234004',
      price: 140.0,
      costPrice: 85.0,
      gstPercent: 5.0,
      stock: 4,
    ),
    const Product(
      id: 'p5',
      name: 'Pure Desi Cow Ghee (500ml)',
      category: 'Dairy',
      barcode: '8901234005',
      price: 490.0,
      costPrice: 380.0,
      gstPercent: 12.0,
      stock: 22,
    ),
    const Product(
      id: 'p6',
      name: 'California Almonds (250g)',
      category: 'Snacks',
      barcode: '8901234006',
      price: 320.0,
      costPrice: 240.0,
      gstPercent: 5.0,
      stock: 50,
    ),
    const Product(
      id: 'p7',
      name: 'Dark Chocolate Cookie Pack',
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
      name: 'Wood Pressed Gingelly Oil (1L)',
      category: 'Essentials',
      barcode: '8901234010',
      price: 260.0,
      costPrice: 190.0,
      gstPercent: 5.0,
      stock: 14,
    ),
  ];

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Bill held successfully (${_heldBills.length} queued)',
          style: const TextStyle(fontFamily: 'Poppins', color: AppColors.white, fontSize: 12),
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

  // DESKTOP: Clean Industrial POS Layout (Catalog Left + Invoice Sheet Right)
  Widget _buildDesktopView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Catalog Area (60% width)
        Expanded(
          flex: 60,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBar(),
                const SizedBox(height: 12),
                _buildSearchBar(),
                const SizedBox(height: 10),
                _buildCategoryTabs(),
                const SizedBox(height: 12),
                Expanded(child: _buildProductGrid(crossAxisCount: 3)),
              ],
            ),
          ),
        ),

        // Vertical Divider
        Container(width: 1, color: AppColors.border),

        // Right Invoice Table Register (40% width)
        Expanded(
          flex: 40,
          child: Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(16),
            child: _buildInvoiceTablePanel(),
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
          flex: 52,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildHeaderBar(),
                const SizedBox(height: 10),
                _buildSearchBar(),
                const SizedBox(height: 10),
                _buildCategoryTabs(),
                const SizedBox(height: 10),
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
            padding: const EdgeInsets.all(12),
            child: _buildInvoiceTablePanel(),
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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBar(),
              const SizedBox(height: 10),
              _buildSearchBar(),
              const SizedBox(height: 10),
              _buildCategoryTabs(),
              const SizedBox(height: 10),
              Expanded(child: _buildProductGrid(crossAxisCount: 2)),
            ],
          ),
        ),

        // Mobile Bottom Cart Summary Bar
        if (_cart.isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Material(
              color: AppColors.pitchBlack,
              borderRadius: BorderRadius.circular(6),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: _openMobileBottomSheet,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_outlined, color: AppColors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        '${_cart.fold(0, (sum, item) => sum + item.quantity)} Items • ${currencyFormatter.format(_grandTotal)}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'View Bill',
                        style: TextStyle(
                          color: AppColors.white,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // COMPACT TOP HEADER
  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'POS Register',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.pitchBlack,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'COUNTER 01',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.zinc700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.zinc500,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (_heldBills.isNotEmpty) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _recallHeldBill,
                icon: const Icon(Icons.history_outlined, size: 14),
                label: Text(
                  'Held (${_heldBills.length})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // SEARCH BAR (No heavy rounded radius)
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Search items by name, category, or barcode...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.zinc500, size: 18),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'F2',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.zinc600,
                ),
              ),
            ),
          ],
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.pitchBlack, width: 1.2),
        ),
      ),
    );
  }

  // CLEAN HORIZONTAL CATEGORY TABS (Crisp 4px radius, Clean Icons, Zero Emojis)
  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          final name = cat['name'] as String;
          final icon = cat['icon'] as IconData;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = name);
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.pitchBlack : AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? AppColors.pitchBlack : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: isSelected ? AppColors.white : AppColors.zinc600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.white : AppColors.zinc700,
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

  // DENSE PRODUCT GRID (Fast, crisp, 6px radius)
  Widget _buildProductGrid({required int crossAxisCount}) {
    final products = _filteredProducts;
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 36, color: AppColors.zinc400),
            const SizedBox(height: 8),
            const Text(
              'No items match your search',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.pitchBlack,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Try another keyword or barcode',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
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
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  // SHARP ENTERPRISE PRODUCT TILE
  Widget _buildProductCard(Product product) {
    final isLowStock = product.stock <= 6;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _addToCart(product),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category tag & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.zinc600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.pitchBlack,
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
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.pitchBlack,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),

              // SKU
              Text(
                'SKU: ${product.barcode}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColors.zinc400,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),

              // Stock Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isLowStock ? 'Stock: ${product.stock} (Low)' : 'Stock: ${product.stock}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: isLowStock ? FontWeight.w600 : FontWeight.w400,
                      color: isLowStock ? Colors.orange.shade800 : AppColors.zinc500,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.pitchBlack,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.add, color: AppColors.white, size: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PROFESSIONAL INVOICE TABLE REGISTER (Clean Tabular Layout)
  Widget _buildInvoiceTablePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ticket Info Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Bill',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.pitchBlack,
                  ),
                ),
                Text(
                  _billNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
                    icon: const Icon(Icons.pause_circle_outline, size: 18, color: AppColors.zinc600),
                    onPressed: _holdCurrentBill,
                  ),
                  IconButton(
                    tooltip: 'Clear Bill',
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.zinc400),
                    onPressed: _clearCart,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Customer Phone Field (Compact)
        TextField(
          controller: _customerController,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Customer phone or name...',
            prefixIcon: const Icon(Icons.person_outline, size: 16, color: AppColors.zinc600),
            filled: true,
            fillColor: AppColors.zinc50,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
        const SizedBox(height: 10),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.zinc100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 5,
                child: Text('ITEM', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.zinc600)),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text('QTY', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.zinc600)),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('AMOUNT', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.zinc600)),
                ),
              ),
              SizedBox(width: 24),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Item List (Clean rows)
        Expanded(
          child: _cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_outlined, size: 32, color: AppColors.zinc400),
                      const SizedBox(height: 8),
                      const Text(
                        'Bill is empty',
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const Text(
                        'Select items from the catalog to add',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _cart.length,
                  separatorBuilder: (_, index) => const Divider(color: AppColors.border, height: 1),
                  itemBuilder: (context, index) {
                    final item = _cart[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      child: Row(
                        children: [
                          // Item Name & Rate
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
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: AppColors.pitchBlack,
                                  ),
                                ),
                                Text(
                                  '${currencyFormatter.format(item.unitPrice)} • GST ${item.product.gstPercent.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.zinc500),
                                ),
                              ],
                            ),
                          ),

                          // Quantity Controls (Crisp compact box)
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () => _updateQuantity(index, -1),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      child: Icon(Icons.remove, size: 12),
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 11),
                                  ),
                                  InkWell(
                                    onTap: () => _updateQuantity(index, 1),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      child: Icon(Icons.add, size: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Line Total
                          Expanded(
                            flex: 3,
                            child: Text(
                              currencyFormatter.format(item.subtotal),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.pitchBlack,
                              ),
                            ),
                          ),

                          // Remove Button
                          IconButton(
                            icon: const Icon(Icons.close, size: 14, color: AppColors.zinc400),
                            onPressed: () => _removeFromCart(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        const Divider(color: AppColors.border, height: 16),

        // Summary Breakdown Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.zinc50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildSummaryLine('Subtotal', currencyFormatter.format(_cartSubtotal)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Discount',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc600),
                      ),
                      const SizedBox(width: 6),
                      DropdownButton<double>(
                        value: _overallDiscountPercent,
                        underline: const SizedBox(),
                        isDense: true,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
                        items: [0.0, 5.0, 10.0, 15.0].map((d) {
                          return DropdownMenuItem<double>(
                            value: d,
                            child: Text('${d.toStringAsFixed(0)}%'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _overallDiscountPercent = val);
                        },
                      ),
                    ],
                  ),
                  Text(
                    '- ${currencyFormatter.format(_discountAmount)}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildSummaryLine('Tax (GST)', currencyFormatter.format(_cartTax)),
              const Divider(color: AppColors.border, height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Net Payable',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.pitchBlack),
                  ),
                  Text(
                    currencyFormatter.format(_grandTotal),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.pitchBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Action Buttons: Hold [F4] + Charge & Print [F12]
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _cart.isEmpty ? null : _holdCurrentBill,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Hold [F4]', style: TextStyle(fontFamily: 'Poppins', fontSize: 11)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _cart.isEmpty ? null : _showPaymentModal,
                icon: const Icon(Icons.print_outlined, size: 16),
                label: Text(
                  'Pay ${currencyFormatter.format(_grandTotal)}',
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pitchBlack,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc600)),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.pitchBlack)),
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
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            padding: const EdgeInsets.all(16),
            child: _buildInvoiceTablePanel(),
          );
        },
      ),
    );
  }

  // PAYMENT MODAL (Sharp 6px radius, max 600 weight)
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            titlePadding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment & Print',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Amount Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormatter.format(_grandTotal),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: AppColors.pitchBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Method Selector
                  Row(
                    children: ['UPI', 'Cash', 'Card'].map((method) {
                      final isSelected = selectedMethod == method;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () => setDialogState(() => selectedMethod = method),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.pitchBlack : AppColors.zinc50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected ? AppColors.pitchBlack : AppColors.border,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    method == 'UPI'
                                        ? Icons.qr_code_scanner_outlined
                                        : method == 'Cash'
                                            ? Icons.payments_outlined
                                            : Icons.credit_card_outlined,
                                    color: isSelected ? AppColors.white : AppColors.zinc700,
                                    size: 18,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
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
                  const SizedBox(height: 14),

                  // Cash Calculation
                  if (selectedMethod == 'Cash') ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cash Given by Customer', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: cashController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
                          onChanged: (_) => setDialogState(() {}),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTenderChip('Exact', _grandTotal, cashController, setDialogState),
                            _buildTenderChip('₹100', 100, cashController, setDialogState),
                            _buildTenderChip('₹200', 200, cashController, setDialogState),
                            _buildTenderChip('₹500', 500, cashController, setDialogState),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: changeDue >= 0 ? AppColors.zinc100 : Colors.red.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                changeDue >= 0 ? 'Change to Return:' : 'Shortage:',
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: changeDue >= 0 ? AppColors.pitchBlack : Colors.red),
                              ),
                              Text(
                                currencyFormatter.format(changeDue.abs()),
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: changeDue >= 0 ? AppColors.pitchBlack : Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (selectedMethod == 'UPI') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_2, size: 90, color: AppColors.pitchBlack),
                          const SizedBox(height: 6),
                          const Text('Scan using any UPI App (GPay, PhonePe, Paytm)', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.zinc500)),
                          const Text('VPA: vihabiller@icici', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.zinc100, borderRadius: BorderRadius.circular(4)),
                      child: const Column(
                        children: [
                          Icon(Icons.contactless_outlined, size: 32),
                          SizedBox(height: 6),
                          Text('Swipe / Tap Card on POS Terminal', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showReceiptCompletedModal();
                  },
                  icon: const Icon(Icons.print_outlined, size: 16),
                  label: const Text('Complete & Print Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pitchBlack,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: () {
            setDialogState(() {
              controller.text = amount.toStringAsFixed(0);
            });
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.zinc100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.pitchBlack, size: 36),
              const SizedBox(height: 8),
              const Text(
                'Bill Generated',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const Text(
                'Receipt sent to 80mm thermal printer',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
              ),
              const SizedBox(height: 12),

              // Authentic Thermal Paper Layout
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.zinc50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'VIHA BILLING STORE',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 1),
                    ),
                    const Text('Chennai - 600002 | GSTIN: 33AAAAA0000A1Z5', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.zinc500)),
                    const Divider(color: AppColors.border, height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_billNumber, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600)),
                        Text(DateFormat('dd/MM/yy hh:mm a').format(DateTime.now()), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10)),
                      ],
                    ),
                    const Divider(color: AppColors.border, height: 12),
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
                    const Divider(color: AppColors.border, height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(currencyFormatter.format(_grandTotal), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.pitchBlack)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('*** THANK YOU VISIT AGAIN ***', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.zinc500)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.share_outlined, size: 14),
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
                      child: const Text('New Bill', style: TextStyle(fontSize: 11)),
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
