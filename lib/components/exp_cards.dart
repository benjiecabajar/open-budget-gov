import 'package:budget_gov/model/exp.dart';
import 'package:flutter/material.dart';

class ExpenseCards extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<Expense> expenses;
  final String selectedYear;

  const ExpenseCards({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.expenses,
    required this.selectedYear,
  });

  @override
  State<ExpenseCards> createState() => _ExpenseCardsState();
}

class _ExpenseCardsState extends State<ExpenseCards> {
  final Map<String, bool> _isCardExpanded = {};
  
  // Modern color palette from dep_cards.dart
  final Color _primaryColor = const Color(0xFF0F4C81); // Deep navy blue
  final Color _secondaryColor = const Color(0xFF2E8BC0); // Ocean blue
  final Color _accentColor = const Color(0xFF00B4D8); // Vibrant teal
  final Color _successColor = const Color(0xFF2E8B57); // Sea green
  final Color _errorColor = const Color(0xFFDC143C); // Crimson red
  final Color _surfaceColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Classifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _primaryColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Breakdown of budget by expense category",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            color: Colors.grey[300],
            height: 1,
          ),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return _buildLoadingState();
    } else if (widget.errorMessage != null) {
      return _buildErrorState();
    } else if (widget.expenses.isNotEmpty) {
      return Column(
        children: widget.expenses.map((expense) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildExpenseCard(expense),
          );
        }).toList(),
      );
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildExpenseCard(Expense expense) {
    final difference = expense.gaa.amountPesos - expense.nep.amountPesos;
    final change = expense.nep.amountPesos != 0 ? (difference / expense.nep.amountPesos) * 100 : 0.0;

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
          leading: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_primaryColor, _secondaryColor]), 
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.category_rounded, color: Colors.white, size: 20),
          ),
          title: Text(
            expense.description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${expense.subClasses.length} sub-classes',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onExpansionChanged: (isExpanded) {
            setState(() {
              _isCardExpanded['expense_${expense.code}'] = isExpanded;
            });
          },
          trailing: TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: 0.0,
                end: (_isCardExpanded['expense_${expense.code}'] ?? false)
                    ? 0.5
                    : 0.0),
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
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: _primaryColor, size: 20),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  const Divider(height: 8),
                  _buildBudgetInfo(expense.nep.amountPesos, expense.gaa.amountPesos),
                  const SizedBox(height: 10),
                  _buildChangeIndicator(difference, change),
                  const SizedBox(height: 10),
                  ...expense.subClasses.map((subClass) => _buildSubClassTile(subClass)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubClassTile(ExpenseSubClass subClass) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(subClass.description, style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text('${subClass.groups.length} groups', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        onExpansionChanged: (isExpanded) {
          setState(() {
            _isCardExpanded['subclass_${subClass.code}'] = isExpanded;
          });
        },
        trailing: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: (_isCardExpanded['subclass_${subClass.code}'] ?? false) ? 0.5 : 0.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) => RotationTransition(
            turns: AlwaysStoppedAnimation(value),
            child: child,
          ),
          child: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryColor, size: 20),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, bottom: 10, right: 16),
        children: [
          _buildBudgetInfo(subClass.nep.amountPesos, subClass.gaa.amountPesos),
          const SizedBox(height: 10),
          ...subClass.groups.map((group) => _buildGroupTile(group)),
        ],
      ),
    );
  }

  Widget _buildGroupTile(ExpenseGroup group) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Text(group.description, style: TextStyle(color: _secondaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text('${group.objects.length} objects', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        onExpansionChanged: (isExpanded) {
          setState(() {
            _isCardExpanded['group_${group.code}'] = isExpanded;
          });
        },
        trailing: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: (_isCardExpanded['group_${group.code}'] ?? false) ? 0.5 : 0.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) => RotationTransition(
            turns: AlwaysStoppedAnimation(value),
            child: child,
          ),
          child: Icon(Icons.keyboard_arrow_down_rounded, color: _secondaryColor, size: 18),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        children: group.objects.map((object) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    object.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _formatLargeNumber(object.gaa.amountPesos),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetInfo(num nepBudget, num gaaBudget) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEP ${widget.selectedYear}',
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              Text(_formatLargeNumber(nepBudget),
                  style: TextStyle(
                      color: _primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GAA ${widget.selectedYear}',
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              Text(_formatLargeNumber(gaaBudget),
                  style: TextStyle(
                      color: _secondaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChangeIndicator(num difference, double change) {
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
              style:
                  TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
            style:
                TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatLargeNumber(num? number) {
    if (number == null || number == 0) return '₱0';
    if (number >= 1e12) return '₱${(number / 1e12).toStringAsFixed(2)}T';
    if (number >= 1e9) return '₱${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '₱${(number / 1e6).toStringAsFixed(2)}M';
    return '₱${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
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
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Expense Data',
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

  Widget _buildErrorState() => Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _errorColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _errorColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: _errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Loading Data',
                    style: TextStyle(
                      color: _errorColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.errorMessage ?? 'Unknown error occurred',
                    style: TextStyle(
                      color: _errorColor.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildEmptyState() => Center(
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
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Expenses Found',
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try selecting a different year',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}