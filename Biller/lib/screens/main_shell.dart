import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'pos_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PosScreen(),
    const _InventoryScreenPlaceholder(),
    const _ReportsScreenPlaceholder(),
    const _SettingsScreenPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 700 && screenWidth < 1024;

    if (isDesktop || isTablet) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: Row(
          children: [
            // Responsive Sidebar (Collapsed on tablet, expanded on desktop)
            _buildSidebar(isCompact: isTablet),

            // Active View
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    } else {
      // Mobile View with Clean Bottom Navigation
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: SafeArea(child: _screens[_selectedIndex]),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
            backgroundColor: AppColors.white,
            indicatorColor: AppColors.lightBrown,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.point_of_sale_outlined, color: AppColors.darkGray),
                selectedIcon: Icon(Icons.point_of_sale_rounded, color: AppColors.darkBrown),
                label: 'POS',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined, color: AppColors.darkGray),
                selectedIcon: Icon(Icons.inventory_2_rounded, color: AppColors.darkBrown),
                label: 'Stock',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined, color: AppColors.darkGray),
                selectedIcon: Icon(Icons.bar_chart_rounded, color: AppColors.darkBrown),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined, color: AppColors.darkGray),
                selectedIcon: Icon(Icons.tune_rounded, color: AppColors.darkBrown),
                label: 'Settings',
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSidebar({required bool isCompact}) {
    return Container(
      width: isCompact ? 72 : 230,
      color: AppColors.white,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: isCompact ? 10 : 16),
      child: Column(
        crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Logo & App Name
          if (isCompact) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.darkBrown,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.receipt_long_rounded, color: AppColors.white, size: 22),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.darkBrown,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.receipt_long_rounded, color: AppColors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BILLER',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      'Retail POS & Invoicing',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 36),

          // Nav Items
          _buildSidebarNavItem(0, 'POS Counter', Icons.point_of_sale_outlined, Icons.point_of_sale_rounded, isCompact),
          _buildSidebarNavItem(1, 'Inventory', Icons.inventory_2_outlined, Icons.inventory_2_rounded, isCompact),
          _buildSidebarNavItem(2, 'Sales & GST', Icons.bar_chart_outlined, Icons.bar_chart_rounded, isCompact),
          _buildSidebarNavItem(3, 'Settings', Icons.tune_outlined, Icons.tune_rounded, isCompact),

          const Spacer(),

          // Bottom Store Status Tag
          if (!isCompact)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.brown,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Counter #01',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'Thermal Printer Ready',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            color: AppColors.textMuted,
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
    );
  }

  Widget _buildSidebarNavItem(int index, String title, IconData icon, IconData activeIcon, bool isCompact) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: isCompact ? title : '',
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.darkBrown : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.white : AppColors.darkGray,
                  size: 20,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.white : AppColors.darkGray,
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
}

// INVENTORY PLACEHOLDER SCREEN
class _InventoryScreenPlaceholder extends StatelessWidget {
  const _InventoryScreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Inventory Catalog')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.gray.withAlpha(120)),
            const SizedBox(height: 16),
            const Text(
              'Stock & Inventory Catalog',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage item barcodes, cost prices, GST slabs, and low-stock alerts',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// REPORTS PLACEHOLDER SCREEN
class _ReportsScreenPlaceholder extends StatelessWidget {
  const _ReportsScreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Sales & Tax Analytics')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 64, color: AppColors.gray.withAlpha(120)),
            const SizedBox(height: 16),
            const Text(
              'Daily Revenue & GST Filing',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Live today\'s totals, UPI/Cash splits, and download GSTR-1 summaries',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// SETTINGS PLACEHOLDER SCREEN
class _SettingsScreenPlaceholder extends StatelessWidget {
  const _SettingsScreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Store & Hardware Setup')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.print_outlined, size: 64, color: AppColors.gray.withAlpha(120)),
            const SizedBox(height: 16),
            const Text(
              'Thermal Printer & POS Settings',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Configure ESC/POS 58mm/80mm USB & Bluetooth printers, store GSTIN, and headers',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
