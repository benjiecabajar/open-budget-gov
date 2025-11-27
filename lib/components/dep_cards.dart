import 'package:flutter/material.dart';
import 'package:budget_gov/model/dep_list.dart';
import 'package:budget_gov/pages/dep_details_page.dart';

class DepartmentCards extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<ListOfAllDepartmets> departments;
  final String selectedYear;
  final String selectedType;

  const DepartmentCards({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.departments,
    required this.selectedYear,
    required this.selectedType,
  });

  @override
  State<DepartmentCards> createState() => _DepartmentCardsState();
}

class _DepartmentCardsState extends State<DepartmentCards> {
  bool _isExpanded = false;
  final Map<String, bool> _isCardExpanded = {};
  String? _loadingDeptCode;

  // Modern color palette
  final Color _primaryColor = const Color(0xFF0F4C81); // Deep navy blue
  final Color _secondaryColor = const Color(0xFF2E8BC0); // Ocean blue
  final Color _accentColor = const Color(0xFF00B4D8); // Vibrant teal
  final Color _successColor = const Color(0xFF2E8B57); // Sea green
  final Color _errorColor = const Color(0xFFDC143C); // Crimson red
  final Color _surfaceColor = Colors.white;
  final Color _backgroundColor = const Color(0xFFF8FAFC); // Light gray background

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 10),
            
            // Content Section
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [            
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Budget by Department",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "All departments with budget allocation",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // Divider
        const SizedBox(height: 20),
        Divider(
          color: Colors.grey[300],
          height: 1,
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return _buildLoadingState();
    } else if (widget.errorMessage != null) {
      return _buildErrorState();
    } else if (widget.departments.isNotEmpty) {
      return _buildDepartmentList();
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            // Animated loading container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pulse animation
                  TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Container(
                        width: 60 + (20 * value),
                        height: 60 + (20 * value),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.05 * (1 - value)),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  
                  // Main spinner
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Department Data',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we fetch the latest budget information',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentList() {
    final bool isCollapsible = widget.departments.length > 5;
    final List<ListOfAllDepartmets> visibleDepartments = isCollapsible && !_isExpanded
        ? widget.departments.take(5).toList()
        : widget.departments;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleDepartments.length,
          itemBuilder: (context, index) {
            final dept = visibleDepartments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: _buildDepartmentCard(dept),
            );
          },
        ),
        if (isCollapsible) ...[
          const SizedBox(height: 16),
          _buildExpansionButton(),
        ],
      ],
    );
  }

  Widget _buildDepartmentCard(ListOfAllDepartmets dept) {
    final nepBudget = widget.selectedType == 'NEP'
        ? dept.totalBudgetPesos
        : (dept.totalBudgetGaaPesos / (1 + (dept.percentDifferenceNepGaa) / 100)).round();
    final gaaBudget = dept.totalBudgetGaaPesos;
    final difference = gaaBudget - nepBudget;
    final change = dept.percentDifferenceNepGaa;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          onExpansionChanged: (isExpanded) {
            setState(() {
              _isCardExpanded[dept.code] = isExpanded;
            });
          },
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_primaryColor, _secondaryColor]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance, color: Colors.white, size: 18),
          ),
          title: Text(
            dept.description,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Code: ${dept.code}',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: (_isCardExpanded[dept.code] ?? false) ? 0.5 : 0.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) => RotationTransition(
              turns: AlwaysStoppedAnimation(value),
              child: child,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryColor, size: 20),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column( 
                children: [
                  const Divider(height: 8),
                  _buildBudgetInfo(nepBudget, gaaBudget),
                  const SizedBox(height: 10),
                  _buildStatRow(dept),
                  const SizedBox(height: 10),
                  _buildChangeIndicator(difference, change),
                  const SizedBox(height: 12),
                  _buildCardActionButton(dept),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(ListOfAllDepartmets dept) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '% of Total Budget',
            '${dept.percentOfTotalBudget.toStringAsFixed(2)}%',
            Icons.pie_chart_outline_rounded,
            _secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            'Agencies',
            dept.totalAgencies.toString(),
            Icons.business_rounded,
            _primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
      ],
    );
  }

  Widget _buildBudgetInfo(int nepBudget, int gaaBudget) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEP ${widget.selectedYear}', style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)),
              Text(_formatLargeNumber(nepBudget), style: TextStyle(color: _primaryColor, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GAA ${widget.selectedYear}', style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)),
              Text(_formatLargeNumber(gaaBudget), style: TextStyle(color: _secondaryColor, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChangeIndicator(int difference, double change) {
    final isPositive = difference >= 0;
    final color = isPositive ? _successColor : _errorColor;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${isPositive ? '+' : ''}${_formatLargeNumber(difference)}',
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActionButton(ListOfAllDepartmets dept) {
    final bool isLoading = _loadingDeptCode == dept.code;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => _navigateToDetails(dept),
        icon: isLoading
            ? Container()
            : Icon(Icons.open_in_new_rounded, size: 16, color: _surfaceColor),
        label: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: _surfaceColor),
              )
            : Text(
                'View Full Details',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _surfaceColor),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _surfaceColor,
          disabledBackgroundColor: _primaryColor.withOpacity(0.7),
          elevation: 2,
          shadowColor: _primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 5),
        ),
      ),
    );
  }

  Widget _buildExpansionButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _surfaceColor,
          foregroundColor: _primaryColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
        ), 
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isExpanded ? 'Show Less' : 'Show All ${widget.departments.length} Departments',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _errorColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: _errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to Load Data',
            style: TextStyle(
              color: _errorColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.errorMessage ?? 'Please try again later',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Add retry logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Departments Found',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different year or budget type',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(ListOfAllDepartmets dept) async {
    setState(() {
      _loadingDeptCode = dept.code;
    });
    
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DepartmentDetailsPage(
          departmentCode: dept.code,
          departmentDescription: dept.description,
          year: widget.selectedYear,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
    
    if (mounted) {
      setState(() {
        _loadingDeptCode = null;
      });
    }
  }

  String _formatNumber(num? number) {
    if (number == null) return "0";
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatLargeNumber(num? number) {
    if (number == null || number == 0) return '₱0';
    if (number == 0) return '₱0'; // No change needed
    if (number >= 1e12) return '₱${(number / 1e12).toStringAsFixed(2)}T';
    if (number >= 1e9) return '₱${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '₱${(number / 1e6).toStringAsFixed(2)}M';
    return '₱${_formatNumber(number)}';
  }
}