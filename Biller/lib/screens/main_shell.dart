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
    const _InventoryScreen(),
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
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.canvas,
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
            indicatorColor: AppColors.zinc100,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.point_of_sale_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.point_of_sale, color: AppColors.pitchBlack),
                label: 'POS',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.inventory_2, color: AppColors.pitchBlack),
                label: 'Stock',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.bar_chart, color: AppColors.pitchBlack),
                label: 'Reports',
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
    return Container(
      width: isCompact ? 64 : 210,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: isCompact ? 8 : 12),
      child: Column(
        crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Brand Logo
          if (isCompact) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.pitchBlack,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(Icons.receipt_outlined, color: AppColors.white, size: 20),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.pitchBlack,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Icon(Icons.receipt_outlined, color: AppColors.white, size: 18),
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
                        color: AppColors.zinc400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Nav Items
          _buildNavItem(0, 'POS Register', Icons.point_of_sale_outlined, Icons.point_of_sale, isCompact),
          _buildNavItem(1, 'Item Catalog', Icons.inventory_2_outlined, Icons.inventory_2, isCompact),
          _buildNavItem(2, 'Sales Reports', Icons.bar_chart_outlined, Icons.bar_chart, isCompact),
          _buildNavItem(3, 'Settings', Icons.tune_outlined, Icons.tune, isCompact),

          const Spacer(),

          // Status Footer
          if (!isCompact)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.zinc50,
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
                        'Counter 01',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.zinc500,
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Tooltip(
        message: isCompact ? title : '',
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.pitchBlack : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.white : AppColors.zinc600,
                  size: 18,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.white : AppColors.zinc700,
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

// INVENTORY TAB
class _InventoryScreen extends StatelessWidget {
  const _InventoryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Inventory & Stock Management')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, size: 32, color: AppColors.pitchBlack),
              SizedBox(height: 12),
              Text(
                'Inventory Catalog',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Manage barcodes, purchase cost, selling rates & GST tax slabs',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
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
            color: AppColors.white,
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
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
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
            color: AppColors.white,
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
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.zinc500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
