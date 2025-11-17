import 'package:flutter/material.dart';
import 'package:budget_gov/model/reg_list.dart';

class RegionalBudgetCards extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<ListOfRegions> regions;
  final String selectedYear;

  const RegionalBudgetCards({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.regions,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Regional Budget Distribution",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D47A1),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Budget allocation across all regions",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
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
                  borderRadius: BorderRadius.circular(16),
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
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (errorMessage != null) {
      return _buildErrorCard();
    } else if (regions.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: regions.length,
        itemBuilder: (context, index) {
          final region = regions[index];
          return _buildRegionCard(context, region);
        },
      );
    } else {
      return _buildEmptyCard();
    }
  }

  Widget _buildRegionCard(BuildContext context, ListOfRegions region) {
    final change = region.percentDifferenceNepGaa;
    final isPositive = change >= 0;
    final changeColor = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);

    String description;
    switch (region.code) {
      case '01':
        description = 'Region I - Ilocos';
        break;
      case '02':
        description = 'Region II - Cagayan Valley';
        break;
      case '03':
        description = 'Region II (Cagayan Valley)';
        break;
      case '04':
        description = 'Region IV-A - CALABARZON';
        break;
      case '05':
        description = 'Region V - Bicol';
        break;
      case '06':
        description = 'Region VI - Western Visayas';
        break;
      case '07':
        description = 'Region VII - Central Visayas';
        break;
      case '08':
        description = 'Region VIII - Eastern Visayas';
        break;
      case '09':
        description = 'Region IX - Zamboanga Peninsula';
        break;
      case '10':
        description = 'Region X - Northern Mindanao';
        break;
      case '11':
        description = 'Region XI - Davao';
        break;
      case '12':
        description = 'Region XII - SOCCSKSARGEN';
        break;
      case '13':
        description = 'National Capital Region (NCR)';
        break;
      case '14':
        description = 'Cordillera Administrative Region (CAR)';
        break;
      case '15':
        description = 'Autonomous Region in Muslim Mindanao (ARMM)';
        break;
      case '16':
        description = 'Region XIII - Caraga';
        break;
      case '17':
        description = 'Region IVB - MIMAROPA';
        break;
      case '18':
        description = 'Negros Island Region';
        break;
      case '19':
        description = 'Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)';
        break;
      default:
        description = region.description;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Color(0xFF0D47A1),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Region ${region.code}",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem("NEP Budget", _formatLargeNumber(region.totalBudgetPesos)),
              _buildStatItem("GAA Budget", _formatLargeNumber(region.totalBudgetGaaPesos)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem("% of Total", "${region.percentOfTotalBudget.toStringAsFixed(1)}%"),
              _buildStatItem(
                "Change",
                "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
                valueColor: changeColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, {Color? valueColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF1565C0),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() => Container(/* ... similar to DepartmentCards ... */);
  Widget _buildEmptyCard() => Container(/* ... similar to DepartmentCards ... */);

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