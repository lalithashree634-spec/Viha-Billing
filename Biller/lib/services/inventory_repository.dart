import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/product.dart';

class InventoryRepository extends ChangeNotifier {
  static final InventoryRepository _instance = InventoryRepository._internal();
  factory InventoryRepository() => _instance;

  InventoryRepository._internal() {
    _initDefaultData();
  }

  final List<ProductCategory> _categories = [];
  final List<Subcategory> _subcategories = [];
  final List<Product> _products = [];

  List<ProductCategory> get categories => List.unmodifiable(_categories);
  List<Subcategory> get subcategories => List.unmodifiable(_subcategories);
  List<Product> get products => List.unmodifiable(_products);

  void _initDefaultData() {
    // Default Categories
    _categories.addAll([
      const ProductCategory(id: 'cat_1', code: 'CAT-001', name: 'Beverages', hsnCode: '0901', gstPercent: 5.0, description: 'Coffee, tea, and packaged beverages'),
      const ProductCategory(id: 'cat_2', code: 'CAT-002', name: 'Bakery', hsnCode: '1905', gstPercent: 0.0, description: 'Fresh breads, buns, and confectionery'),
      const ProductCategory(id: 'cat_3', code: 'CAT-003', name: 'Dairy', hsnCode: '0405', gstPercent: 12.0, description: 'Milk, ghee, cheese, and dairy items'),
      const ProductCategory(id: 'cat_4', code: 'CAT-004', name: 'Snacks', hsnCode: '1904', gstPercent: 5.0, description: 'Dry fruits, chips, cookies, and nuts'),
      const ProductCategory(id: 'cat_5', code: 'CAT-005', name: 'Spices', hsnCode: '0910', gstPercent: 5.0, description: 'Whole spices, powdered masalas, seasonings'),
      const ProductCategory(id: 'cat_6', code: 'CAT-006', name: 'Essentials', hsnCode: '3401', gstPercent: 18.0, description: 'Household staples, oils, and hygiene'),
    ]);

    // Default Subcategories
    _subcategories.addAll([
      const Subcategory(id: 'sub_1', categoryId: 'cat_1', categoryName: 'Beverages', code: 'SUB-001', name: 'Coffee & Tea', description: 'Filter coffee and roasted tea blends'),
      const Subcategory(id: 'sub_2', categoryId: 'cat_1', categoryName: 'Beverages', code: 'SUB-002', name: 'Cold Beverages', description: 'Packaged juices and bottled drinks'),
      const Subcategory(id: 'sub_3', categoryId: 'cat_2', categoryName: 'Bakery', code: 'SUB-003', name: 'Artisan Breads', description: 'Sourdough, whole wheat and multigrain'),
      const Subcategory(id: 'sub_4', categoryId: 'cat_2', categoryName: 'Bakery', code: 'SUB-004', name: 'Pastries & Croissants', description: 'French croissants and sweet rolls'),
      const Subcategory(id: 'sub_5', categoryId: 'cat_3', categoryName: 'Dairy', code: 'SUB-005', name: 'Ghee & Butter', description: 'Desi cow ghee, farm table butter'),
      const Subcategory(id: 'sub_6', categoryId: 'cat_3', categoryName: 'Dairy', code: 'SUB-006', name: 'Paneer & Cheese', description: 'Fresh malai paneer and sliced cheese'),
      const Subcategory(id: 'sub_7', categoryId: 'cat_4', categoryName: 'Snacks', code: 'SUB-007', name: 'Dry Fruits & Nuts', description: 'Almonds, cashews, raisins, walnuts'),
      const Subcategory(id: 'sub_8', categoryId: 'cat_4', categoryName: 'Snacks', code: 'SUB-008', name: 'Cookies & Rusks', description: 'Chocolate cookies and butter rusks'),
      const Subcategory(id: 'sub_9', categoryId: 'cat_5', categoryName: 'Spices', code: 'SUB-009', name: 'Whole Spices', description: 'Cardamom, cinnamon, black pepper'),
      const Subcategory(id: 'sub_10', categoryId: 'cat_6', categoryName: 'Essentials', code: 'SUB-010', name: 'Cold-Pressed Oils', description: 'Gingelly oil, groundnut and coconut oil'),
    ]);

    // Default Products
    _products.addAll([
      const Product(
        id: 'p1',
        name: 'Artisan Filter Coffee (250g)',
        category: 'Beverages',
        subcategory: 'Coffee & Tea',
        barcode: '8901234001',
        price: 180.0,
        costPrice: 120.0,
        gstPercent: 5.0,
        stock: 45,
        uom: 'Pack',
        hsnCode: '0901',
        reorderLevel: 10,
      ),
      const Product(
        id: 'p2',
        name: 'Roasted Masala Tea (200g)',
        category: 'Beverages',
        subcategory: 'Coffee & Tea',
        barcode: '8901234002',
        price: 120.0,
        costPrice: 80.0,
        gstPercent: 5.0,
        stock: 28,
        uom: 'Pack',
        hsnCode: '0902',
        reorderLevel: 8,
      ),
      const Product(
        id: 'p3',
        name: 'Whole Wheat Sourdough Loaf',
        category: 'Bakery',
        subcategory: 'Artisan Breads',
        barcode: '8901234003',
        price: 95.0,
        costPrice: 60.0,
        gstPercent: 0.0,
        stock: 6,
        uom: 'Loaf',
        hsnCode: '1905',
        reorderLevel: 5,
      ),
      const Product(
        id: 'p4',
        name: 'Butter Croissant (2 pcs)',
        category: 'Bakery',
        subcategory: 'Pastries & Croissants',
        barcode: '8901234004',
        price: 140.0,
        costPrice: 85.0,
        gstPercent: 5.0,
        stock: 4,
        uom: 'Pcs',
        hsnCode: '1905',
        reorderLevel: 5,
      ),
      const Product(
        id: 'p5',
        name: 'Pure Desi Cow Ghee (500ml)',
        category: 'Dairy',
        subcategory: 'Ghee & Butter',
        barcode: '8901234005',
        price: 490.0,
        costPrice: 380.0,
        gstPercent: 12.0,
        stock: 22,
        uom: 'Jar',
        hsnCode: '0405',
        reorderLevel: 10,
      ),
      const Product(
        id: 'p6',
        name: 'California Almonds (250g)',
        category: 'Snacks',
        subcategory: 'Dry Fruits & Nuts',
        barcode: '8901234006',
        price: 320.0,
        costPrice: 240.0,
        gstPercent: 5.0,
        stock: 50,
        uom: 'Pack',
        hsnCode: '1904',
        reorderLevel: 15,
      ),
      const Product(
        id: 'p7',
        name: 'Dark Chocolate Cookie Pack',
        category: 'Snacks',
        subcategory: 'Cookies & Rusks',
        barcode: '8901234007',
        price: 160.0,
        costPrice: 100.0,
        gstPercent: 5.0,
        stock: 35,
        uom: 'Pack',
        hsnCode: '1905',
        reorderLevel: 10,
      ),
      const Product(
        id: 'p8',
        name: 'Organic Malabar Black Pepper (100g)',
        category: 'Spices',
        subcategory: 'Whole Spices',
        barcode: '8901234008',
        price: 135.0,
        costPrice: 90.0,
        gstPercent: 5.0,
        stock: 60,
        uom: 'Pouch',
        hsnCode: '0904',
        reorderLevel: 12,
      ),
      const Product(
        id: 'p9',
        name: 'Wood Pressed Groundnut Oil (1L)',
        category: 'Essentials',
        subcategory: 'Cold-Pressed Oils',
        barcode: '8901234009',
        price: 260.0,
        costPrice: 200.0,
        gstPercent: 5.0,
        stock: 18,
        uom: 'Bottle',
        hsnCode: '1508',
        reorderLevel: 8,
      ),
      const Product(
        id: 'p10',
        name: 'Green Cardamom Premium (50g)',
        category: 'Spices',
        subcategory: 'Whole Spices',
        barcode: '8901234010',
        price: 210.0,
        costPrice: 150.0,
        gstPercent: 5.0,
        stock: 40,
        uom: 'Pouch',
        hsnCode: '0908',
        reorderLevel: 10,
      ),
    ]);
  }

  // Category Operations
  void addCategory(ProductCategory category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(ProductCategory category) {
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _categories[idx] = category;
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // Subcategory Operations
  void addSubcategory(Subcategory subcategory) {
    _subcategories.add(subcategory);
    notifyListeners();
  }

  void updateSubcategory(Subcategory subcategory) {
    final idx = _subcategories.indexWhere((s) => s.id == subcategory.id);
    if (idx != -1) {
      _subcategories[idx] = subcategory;
      notifyListeners();
    }
  }

  void deleteSubcategory(String id) {
    _subcategories.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  List<Subcategory> getSubcategoriesForCategory(String categoryName) {
    return _subcategories.where((s) => s.categoryName.toLowerCase() == categoryName.toLowerCase()).toList();
  }

  // Product Operations
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _products[idx] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  int getProductCountForCategory(String categoryName) {
    return _products.where((p) => p.category.toLowerCase() == categoryName.toLowerCase()).length;
  }

  int getProductCountForSubcategory(String subcategoryName) {
    return _products.where((p) => p.subcategory.toLowerCase() == subcategoryName.toLowerCase()).length;
  }
}
