import 'package:flutter/material.dart';
import 'package:budget_gov/model/reg_list.dart';

class RegionalBudgetCards extends StatefulWidget {
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
  State<RegionalBudgetCards> createState() => _RegionalBudgetCardsState();
}

class _RegionalBudgetCardsState extends State<RegionalBudgetCards> {
  bool _isExpanded = false;
  final Map<String, bool> _isCardExpanded = {};

  // Modern color palette from dep_cards.dart
  final Color _primaryColor = const Color(0xFF0F4C81); // Deep navy blue
  final Color _secondaryColor = const Color(0xFF2E8BC0); // Ocean blue
  final Color _accentColor = const Color(0xFF00B4D8); // Vibrant teal
  final Color _successColor = const Color(0xFF2E8B57); // Sea green
  final Color _errorColor = const Color(0xFFDC143C); // Crimson red
  final Color _surfaceColor = Colors.white;
// Light gray background

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Regional Budget Distribution",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _primaryColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Budget allocation across all regions",
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
    } else if (widget.regions.isNotEmpty) {
      final bool isCollapsible = widget.regions.length > 5;
      final List<ListOfRegions> visibleRegions =
          isCollapsible && !_isExpanded
              ? widget.regions.take(5).toList()
              : widget.regions;

      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleRegions.length,
            itemBuilder: (context, index) {
              final region = visibleRegions[index];
              return Padding( 
                padding: const EdgeInsets.only(bottom: 5.0),
                child: _buildRegionCard(region),
              );
            },
          ),
          if (isCollapsible) ...[
            const SizedBox(height: 10),
            _buildExpansionButton(),
          ],
        ],
      );
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildRegionCard(ListOfRegions region) {
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
        description = 'Region III - Central Luzon';
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
        description = 'Autonomous Region In Nuslim Mindanao (ARMM)';
        break;
      case '16':
        description = 'Region XIII - Caraga';
        break;
      case '17':
        description = 'Region IV-B - MIMAROPA';
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
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          onExpansionChanged: (isExpanded) {
            setState(() {
              _isCardExpanded[region.code] = isExpanded;
            });
          },
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_primaryColor, _secondaryColor]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.map_rounded, color: Colors.white, size: 18),
          ),
          title: Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          trailing: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: (_isCardExpanded[region.code] ?? false) ? 0.5 : 0.0),
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
                  _buildBudgetInfo(region.totalBudgetPesos, region.totalBudgetGaaPesos),
                  const SizedBox(height: 10),
                  _buildStatRow(region),
                  const SizedBox(height: 10),
                  _buildChangeIndicator(difference, change),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(ListOfRegions region) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '% of Total Budget',
            '${region.percentOfTotalBudget.toStringAsFixed(2)}%',
            Icons.pie_chart_outline_rounded,
            _secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            'Region Code',
            region.code,
            Icons.tag,
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

  Widget _buildChangeIndicator(num difference, num change) {
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
              'Loading Regional Data',
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
                    'Error Loading Regions',
                    style: TextStyle(
                      color: _errorColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.errorMessage ?? 'An unknown error occurred',
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
                'No Regions Found',
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ), 
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isExpanded ? 'Show Less' : 'Show All ${widget.regions.length} Regions',
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