import 'package:flutter/material.dart';
import 'package:budget_gov/model/details_of_departments.dart';
import 'package:budget_gov/service/department_details.dart';
import 'package:budget_gov/model/sources_of_funds.dart';
import 'package:budget_gov/service/funding_sources.dart';


class DepartmentDetailsPage extends StatefulWidget {
  final String departmentCode;
  final String departmentDescription;
  final String year;
  final DepartmentDetails? initialDetails;

  const DepartmentDetailsPage({
    super.key,
    required this.departmentCode,
    required this.departmentDescription,
    required this.year,
    this.initialDetails,
  });

  @override
  State<DepartmentDetailsPage> createState() => _DepartmentDetailsPageState();
}

class _DepartmentDetailsPageState extends State<DepartmentDetailsPage> {
  DepartmentDetails? _departmentDetails;
  bool _isLoading = true;
  List<FundingFund> _fundingFunds = []; // Changed from FundingFund to FundingFund
  bool _isFundingFundsLoading = true;


  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialDetails != null) {
      _departmentDetails = widget.initialDetails;
      _isLoading = false;
      // Fetch other data that wasn't pre-cached
      _fetchSecondaryDetails();
    } else {
      _fetchDetails();
    }
  }

  Future<void> _fetchDetails() async {
    try {
      final results = await Future.wait([
        fetchDepartmentDetails(code: widget.departmentCode, year: widget.year),
        fetchFundingSourcesHierarchy(),
       
      ]);

      if (mounted) {
        setState(() {
          _departmentDetails = results[0] as DepartmentDetails;
          _isLoading = false;
          _fundingFunds = results[1] as List<FundingFund>;
          _isFundingFundsLoading = false;
        

        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isFundingFundsLoading = false;

        });
      }
    }
  }

  Future<void> _fetchSecondaryDetails() async {
    try {
 //     final results = await Future.wait
 ([
        fetchFundingSourcesHierarchy(),
   
      ]);
      if (mounted) {
        setState(() {
       //   _fundingFunds = results[0] as List<FundingFund>;
          _isFundingFundsLoading = false;

   
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isFundingFundsLoading = false;

        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.departmentDescription,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $_errorMessage'),
        ),
      );
    }
    if (_departmentDetails == null) {
      return const Center(child: Text('No details found.'));
    }

    final details = _departmentDetails!;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              isScrollable: true,
              labelColor: Color(0xFF1565C0),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF1565C0),
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Agencies'),
                Tab(text: 'Funding Sources'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverviewTab(details),
                _buildAgenciesTab(details.agencies),
                _buildFundingSourcesTab(), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(DepartmentDetails details) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _buildStatTile('Total Agencies', details.statistics.totalAgencies.toString(), Icons.apartment),
            _buildStatTile('Operating Units', details.statistics.totalOperatingUnitClasses.toString(), Icons.business_center),
            _buildStatTile('Regions', details.statistics.totalRegions.toString(), Icons.map),
            _buildStatTile('Funding Sources', details.statistics.totalFundingSources.toString(), Icons.account_balance_wallet),
            _buildStatTile('Expense Classes', details.statistics.totalExpenseClassifications.toString(), Icons.receipt_long),
            _buildStatTile('Projects', details.statistics.totalProjects.toString(), Icons.construction),
          ],
        ),
      ],
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF1E88E5), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgenciesTab(List<Agency> agencies) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agencies.length,
      itemBuilder: (context, index) {
        final agency = agencies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            title: Text(agency.description),
            subtitle: Text('UACS Code: ${agency.uacsCode}'),
          ),
        );
      },
    );
  }

  Widget _buildFundingSourcesTab() {
    if (_isFundingFundsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: $_errorMessage'),
        ),
      );
    }
    if (_fundingFunds.isEmpty) {
      return const Center(child: Text('No funding sources found.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Funding Sources Hierarchy',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Detailed breakdown of funding categories and sources.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        // ignore: unnecessary_to_list_in_spreads
        ..._fundingFunds.map((fundCategory) => _buildFundCategoryExpansionTile(fundCategory)).toList(),
      ],
    );
  }

  Widget _buildFundCategoryExpansionTile(FundingFund fundCategory) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          fundCategory.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E3A8A),
          ),
        ),
        subtitle: Text('Code: ${fundCategory.code}'),
        children: fundCategory.fundingSources.map((source) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.description,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'UACS Code: ${source.uacsCode}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Financing Source: ${source.financingSource.description} (${source.financingSource.code})',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Authorization: ${source.authorization.description} (${source.authorization.code})',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 16),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}