import 'package:flutter/material.dart';
import '../../models/subcategory.dart';
import '../../services/inventory_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/form_helpers.dart';
import '../../widgets/antd_message.dart';

class SubcategoryMasterScreen extends StatefulWidget {
  const SubcategoryMasterScreen({super.key});

  @override
  State<SubcategoryMasterScreen> createState() => _SubcategoryMasterScreenState();
}

class _SubcategoryMasterScreenState extends State<SubcategoryMasterScreen> {
  final InventoryRepository _repo = InventoryRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _categoryFilter = 'All';
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

  List<Subcategory> get _filteredSubcategories {
    return _repo.subcategories.where((sub) {
      final matchesSearch = sub.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sub.categoryName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == 'All' || sub.categoryName.toLowerCase() == _categoryFilter.toLowerCase();
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && sub.isActive) ||
          (_statusFilter == 'Inactive' && !sub.isActive);
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  void _openSubcategoryForm([Subcategory? subcategoryToEdit]) {
    if (_repo.categories.isEmpty) {
      AntdMessage.warning(context, 'Please create at least one Category in Category Master first');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SubcategoryFormDialog(
        subcategory: subcategoryToEdit,
        repo: _repo,
      ),
    );
  }

  void _confirmDelete(Subcategory subcategory) {
    final productCount = _repo.getProductCountForSubcategory(subcategory.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Delete Sub-Category',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.pitchBlack),
        ),
        content: Text(
          productCount > 0
              ? 'Warning: "${subcategory.name}" has $productCount products linked to it. Are you sure you want to delete it?'
              : 'Are you sure you want to delete sub-category "${subcategory.name}"?',
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
                _repo.deleteSubcategory(subcategory.id);
                Navigator.pop(ctx);
                AntdMessage.success(context, 'Sub-Category "${subcategory.name}" deleted successfully');
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
    final subcategories = _filteredSubcategories;
    final totalCount = _repo.subcategories.length;
    final activeCount = _repo.subcategories.where((s) => s.isActive).length;

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
                      'Sub-Category Master',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pitchBlack,
                      ),
                    ),
                    Text(
                      'Granular product sub-divisions mapped to parent categories',
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
                _buildStatPill('Total', '$totalCount', Icons.account_tree_outlined),
                const SizedBox(width: 8),
                _buildStatPill('Active', '$activeCount', Icons.check_circle_outline),
                const SizedBox(width: 16),
                // Add Sub-Category Button (35px)
                ErpFormWidgets.primaryButton(
                  onPressed: () => _openSubcategoryForm(),
                  text: 'Add Sub-Category',
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
                      hintText: 'Search by sub-category name or parent category...',
                      prefixIcon: Icons.search,
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Category Filter Dropdown (35px height)
                  SizedBox(
                    width: 170,
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

                  // Status Filter Dropdown (35px height)
                  SizedBox(
                    width: 140,
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

                  // Reset Button (35px height)
                  ErpFormWidgets.secondaryButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _categoryFilter = 'All';
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
                          Expanded(flex: 3, child: Text('SUB-CATEGORY NAME', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          Expanded(flex: 2, child: Text('PARENT CATEGORY', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 120, child: Text('PRODUCTS', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 100, child: Text('STATUS', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700))),
                          SizedBox(width: 90, child: Align(alignment: Alignment.centerRight, child: Text('ACTIONS', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc700)))),
                        ],
                      ),
                    ),

                    // Table Rows
                    Expanded(
                      child: subcategories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.account_tree_outlined, size: 36, color: AppColors.zinc400),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No sub-categories found',
                                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.pitchBlack),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Try adjusting search or add a new sub-category above',
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: subcategories.length,
                              separatorBuilder: (_, index) => const Divider(color: AppColors.border, height: 1),
                              itemBuilder: (context, index) {
                                final sub = subcategories[index];
                                final prodCount = _repo.getProductCountForSubcategory(sub.name);

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
                                              sub.name,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: AppColors.pitchBlack,
                                              ),
                                            ),
                                            if (sub.description.isNotEmpty)
                                              Text(
                                                sub.description,
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
                                      // Parent Category Badge
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.canvas,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.folder_outlined, size: 12, color: AppColors.zinc600),
                                                const SizedBox(width: 5),
                                                Text(
                                                  sub.categoryName,
                                                  style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.pitchBlack,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                        child: ErpFormWidgets.statusBadge(sub.isActive),
                                      ),
                                      // Actions
                                      SizedBox(
                                        width: 90,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.zinc700),
                                              tooltip: 'Edit Sub-Category',
                                              onPressed: () => _openSubcategoryForm(sub),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                              tooltip: 'Delete Sub-Category',
                                              onPressed: () => _confirmDelete(sub),
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

/// Streamlined Subcategory Form Dialog without code requirement
class _SubcategoryFormDialog extends StatefulWidget {
  final Subcategory? subcategory;
  final InventoryRepository repo;

  const _SubcategoryFormDialog({this.subcategory, required this.repo});

  @override
  State<_SubcategoryFormDialog> createState() => _SubcategoryFormDialogState();
}

class _SubcategoryFormDialogState extends State<_SubcategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late String _selectedCategoryId;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final isEdit = widget.subcategory != null;
    _nameController = TextEditingController(text: isEdit ? widget.subcategory!.name : '');
    _descController = TextEditingController(text: isEdit ? widget.subcategory!.description : '');

    if (isEdit) {
      _selectedCategoryId = widget.subcategory!.categoryId;
    } else {
      _selectedCategoryId = widget.repo.categories.first.id;
    }

    _isActive = isEdit ? widget.subcategory!.isActive : true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveSubcategory() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      AntdMessage.error(context, 'Please enter Sub-Category Name');
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 200));

    final parentCat = widget.repo.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => widget.repo.categories.first,
    );

    if (widget.subcategory == null) {
      final newSub = Subcategory(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: parentCat.id,
        categoryName: parentCat.name,
        name: name,
        description: _descController.text.trim(),
        isActive: _isActive,
      );
      widget.repo.addSubcategory(newSub);
      if (mounted) {
        Navigator.pop(context);
        AntdMessage.success(context, 'Sub-Category "$name" created successfully');
      }
    } else {
      final updated = widget.subcategory!.copyWith(
        categoryId: parentCat.id,
        categoryName: parentCat.name,
        name: name,
        description: _descController.text.trim(),
        isActive: _isActive,
      );
      widget.repo.updateSubcategory(updated);
      if (mounted) {
        Navigator.pop(context);
        AntdMessage.success(context, 'Sub-Category "$name" updated successfully');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subcategory != null;

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
                    isEdit ? 'Edit Sub-Category' : 'New Sub-Category',
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

              // Form fields (Strictly 35px height)
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Parent Category Dropdown (35px)
                    ErpFormWidgets.dropdownField<String>(
                      label: 'Parent Category',
                      value: _selectedCategoryId,
                      isRequired: true,
                      items: widget.repo.categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategoryId = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Sub-Category Name (35px)
                    ErpFormWidgets.textField(
                      controller: _nameController,
                      label: 'Sub-Category Name',
                      hintText: 'e.g. Coffee & Tea, Pastries, Whole Spices',
                      isRequired: true,
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
                      hintText: 'Optional details about this sub-classification',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 16),

              // Action Buttons (Strictly 35px)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ErpFormWidgets.outlinedButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Cancel',
                  ),
                  const SizedBox(width: 10),
                  ErpFormWidgets.primaryButton(
                    onPressed: _saveSubcategory,
                    text: isEdit ? 'Update Sub-Category' : 'Save Sub-Category',
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
