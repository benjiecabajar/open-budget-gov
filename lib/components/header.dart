import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final String selectedYear;
  final String selectedType;
  final List<String> availableYears;
  final ValueChanged<String?> onYearChanged;
  final ValueChanged<String?> onTypeChanged;

  const Header({
    super.key,
    required this.selectedYear,
    required this.selectedType,
    required this.availableYears,
    required this.onYearChanged,
    required this.onTypeChanged,
  });

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(58);
}

class _HeaderState extends State<Header> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 58,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              
                            ),
                          
                            child: const Icon(Icons.account_balance, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Open Budget',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 23,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                'Philippines Budget Transparency',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                              
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
  
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        _buildWideDropdown(
                          value: widget.selectedYear,
                          items: widget.availableYears,
                          onChanged: widget.onYearChanged,
                          icon: Icons.calendar_today,
                          width: 70,
                          dropdownWidth: 75,
                          dropdownMaxHeight: 400,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    double width = 80,
    double dropdownWidth = 200,
    double dropdownMaxHeight = 200,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Row(
                  children: [
                    Icon(icon, size: 12, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            buttonStyleData: ButtonStyleData(
              width: width,
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration( 
                color: const Color(0xFF1A5DAA),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: dropdownMaxHeight,
              width: dropdownWidth,
              decoration: BoxDecoration(
                color: const Color(0xFF1A5DAA), 
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              offset: Offset((width - dropdownWidth) / 2, 32),
              openInterval: const Interval(
                0.0,
                0.7,
                curve: Curves.easeInOut,
              ),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down, size: 12, color: Colors.white),
            ),
            selectedItemBuilder: (context) {
              return items.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ 
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
