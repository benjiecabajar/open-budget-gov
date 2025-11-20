import 'package:budget_gov/model/funds_sources.dart';
import 'package:flutter/material.dart';
import 'package:budget_gov/model/dep_details.dart';
import 'package:budget_gov/service/dep_details_service.dart';


// Already imported, but good to confirm

class DepartmentDetailsPage extends StatefulWidget {
	final String departmentCode;
	final String departmentDescription;
	final String year;

	const DepartmentDetailsPage({
		super.key,
		required this.departmentCode,
		required this.departmentDescription,
		required this.year,
	});

	@override
	State<DepartmentDetailsPage> createState() => _DepartmentDetailsPageState();
}

class _DepartmentDetailsPageState extends State<DepartmentDetailsPage> {
	late Future<DepartmentDetails> _detailsFuture;

	@override
	void initState() {
		super.initState();
		_detailsFuture = fetchDepartmentDetails(
			code: widget.departmentCode,
			year: widget.year,
			combineBudgets: true,
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF6FAFF),
			appBar: AppBar(
				title: Text(widget.departmentDescription,
						style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
				backgroundColor: const Color(0xFF1565C0),
				foregroundColor: Colors.white,
				elevation: 0,
			),
			body: FutureBuilder<DepartmentDetails>(
				future: _detailsFuture,
				builder: (context, snapshot) {
					if (snapshot.connectionState == ConnectionState.waiting) {
						return const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)));
					} else if (snapshot.hasError) {
						return Center(
							child: Padding(
								padding: const EdgeInsets.all(32),
								child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Icon(Icons.error_outline_rounded, color: Colors.red[700], size: 48),
										const SizedBox(height: 16),
										Text('Failed to load details',
												style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w700, fontSize: 18)),
										const SizedBox(height: 8),
										Text('${snapshot.error}',
												style: TextStyle(color: Colors.red[400], fontSize: 13)),
									],
								),
							),
						);
					} else if (snapshot.hasData) {
						final details = snapshot.data!;
            

						return SingleChildScrollView(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildComparisonHeader(details),
									const SizedBox(height: 18),
									_buildStats(details),
									const SizedBox(height: 24),
									_buildSectionTitle('Agencies'),
									_buildAgencies(details),
									const SizedBox(height: 24),
									_buildSectionTitle('Operating Unit Classes'),
									_buildOperatingUnitClasses(details),
									const SizedBox(height: 24),
									_buildSectionTitle('Regions'),
									_buildRegions(details),
									const SizedBox(height: 24),
									_buildSectionTitle('Funding Sources'),
									_buildFundingSources(details),
									const SizedBox(height: 24),
									_buildSectionTitle('Expense Categories'),
									_buildExpenseCategories(details),
								],
							),
						);
					} else {
						return const Center(child: Text('No details found.'));
					}
				},
			),
		);
	}

	Widget _buildComparisonHeader(DepartmentDetails details) {
		final comparison = details.budgetComparison;
		final insertions = comparison.difference.amountPesos;
		final changePercent = comparison.difference.percentChange ?? 0.0;

		return Container(
			width: double.infinity,
			padding: const EdgeInsets.all(20),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(12),
				boxShadow: [
					BoxShadow(
						color: Colors.blue.withOpacity(0.1),
						blurRadius: 20,
						offset: const Offset(0, 4),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Department Code: ${details.code}', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
					const SizedBox(height: 4),
					Text(details.description, style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.w900, fontSize: 20)),
					const SizedBox(height: 12),
					const Divider(),
					const SizedBox(height: 12),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							_buildBudgetColumn('NEP ${widget.year}', comparison.nep.amountPesos, Colors.blueGrey),
							_buildBudgetColumn('GAA ${widget.year}', comparison.gaa.amountPesos, const Color(0xFF1565C0)),
						],
					),
					const SizedBox(height: 16),
					Row(
						children: [
							_buildChangeCard('Insertions', _formatLargeNumber(insertions, showSign: true), insertions >= 0 ? Colors.green.shade700 : Colors.red.shade700, Icons.add_circle_outline_rounded),
							const SizedBox(width: 10),
							_buildChangeCard('Change', '${changePercent.toStringAsFixed(2)}%', changePercent >= 0 ? Colors.green.shade700 : Colors.red.shade700, Icons.change_circle_outlined),
						],
					)
				],
			),
		);
	}

	Widget _buildBudgetColumn(String label, num value, Color color) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
				const SizedBox(height: 2),
				Text(_formatLargeNumber(value), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22)),
			],
		);
	}

	Widget _buildChangeCard(String label, String value, Color color, IconData icon) {
		return _buildStatCard(label, value, icon, color);
	}

	Widget _buildStats(DepartmentDetails details) {
		final stats = details.statistics;
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				_buildMiniStat('Agencies', stats.totalAgencies, const Color(0xFF1565C0)),
				_buildMiniStat('Op. Classes', stats.totalOperatingUnitClasses, const Color(0xFF1976D2)),
				_buildMiniStat('Regions', stats.totalRegions, const Color(0xFF1E88E5)),
				_buildMiniStat('Sources', stats.totalFundingSources, const Color(0xFF42A5F5)),
				_buildMiniStat('Expenses', stats.totalExpenseClassifications, const Color(0xFF64B5F6)),
				_buildMiniStat('Projects', stats.totalProjects, const Color(0xFF2E7D32))
			],
		);
	}

	Widget _buildMiniStat(String label, int value, Color color) {
		return Column(
			children: [
				Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
				const SizedBox(height: 2),
				Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w700)),
			],
		);
	}

	Widget _buildStatCard(String label, String value, IconData icon, Color color) {
		return Expanded(
			child: Container(
				margin: const EdgeInsets.only(right: 0),
				padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
				decoration: BoxDecoration(
					color: color.withOpacity(0.1),
					borderRadius: BorderRadius.circular(8),
				),
				child: Row(
					children: [
						Icon(icon, color: color, size: 24),
						const SizedBox(width: 8),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
								Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
							],
						),
					],
				),
			),
		);
	}

	Widget _buildSectionTitle(String title) {
		return Text(title,
				style: const TextStyle(
					fontSize: 18,
					fontWeight: FontWeight.w800,
					color: Color(0xFF0D47A1),
					letterSpacing: -0.2,
				));
	}

	Widget _buildAgencies(DepartmentDetails details) {
		if (details.agencies.isEmpty) {
			return _buildEmptyCard('No agencies found.');
		}

		return Column(
			children: details.agencies.map((agency) {
				return _buildAgencyCard(agency);
			}).toList(),
		);
	}

	Widget _buildAgencyCard(Agency agency) {
		return Container(
			margin: const EdgeInsets.only(top: 10),
			padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(10),
				border: Border.all(
					color: const Color(0xFF1565C0).withOpacity(0.08),
					width: 1,
				),
				boxShadow: [
					BoxShadow(
						color: const Color(0xFF1565C0).withOpacity(0.07),
						blurRadius: 10,
						offset: const Offset(0, 2),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					Text(agency.description, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0D47A1))),
					const SizedBox(height: 2),
					Text('Code: ${agency.code}${agency.uacsCode != null ? " | UACS: ${agency.uacsCode}" : ""}', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
					const SizedBox(height: 8),
					Row(
						children: [
							Expanded(child: Text('NEP: ${_formatLargeNumber(agency.nep.amountPesos)}', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700))),
							Expanded(child: Text('GAA: ${_formatLargeNumber(agency.gaa.amountPesos)}', textAlign: TextAlign.end, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700))),
						],
					),
				],
			),
		);
	}

	Widget _buildOperatingUnitClasses(DepartmentDetails details) {
		if (details.operatingUnitClasses.isEmpty) {
			return _buildEmptyCard('No operating unit classes found.');
		}
		return Column(
			children: details.operatingUnitClasses.map((ouc) => _buildOperatingUnitClassCard(ouc)).toList(),
		);
	}

	Widget _buildOperatingUnitClassCard(OperatingUnitClass ouc) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1976D2).withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ouc.description, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0D47A1))),
          const SizedBox(height: 2),
          Text(
            'Code: ${ouc.code}${ouc.operatingUnitCount != null ? " | Units: ${ouc.operatingUnitCount}" : ""}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: Text('NEP: ${_formatLargeNumber(ouc.nep.amountPesos)}', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700))),
              Expanded(
                  child: Text(
                'GAA: ${_formatLargeNumber(ouc.gaa.amountPesos)}',
                textAlign: TextAlign.end,
                style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700),
              )),
            ],
          ),
        ],
      ),
    );
  }

	Widget _buildRegions(DepartmentDetails details) {
		if (details.regions.isEmpty) {
			return _buildEmptyCard('No regions found.');
		}
		return Column(
			children: details.regions.map((region) {
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
            description = 'Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)';
            break;
          case '16':
            description = 'Region XIII - Caraga';
            break;
          case '17':
            description = 'Region IV-B - MIMAROPA';
            break;
          default:
            description = region.description ?? 'N/A';
        }
        return _buildInfoCard(
          title: description,
          subtitle: 'Code: ${region.code}',
          trailing: _formatLargeNumber(region.gaa.amountPesos), // Corrected from budgetPesos
          icon: Icons.location_on_rounded,
          color: const Color(0xFF1E88E5),
        );
      }).toList(),
		);
	}

	Widget _buildFundingSources(DepartmentDetails details) {
		if (details.fundingSources.isEmpty) {
			return _buildEmptyCard('No funding sources found.');
		}
		return Column(
			children: details.fundingSources
					.map((fs) => _buildFundingSourceCard(fs))
					.toList(),
		);
	}

	Widget _buildFundingSourceCard(FundSource fs) {
		// The combined details already contain the correct NEP and GAA budgets.
		// fs.totalBudget holds NEP, and fs.totalBudgetPesos holds GAA.
		final nepText = 'NEP: ${_formatLargeNumber(fs.totalBudget)}';
		final gaaText = 'GAA: ${_formatLargeNumber(fs.totalBudgetPesos)}';

		return Container(
			margin: const EdgeInsets.only(top: 10),
			padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(10),
				border: Border.all(
					color: const Color(0xFF42A5F5).withOpacity(0.08),
					width: 1,
				),
				boxShadow: [
					BoxShadow(
						color: const Color(0xFF42A5F5).withOpacity(0.07),
						blurRadius: 10,
						offset: const Offset(0, 2),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(fs.description, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0D47A1))),
					const SizedBox(height: 2),
					Text('UACS: ${fs.uacsCode} ${fs.clusterDescription ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
					const SizedBox(height: 8),
					Row(
						children: [
							Expanded(child: Text(nepText, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700))),
							Expanded(child: Text(gaaText, textAlign: TextAlign.end, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700))),
						],
					),
				],
			),
		);
	}
  

  Widget _buildExpenseCategories(DepartmentDetails details) {
		if (details.expenseClassifications.isEmpty) {
			return _buildEmptyCard('No expense categories found.');
		}
		return Column(
			children: details.expenseClassifications.map((ec) => _buildInfoCard(
				title: ec.description,
				subtitle: 'Code: ${ec.code}',
				trailing: _formatLargeNumber(ec.gaa.amountPesos),
				icon: Icons.category_rounded,
				color: const Color(0xFF64B5F6),
			)).toList(),
		);
  }


	Widget _buildEmptyCard(String message) {
		return Container(
			margin: const EdgeInsets.symmetric(vertical: 10),
			padding: const EdgeInsets.all(20),
			decoration: BoxDecoration(
				color: Colors.grey.shade100,
				borderRadius: BorderRadius.circular(10),
			),
			child: Row(
				children: [
					Icon(Icons.inbox_rounded, size: 28, color: Colors.grey.shade400),
					const SizedBox(width: 12),
					Expanded(
						child: Text(
							message,
							style: TextStyle(
								color: Colors.grey[700],
								fontSize: 14,
								fontWeight: FontWeight.w600,
							),
						),
					),
				],
			),
		);
	}

	String _formatLargeNumber(num? number, {bool showSign = false}) {
		if (number == null || number == 0) return '₱0';
		String sign = '';
		if (showSign) {
			if (number > 0) sign = '+';
			// Negative sign is handled by default
		}

		final absNumber = number.abs();
		if (absNumber >= 1e12) return '$sign₱${(absNumber / 1e12).toStringAsFixed(2)}T';
		if (absNumber >= 1e9) return '$sign₱${(absNumber / 1e9).toStringAsFixed(2)}B';
		if (absNumber >= 1e6) return '$sign₱${(absNumber / 1e6).toStringAsFixed(2)}M';
		return '$sign₱${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
	}
}

Widget _buildInfoCard({
  required String title,
  String? subtitle,
  String? trailing,
  Widget? trailingWidget,
  IconData? icon,
  Color? color,
}) {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: (color ?? Colors.grey).withOpacity(0.08), width: 1),
      boxShadow: [
        BoxShadow(color: (color ?? Colors.grey).withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color ?? Colors.blue, size: 24),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0D47A1))),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ),
        if (trailingWidget != null) trailingWidget,
        if (trailing != null && trailing.isNotEmpty && trailingWidget == null)
          Text(trailing, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
