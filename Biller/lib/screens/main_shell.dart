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
            // Responsive Sidebar Dock
            _buildSidebarDock(isCompact: isTablet),

            // Active Viewport
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    } else {
      // Mobile Viewport with Clean Minimalist Bottom Bar
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
                selectedIcon: Icon(Icons.point_of_sale_rounded, color: AppColors.pitchBlack),
                label: 'POS',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.inventory_2_rounded, color: AppColors.pitchBlack),
                label: 'Catalog',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.bar_chart_rounded, color: AppColors.pitchBlack),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined, color: AppColors.zinc600),
                selectedIcon: Icon(Icons.tune_rounded, color: AppColors.pitchBlack),
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
      width: isCompact ? 76 : 240,
      margin: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.pitchBlack.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: isCompact ? 10 : 16),
      child: Column(
        crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Brand Header
          if (isCompact) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.pitchBlack,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(Icons.bolt_rounded, color: AppColors.white, size: 24),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.pitchBlack,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.bolt_rounded, color: AppColors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIHA POS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.pitchBlack,
                      ),
                    ),
                    Text(
                      'Enterprise Billing',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.zinc400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
          const SizedBox(height: 36),

          // Nav Items
          _buildNavItem(0, 'Cash Register', Icons.point_of_sale_outlined, Icons.point_of_sale_rounded, isCompact),
          _buildNavItem(1, 'Item Catalog', Icons.inventory_2_outlined, Icons.inventory_2_rounded, isCompact),
          _buildNavItem(2, 'Daily Analytics', Icons.bar_chart_outlined, Icons.bar_chart_rounded, isCompact),
          _buildNavItem(3, 'Settings', Icons.tune_outlined, Icons.tune_rounded, isCompact),

          const Spacer(),

          // Bottom Cashier Card
          if (!isCompact)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.zinc50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.pitchBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '01',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Counter #01',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.pitchBlack,
                          ),
                        ),
                        Text(
                          'Printer Online',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: AppColors.zinc500,
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

  Widget _buildNavItem(int index, String title, IconData icon, IconData activeIcon, bool isCompact) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Tooltip(
        message: isCompact ? title : '',
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.pitchBlack : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.white : AppColors.zinc600,
                  size: 20,
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.zinc100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_rounded, size: 36, color: AppColors.pitchBlack),
              ),
              const SizedBox(height: 16),
              const Text(
                'Inventory Catalog',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 6),
              const Text(
                'Track barcodes, low-stock warnings, purchase cost & GST slabs',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc500),
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
      appBar: AppBar(title: const Text('Daily Analytics & Tax Filing')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.zinc100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bar_chart_rounded, size: 36, color: AppColors.pitchBlack),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sales & GST Analytics',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 6),
              const Text(
                'Daily gross revenue, UPI/Cash split, and GSTR-1 summaries',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc500),
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
      appBar: AppBar(title: const Text('Hardware & Store Settings')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.zinc100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tune_rounded, size: 36, color: AppColors.pitchBlack),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hardware & Printer Settings',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 6),
              const Text(
                'ESC/POS Thermal Printer (58mm/80mm USB & Bluetooth) & GSTIN setup',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.zinc500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
