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
      const ProductCategory(id: 'cat_1', name: 'Beverages', hsnCode: '0901', gstPercent: 5.0, description: 'Coffee, tea, and packaged beverages'),
      const ProductCategory(id: 'cat_2', name: 'Bakery', hsnCode: '1905', gstPercent: 0.0, description: 'Fresh breads, buns, and confectionery'),
      const ProductCategory(id: 'cat_3', name: 'Dairy', hsnCode: '0405', gstPercent: 12.0, description: 'Milk, ghee, cheese, and dairy items'),
      const ProductCategory(id: 'cat_4', name: 'Snacks', hsnCode: '1904', gstPercent: 5.0, description: 'Dry fruits, chips, cookies, and nuts'),
      const ProductCategory(id: 'cat_5', name: 'Spices', hsnCode: '0910', gstPercent: 5.0, description: 'Whole spices, powdered masalas, seasonings'),
      const ProductCategory(id: 'cat_6', name: 'Essentials', hsnCode: '3401', gstPercent: 18.0, description: 'Household staples, oils, and hygiene'),
    ]);

    // Default Subcategories
    _subcategories.addAll([
      const Subcategory(id: 'sub_1', categoryId: 'cat_1', categoryName: 'Beverages', name: 'Coffee & Tea', description: 'Filter coffee and roasted tea blends'),
      const Subcategory(id: 'sub_2', categoryId: 'cat_1', categoryName: 'Beverages', name: 'Cold Beverages', description: 'Packaged juices and bottled drinks'),
      const Subcategory(id: 'sub_3', categoryId: 'cat_2', categoryName: 'Bakery', name: 'Artisan Breads', description: 'Sourdough, whole wheat and multigrain'),
      const Subcategory(id: 'sub_4', categoryId: 'cat_2', categoryName: 'Bakery', name: 'Pastries & Croissants', description: 'French croissants and sweet rolls'),
      const Subcategory(id: 'sub_5', categoryId: 'cat_3', categoryName: 'Dairy', name: 'Ghee & Butter', description: 'Desi cow ghee, farm table butter'),
      const Subcategory(id: 'sub_6', categoryId: 'cat_3', categoryName: 'Dairy', name: 'Paneer & Cheese', description: 'Fresh malai paneer and sliced cheese'),
      const Subcategory(id: 'sub_7', categoryId: 'cat_4', categoryName: 'Snacks', name: 'Dry Fruits & Nuts', description: 'Almonds, cashews, raisins, walnuts'),
      const Subcategory(id: 'sub_8', categoryId: 'cat_4', categoryName: 'Snacks', name: 'Cookies & Rusks', description: 'Chocolate cookies and butter rusks'),
      const Subcategory(id: 'sub_9', categoryId: 'cat_5', categoryName: 'Spices', name: 'Whole Spices', description: 'Cardamom, cinnamon, black pepper'),
      const Subcategory(id: 'sub_10', categoryId: 'cat_6', categoryName: 'Essentials', name: 'Cold-Pressed Oils', description: 'Gingelly oil, groundnut and coconut oil'),
    ]);

    // Default Products with Curated Realistic Images
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
        imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&q=80',
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
        imageUrl: 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=400&q=80',
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
