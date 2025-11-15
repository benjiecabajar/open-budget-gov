import 'package:flutter/material.dart';
import 'package:budget_gov/model/list_of_departments.dart';
import 'package:budget_gov/model/list_of_regions.dart';
import 'package:budget_gov/service/departments.dart';
import 'package:budget_gov/service/budgets.dart';
import 'package:budget_gov/service/funding_sources.dart';
import 'package:budget_gov/service/list_of_regions_service.dart';
import 'package:budget_gov/components/header.dart';
import 'package:budget_gov/components/department_cards.dart';
import 'package:budget_gov/components/regional_budget_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _BudgetData {
  final List<ListOfAllDepartmets> departments;
  final int totalNepBudget;
  final int totalDepartments;
  final int totalAgencies;

  _BudgetData(
      {required this.departments, required this.totalNepBudget, required this.totalDepartments, required this.totalAgencies});
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedYear = '2025';
  List<ListOfAllDepartmets> _departments = [];
  List<ListOfRegions> _regions = [];
  bool _isLoading = false;
  bool _isRegionsLoading = false;
  String? _errorMessage;
  String? _regionsErrorMessage;
  int _totalNepBudget = 0;
  int _totalDepartments = 0;
  int _totalAgencies = 0;

  final List<String> _years = [
    '2020', '2021', '2022', '2023', '2024', '2025', '2026',
  ];

  final Map<String, _BudgetData> _cache = {};

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
    _fetchRegions();
  }

  Future<void> _fetchDepartments() async {
    final cacheKey = '$_selectedYear-NEP';

    if (_cache.containsKey(cacheKey)) {
      final cachedData = _cache[cacheKey]!;
      setState(() {
        _departments = cachedData.departments;
        _totalNepBudget = cachedData.totalNepBudget;
        _totalDepartments = cachedData.totalDepartments;
        _totalAgencies = cachedData.totalAgencies;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        fetchTotalBudget(year: _selectedYear, type: 'NEP'),
        fetchListOfAllDepartments(
          withBudget: true,
          year: _selectedYear,
          type: 'NEP',
        ),
        fetchFundingSourcesHierarchy(),
      ]);

      final totalBudgetResult = results[0] as dynamic;
      final departments = results[1] as List<ListOfAllDepartmets>;
      final yearlyNepBudget = totalBudgetResult.totalInPesos ~/ 2;

      _cache[cacheKey] = _BudgetData(
        departments: departments,
        totalNepBudget: yearlyNepBudget,
        totalDepartments: departments.length,
        totalAgencies: departments.fold<int>(
            0, (sum, dept) => sum + dept.totalAgencies),
      );

      setState(() {
        _departments = departments;
        _totalNepBudget = yearlyNepBudget;
        _totalDepartments = departments.length;
        _totalAgencies = departments.fold<int>(0, (sum, dept) => sum + dept.totalAgencies);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRegions() async {
    setState(() {
      _isRegionsLoading = true;
      _regionsErrorMessage = null;
    });

    try {
      final regions = await fetchListOfRegions(
        year: _selectedYear,
        type: 'NEP',
      );

      setState(() {
        _regions = regions;
        _isRegionsLoading = false;
      });
    } catch (e) {
      setState(() {
        _regionsErrorMessage = e.toString();
        _isRegionsLoading = false;
      });
    }
  }

  void _onYearChanged(String? newValue) {
    if (newValue != null) {
      setState(() => _selectedYear = newValue);
      _fetchDepartments();
      _fetchRegions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: Header(
        selectedYear: _selectedYear,
        selectedType: 'NEP',
        availableYears: _years,
        onYearChanged: _onYearChanged,
        onTypeChanged: (String? newValue) {},
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDepartments,
        color: const Color(0xFF1565C0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 14),
              _buildStatsGrid(),
              const SizedBox(height: 21),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: DepartmentCards(
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  departments: _departments,
                  selectedYear: _selectedYear,
                  selectedType: 'NEP',
                ),
              ),
              const SizedBox(height: 21),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: RegionalBudgetCards(
                  isLoading: _isRegionsLoading,
                  errorMessage: _regionsErrorMessage,
                  regions: _regions,
                  selectedYear: _selectedYear,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1565C0),
            Color(0xFF1976D2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                "FISCAL YEAR $_selectedYear",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Transparency in Every Peso",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Track Philippine national budget allocations across departments, regions, and programs",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildLargeStatCard(
            icon: Icons.account_balance_wallet_rounded,
            title: "Total NEP Budget",
            value: _formatLargeNumber(_totalNepBudget),
            subtitle: "National Expenditure Program $_selectedYear",
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.domain_rounded,
                  title: "Departments",
                  value: _totalDepartments.toString(),
                  subtitle: "${_formatNumber(_totalAgencies)} Agencies",
                  accentColor: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.location_on_rounded,
                  title: "Regions",
                  value: "19",
                  subtitle: "Geographic coverage",
                  accentColor: const Color(0xFF1565C0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
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
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color accentColor,
  }) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.1),
                      accentColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(width: 6)  ,
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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