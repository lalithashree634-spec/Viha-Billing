import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'pos_screen.dart';
import 'masters/category_master_screen.dart';
import 'masters/subcategory_master_screen.dart';
import 'masters/product_master_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _isProductExpanded = true;

  final List<Widget> _screens = [
    const PosScreen(),
    const CategoryMasterScreen(),
    const SubcategoryMasterScreen(),
    const ProductMasterScreen(),
    const _ReportsScreen(),
    const _SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 720 && screenWidth < 1024;

    if (isDesktop || isTablet) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: Row(
          children: [
            _buildSidebarDock(isCompact: isTablet),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.lightGray,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex > 4 ? 4 : _selectedIndex,
            onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
            backgroundColor: AppColors.lightGray,
            indicatorColor: AppColors.canvas,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.point_of_sale_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.point_of_sale, color: AppColors.pitchBlack),
                label: 'POS',
              ),
              NavigationDestination(
                icon: Icon(Icons.category_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.category, color: AppColors.pitchBlack),
                label: 'Category',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_tree_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.account_tree, color: AppColors.pitchBlack),
                label: 'Sub-Cat',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.inventory_2, color: AppColors.pitchBlack),
                label: 'Products',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.tune, color: AppColors.pitchBlack),
                label: 'Settings',
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSidebarDock({required bool isCompact}) {
    final isProductSubSelected = _selectedIndex >= 1 && _selectedIndex <= 3;

    return Container(
      width: isCompact ? 64 : 220,
      decoration: const BoxDecoration(
        color: AppColors.lightGray,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: isCompact ? 8 : 10),
      child: Column(
        crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Brand Logo
          if (isCompact) ...[
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIHA POS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.pitchBlack,
                        ),
                      ),
                      Text(
                        'Enterprise Billing',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: AppColors.zinc500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // 1. POS Register
          _buildNavItem(0, 'POS Register', Icons.point_of_sale_outlined, Icons.point_of_sale, isCompact),
          const SizedBox(height: 4),

          // 2. Product Parent Section (Expandable with 3 Masters)
          if (isCompact) ...[
            _buildNavItem(1, 'Category Master', Icons.category_outlined, Icons.category, true),
            _buildNavItem(2, 'Sub-Category Master', Icons.account_tree_outlined, Icons.account_tree, true),
            _buildNavItem(3, 'Products', Icons.inventory_2_outlined, Icons.inventory_2, true),
          ] else ...[
            // Expandable Header for Product
            InkWell(
              onTap: () {
                setState(() => _isProductExpanded = !_isProductExpanded);
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isProductSubSelected && !_isProductExpanded ? AppColors.canvas : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 17,
                      color: isProductSubSelected ? AppColors.pitchBlack : AppColors.zinc600,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Product',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: isProductSubSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isProductSubSelected ? AppColors.pitchBlack : AppColors.zinc700,
                        ),
                      ),
                    ),
                    Icon(
                      _isProductExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.zinc600,
                    ),
                  ],
                ),
              ),
            ),

            // Indented 3 Options
            if (_isProductExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 2, bottom: 2),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: AppColors.border, width: 1.5)),
                  ),
                  padding: const EdgeInsets.only(left: 6),
                  child: Column(
                    children: [
                      _buildSubNavItem(1, 'Category Master', Icons.category_outlined),
                      _buildSubNavItem(2, 'Sub-Cat Master', Icons.account_tree_outlined),
                      _buildSubNavItem(3, 'Products', Icons.shopping_bag_outlined),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 4),

          // 3. Sales Reports
          _buildNavItem(4, 'Sales Reports', Icons.bar_chart_outlined, Icons.bar_chart, isCompact),

          // 4. Settings
          _buildNavItem(5, 'Settings', Icons.tune_outlined, Icons.tune, isCompact),

          const Spacer(),

          // Status Footer
          if (!isCompact)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: AppColors.pitchBlack),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shift Active',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pitchBlack,
                        ),
                      ),
                      Text(
                        'Counter 01 • Main',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.zinc600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon, IconData activeIcon, bool isCompact) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Tooltip(
        message: isCompact ? title : '',
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.pitchBlack : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.textOnDark : AppColors.zinc600,
                  size: 17,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.textOnDark : AppColors.zinc700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubNavItem(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.pitchBlack : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.zinc600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.zinc700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// REPORTS TAB
class _ReportsScreen extends StatelessWidget {
  const _ReportsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Sales & Tax Analytics')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart_outlined, size: 32, color: AppColors.pitchBlack),
              SizedBox(height: 12),
              Text(
                'Sales & GST Analytics',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Daily revenue summary, UPI/Cash split, and GSTR-1 Excel export',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SETTINGS TAB
class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Store & Hardware Configuration')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_outlined, size: 32, color: AppColors.pitchBlack),
              SizedBox(height: 12),
              Text(
                'Hardware & Printer Settings',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'ESC/POS Thermal Printer (58mm/80mm USB & Bluetooth) & Store Header',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
