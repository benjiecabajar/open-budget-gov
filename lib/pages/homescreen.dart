import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:budget_gov/model/list_of_departments.dart';
import 'package:budget_gov/service/departments.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String _selectedYear = '2025';
  DateTime? _selectedDate;
  String _selectedType = 'NEP';
  List<ListOfAllDepartmets>? _departments;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
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
      setState(() {
        _departments = departments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        _selectedDate = args.value;
        _selectedYear = '${args.value.year}';
      }
    });
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            height: 400,
            width: 300,
            child: SfDateRangePicker(
              view: DateRangePickerView.decade,
              allowViewNavigation: false,
              selectionMode: DateRangePickerSelectionMode.single,
              initialSelectedDate: _selectedDate,
              onSelectionChanged: _onSelectionChanged,
              showActionButtons: true,
              onSubmit: (Object? value) {
                Navigator.pop(context);
                _fetchDepartments();
              },
              onCancel: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Gov'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildYearTypeCard(),
              const SizedBox(height: 16),
              _buildBodyContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearTypeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  'Year: $_selectedYear',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'NEP', child: Text('NEP')),
                    DropdownMenuItem(value: 'GAA', child: Text('GAA')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedType = newValue;
                      });
                      _fetchDepartments();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_errorMessage != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_departments != null && _departments!.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _departments!.length,
        itemBuilder: (context, index) {
          final dept = _departments![index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ExpansionTile(
              title: Text(
                dept.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Code: ${dept.code}'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Total Budget',
                        '₱${_formatNumber(dept.totalBudgetPesos)}',
                      ),
                      _buildInfoRow(
                        'Budget (in thousands)',
                        '${_formatNumber(dept.totalBudget)}',
                      ),
                      _buildInfoRow(
                        '% of Total Budget',
                        '${dept.percentOfTotalBudget.toStringAsFixed(2)}%',
                      ),
                      _buildInfoRow('Total Agencies', '${dept.totalAgencies}'),
                      const Divider(),
                      _buildInfoRow(
                        'GAA Budget',
                        '₱${_formatNumber(dept.totalBudgetGaaPesos)}',
                      ),
                      _buildInfoRow(
                        'GAA (in thousands)',
                        '${_formatNumber(dept.totalBudgetGaa)}',
                      ),
                      _buildInfoRow(
                        '% Difference (NEP-GAA)',
                        '${dept.percentDifferenceNepGaa.toStringAsFixed(2)}%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No departments found')),
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
