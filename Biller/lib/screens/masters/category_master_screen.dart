import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/inventory_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/form_helpers.dart';
import '../../widgets/antd_message.dart';

class CategoryMasterScreen extends StatefulWidget {
  const CategoryMasterScreen({super.key});

  @override
  State<CategoryMasterScreen> createState() => _CategoryMasterScreenState();
}

class _CategoryMasterScreenState extends State<CategoryMasterScreen> {
  final InventoryRepository _repo = InventoryRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

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

  List<ProductCategory> get _filteredCategories {
    return _repo.categories.where((cat) {
      final matchesSearch = cat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cat.hsnCode.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && cat.isActive) ||
          (_statusFilter == 'Inactive' && !cat.isActive);
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _openCategoryForm([ProductCategory? categoryToEdit]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CategoryFormDialog(
        category: categoryToEdit,
        repo: _repo,
      ),
    );
  }

  void _confirmDelete(ProductCategory category) {
    final productCount = _repo.getProductCountForCategory(category.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Delete Category',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
        ),
        content: Text(
          productCount > 0
              ? 'Warning: "${category.name}" has $productCount products linked to it. Are you sure you want to delete it?'
              : 'Are you sure you want to delete category "${category.name}"?',
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
                _repo.deleteCategory(category.id);
                Navigator.pop(ctx);
                AntdMessage.success(context, 'Category "${category.name}" deleted successfully');
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
    final categories = _filteredCategories;
    final totalCount = _repo.categories.length;
    final activeCount = _repo.categories.where((c) => c.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Title & Stats
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category Master',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pitchBlack,
                      ),
                    ),
                    Text(
                      'Classification of goods, HSN prefix & default GST rates',
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
                _buildStatPill('Total', '$totalCount', Icons.category_outlined),
                const SizedBox(width: 8),
                _buildStatPill('Active', '$activeCount', Icons.check_circle_outline),
                const SizedBox(width: 16),
                // Add New Category Button (35px)
                ErpFormWidgets.primaryButton(
                  onPressed: () => _openCategoryForm(),
                  text: 'Add Category',
                  icon: Icons.add,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Filter Bar (All inputs strictly 35px)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Search Input (35px height)
                  Expanded(
                    flex: 3,
                    child: ErpFormWidgets.textField(
                      controller: _searchController,
                      hintText: 'Search by category name or HSN...',
                      prefixIcon: Icons.search,
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Status Filter Dropdown (35px height)
                  SizedBox(
                    width: 150,
                    child: ErpFormWidgets.dropdownField<String>(
                      value: _statusFilter,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('Status: All')),
                        DropdownMenuItem(value: 'Active', child: Text('Status: Active')),
                        DropdownMenuItem(value: 'Inactive', child: Text('Status: Inactive')),
                      ],
                      onChanged: (val) => setState(() => _statusFilter = val ?? 'All'),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Reset Filter Button (35px height)
                  ErpFormWidgets.secondaryButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _statusFilter = 'All';
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
                          Expanded(flex: 3, child: Text('CATEGORY NAME', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 110, child: Text('HSN CODE', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 120, child: Text('DEFAULT GST', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 130, child: Text('SUB-CATEGORIES', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 120, child: Text('PRODUCTS', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 100, child: Text('STATUS', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 90, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700)))),
                        ],
                      ),
                    ),

                    // Table Rows
                    Expanded(
                      child: categories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.category_outlined, size: 36, color: AppColors.zinc400),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No categories found',
                                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.pitchBlack),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Try adjusting search or add a new category above',
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: categories.length,
                              separatorBuilder: (_, index) => const Divider(color: AppColors.border, height: 1),
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final subCount = _repo.getSubcategoriesForCategory(cat.name).length;
                                final prodCount = _repo.getProductCountForCategory(cat.name);

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  color: index.isEven ? AppColors.lightGray : AppColors.canvas.withValues(alpha: 0.5),
                                  child: Row(
                                    children: [
                                      // Name & Description
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cat.name,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: AppColors.pitchBlack,
                                              ),
                                            ),
                                            if (cat.description.isNotEmpty)
                                              Text(
                                                cat.description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 10,
                                                  color: AppColors.zinc500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // HSN
                                      SizedBox(
                                        width: 110,
                                        child: Text(
                                          cat.hsnCode.isEmpty ? '—' : cat.hsnCode,
                                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc700),
                                        ),
                                      ),
                                      // GST
                                      SizedBox(
                                        width: 120,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.canvas,
                                            borderRadius: BorderRadius.circular(3),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Text(
                                            '${cat.gstPercent.toStringAsFixed(0)}% GST',
                                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
                                          ),
                                        ),
                                      ),
                                      // Subcategories count
                                      SizedBox(
                                        width: 130,
                                        child: Text(
                                          '$subCount sub-types',
                                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc700),
                                        ),
                                      ),
                                      // Products count
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          '$prodCount items',
                                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc700),
                                        ),
                                      ),
                                      // Status
                                      SizedBox(
                                        width: 100,
                                        child: ErpFormWidgets.statusBadge(cat.isActive),
                                      ),
                                      // Actions (Edit / Delete)
                                      SizedBox(
                                        width: 90,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.zinc700),
                                              tooltip: 'Edit Category',
                                              onPressed: () => _openCategoryForm(cat),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                              tooltip: 'Delete Category',
                                              onPressed: () => _confirmDelete(cat),
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

