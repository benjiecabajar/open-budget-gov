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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Classifications',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1), letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(
            "Breakdown of budget by expense category",
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 10),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1565C0),
                    strokeWidth: 3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    } else if (widget.errorMessage != null) {
      return _buildErrorCard();
    } else if (widget.expenses.isNotEmpty) {
      return Column(
        children: widget.expenses.map((expense) => _buildExpenseCard(expense)).toList(),
      );
    } else {
      return _buildEmptyCard();
    }
  }

  Widget _buildExpenseCard(Expense expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile( // Added hoverColor and focusColor
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(
            expense.description,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0D47A1)),
          ),
          subtitle: Text(
            '${expense.subClasses.length} sub-classifications',
            style: TextStyle(color: Colors.grey[600]),
          ),
          onExpansionChanged: (isExpanded) {
            setState(() {
              _isCardExpanded['expense_${expense.code}'] = isExpanded;
            });
          },
          trailing: RotationTransition(
            turns: AlwaysStoppedAnimation((_isCardExpanded['expense_${expense.code}'] ?? false) ? 0.5 : 0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.08),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1565C0), size: 20),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBudgetColumn('NEP Budget', expense.nep.amountPesos),
                      _buildBudgetColumn('GAA Budget', expense.gaa.amountPesos, alignRight: true),
                    ],
                  ),
                  const Divider(height: 20),
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
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile( // Added hoverColor and focusColor
        title: Text(subClass.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        onExpansionChanged: (isExpanded) {
          setState(() {
            _isCardExpanded['subclass_${subClass.code}'] = isExpanded;
          });
        },
        trailing: RotationTransition(
          turns: AlwaysStoppedAnimation((_isCardExpanded['subclass_${subClass.code}'] ?? false) ? 0.5 : 0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1565C0), size: 20),
          ),
        ),
        subtitle: Text('${subClass.groups.length} groups', style: TextStyle(color: Colors.grey[600])),
        childrenPadding: const EdgeInsets.only(left: 15, bottom: 10, right: 15),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBudgetColumn('NEP', subClass.nep.amountPesos, isSub: true),
              _buildBudgetColumn('GAA', subClass.gaa.amountPesos, isSub: true, alignRight: true),
            ],
          ),
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
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile( // Added hoverColor and focusColor
        title: Text(group.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        onExpansionChanged: (isExpanded) {
          setState(() {
            _isCardExpanded['group_${group.code}'] = isExpanded;
          });
        },
        trailing: RotationTransition(
          turns: AlwaysStoppedAnimation((_isCardExpanded['group_${group.code}'] ?? false) ? 0.5 : 0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1565C0), size: 20),
          ),
        ),
        subtitle: Text('${group.objects.length} objects', style: TextStyle(color: Colors.grey[600])),
        childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
        children: group.objects
            .map((object) => Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(object.description, style: const TextStyle(fontSize: 12))),
                      Text(
                        _formatLargeNumber(object.gaa.amountPesos),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBudgetColumn(String label, num value, {bool isSub = false, bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w700, fontSize: isSub ? 12 : 14)),
        const SizedBox(height: 2),
        Text(
          _formatLargeNumber(value),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: isSub ? 16 : 18,
            color: const Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }

  String _formatLargeNumber(num? number) {
    if (number == null || number == 0) return '₱0';
    if (number >= 1e12) return '₱${(number / 1e12).toStringAsFixed(2)}T';
    if (number >= 1e9) return '₱${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '₱${(number / 1e6).toStringAsFixed(2)}M';
    return '₱${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Widget _buildErrorCard() => Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Loading Expenses',
                    style: TextStyle(color: Colors.red.shade900, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.errorMessage ?? 'Unknown error occurred',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildEmptyCard() => Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Expenses Found',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'No expense data for this year',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}