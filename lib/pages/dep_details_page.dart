import 'package:budget_gov/model/funds_sources.dart';
import 'package:budget_gov/service/fund_sources_service.dart';
import 'package:flutter/material.dart';
import 'package:budget_gov/model/dep_details.dart';
import 'package:budget_gov/service/expenses_service.dart';
import 'package:budget_gov/model/expenses.dart';
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
  late Future<List<Expense>> _expensesFuture;

	@override
	void initState() {
		super.initState();
		_detailsFuture = fetchDepartmentDetails(
			code: widget.departmentCode,
			year: widget.year,
      combineBudgets: true,
		);
    _expensesFuture = fetchExpenseCategories(
        year: widget.year, departmentCode: widget.departmentCode);
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
									_buildSectionTitle('Expense Classifications'),
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
				Text(_formatNumber(value), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
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
					Text('Code: ${agency.code}',
							style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(ouc.description, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0D47A1))),
              ),
              if (ouc.status != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (ouc.status?.toLowerCase() == 'active' ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ouc.status!,
                    style: TextStyle(
                      color: ouc.status?.toLowerCase() == 'active' ? Colors.green.shade800 : Colors.red.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
        final nepAmount = region.nep.amountPesos;
        final gaaAmount = region.gaa.amountPesos;
        final insertion = gaaAmount - nepAmount;
        final percentChange = (nepAmount != 0) ? (insertion / nepAmount) * 100 : 0.0;

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


        return Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF1E88E5).withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(description,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF0D47A1))),
                const SizedBox(height: 2),
                Text('Code: ${region.code}',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: Text('NEP: ${_formatLargeNumber(nepAmount)}',
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w700))),
                    Expanded(
                        child: Text('GAA: ${_formatLargeNumber(gaaAmount)}',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w700))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildChangeCard('Insertion', _formatLargeNumber(insertion, showSign: true), insertion >= 0 ? Colors.green.shade700 : Colors.red.shade700, Icons.add_circle_outline_rounded),
                    const SizedBox(width: 10),
                    _buildChangeCard('Change', '${percentChange.toStringAsFixed(2)}%', percentChange >= 0 ? Colors.green.shade700 : Colors.red.shade700, Icons.change_circle_outlined),
                  ],
                )
              ],
            ));
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
		// fetch NEP and GAA totals for this funding source (uses fund_sources_service)
		final future = Future.wait([
			fetchFundSourceDetails(code: fs.uacsCode, year: widget.year, type: 'NEP'),
			fetchFundSourceDetails(code: fs.uacsCode, year: widget.year, type: 'GAA'),
		]);

		return FutureBuilder<List<FundSource>>(
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
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(fs.description, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0D47A1))),
							const SizedBox(height: 2),
							Text('UACS: ${fs.uacsCode} ${fs.clusterDescription ?? ''}', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
							const SizedBox(height: 8),
							Row(
								children: [
									Expanded(
										child: Text(
											nepText.isNotEmpty ? 'NEP: $nepText' : (snapshot.connectionState == ConnectionState.waiting ? 'NEP: Loading...' : 'NEP:'),
											style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700),
										),
									),
									Expanded(
										child: Text(
											gaaText.isNotEmpty ? 'GAA: $gaaText' : (snapshot.connectionState == ConnectionState.waiting ? 'GAA: Loading...' : 'GAA:'),
											textAlign: TextAlign.end,
											style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700),
										),
									),
								],
							),
						],
					),
				);
			},
		);
	}

  Widget _buildExpenseCategories(DepartmentDetails details) {
    return FutureBuilder<List<Expense>>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildEmptyCard('Could not load expense categories.');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard('No expense categories found.');
        }

        final expenses = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed breakdown by expense category',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 10),
            ...expenses.map((expense) => _buildExpenseCard(expense)),
          ],
        );
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0D47A1))),
        subtitle: Text('${expense.subClasses.length} sub-classifications', style: TextStyle(color: Colors.grey[600])),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildBudgetColumn('NEP Budget', expense.nep.amountPesos, Colors.blueGrey)),
                    Expanded(child: _buildBudgetColumn('GAA Budget', expense.gaa.amountPesos, const Color(0xFF1565C0))),
                  ],
                ),
                const Divider(height: 20),
                ...expense.subClasses.map((subClass) => _buildSubClassTile(subClass)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubClassTile(ExpenseSubClass subClass) {
    return ExpansionTile(
      title: Text(subClass.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text('${subClass.groups.length} groups', style: TextStyle(color: Colors.grey[600])),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 10),
      children: [
        Row(
          children: [
            Expanded(child: Text('NEP: ${_formatLargeNumber(subClass.nep.amountPesos)}', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700))),
            Expanded(child: Text('GAA: ${_formatLargeNumber(subClass.gaa.amountPesos)}', textAlign: TextAlign.end, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w700))),
          ],
        ),
        const SizedBox(height: 10),
        ...subClass.groups.map((group) => _buildGroupTile(group)),
      ],
    );
  }

  Widget _buildGroupTile(ExpenseGroup group) {
    return ExpansionTile(
      title: Text(group.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text('${group.objects.length} objects', style: TextStyle(color: Colors.grey[600])),
      childrenPadding: const EdgeInsets.only(left: 16, bottom: 10, right: 16),
      children: group.objects.map((object) => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(object.description, style: const TextStyle(fontSize: 12))),
            Text(_formatLargeNumber(object.gaa.amountPesos), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
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

	String _formatNumber(num? number) {
		if (number == null) return "0";
		return number.toStringAsFixed(0).replaceAllMapped(
					RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
					(Match m) => '${m[1]},',
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
