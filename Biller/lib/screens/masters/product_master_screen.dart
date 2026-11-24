import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../services/inventory_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/form_helpers.dart';
import '../../widgets/antd_message.dart';

class ProductMasterScreen extends StatefulWidget {
  const ProductMasterScreen({super.key});

  @override
  State<ProductMasterScreen> createState() => _ProductMasterScreenState();
}

class _ProductMasterScreenState extends State<ProductMasterScreen> {
  final InventoryRepository _repo = InventoryRepository();
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  String _searchQuery = '';
  String _categoryFilter = 'All';
  String _stockFilter = 'All';

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  List<Product> get _filteredProducts {
    return _repo.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.barcode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.subcategory.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == 'All' || p.category.toLowerCase() == _categoryFilter.toLowerCase();
      final matchesStock = _stockFilter == 'All' ||
          (_stockFilter == 'In Stock' && p.stock > p.reorderLevel) ||
          (_stockFilter == 'Low Stock' && p.stock <= p.reorderLevel && p.stock > 0) ||
          (_stockFilter == 'Out of Stock' && p.stock <= 0);

      return matchesSearch && matchesCategory && matchesStock;
    }).toList();
  }

  void _openProductForm([Product? productToEdit]) {
    if (_repo.categories.isEmpty) {
      AntdMessage.warning(context, 'Please create at least one Category in Category Master first');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ProductFormDialog(
        product: productToEdit,
        repo: _repo,
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Delete Product',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}" (SKU: ${product.barcode})? This action cannot be undone.',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc700),
        ),
        actions: [
          ErpFormWidgets.outlinedButton(
            onPressed: () => Navigator.pop(ctx),
            text: 'Cancel',
          ),
          SizedBox(
            height: 35,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                _repo.deleteProduct(product.id);
                Navigator.pop(ctx);
                AntdMessage.success(context, 'Product "${product.name}" deleted successfully');
              },
              child: const Text(
                'Delete',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    final totalSkus = _repo.products.length;
    final inStockCount = _repo.products.where((p) => p.stock > p.reorderLevel).length;
    final lowStockCount = _repo.products.where((p) => p.stock <= p.reorderLevel).length;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Master',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pitchBlack,
                      ),
                    ),
                    Text(
                      'Inventory items, barcode indexing, pricing, and GST configurations',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.zinc500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Metric Pills
                _buildStatPill('Total SKUs', '$totalSkus', Icons.inventory_2_outlined),
                const SizedBox(width: 8),
                _buildStatPill('In Stock', '$inStockCount', Icons.check_circle_outline),
                const SizedBox(width: 8),
                _buildStatPill('Low Stock', '$lowStockCount', Icons.warning_amber_outlined, isAlert: lowStockCount > 0),
                const SizedBox(width: 16),
                // Add Product Button (35px)
                ErpFormWidgets.primaryButton(
                  onPressed: () => _openProductForm(),
                  text: 'Add Product',
                  icon: Icons.add,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Filter Bar (Strict 35px height)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Search Input (35px)
                  Expanded(
                    flex: 3,
                    child: ErpFormWidgets.textField(
                      controller: _searchController,
                      hintText: 'Search by SKU, barcode, product name or sub-category...',
                      prefixIcon: Icons.search,
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Category Filter Dropdown (35px)
                  SizedBox(
                    width: 160,
                    child: ErpFormWidgets.dropdownField<String>(
                      value: _categoryFilter,
                      items: [
                        const DropdownMenuItem(value: 'All', child: Text('Category: All')),
                        ..._repo.categories.map(
                          (c) => DropdownMenuItem(value: c.name, child: Text(c.name)),
                        ),
                      ],
                      onChanged: (val) => setState(() => _categoryFilter = val ?? 'All'),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Stock Level Filter (35px)
                  SizedBox(
                    width: 150,
                    child: ErpFormWidgets.dropdownField<String>(
                      value: _stockFilter,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('Stock: All')),
                        DropdownMenuItem(value: 'In Stock', child: Text('In Stock')),
                        DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock Alert')),
                        DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock')),
                      ],
                      onChanged: (val) => setState(() => _stockFilter = val ?? 'All'),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Reset Button (35px)
                  ErpFormWidgets.secondaryButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _categoryFilter = 'All';
                        _stockFilter = 'All';
                      });
                    },
                    text: 'Reset',
                    icon: Icons.refresh,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Enterprise Data Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        border: Border(bottom: BorderSide(color: AppColors.border)),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 110, child: Text('BARCODE / SKU', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          Expanded(flex: 3, child: Text('PRODUCT NAME', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 120, child: Text('CATEGORY', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 130, child: Text('SUB-CATEGORY', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 60, child: Text('UOM', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 90, child: Align(alignment: Alignment.centerRight, child: Text('COST', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700)))),
                          SizedBox(width: 100, child: Align(alignment: Alignment.centerRight, child: Text('SELLING (MRP)', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700)))),
                          SizedBox(width: 70, child: Center(child: Text('GST', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700)))),
                          SizedBox(width: 80, child: Center(child: Text('STOCK', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700)))),
                          SizedBox(width: 80, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700)))),
                        ],
                      ),
                    ),

                    // Table Rows
                    Expanded(
                      child: products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.zinc400),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No products found',
                                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.pitchBlack),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Try adjusting search or add a new product above',
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: products.length,
                              separatorBuilder: (_, index) => const Divider(color: AppColors.border, height: 1),
                              itemBuilder: (context, index) {
                                final p = products[index];
                                final isLowStock = p.stock <= p.reorderLevel;

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  color: index.isEven ? AppColors.lightGray : AppColors.canvas.withValues(alpha: 0.5),
                                  child: Row(
                                    children: [
                                      // SKU
                                      SizedBox(
                                        width: 110,
                                        child: Text(
                                          p.barcode,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                            color: AppColors.pitchBlack,
                                          ),
                                        ),
                                      ),
                                      // Product Name
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: AppColors.pitchBlack,
                                          ),
                                        ),
                                      ),
                                      // Category
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          p.category,
                                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc700),
                                        ),
                                      ),
                                      // Subcategory
                                      SizedBox(
                                        width: 130,
                                        child: Text(
                                          p.subcategory.isEmpty ? '—' : p.subcategory,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc600),
                                        ),
                                      ),
                                      // UOM
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          p.uom,
                                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc700),
                                        ),
                                      ),
                                      // Cost Price
                                      SizedBox(
                                        width: 90,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            _currencyFormatter.format(p.costPrice),
                                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc600),
                                          ),
                                        ),
                                      ),
                                      // Selling Price (MRP)
                                      SizedBox(
                                        width: 100,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            _currencyFormatter.format(p.price),
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: AppColors.pitchBlack,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // GST
                                      SizedBox(
                                        width: 70,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.canvas,
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: Text(
                                              '${p.gstPercent.toStringAsFixed(0)}%',
                                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Stock
                                      SizedBox(
                                        width: 80,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isLowStock ? Colors.red.withValues(alpha: 0.12) : AppColors.canvas,
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(
                                                color: isLowStock ? Colors.red.shade400 : AppColors.border,
                                              ),
                                            ),
                                            child: Text(
                                              '${p.stock}',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isLowStock ? Colors.red.shade800 : AppColors.pitchBlack,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Actions
                                      SizedBox(
                                        width: 80,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.zinc700),
                                              tooltip: 'Edit Product',
                                              onPressed: () => _openProductForm(p),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                              tooltip: 'Delete Product',
                                              onPressed: () => _confirmDelete(p),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  Widget _buildStatPill(String title, String count, IconData icon, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAlert ? Colors.red.withValues(alpha: 0.08) : AppColors.lightGray,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isAlert ? Colors.red.shade400 : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isAlert ? Colors.red.shade700 : AppColors.zinc600),
          const SizedBox(width: 6),
          Text(
            '$title: ',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: isAlert ? Colors.red.shade800 : AppColors.zinc600),
          ),
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isAlert ? Colors.red.shade900 : AppColors.pitchBlack,
            ),
          ),
        ],
      ),
    );
  }
}

