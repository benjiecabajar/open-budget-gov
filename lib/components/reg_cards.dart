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
    final difference = region.totalBudgetGaaPesos - region.totalBudgetPesos;
    final change = region.percentDifferenceNepGaa;

 
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1565C0).withOpacity(0.15),
                        const Color(0xFF1E88E5).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: Color(0xFF1565C0),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBudgetCards(region),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildChangeCard(difference, change.toDouble())),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    "Percentage of Total Budget",
                    "${region.percentOfTotalBudget.toStringAsFixed(1)}%",
                    Icons.pie_chart_rounded,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCards(ListOfRegions region) {
    return Row(
      children: [
        Expanded(child: _buildStatItem("NEP Budget", _formatLargeNumber(region.totalBudgetPesos))),
        const SizedBox(width: 10),
        Expanded(child: _buildStatItem("GAA Budget", _formatLargeNumber(region.totalBudgetGaaPesos), isGaa: true)),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, {bool isGaa = false}) {
    final baseColor = isGaa ? const Color(0xFF1E88E5) : const Color(0xFF1565C0);
    final gradientColors = isGaa
        ? [const Color(0xFF1E88E5).withOpacity(0.08), const Color(0xFF42A5F5).withOpacity(0.05)]
        : [const Color(0xFF1565C0).withOpacity(0.08), const Color(0xFF1E88E5).withOpacity(0.05)];

    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: baseColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: baseColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildChangeCard(int difference, double change) {
    final isPositive = difference >= 0;
    final color = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);
    final bgColor = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: bgColor.withOpacity(0.2),
          width: 1,
        ),
      ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: bgColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${difference >= 0 ? '+' : ''}${_formatLargeNumber(difference)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.1),
          width: 1,
        ),
      ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorCard() => Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.red.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade700,
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
                      color: Colors.red.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    errorMessage ?? 'Unknown error occurred',
                    style: TextStyle(
                      color: Colors.red.shade700,
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
                'No Regions Found',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try selecting a different year',
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
    if (number >= 1e3) return '₱${(number / 1e3).toStringAsFixed(2)}K';
    return '₱${_formatNumber(number)}';
  }
}