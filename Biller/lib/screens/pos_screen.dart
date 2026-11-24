import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/bill_item.dart';
import '../theme/app_colors.dart';
import '../services/inventory_repository.dart';
import '../widgets/antd_message.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final InventoryRepository _inventoryRepo = InventoryRepository();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _inventoryRepo.addListener(_onRepoChange);
  }

  @override
  void dispose() {
    _inventoryRepo.removeListener(_onRepoChange);
    _searchController.dispose();
    _customerController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onRepoChange() {
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> get _categories {
    final defaultIcons = {
      'Beverages': Icons.local_cafe_outlined,
      'Bakery': Icons.bakery_dining_outlined,
      'Dairy': Icons.egg_outlined,
      'Snacks': Icons.cookie_outlined,
      'Spices': Icons.grain_outlined,
      'Essentials': Icons.inventory_2_outlined,
    };
    return [
      {'name': 'All', 'icon': Icons.apps_outlined},
      ..._inventoryRepo.categories.map((c) => {
        'name': c.name,
        'icon': defaultIcons[c.name] ?? Icons.category_outlined,
      }),
    ];
  }

  List<Product> get _allProducts => _inventoryRepo.products;

  final List<BillItem> _cart = [];
  final List<List<BillItem>> _heldBills = [];
  double _overallDiscountPercent = 0.0;
  String _billNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

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
    AntdMessage.info(context, 'Bill held in queue (${_heldBills.length} queued)');
  }

  void _recallHeldBill() {
    if (_heldBills.isEmpty) return;
    setState(() {
      final lastHeld = _heldBills.removeLast();
      _cart.clear();
      _cart.addAll(lastHeld);
    });
    AntdMessage.success(context, 'Recalled queued bill (${_cart.length} items)');
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

  // DESKTOP: Light Gray Industrial Layout
  Widget _buildDesktopView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Catalog Area (60% width) - RepaintBoundary for 60fps rendering
        Expanded(
          flex: 60,
          child: RepaintBoundary(
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
        ),

        // Vertical Divider
        Container(width: 1, color: AppColors.border),

        // Right Invoice Table Register (40% width) - Isolated RepaintBoundary
        Expanded(
          flex: 40,
          child: RepaintBoundary(
            child: Container(
              color: AppColors.lightGray,
              padding: const EdgeInsets.all(16),
              child: _buildInvoiceTablePanel(),
            ),
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
          child: RepaintBoundary(
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
        ),
        Container(width: 1, color: AppColors.border),
        Expanded(
          flex: 48,
          child: RepaintBoundary(
            child: Container(
              color: AppColors.lightGray,
              padding: const EdgeInsets.all(12),
              child: _buildInvoiceTablePanel(),
            ),
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
                      const Icon(Icons.receipt_outlined, color: AppColors.textOnDark, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        '${_cart.fold(0, (sum, item) => sum + item.quantity)} Items • ${currencyFormatter.format(_grandTotal)}',
                        style: const TextStyle(
                          color: AppColors.textOnDark,
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'View Bill',
                        style: TextStyle(
                          color: AppColors.textOnDark,
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textOnDark, size: 12),
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
                color: AppColors.lightGray,
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
                  backgroundColor: AppColors.lightGray,
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

  // SEARCH BAR IN LIGHT GRAY
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
                color: AppColors.canvas,
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
        fillColor: AppColors.lightGray,
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

  // CLEAN HORIZONTAL CATEGORY TABS (Light Gray)
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
                  color: isSelected ? AppColors.pitchBlack : AppColors.lightGray,
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
                      color: isSelected ? AppColors.textOnDark : AppColors.zinc600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.textOnDark : AppColors.zinc700,
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

  // DENSE PRODUCT GRID (Light Gray)
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
      cacheExtent: 1000,
      addRepaintBoundaries: true,
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

  // SHARP PRODUCT TILE IN LIGHT GRAY
  Widget _buildProductCard(Product product) {
    final isLowStock = product.stock <= 6;

    return Material(
      key: ValueKey(product.id),
      color: AppColors.lightGray,
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
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.zinc600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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
                  color: AppColors.zinc500,
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
                      color: isLowStock ? Colors.orange.shade900 : AppColors.zinc600,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.pitchBlack,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.add, color: AppColors.textOnDark, size: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // INVOICE TABLE REGISTER (In Sleek Light Gray)
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
                    color: AppColors.zinc600,
                  ),
                ),
              ],
            ),
            if (_cart.isNotEmpty)
              Row(
                children: [
                  IconButton(
                    tooltip: 'Hold Bill [F4]',
                    icon: const Icon(Icons.pause_circle_outline, size: 18, color: AppColors.zinc700),
                    onPressed: _holdCurrentBill,
                  ),
                  IconButton(
                    tooltip: 'Clear Bill',
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.zinc500),
                    onPressed: _clearCart,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Customer Phone Field (Light Gray)
        TextField(
          controller: _customerController,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Customer phone or name...',
            prefixIcon: const Icon(Icons.person_outline, size: 16, color: AppColors.zinc600),
            filled: true,
            fillColor: AppColors.canvas,
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
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text('ITEM', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.zinc700)),
              ),
              SizedBox(
                width: 78,
                child: Center(
                  child: Text('QTY', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.zinc700)),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 65,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('AMOUNT', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.zinc700)),
                ),
              ),
              SizedBox(width: 28),
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
                      key: ValueKey(item.product.id),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Row(
                        children: [
                          // Item Name & Rate
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
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: AppColors.pitchBlack,
                                  ),
                                ),
                                Text(
                                  '${currencyFormatter.format(item.unitPrice)} • GST ${item.product.gstPercent.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.zinc600),
                                ),
                              ],
                            ),
                          ),

                          // Compact Segmented Stepper Box
                          SizedBox(
                            width: 78,
                            child: Center(
                              child: Container(
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.canvas,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => _updateQuantity(index, -1),
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(3)),
                                      child: const SizedBox(
                                        width: 24,
                                        height: 26,
                                        child: Center(
                                          child: Icon(Icons.remove, size: 12, color: AppColors.pitchBlack),
                                        ),
                                      ),
                                    ),
                                    Container(width: 1, height: 26, color: AppColors.border),
                                    SizedBox(
                                      width: 26,
                                      child: Center(
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                            color: AppColors.pitchBlack,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(width: 1, height: 26, color: AppColors.border),
                                    InkWell(
                                      onTap: () => _updateQuantity(index, 1),
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
                                      child: const SizedBox(
                                        width: 24,
                                        height: 26,
                                        child: Center(
                                          child: Icon(Icons.add, size: 12, color: AppColors.pitchBlack),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Line Total
                          SizedBox(
                            width: 65,
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
                          SizedBox(
                            width: 28,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 14, color: AppColors.zinc500),
                              onPressed: () => _removeFromCart(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        const Divider(color: AppColors.border, height: 16),

        // Summary Breakdown Box in Canvas Light Gray
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(4),
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
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc700),
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
                  backgroundColor: AppColors.lightGray,
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
                  foregroundColor: AppColors.textOnDark,
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
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc700)),
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
              color: AppColors.lightGray,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            padding: const EdgeInsets.all(16),
            child: _buildInvoiceTablePanel(),
          );
        },
      ),
    );
  }

  // COMPLETELY REDESIGNED 2-COLUMN COMMERCIAL POS PAYMENT TERMINAL
  void _showPaymentModal() {
    String selectedMethod = 'Cash';
    double cashReceived = _grandTotal.ceilToDouble();
    final cashController = TextEditingController(text: cashReceived.toStringAsFixed(0));
    String cardType = 'Visa';
    final cardRefController = TextEditingController();
    bool isCompleting = false;

    void addNumpadDigit(String digit, StateSetter setDialogState) {
      setDialogState(() {
        if (digit == 'C') {
          cashController.text = '0';
        } else if (digit == '00') {
          if (cashController.text != '0') {
            cashController.text += '00';
          }
        } else {
          if (cashController.text == '0') {
            cashController.text = digit;
          } else {
            cashController.text += digit;
          }
        }
      });
    }

    void backspaceNumpad(StateSetter setDialogState) {
      setDialogState(() {
        if (cashController.text.length > 1) {
          cashController.text = cashController.text.substring(0, cashController.text.length - 1);
        } else {
          cashController.text = '0';
        }
      });
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final double parsedCash = double.tryParse(cashController.text) ?? 0.0;
          final double changeDue = parsedCash - _grandTotal;
          final screenWidth = MediaQuery.of(context).size.width;
          final isWide = screenWidth >= 800;

          return Dialog(
            backgroundColor: AppColors.lightGray,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SizedBox(
              width: isWide ? 760 : 420,
              height: isWide ? 560 : null,
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left 40%: Bill Receipt Summary Column
                        Expanded(
                          flex: 40,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
                              border: Border(right: BorderSide(color: AppColors.border, width: 1)),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: _buildTerminalBillSummary(),
                          ),
                        ),

                        // Right 60%: Interactive Payment & Numpad Controller
                        Expanded(
                          flex: 60,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _buildTerminalPaymentControls(
                              selectedMethod: selectedMethod,
                              cashController: cashController,
                              changeDue: changeDue,
                              cardType: cardType,
                              cardRefController: cardRefController,
                              onMethodChanged: (method) => setDialogState(() => selectedMethod = method),
                              onCardTypeChanged: (type) => setDialogState(() => cardType = type),
                              onNumpadTap: (val) => addNumpadDigit(val, setDialogState),
                              onNumpadBackspace: () => backspaceNumpad(setDialogState),
                              setDialogState: setDialogState,
                              isCompleting: isCompleting,
                              onComplete: () async {
                                if (isCompleting) return;
                                setDialogState(() => isCompleting = true);
                                await Future.delayed(const Duration(milliseconds: 300));
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  _showReceiptCompletedModal();
                                }
                              },
                              onClose: () => Navigator.pop(ctx),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTerminalBillSummary(compact: true),
                          const SizedBox(height: 16),
                          _buildTerminalPaymentControls(
                            selectedMethod: selectedMethod,
                            cashController: cashController,
                            changeDue: changeDue,
                            cardType: cardType,
                            cardRefController: cardRefController,
                            onMethodChanged: (method) => setDialogState(() => selectedMethod = method),
                            onCardTypeChanged: (type) => setDialogState(() => cardType = type),
                            onNumpadTap: (val) => addNumpadDigit(val, setDialogState),
                            onNumpadBackspace: () => backspaceNumpad(setDialogState),
                            setDialogState: setDialogState,
                            isCompleting: isCompleting,
                            onComplete: () async {
                              if (isCompleting) return;
                              setDialogState(() => isCompleting = true);
                              await Future.delayed(const Duration(milliseconds: 300));
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                _showReceiptCompletedModal();
                              }
                            },
                            onClose: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  // LEFT COLUMN: TICKET RECEIPT OVERVIEW
  Widget _buildTerminalBillSummary({bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pitchBlack,
                  ),
                ),
                Text(
                  _billNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.zinc600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.pitchBlack,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${_cart.length} ITEMS',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 8),

        // Scrollable itemized lines
        if (!compact)
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _cart.length,
              separatorBuilder: (_, index) => const Divider(color: AppColors.border, height: 10),
              itemBuilder: (context, index) {
                final item = _cart[index];
                return Row(
                  children: [
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
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.pitchBlack,
                            ),
                          ),
                          Text(
                            '${currencyFormatter.format(item.unitPrice)} × ${item.quantity}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: AppColors.zinc500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormatter.format(item.subtotal),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pitchBlack,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        const Divider(color: AppColors.border, height: 14),

        // Net Amount Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.pitchBlack,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL PAYABLE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.zinc400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currencyFormatter.format(_grandTotal),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Subtotal: ${currencyFormatter.format(_cartSubtotal)} • GST: ${currencyFormatter.format(_cartTax)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColors.zinc400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // RIGHT COLUMN: INTERACTIVE TENDER CONTROLS & TOUCH NUMPAD
  Widget _buildTerminalPaymentControls({
    required String selectedMethod,
    required TextEditingController cashController,
    required double changeDue,
    required String cardType,
    required TextEditingController cardRefController,
    required ValueChanged<String> onMethodChanged,
    required ValueChanged<String> onCardTypeChanged,
    required ValueChanged<String> onNumpadTap,
    required VoidCallback onNumpadBackspace,
    required StateSetter setDialogState,
    required VoidCallback onComplete,
    required VoidCallback onClose,
    bool isCompleting = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Close
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Payment Tender',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.pitchBlack,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Method Selector Tabs (Cash, UPI, Card)
        Row(
          children: [
            _buildTenderMethodTab('Cash', Icons.payments_outlined, selectedMethod == 'Cash', onMethodChanged),
            const SizedBox(width: 8),
            _buildTenderMethodTab('UPI', Icons.qr_code_scanner_outlined, selectedMethod == 'UPI', onMethodChanged),
            const SizedBox(width: 8),
            _buildTenderMethodTab('Card', Icons.credit_card_outlined, selectedMethod == 'Card', onMethodChanged),
          ],
        ),
        const SizedBox(height: 14),

        // Dynamic Method Content
        Expanded(
          child: selectedMethod == 'Cash'
              ? _buildCashNumpadView(
                  cashController: cashController,
                  changeDue: changeDue,
                  onNumpadTap: onNumpadTap,
                  onNumpadBackspace: onNumpadBackspace,
                  setDialogState: setDialogState,
                )
              : selectedMethod == 'UPI'
                  ? _buildUpiTerminalView()
                  : _buildCardTerminalView(
                      cardType: cardType,
                      cardRefController: cardRefController,
                      onCardTypeChanged: onCardTypeChanged,
                    ),
        ),

        const SizedBox(height: 12),

        // Full Width Finish Button with Loader
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: isCompleting ? null : onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pitchBlack,
              foregroundColor: AppColors.textOnDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: isCompleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print_outlined, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Complete & Print Receipt [Enter]',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTenderMethodTab(String label, IconData icon, bool isSelected, ValueChanged<String> onChanged) {
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(label),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.pitchBlack : AppColors.canvas,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppColors.pitchBlack : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.textOnDark : AppColors.zinc700,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.textOnDark : AppColors.zinc700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CASH NUMPAD INTERACTIVE REGISTER
  Widget _buildCashNumpadView({
    required TextEditingController cashController,
    required double changeDue,
    required ValueChanged<String> onNumpadTap,
    required VoidCallback onNumpadBackspace,
    required StateSetter setDialogState,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Side: Tender Inputs & Change Due (55% width)
        Expanded(
          flex: 55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cash Tendered (₹)',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.zinc600),
              ),
              const SizedBox(height: 4),

              // Digital Tender Display Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '₹ ${cashController.text}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pitchBlack,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Quick Note Pills
              Row(
                children: [
                  _buildTenderChip('Exact', _grandTotal, cashController, setDialogState),
                  _buildTenderChip('₹100', 100, cashController, setDialogState),
                  _buildTenderChip('₹500', 500, cashController, setDialogState),
                  _buildTenderChip('₹2000', 2000, cashController, setDialogState),
                ],
              ),
              const Spacer(),

              // Change Return Status Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: changeDue >= 0 ? AppColors.canvas : Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: changeDue >= 0 ? AppColors.border : Colors.redAccent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      changeDue >= 0 ? 'BALANCE RETURN' : 'AMOUNT SHORTAGE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: changeDue >= 0 ? AppColors.zinc600 : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currencyFormatter.format(changeDue.abs()),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: changeDue >= 0 ? AppColors.pitchBlack : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),

        // Right Side: Commercial Touch Numpad (45% width)
        Expanded(
          flex: 45,
          child: Column(
            children: [
              _buildNumpadRow(['1', '2', '3'], onNumpadTap),
              const SizedBox(height: 6),
              _buildNumpadRow(['4', '5', '6'], onNumpadTap),
              const SizedBox(height: 6),
              _buildNumpadRow(['7', '8', '9'], onNumpadTap),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildNumpadKey('C', onNumpadTap),
                  const SizedBox(width: 6),
                  _buildNumpadKey('0', onNumpadTap),
                  const SizedBox(width: 6),
                  _buildNumpadBackspaceKey(onNumpadBackspace),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumpadRow(List<String> keys, ValueChanged<String> onKey) {
    return Row(
      children: keys.map((k) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildNumpadKey(k, onKey),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumpadKey(String label, ValueChanged<String> onKey) {
    return Expanded(
      child: InkWell(
        onTap: () => onKey(label),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.pitchBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadBackspaceKey(VoidCallback onBackspace) {
    return Expanded(
      child: InkWell(
        onTap: onBackspace,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Icon(Icons.backspace_outlined, size: 16, color: AppColors.pitchBlack),
          ),
        ),
      ),
    );
  }

  // DYNAMIC UPI TERMINAL VIEW
  Widget _buildUpiTerminalView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.qr_code_2_rounded, size: 100, color: AppColors.pitchBlack),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Dynamic UPI QR',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Scan with GPay, PhonePe, or Paytm',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'VPA: vihabiller@icici',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount: ${currencyFormatter.format(_grandTotal)}',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CARD TERMINAL VIEW
  Widget _buildCardTerminalView({
    required String cardType,
    required TextEditingController cardRefController,
    required ValueChanged<String> onCardTypeChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.contactless_outlined, size: 24, color: AppColors.pitchBlack),
              SizedBox(width: 8),
              Text(
                'POS EDC Machine Connected',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Insert, swipe, or tap customer card on EDC pin-pad.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc600),
          ),
          const SizedBox(height: 14),

          // Card Brand Selector
          Row(
            children: ['Visa', 'Mastercard', 'RuPay'].map((brand) {
              final isSel = cardType == brand;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => onCardTypeChanged(brand),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.pitchBlack : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isSel ? AppColors.pitchBlack : AppColors.border),
                    ),
                    child: Text(
                      brand,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSel ? AppColors.textOnDark : AppColors.zinc700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Transaction Auth / Ref ID
          TextField(
            controller: cardRefController,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Card Approval / Auth Code (Optional)...',
              isDense: true,
              fillColor: AppColors.lightGray,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ],
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
              color: AppColors.canvas,
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
        backgroundColor: AppColors.lightGray,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', width: 42, height: 42, fit: BoxFit.contain),
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

              // Authentic Thermal Paper in Canvas Gray
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'VIHA BILLING STORE',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 1),
                    ),
                    const Text('Chennai - 600002 | GSTIN: 33AAAAA0000A1Z5', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: AppColors.zinc600)),
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
                    const Text('*** THANK YOU VISIT AGAIN ***', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.zinc600)),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pitchBlack,
                        foregroundColor: AppColors.textOnDark,
                      ),
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
