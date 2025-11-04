import 'package:flutter/material.dart';
import 'package:budget_gov/model/list_of_departments.dart';
import 'package:budget_gov/service/departments.dart';
import 'package:budget_gov/components/header.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// A data class to hold the fetched budget data for a specific year and type.
class BudgetData {
  final List<ListOfAllDepartmets> departments;
  final int totalNepBudget;
  final int totalDepartments;
  final int totalAgencies;

  BudgetData(
      {required this.departments,
      required this.totalNepBudget,
      required this.totalDepartments,
      required this.totalAgencies});
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedYear = '2025';
  String _selectedType = 'NEP';
  List<ListOfAllDepartmets> _departments = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _totalNepBudget = 0;
  int _totalDepartments = 0;
  int _totalAgencies = 0;

  final List<String> _years = [
    '2020', '2021', '2022', '2023', '2024', '2025', '2026',
  ];

  // Cache to store fetched data. The key is a combination of year and type (e.g., "2025-NEP").
  final Map<String, BudgetData> _cache = {};

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final cacheKey = '$_selectedYear-$_selectedType';

    // 1. Check if data is already in the cache.
    if (_cache.containsKey(cacheKey)) {
      setState(() {
        final cachedData = _cache[cacheKey]!;
        _departments = cachedData.departments;
        _totalNepBudget = cachedData.totalNepBudget;
        _totalDepartments = cachedData.totalDepartments;
        _totalAgencies = cachedData.totalAgencies;
        _isLoading = false; // Data is loaded instantly from cache
      });
      return; // Stop execution if we have cached data.
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final departments = await fetchListOfAllDepartments(
        withBudget: true,
        year: _selectedYear,
        type: _selectedType,
      );

      final totalBudget = departments.fold<int>(
          0, (sum, dept) => sum + (dept.totalBudgetPesos));
      final totalAgencies =
          departments.fold<int>(0, (sum, dept) => sum + (dept.totalAgencies));

      // 2. Store the newly fetched data in the cache.
      _cache[cacheKey] = BudgetData(
        departments: departments,
        totalNepBudget: totalBudget,
        totalDepartments: departments.length,
        totalAgencies: totalAgencies,
      );

      setState(() {
        _departments = departments;
        _totalNepBudget = totalBudget;
        _totalDepartments = departments.length;
        _totalAgencies = totalAgencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onYearChanged(String? newValue) {
    if (newValue != null) {
      setState(() => _selectedYear = newValue);
      _fetchDepartments();
    }
  }

  void _onTypeChanged(String? newValue) {
    if (newValue != null) {
      setState(() => _selectedType = newValue);
      _fetchDepartments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: Header(
        selectedYear: _selectedYear,
        selectedType: _selectedType,
        availableYears: _years,
        onYearChanged: _onYearChanged,
        onTypeChanged: _onTypeChanged,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDepartments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewSection(),
                const SizedBox(height: 24),
                const Text(
                  "Budget by Department",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _buildBodyContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Text(
          "Transparency in Every Peso",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D47A1),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          "Explore the Philippine national budget with clarity and accountability."
          " Track $_selectedYear NEP allocations across departments, regions, and programs.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.attach_money_rounded,
                title: "Total NEP Budget",
                value: _formatLargeNumber(_totalNepBudget),
                subtitle: "Fiscal Year $_selectedYear",
                isPrimary: true,

              ),
              const SizedBox(height: 10),
              _buildStatCard(
                color: Colors.white,
                icon: Icons.apartment_rounded,
                title: "Departments",
                value: _totalDepartments.toString(),
                subtitle: "${_formatNumber(_totalAgencies)} agencies tracked",
              ),
              const SizedBox(height: 10),
              _buildStatCard(
                color: Colors.white,
                icon: Icons.map_rounded,
                title: "Regions",
                value: "19",
                subtitle: "Geographic coverage",
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildStatCard({
  Color? color,
  LinearGradient? gradient,
  required IconData icon,
  required String title,
  required String value,
  required String subtitle,
  bool isPrimary = false,
}) {
  final Color textColor = isPrimary ? Colors.white : Colors.black87;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isPrimary 
              ? const Color(0xFF1565C0).withOpacity(0.25)
              : Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        // Icon Container
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPrimary
                ? Colors.white.withOpacity(0.2)
                : const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFF1565C0).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : const Color(0xFF1565C0),
            size: 28,
          ),
        ),
        const SizedBox(width: 18),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withOpacity(0.75),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Optional trailing indicator
        if (isPrimary)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 20,
            ),
          ),
      ],
    ),
  );
}

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(color: Color(0xFF1565C0)),
        ),
      );
    } else if (_errorMessage != null) {
      return _buildErrorCard();
    } else if (_departments.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _departments.length,
        itemBuilder: (context, index) {
          final dept = _departments[index];
          return _buildDepartmentCard(dept);
        },
      );
    } else {
      return _buildEmptyCard();
    }
  }

  Widget _buildDepartmentCard(ListOfAllDepartmets dept) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const Border(), // Remove default border when expanded
        collapsedShape: const Border(), // Remove default border when collapsed
        title: Text(
          dept.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E3A8A),
          ),
        ),
        subtitle: Text(
          'Code: ${dept.code}',
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildComparisonDetails(dept),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() => Card(
        color: Colors.red.shade50,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildComparisonDetails(ListOfAllDepartmets dept) {
    final nepBudget = _selectedType == 'NEP' ? dept.totalBudgetPesos : (dept.totalBudgetGaaPesos / (1 + dept.percentDifferenceNepGaa / 100)).round();
    final gaaBudget = dept.totalBudgetGaaPesos;
    final difference = gaaBudget - nepBudget;
    final change = dept.percentDifferenceNepGaa;

    return Column(
      children: [
        const SizedBox(height: 8),
        _buildInfoRow(
          'NEP $_selectedYear',
          _formatLargeNumber(nepBudget),
        ),
        _buildInfoRow(
          'GAA $_selectedYear',
          _formatLargeNumber(gaaBudget),
        ),
        const Divider(height: 24),
        _buildInfoRow(
          'Insertions',
          '${difference >= 0 ? '+' : ''}${_formatLargeNumber(difference)}',
          valueColor: difference >= 0 ? Colors.green.shade700 : Colors.red.shade700,
        ),
        _buildInfoRow(
          'Change',
          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
          valueColor: change >= 0 ? Colors.green.shade700 : Colors.red.shade700,
        ),
        const Divider(height: 24),
        _buildInfoRow(
          'Total Agencies',
          '${dept.totalAgencies}',
        ),
      ],
    );
  }

  Widget _buildEmptyCard() => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No departments found',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
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
    if (number >= 1e12) return '₱${(number / 1e12).toStringAsFixed(2)}T';
    if (number >= 1e9) return '₱${(number / 1e9).toStringAsFixed(2)}B';
    if (number >= 1e6) return '₱${(number / 1e6).toStringAsFixed(2)}M';
    return '₱${_formatNumber(number)}';
  }
}