  Widget _buildStatPill(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.zinc600),
          const SizedBox(width: 6),
          Text(
            '$title: ',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc600),
          ),
          Text(
            count,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
          ),
        ],
      ),
    );
  }
}

/// Streamlined Category Form Dialog without code requirement
class _CategoryFormDialog extends StatefulWidget {
  final ProductCategory? category;
  final InventoryRepository repo;

  const _CategoryFormDialog({this.category, required this.repo});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _hsnController;
  late TextEditingController _descController;
  late double _selectedGst;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final isEdit = widget.category != null;
    _nameController = TextEditingController(text: isEdit ? widget.category!.name : '');
    _hsnController = TextEditingController(text: isEdit ? widget.category!.hsnCode : '');
    _descController = TextEditingController(text: isEdit ? widget.category!.description : '');
    _selectedGst = isEdit ? widget.category!.gstPercent : 5.0;
    _isActive = isEdit ? widget.category!.isActive : true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hsnController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      AntdMessage.error(context, 'Please enter Category Name');
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 200));

    if (widget.category == null) {
      final newCat = ProductCategory(
        id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        hsnCode: _hsnController.text.trim(),
        gstPercent: _selectedGst,
        description: _descController.text.trim(),
        isActive: _isActive,
      );
      widget.repo.addCategory(newCat);
      if (mounted) {
        Navigator.pop(context);
        AntdMessage.success(context, 'Category "$name" created successfully');
      }
    } else {
      final updated = widget.category!.copyWith(
        name: name,
        hsnCode: _hsnController.text.trim(),
        gstPercent: _selectedGst,
        description: _descController.text.trim(),
        isActive: _isActive,
      );
      widget.repo.updateCategory(updated);
      if (mounted) {
        Navigator.pop(context);
        AntdMessage.success(context, 'Category "$name" updated successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Dialog(
      backgroundColor: AppColors.lightGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
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
                  Text(
                    isEdit ? 'Edit Category' : 'New Category',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pitchBlack,
                    ),
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

              // Form fields (Strict 35px height)
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Name (35px)
                    ErpFormWidgets.textField(
                      controller: _nameController,
                      label: 'Category Name',
                      hintText: 'e.g. Beverages, Bakery, Snacks, Dairy',
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // HSN Prefix (35px)
                        Expanded(
                          flex: 2,
                          child: ErpFormWidgets.textField(
                            controller: _hsnController,
                            label: 'HSN Prefix',
                            hintText: 'e.g. 0901, 1905',
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Default GST Slab Dropdown (35px)
                        Expanded(
                          flex: 2,
                          child: ErpFormWidgets.dropdownField<double>(
                            label: 'Default GST Slab',
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
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Status Dropdown (35px)
                    ErpFormWidgets.dropdownField<bool>(
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
                    const SizedBox(height: 12),

                    // Description (35px)
                    ErpFormWidgets.textField(
                      controller: _descController,
                      label: 'Description / Remarks',
                      hintText: 'Optional brief category description',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),

              // Form Action Buttons (Strictly 35px)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ErpFormWidgets.outlinedButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Cancel',
                  ),
                  const SizedBox(width: 10),
                  ErpFormWidgets.primaryButton(
                    onPressed: _saveCategory,
                    text: isEdit ? 'Update Category' : 'Save Category',
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
}
