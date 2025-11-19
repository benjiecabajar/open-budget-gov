import 'dart:convert';
import 'package:budget_gov/model/dep_details.dart';
import 'package:flutter/material.dart';
import 'package:budget_gov/model/dep_list.dart';
import 'package:budget_gov/service/dep_service.dart';
import 'package:budget_gov/model/reg_list.dart';
import 'package:budget_gov/service/budgets_service.dart';
import 'package:budget_gov/service/reg_list_service.dart';
import 'package:budget_gov/service/dep_details_service.dart';
import 'package:budget_gov/components/header.dart';
import 'package:budget_gov/components/dep_cards.dart';
import 'package:budget_gov/components/reg_cards.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int totalProjects;

  _BudgetData(
      {required this.departments, required this.totalNepBudget, required this.totalDepartments, required this.totalAgencies, required this.totalProjects});

  factory _BudgetData.fromJson(Map<String, dynamic> json) {
    return _BudgetData(
      departments: (json['departments'] as List)
          .map((i) => ListOfAllDepartmets.fromJson(i))
          .toList(),
      totalNepBudget: json['totalNepBudget'],
      totalDepartments: json['totalDepartments'],
      totalAgencies: json['totalAgencies'],
      totalProjects: json['totalProjects'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departments': departments.map((d) => d.toJson()).toList(),
      'totalNepBudget': totalNepBudget,
      'totalDepartments': totalDepartments,
      'totalAgencies': totalAgencies,
      'totalProjects': totalProjects,
    };
  }
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
  int _totalProjects = 0;
  int _totalRegions = 0;

  final List<String> _years = [
    '2020', '2021', '2022', '2023', '2024', '2025', '2026',
  ];

  final Map<String, _BudgetData> _cache = {};
  final Map<String, List<ListOfRegions>> _regionsCache = {};

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetchData();
  }

  Future<void> _loadCacheAndFetchData() async {
    await _loadCachesFromDisk();
    if (mounted) {
      _fetchDepartments();
      _fetchRegions();
    }
  }

  Future<void> _loadCachesFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final departmentsCacheString = prefs.getString('departments_cache');
    if (departmentsCacheString != null) {
      final Map<String, dynamic> decodedMap = jsonDecode(departmentsCacheString);
      _cache.addAll(decodedMap.map((key, value) => MapEntry(key, _BudgetData.fromJson(value))));
    }

    final regionsCacheString = prefs.getString('regions_cache');
    if (regionsCacheString != null) {
      final Map<String, dynamic> decodedMap = jsonDecode(regionsCacheString);
      _regionsCache.addAll(decodedMap.map((key, value) => MapEntry(key, (value as List).map((i) => ListOfRegions.fromJson(i)).toList())));
    }
  }

  Future<void> _fetchDepartments() async {
    final cacheKey = '$_selectedYear-NEP';

    if (_cache.containsKey(cacheKey)) {
      final cachedData = _cache[cacheKey]!;
      setState(() {
        _departments = cachedData.departments;
        _totalNepBudget = cachedData.totalNepBudget;
        _totalDepartments = cachedData.totalDepartments;
        _totalProjects = cachedData.totalProjects;
        _isLoading = false;
      });

      // Even with cached list, we might need to pre-fetch details if they are missing.
      _prefetchDepartmentDetails(cachedData.departments);

      // Also, fetch the total projects from the details cache
      _calculateTotalProjectsFromDetails(cachedData.departments);

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        fetchTotalBudget(year: _selectedYear, type: 'NEP'),
        fetchListOfAllDepartments(withBudget: true, year: _selectedYear, type: 'NEP')
      ]);

      final totalBudgetResult = results[0] as dynamic;
      final departments = results[1] as List<ListOfAllDepartmets>; // Cast to List<ListOfAllDepartmets>
      final yearlyNepBudget = totalBudgetResult.totalInPesos ~/ 2;

      _cache[cacheKey] = _BudgetData(
        departments: departments,
        totalNepBudget: yearlyNepBudget,
        totalDepartments: departments.length,
        totalAgencies: departments.fold<int>(
            0, (sum, dept) => sum + dept.totalAgencies),
        totalProjects: 0, // Initialize with 0, will be updated by background fetch
      );
      _saveDepartmentsCacheToDisk();

      setState(() {
        _departments = departments;
        _totalNepBudget = yearlyNepBudget;
        _totalDepartments = departments.length;
        _isLoading = false;
      });

      // Pre-fetch details for all departments in the background
      _prefetchDepartmentDetails(departments);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateTotalProjectsFromDetails(List<ListOfAllDepartmets> departments) async {
    final prefs = await SharedPreferences.getInstance();
    final detailsCacheString = prefs.getString('department_details_cache');
    Map<String, dynamic> detailsCache = detailsCacheString != null ? jsonDecode(detailsCacheString) : {};

    int totalProjects = 0;
    bool allDetailsCached = true;

    for (var dept in departments) {
      final cacheKey = '${dept.code}-$_selectedYear';
      if (detailsCache.containsKey(cacheKey)) {
        final details = DepartmentDetails.fromJson(detailsCache[cacheKey] as Map<String, dynamic>);
        totalProjects += details.statistics.totalProjects;
      } else {
        allDetailsCached = false;
      }
    }

    // If all details were in the cache, we have the final count.
    // If not, the pre-fetch will eventually get them, and this will be recalculated on next load.
    if (allDetailsCached && mounted) {
      setState(() {
        _totalProjects = totalProjects;
      });
      // Optionally, update the main cache as well
      final cacheKey = '$_selectedYear-NEP';
      if (_cache.containsKey(cacheKey)) {
        _cache[cacheKey]!.totalProjects = totalProjects;
        _saveDepartmentsCacheToDisk();
      }
    }
  }

  Future<void> _prefetchDepartmentDetails(List<ListOfAllDepartmets> departments) async {
    final prefs = await SharedPreferences.getInstance();
    final detailsCacheString = prefs.getString('department_details_cache');
    Map<String, dynamic> detailsCache = detailsCacheString != null ? jsonDecode(detailsCacheString) : {};

    List<Future> prefetchFutures = [];

    for (var dept in departments) {
      final cacheKey = '${dept.code}-$_selectedYear';
      if (!detailsCache.containsKey(cacheKey)) {
        prefetchFutures.add(
          fetchDepartmentDetails(code: dept.code, year: _selectedYear, combineBudgets: false).then((details) {
            detailsCache[cacheKey] = details.toJson();
          }).catchError((e) {
            // Silently fail or log the error, so it doesn't disrupt the UI
            // print('Failed to prefetch details for ${dept.code}: $e');
          })
        );
      }
    }

    if (prefetchFutures.isNotEmpty) {
      // Wait for all fetches to complete
      await Future.wait(prefetchFutures);
      // Save the updated cache to disk
      final String encodedDetails = jsonEncode(detailsCache);
      await prefs.setString('department_details_cache', encodedDetails);
      
      // Now that fetching is done, recalculate the total projects
      _calculateTotalProjectsFromDetails(departments);
      // print('Department details cache updated.');
    }
  }

  Future<void> _saveDepartmentsCacheToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedMap = jsonEncode(_cache.map((key, value) => MapEntry(key, value.toJson())));
    await prefs.setString('departments_cache', encodedMap);
  }

  Future<void> _fetchRegions() async {
    final cacheKey = '$_selectedYear-NEP';

    if (_regionsCache.containsKey(cacheKey)) {
      final cachedRegions = _regionsCache[cacheKey]!;
      setState(() {
        _regions = cachedRegions;
        _totalRegions = cachedRegions.length;
        _isRegionsLoading = false;
      });
      return;
    }
    setState(() {
      _isRegionsLoading = true;
      _regionsErrorMessage = null;
    });

    try {
      final regions = await fetchListOfRegions(
        year: _selectedYear,
        type: 'NEP',
      );

      _regionsCache[cacheKey] = regions;
      _saveRegionsCacheToDisk();
      setState(() {
        _regions = regions;
        _totalRegions = regions.length;
        _isRegionsLoading = false;
      });
    } catch (e) {
      setState(() {
        _regionsErrorMessage = e.toString();
        _isRegionsLoading = false;
      });
    }
  }

  Future<void> _saveRegionsCacheToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedMap = jsonEncode(_regionsCache.map((key, value) => MapEntry(key, value.map((r) => r.toJson()).toList())));
    await prefs.setString('regions_cache', encodedMap);
  }

  void _onYearChanged(String? newValue) {
    // Only refetch if the year has actually changed.
    if (newValue != null && newValue != _selectedYear) { 
      setState(() => _selectedYear = newValue);
      _refreshData();
    } else if (newValue != null) {
      // Allow refreshing even if the same year is selected again.
      _refreshData();
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
        onRefresh: _refreshData, // Hook up the refresh logic
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

  Future<void> _refreshData() async {
    // This function can be called by both pull-to-refresh and year change. It runs fetches concurrently.
    await Future.wait([
      _fetchDepartments(),
      _fetchRegions(),
    ]);
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
                borderRadius: BorderRadius.circular(5),
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
                  subtitle: "${_formatNumber(_totalProjects)} Projects",
                  accentColor: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.location_on_rounded,
                  title: "Regions",
                  value: _totalRegions.toString(),
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
        borderRadius: BorderRadius.circular(10),
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
              borderRadius: BorderRadius.circular(10),
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
        borderRadius: BorderRadius.circular(10),
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
                  borderRadius: BorderRadius.circular(7),
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
                  borderRadius: BorderRadius.circular(10),
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