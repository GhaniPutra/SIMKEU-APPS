import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const GlassBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  static const _ink = Color(0xFF1D2310);
  static const _olive = Color(0xFFAA9C68);
  static const _brown = Color(0xFF825F48);
  static const _cream = Color(0xFFF7F8ED);
  static const _items = <_NavigationItem>[
    _NavigationItem('Beranda', Icons.home_rounded),
    _NavigationItem('Kasir', Icons.point_of_sale_rounded),
    _NavigationItem('Penjualan', Icons.receipt_long_rounded),
    _NavigationItem('Pengeluaran', Icons.payments_rounded),
    _NavigationItem('Stok', Icons.inventory_2_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const horizontalInset = 12.0;
              final contentWidth = constraints.maxWidth - horizontalInset;
              final minInactiveWidth = constraints.maxWidth < 320 ? 44.0 : 48.0;
              final activeWidth =
                  (contentWidth - minInactiveWidth * (_items.length - 1))
                      .clamp(88.0, 158.0)
                      .toDouble();
              final inactiveWidth =
                  (contentWidth - activeWidth) / (_items.length - 1);

              return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: _cream.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(32),
                        border:
                            Border.all(color: _olive.withValues(alpha: 0.36)),
                        boxShadow: [
                          BoxShadow(
                            color: _ink.withValues(alpha: 0.09),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.72),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_items.length, (index) {
                          final item = _items[index];
                          final selected = index == currentIndex;
                          return _NavigationButton(
                            item: item,
                            selected: selected,
                            width: selected ? activeWidth : inactiveWidth,
                            selectedColor: selected && index == 1
                                ? const Color(0xFFE9E3D2)
                                : Colors.white.withValues(alpha: 0.92),
                            onTap: () => onDestinationSelected(index),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  final String label;
  final IconData icon;

  const _NavigationItem(this.label, this.icon);
}

class _NavigationButton extends StatelessWidget {
  final _NavigationItem item;
  final bool selected;
  final double width;
  final Color selectedColor;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.width,
    required this.selectedColor,
    required this.onTap,
  });

  static const _ink = Color(0xFF1D2310);
  static const _brown = Color(0xFF825F48);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          width: width,
          height: 50,
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onTap,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: selected
                      ? Padding(
                          key: ValueKey('selected_${item.label}'),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, size: 21, color: _brown),
                              const SizedBox(width: 6),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    item.label,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: const TextStyle(
                                      color: _ink,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Icon(
                          item.icon,
                          key: ValueKey('idle_${item.label}'),
                          size: 22,
                          color: _brown.withValues(alpha: 0.84),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