/// Comprehensive Product Form Dialog (Width 680px)
/// Strict 35px height for all inputs, dropdowns, and buttons
class _ProductFormDialog extends StatefulWidget {
  final Product? product;
  final InventoryRepository repo;

  const _ProductFormDialog({this.product, required this.repo});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _reorderController;
  late TextEditingController _hsnController;

  late String _selectedCategory;
  String? _selectedSubcategory;
  late String _selectedUom;
  late double _selectedGst;
  late bool _isActive;
  bool _isSaving = false;

  final List<String> _uomOptions = ['Pcs', 'Kg', 'Litre', 'Pack', 'Jar', 'Loaf', 'Bottle', 'Box', 'Grams', 'Pouch'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    final isEdit = p != null;

    _nameController = TextEditingController(text: isEdit ? p.name : '');
    _barcodeController = TextEditingController(
      text: isEdit ? p.barcode : '890${(1000000 + Random().nextInt(8999999))}',
    );
    _costPriceController = TextEditingController(text: isEdit ? p.costPrice.toStringAsFixed(2) : '100.00');
    _sellingPriceController = TextEditingController(text: isEdit ? p.price.toStringAsFixed(2) : '150.00');
    _stockController = TextEditingController(text: isEdit ? p.stock.toString() : '50');
    _reorderController = TextEditingController(text: isEdit ? p.reorderLevel.toString() : '10');
    _hsnController = TextEditingController(text: isEdit ? p.hsnCode : '');

    _selectedCategory = isEdit ? p.category : widget.repo.categories.first.name;

    final subcats = widget.repo.getSubcategoriesForCategory(_selectedCategory);
    if (isEdit && p.subcategory.isNotEmpty && subcats.any((s) => s.name == p.subcategory)) {
      _selectedSubcategory = p.subcategory;
    } else {
      _selectedSubcategory = subcats.isNotEmpty ? subcats.first.name : null;
    }

    _selectedUom = isEdit ? p.uom : 'Pcs';
    _selectedGst = isEdit ? p.gstPercent : 5.0;
    _isActive = isEdit ? p.isActive : true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _reorderController.dispose();
    _hsnController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? newCategory) {
    if (newCategory == null) return;
    setState(() {
      _selectedCategory = newCategory;
      final subcats = widget.repo.getSubcategoriesForCategory(newCategory);
      _selectedSubcategory = subcats.isNotEmpty ? subcats.first.name : null;

      final cat = widget.repo.categories.firstWhere((c) => c.name == newCategory);
      _selectedGst = cat.gstPercent;
      if (cat.hsnCode.isNotEmpty && _hsnController.text.isEmpty) {
        _hsnController.text = cat.hsnCode;
      }
    });
  }

