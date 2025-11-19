import 'package:flutter/material.dart';
import 'package:budget_gov/model/dep_details.dart';
import 'package:budget_gov/service/dep_details_service.dart';
import 'package:budget_gov/model/funds_sources.dart' as fund_model;
import 'package:budget_gov/service/fund_sources_service.dart';
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
	late Future<List<dynamic>> _detailsFuture;

	@override
	void initState() {
		super.initState();
		// Fetch combined details for display, and NEP/GAA separately for the header comparison
		_detailsFuture = Future.wait([
			fetchDepartmentDetails(code: widget.departmentCode, year: widget.year, combineBudgets: true), // This gets the merged data
			fetchDepartmentDetails(code: widget.departmentCode, year: widget.year, type: 'NEP'), // This gets just NEP for the header
    ]);
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
			body: FutureBuilder<List<dynamic>>(
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
						// The first item is the combined details for the main view
						final displayDetails = snapshot.data![0] as DepartmentDetails; // Our new combined object
						final nepDetails = snapshot.data![1] as DepartmentDetails; // Just for the header
						final gaaDetails = displayDetails; // The combined object is based on GAA totals

						return SingleChildScrollView(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									_buildComparisonHeader(nepDetails, gaaDetails),
									const SizedBox(height: 18),
									_buildStats(displayDetails),
									const SizedBox(height: 24),
									_buildSectionTitle('Agencies'),
									_buildAgencies(displayDetails), // Now only needs one parameter
									const SizedBox(height: 24),
									_buildSectionTitle('Operating Units'),
									_buildOperatingUnits(displayDetails),
									const SizedBox(height: 24),
									_buildSectionTitle('Regions'),
									_buildRegions(displayDetails),
									const SizedBox(height: 24),
									_buildSectionTitle('Funding Sources'),
									_buildFundingSources(displayDetails),
									const SizedBox(height: 24),
									_buildSectionTitle('Expense Categories'),
									_buildExpenseCategories(displayDetails),
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

	Widget _buildComparisonHeader(DepartmentDetails nep, DepartmentDetails gaa) {
		final insertions = gaa.totalBudgetPesos - nep.totalBudgetPesos;
		final changePercent = nep.totalBudgetPesos == 0 ? 0.0 : (insertions / nep.totalBudgetPesos) * 100;

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
					Text('Department Code: ${gaa.code}', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
					const SizedBox(height: 4),
					Text(gaa.description, style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.w900, fontSize: 20)),
					const SizedBox(height: 12),
					const Divider(),
					const SizedBox(height: 12),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							_buildBudgetColumn('NEP ${widget.year}', nep.totalBudgetPesos, Colors.blueGrey),
							_buildBudgetColumn('GAA ${widget.year}', gaa.totalBudgetPesos, const Color(0xFF1565C0)),
						],
					),
					const SizedBox(height: 16),
					Row(
						children: [
							_buildChangeCard('Insertions', _formatLargeNumber(insertions, showSign: true), insertions >= 0 ? Colors.green.shade700 : Colors.red.shade700, Icons.add_circle_outline_rounded),
							const SizedBox(width: 12),
							_buildChangeCard('Change', '${changePercent.toStringAsFixed(2)}%', changePercent >= 0 ? Colors.green.shade700 : Colors.red.shade700, Icons.change_circle_outlined),
						],
					)
				],
			),
		);
	}

	Widget _buildBudgetColumn(String label, int value, Color color) {
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
				_buildMiniStat('Op. Units', stats.totalOperatingUnits, const Color(0xFF1976D2)),
				_buildMiniStat('Regions', stats.totalRegions, const Color(0xFF1E88E5)),
				_buildMiniStat('Sources', stats.totalFundingSources, const Color(0xFF42A5F5)),
				_buildMiniStat('Expenses', stats.totalExpenseCategories, const Color(0xFF64B5F6)),
				_buildMiniStat('Projects', stats.totalProjects, const Color(0xFF2E7D32)),
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

		// The details object now contains agencies with combined budgets.
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
					Text('UACS: ${agency.uacsCode}', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
					
				],
			),
		);
	}

	Widget _buildOperatingUnits(DepartmentDetails details) {
		if (details.operatingUnits.isEmpty) {
			return _buildEmptyCard('No operating units found.');
		}

		// The operating units in `details` now have combined budgets from the service.
		// We can directly map over them.
		return Column(
			children: details.operatingUnits.map((ou) => _buildOperatingUnitCard(ou)).toList(),
		);
	}

	Widget _buildOperatingUnitCard(OperatingUnit ou) {
    // This card now uses the summary data from DepartmentDetails.
    // The budgetPesos here corresponds to the selected type (GAA in this case).
    final nepText = (ou.nepBudgetPesos == null || ou.nepBudgetPesos == 0)
        ? 'NEP: '
        : 'NEP: ${_formatLargeNumber(ou.nepBudgetPesos)}';
    final gaaText = (ou.gaaBudgetPesos == null || ou.gaaBudgetPesos == 0)
        ? 'GAA: '
        : 'GAA: ${_formatLargeNumber(ou.gaaBudgetPesos)}';

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF1976D2).withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ou.description,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF0D47A1))),
          const SizedBox(height: 2),
          Text('UACS: ${ou.uacsCode} | Agency: ${ou.agencyCode}',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: Text(nepText,
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w700))),
              Expanded(
                  child: Text(gaaText,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w700))),
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
			children: details.regions.map((r) => _buildInfoCard(
				title: r.description,
				subtitle: 'Code: ${r.code}',
				trailing: _formatLargeNumber(r.budgetPesos),
				icon: Icons.location_on_rounded,
				color: const Color(0xFF1E88E5),
			)).toList(),
		);
	}

	Widget _buildFundingSources(DepartmentDetails details) {
		if (details.fundingSources.isEmpty) {
			return _buildEmptyCard('No funding sources found.');
		}
		return Column(
			children: details.fundingSources.map((fs) => _buildFundingSourceCard(fs)).toList(),
		);
	}

	Widget _buildFundingSourceCard(FundingSource fs) {
		// fetch NEP and GAA totals for this funding source (uses fund_sources_service)
		final future = Future.wait([
			fetchFundSourceDetails(code: fs.uacsCode, year: widget.year, type: 'NEP'),
			fetchFundSourceDetails(code: fs.uacsCode, year: widget.year, type: 'GAA'),
		]);

		return FutureBuilder<List<fund_model.FundSource>>(
			future: future,
			builder: (context, snapshot) {
				// prepare display values for NEP/GAA, hide when zero to avoid showing '₱0'
				String nepText = '';
				String gaaText = '';
				if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
					final nep = snapshot.data![0];
					final gaa = snapshot.data![1];
					nepText = (nep.totalBudgetPesos == 0) ? '' : _formatLargeNumber(nep.totalBudgetPesos);
					gaaText = (gaa.totalBudgetPesos == 0) ? '' : _formatLargeNumber(gaa.totalBudgetPesos);
				}

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
					child: Row(
						children: [
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(fs.description, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0D47A1))),
										const SizedBox(height: 2),
										Text('UACS: ${fs.uacsCode} ${fs.fundClusterDescription ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
										const SizedBox(height: 8),
										Row(
											children: [
												Expanded(child: Text(nepText.isNotEmpty ? 'NEP: $nepText' : (snapshot.connectionState == ConnectionState.waiting ? 'NEP: Loading...' : 'NEP:'), style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700))),
												Expanded(child: Text(gaaText.isNotEmpty ? 'GAA: $gaaText' : (snapshot.connectionState == ConnectionState.waiting ? 'GAA: Loading...' : 'GAA:'), textAlign: TextAlign.end, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700))),
												],
												),
									],
								),
							),
							const SizedBox(width: 10),
							Text(fs.budgetPesos == 0 ? '' : _formatLargeNumber(fs.budgetPesos), style: TextStyle(color: const Color(0xFF42A5F5), fontWeight: FontWeight.w900, fontSize: 15)),
						],
					),
				);
			},
		);
	}

	Widget _buildExpenseCategories(DepartmentDetails details) {
		if (details.expenseCategories.isEmpty) {
			return _buildEmptyCard('No expense categories found.');
		}
		return Column(
			children: details.expenseCategories.map((ec) => _buildInfoCard(
				title: ec.description,
				subtitle: 'Code: ${ec.code}',
				trailing: _formatLargeNumber(ec.budgetPesos),
				icon: Icons.category_rounded,
				color: const Color(0xFF64B5F6),
			)).toList(),
		);
	}

	Widget _buildInfoCard({
		required String title,
		required String subtitle,
		required String trailing,
		required IconData icon,
		required Color color,
	}) {
		return Container(
			margin: const EdgeInsets.only(top: 10),
			padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(10),
				border: Border.all(
					color: color.withOpacity(0.08),
					width: 1,
				),
				boxShadow: [
					BoxShadow(
						color: color.withOpacity(0.07),
						blurRadius: 10,
						offset: const Offset(0, 2),
					),
				],
			),
			child: Row(
				children: [
					Container(
						padding: const EdgeInsets.all(10),
						decoration: BoxDecoration(
							color: color.withOpacity(0.13),
							borderRadius: BorderRadius.circular(8),
						),
						child: Icon(icon, color: color, size: 22),
					),
					const SizedBox(width: 14),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0D47A1))),
								const SizedBox(height: 2),
								Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
							],
						),
					),
					const SizedBox(width: 10),
					Text(trailing, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
				],
			),
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