  void _generateBarcode() {
    setState(() {
      _barcodeController.text = '890${(1000000 + Random().nextInt(8999999))}';
    });
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final barcode = _barcodeController.text.trim();
    final cost = double.tryParse(_costPriceController.text.trim()) ?? 0.0;
    final price = double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final reorder = int.tryParse(_reorderController.text.trim()) ?? 10;

    if (name.isEmpty) {
      AntdMessage.error(context, 'Please enter Product Name');
      return;
    }

    if (barcode.isEmpty) {
      AntdMessage.error(context, 'Please enter or generate Barcode/SKU');
      return;
    }

    if (price <= 0) {
      AntdMessage.error(context, 'Selling Price must be greater than zero');
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 200));

    if (widget.product == null) {
      final newProd = Product(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        category: _selectedCategory,
        subcategory: _selectedSubcategory ?? '',
        barcode: barcode,
        price: price,
        costPrice: cost,
        gstPercent: _selectedGst,
        stock: stock,
        uom: _selectedUom,
        hsnCode: _hsnController.text.trim(),
        reorderLevel: reorder,
        isActive: _isActive,
      );
      widget.repo.addProduct(newProd);
      if (mounted) {
        Navigator.pop(context);
        AntdMessage.success(context, 'Product "$name" added to inventory');
      }
    } else {
      final updated = widget.product!.copyWith(
        name: name,
        category: _selectedCategory,
        subcategory: _selectedSubcategory ?? '',
        barcode: barcode,
        price: price,
        costPrice: cost,
        gstPercent: _selectedGst,
        stock: stock,
        uom: _selectedUom,
        hsnCode: _hsnController.text.trim(),
        reorderLevel: reorder,
        isActive: _isActive,
      );
      widget.repo.updateProduct(updated);
      if (mounted) {
        Navigator.pop(context);
        AntdMessage.success(context, 'Product "$name" updated successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final currentSubcats = widget.repo.getSubcategoriesForCategory(_selectedCategory);

    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0.0;
    final marginPercent = cost > 0 ? (((selling - cost) / cost) * 100) : 0.0;

    return Dialog(
      backgroundColor: AppColors.lightGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.pitchBlack),
                      const SizedBox(width: 8),
                      Text(
                        isEdit ? 'Edit Product Master' : 'New Product Master',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pitchBlack,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.zinc600),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 20),

              // Scrollable Form Sections
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SECTION 1: Item Identification
                        _buildSectionHeader('Item Identification & Taxonomy'),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            // Product Name (35px)
                            Expanded(
                              flex: 3,
                              child: ErpFormWidgets.textField(
                                controller: _nameController,
                                label: 'Product Name',
                                hintText: 'e.g. Artisan Filter Coffee (250g)',
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Barcode / SKU (35px) with Generate Button
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Text(
                                        'Barcode / SKU',
                                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
                                      ),
                                      Text(' *', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    height: 35,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _barcodeController,
                                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.pitchBlack),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: '8901234...',
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              filled: true,
                                              fillColor: AppColors.canvas,
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
                                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.border)),
                                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.pitchBlack, width: 1.5)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // Quick Generate Button (35px)
                                        SizedBox(
                                          height: 35,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor: AppColors.canvas,
                                              foregroundColor: AppColors.pitchBlack,
                                              side: const BorderSide(color: AppColors.border),
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            ),
                                            onPressed: _generateBarcode,
                                            child: const Icon(Icons.qr_code, size: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            // Category (35px)
                            Expanded(
                              child: ErpFormWidgets.dropdownField<String>(
                                label: 'Category',
                                value: _selectedCategory,
                                isRequired: true,
                                items: widget.repo.categories
                                    .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                                    .toList(),
                                onChanged: _onCategoryChanged,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Sub-Category (35px)
                            Expanded(
                              child: ErpFormWidgets.dropdownField<String>(
                                label: 'Sub-Category',
                                value: _selectedSubcategory,
                                hintText: currentSubcats.isEmpty ? 'No sub-categories' : 'Select sub-category',
                                items: currentSubcats
                                    .map((s) => DropdownMenuItem(value: s.name, child: Text(s.name)))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedSubcategory = val),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // UOM (35px)
                            SizedBox(
                              width: 110,
                              child: ErpFormWidgets.dropdownField<String>(
                                label: 'UOM (Unit)',
                                value: _selectedUom,
                                items: _uomOptions
                                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedUom = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // SECTION 2: Pricing & Taxation
                        _buildSectionHeader('Pricing, Margin & GST Taxation'),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            // Cost Price (35px)
                            Expanded(
                              child: ErpFormWidgets.textField(
                                controller: _costPriceController,
                                label: 'Cost Price (₹)',
                                hintText: '0.00',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Selling Price (35px)
                            Expanded(
                              child: ErpFormWidgets.textField(
                                controller: _sellingPriceController,
                                label: 'Selling Price / MRP (₹)',
                                hintText: '0.00',
                                isRequired: true,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // GST Slab (35px)
                            Expanded(
                              child: ErpFormWidgets.dropdownField<double>(
                                label: 'GST Slab',
                                value: _selectedGst,
                                items: const [
                                  DropdownMenuItem(value: 0.0, child: Text('0% (Exempt)')),
                                  DropdownMenuItem(value: 5.0, child: Text('5% GST')),
                                  DropdownMenuItem(value: 12.0, child: Text('12% GST')),
                                  DropdownMenuItem(value: 18.0, child: Text('18% GST')),
                                  DropdownMenuItem(value: 28.0, child: Text('28% Luxury')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedGst = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Margin Pill Indicator (35px)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gross Margin',
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    height: 35,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: marginPercent > 0 ? Colors.green.withValues(alpha: 0.1) : AppColors.canvas,
                                      border: Border.all(color: marginPercent > 0 ? Colors.green.shade600 : AppColors.border),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${marginPercent.toStringAsFixed(1)}% markup',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: marginPercent > 0 ? Colors.green.shade800 : AppColors.zinc600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // SECTION 3: Stock Control
                        _buildSectionHeader('Inventory & Stock Levels'),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            // Opening Stock (35px)
                            Expanded(
                              child: ErpFormWidgets.textField(
                                controller: _stockController,
                                label: 'Current / Opening Stock',
                                hintText: '0',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Reorder Level (35px)
                            Expanded(
                              child: ErpFormWidgets.textField(
                                controller: _reorderController,
                                label: 'Low Stock Alert Trigger',
                                hintText: '10',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // HSN Code (35px)
                            Expanded(
                              child: ErpFormWidgets.textField(
                                controller: _hsnController,
                                label: 'HSN / SAC Code',
                                hintText: 'e.g. 0901',
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Status Dropdown (35px)
                            Expanded(
                              child: ErpFormWidgets.dropdownField<bool>(
                                label: 'Status',
                                value: _isActive,
                                items: const [
                                  DropdownMenuItem(value: true, child: Text('Active')),
                                  DropdownMenuItem(value: false, child: Text('Inactive')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _isActive = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),

              // Action Buttons (Strictly 35px height)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ErpFormWidgets.outlinedButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Cancel',
                  ),
                  const SizedBox(width: 10),
                  ErpFormWidgets.primaryButton(
                    onPressed: _saveProduct,
                    text: isEdit ? 'Update Product' : 'Save Product',
                    icon: Icons.check,
                    isLoading: _isSaving,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: AppColors.zinc700,
        ),
      ),
    );
  }
}
