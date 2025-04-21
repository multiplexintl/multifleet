import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // Selected report type and date range
  String _selectedReportType = 'Mileage Report';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  // Available report types
  final List<String> reportTypes = [
    'Mileage Report',
    'Fuel Consumption Report',
    'Maintenance Cost Report',
    'Driver Performance Report',
    'Vehicle Utilization Report',
    'Incidents & Fines Report',
  ];

  // Sample data - in a real app this would come from your API/database
  final List<Map<String, dynamic>> vehicleReportData = [
    {
      'id': 'TRK-1234',
      'type': 'Truck',
      'mileage': 4520,
      'fuel': 670,
      'maintenance': 820,
      'utilization': 85
    },
    {
      'id': 'VAN-5678',
      'type': 'Van',
      'mileage': 3250,
      'fuel': 420,
      'maintenance': 350,
      'utilization': 75
    },
    {
      'id': 'SUV-9012',
      'type': 'SUV',
      'mileage': 2800,
      'fuel': 380,
      'maintenance': 420,
      'utilization': 90
    },
    {
      'id': 'CAR-3456',
      'type': 'Car',
      'mileage': 1950,
      'fuel': 210,
      'maintenance': 150,
      'utilization': 65
    },
    {
      'id': 'TRK-7890',
      'type': 'Truck',
      'mileage': 3870,
      'fuel': 590,
      'maintenance': 720,
      'utilization': 80
    },
    {
      'id': 'VAN-1245',
      'type': 'Van',
      'mileage': 2730,
      'fuel': 360,
      'maintenance': 290,
      'utilization': 70
    },
    {
      'id': 'CAR-5678',
      'type': 'Car',
      'mileage': 2100,
      'fuel': 230,
      'maintenance': 180,
      'utilization': 68
    },
    {
      'id': 'SUV-9876',
      'type': 'SUV',
      'mileage': 3250,
      'fuel': 420,
      'maintenance': 380,
      'utilization': 88
    },
  ];

  final List<Map<String, dynamic>> driverReportData = [
    {
      'id': 'DRV-001',
      'name': 'John Smith',
      'incidents': 0,
      'fines': 0,
      'rating': 4.8,
      'tripCount': 124
    },
    {
      'id': 'DRV-002',
      'name': 'Maria Garcia',
      'incidents': 1,
      'fines': 2,
      'rating': 4.2,
      'tripCount': 118
    },
    {
      'id': 'DRV-003',
      'name': 'James Johnson',
      'incidents': 0,
      'fines': 1,
      'rating': 4.6,
      'tripCount': 132
    },
    {
      'id': 'DRV-004',
      'name': 'Sarah Williams',
      'incidents': 2,
      'fines': 3,
      'rating': 3.9,
      'tripCount': 105
    },
    {
      'id': 'DRV-005',
      'name': 'Robert Brown',
      'incidents': 0,
      'fines': 0,
      'rating': 4.9,
      'tripCount': 128
    },
    {
      'id': 'DRV-006',
      'name': 'Lisa Davis',
      'incidents': 1,
      'fines': 1,
      'rating': 4.3,
      'tripCount': 116
    },
  ];

  final List<Map<String, dynamic>> monthlyData = [
    {
      'month': 'Jan',
      'mileage': 34500,
      'fuel': 4800,
      'maintenance': 3200,
      'incidents': 3
    },
    {
      'month': 'Feb',
      'mileage': 31200,
      'fuel': 4200,
      'maintenance': 2800,
      'incidents': 2
    },
    {
      'month': 'Mar',
      'mileage': 36800,
      'fuel': 5100,
      'maintenance': 3600,
      'incidents': 4
    },
    {
      'month': 'Apr',
      'mileage': 38500,
      'fuel': 5300,
      'maintenance': 2900,
      'incidents': 1
    },
    {
      'month': 'May',
      'mileage': 37200,
      'fuel': 5000,
      'maintenance': 3100,
      'incidents': 2
    },
    {
      'month': 'Jun',
      'mileage': 39800,
      'fuel': 5500,
      'maintenance': 3800,
      'incidents': 3
    },
  ];

  bool _isGeneratingReport = false;
  bool _showAdvancedOptions = false;
  String _selectedVehicleType = 'All';
  String _selectedDriverId = 'All';

  final List<String> vehicleTypes = ['All', 'Truck', 'Van', 'SUV', 'Car'];
  final List<String> driverIds = [
    'All',
    'DRV-001',
    'DRV-002',
    'DRV-003',
    'DRV-004',
    'DRV-005',
    'DRV-006'
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportsHeader(),
              const SizedBox(height: 24),
              _buildReportFilters(isMobile),
              const SizedBox(height: 24),
              if (_showAdvancedOptions) _buildAdvancedFilters(isMobile),
              _buildReportContent(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Generate and analyze fleet performance reports',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildReportFilters(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReportTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildDateRangePicker(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildReportTypeDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDateRangePicker()),
                    ],
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAdvancedOptions = !_showAdvancedOptions;
                    });
                  },
                  icon: Icon(
                    _showAdvancedOptions
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: Colors.grey[700],
                  ),
                  label: Text(
                    'Advanced Options',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isGeneratingReport = true;
                    });

                    // Simulate report generation delay
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        _isGeneratingReport = false;
                      });
                    });
                  },
                  icon: _isGeneratingReport
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text('Generate Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Type',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedReportType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: reportTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedReportType = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Range',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              initialDateRange: _dateRange,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.blue[700]!,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _dateRange = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
                  style: TextStyle(
                    color: Colors.grey[800],
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilters(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVehicleTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildDriverDropdown(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildVehicleTypeDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDriverDropdown()),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Type',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: _selectedVehicleType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: vehicleTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedVehicleType = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDriverDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driver',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: _selectedDriverId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: driverIds.map((String id) {
              String label = id;
              if (id != 'All') {
                final driver =
                    driverReportData.firstWhere((d) => d['id'] == id);
                label = '${id} - ${driver['name']}';
              }
              return DropdownMenuItem<String>(
                value: id,
                child: Text(label),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedDriverId = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportContent(bool isMobile) {
    // Show different report content based on selected report type
    switch (_selectedReportType) {
      case 'Mileage Report':
        return _buildMileageReport(isMobile);
      case 'Fuel Consumption Report':
        return _buildFuelConsumptionReport(isMobile);
      case 'Driver Performance Report':
        return _buildDriverPerformanceReport(isMobile);
      case 'Vehicle Utilization Report':
        return _buildVehicleUtilizationReport(isMobile);
      case 'Incidents & Fines Report':
        return _buildIncidentsReport(isMobile);
      case 'Maintenance Cost Report':
      default:
        return _buildMaintenanceReport(isMobile);
    }
  }

  Widget _buildMileageReport(bool isMobile) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mileage Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          tooltip: 'Download Report',
                          onPressed: () {
                            // Implement download logic
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.print),
                          tooltip: 'Print Report',
                          onPressed: () {
                            // Implement print logic
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          // tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${monthlyData[groupIndex]['month']}: ${monthlyData[groupIndex]['mileage']} km',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= monthlyData.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  monthlyData[value.toInt()]['month'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toStringAsFixed(1)}K',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10000,
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: monthlyData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data['mileage'].toDouble(),
                              color: Colors.blue[400],
                              width: 22,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      maxY: 50000,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Vehicle Mileage Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMileageTable(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildMileageSummaryCards(isMobile),
      ],
    );
  }

  Widget _buildMileageTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Colors.grey[200]!,
        ),
        columns: const [
          DataColumn(label: Text('Vehicle ID')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Period Mileage (km)')),
          DataColumn(label: Text('Avg Daily (km)')),
          DataColumn(label: Text('Trend')),
        ],
        rows: vehicleReportData.map((data) {
          final mileage = data['mileage'];
          final days = _dateRange.duration.inDays;
          final avgDaily = (mileage / days).toStringAsFixed(1);

          return DataRow(
            cells: [
              DataCell(Text(data['id'])),
              DataCell(Text(data['type'])),
              DataCell(Text(mileage.toString())),
              DataCell(Text(avgDaily)),
              DataCell(Row(
                children: [
                  Icon(
                    mileage > 3000 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: mileage > 3000 ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mileage > 3000 ? '+' : '-'}${(mileage > 3000 ? 8.2 : 5.7).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: mileage > 3000 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMileageSummaryCards(bool isMobile) {
    final flexCount = isMobile ? 1 : 3;

    return GridView.count(
      crossAxisCount: flexCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Fleet Mileage',
          '218,000 km',
          Icons.speed,
          Colors.blue[700]!,
          '+12.5% from previous period',
          Colors.green,
        ),
        _buildSummaryCard(
          'Average Vehicle Mileage',
          '3,259 km',
          Icons.directions_car,
          Colors.purple[700]!,
          '+8.7% from previous period',
          Colors.green,
        ),
        _buildSummaryCard(
          'Highest Mileage Vehicle',
          'TRK-1234 (4,520 km)',
          Icons.emoji_events,
          Colors.amber[700]!,
          '32.3% above fleet average',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon,
      Color iconColor, String subtext, Color subtextColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  subtextColor == Colors.green
                      ? Icons.arrow_upward
                      : Icons.info_outline,
                  color: subtextColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subtext,
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelConsumptionReport(bool isMobile) {
    // Implement similar to mileage report but with fuel consumption focus
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fuel Consumption Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      tooltip: 'Download Report',
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.print),
                      tooltip: 'Print Report',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Monthly Fuel Consumption (Liters)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1000,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= monthlyData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              monthlyData[value.toInt()]['month'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000).toStringAsFixed(1)}K',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return FlSpot(
                            index.toDouble(), data['fuel'].toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.orange[700],
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange[200]!.withOpacity(0.3),
                      ),
                    ),
                  ],
                  minY: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Vehicle Fuel Consumption Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildFuelConsumptionTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelConsumptionTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Colors.grey[200]!,
        ),
        columns: const [
          DataColumn(label: Text('Vehicle ID')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Fuel Used (L)')),
          DataColumn(label: Text('Consumption (L/100km)')),
          DataColumn(label: Text('Efficiency')),
        ],
        rows: vehicleReportData.map((data) {
          final fuel = data['fuel'];
          final mileage = data['mileage'];
          final consumption = ((fuel / mileage) * 100).toStringAsFixed(2);

          // Determine efficiency rating
          String efficiency;
          Color efficiencyColor;
          if (double.parse(consumption) < 12) {
            efficiency = 'Excellent';
            efficiencyColor = Colors.green;
          } else if (double.parse(consumption) < 15) {
            efficiency = 'Good';
            efficiencyColor = Colors.blue;
          } else if (double.parse(consumption) < 18) {
            efficiency = 'Average';
            efficiencyColor = Colors.orange;
          } else {
            efficiency = 'Poor';
            efficiencyColor = Colors.red;
          }

          return DataRow(
            cells: [
              DataCell(Text(data['id'])),
              DataCell(Text(data['type'])),
              DataCell(Text('$fuel L')),
              DataCell(Text(consumption)),
              DataCell(Text(
                efficiency,
                style: TextStyle(
                  color: efficiencyColor,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMaintenanceReport(bool isMobile) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Maintenance Cost Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          tooltip: 'Download Report',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.print),
                          tooltip: 'Print Report',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.blue[400],
                          value: 35,
                          title: '35%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red[400],
                          value: 25,
                          title: '25%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.green[400],
                          value: 20,
                          title: '20%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.purple[400],
                          value: 15,
                          title: '15%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.amber[400],
                          value: 5,
                          title: '5%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Regular Service', Colors.blue[400]!),
                    const SizedBox(width: 16),
                    _buildLegendItem('Repairs', Colors.red[400]!),
                    const SizedBox(width: 16),
                    _buildLegendItem('Tyres', Colors.green[400]!),
                    const SizedBox(width: 16),
                    _buildLegendItem('Parts', Colors.purple[400]!),
                    const SizedBox(width: 16),
                    _buildLegendItem('Other', Colors.amber[400]!),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  'Maintenance Cost Details by Vehicle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMaintenanceTable(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildMaintenanceSummaryCards(isMobile),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Colors.grey[200]!,
        ),
        columns: const [
          DataColumn(label: Text('Vehicle ID')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Total Cost (\$)')),
          DataColumn(label: Text('Services')),
          DataColumn(label: Text('Cost/km (\$/km)')),
        ],
        rows: vehicleReportData.map((data) {
          final maintenanceCost = data['maintenance'];
          final mileage = data['mileage'];
          final costPerKm = (maintenanceCost / mileage).toStringAsFixed(2);

          return DataRow(
            cells: [
              DataCell(Text(data['id'])),
              DataCell(Text(data['type'])),
              DataCell(Text('\$$maintenanceCost')),
              DataCell(Text('${(maintenanceCost / 150).round()}')),
              DataCell(Text('\$$costPerKm')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMaintenanceSummaryCards(bool isMobile) {
    final flexCount = isMobile ? 1 : 3;

    return GridView.count(
      crossAxisCount: flexCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Maintenance Cost',
          '\$12,560',
          Icons.build,
          Colors.indigo[700]!,
          '-5.2% from previous period',
          Colors.green,
        ),
        _buildSummaryCard(
          'Total Service Visits',
          '48',
          Icons.event,
          Colors.teal[700]!,
          '2 preventive, 46 corrective',
          Colors.blue,
        ),
        _buildSummaryCard(
          'Average Cost per Vehicle',
          '\$1,570',
          Icons.attach_money,
          Colors.red[700]!,
          '8.3% above fleet average',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildDriverPerformanceReport(bool isMobile) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Driver Performance Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          tooltip: 'Download Report',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.print),
                          tooltip: 'Print Report',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Driver Rating Comparison',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          // tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final driver = driverReportData[groupIndex];
                            return BarTooltipItem(
                              '${driver['name']}: ${driver['rating']}',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 ||
                                  value >= driverReportData.length) {
                                return const SizedBox.shrink();
                              }
                              final driver = driverReportData[value.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  driver['id']
                                      .toString()
                                      .replaceAll('DRV-', ''),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: driverReportData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final driver = entry.value;

                        // Determine color based on rating
                        Color barColor;
                        if (driver['rating'] >= 4.5) {
                          barColor = Colors.green[400]!;
                        } else if (driver['rating'] >= 4.0) {
                          barColor = Colors.blue[400]!;
                        } else if (driver['rating'] >= 3.5) {
                          barColor = Colors.amber[400]!;
                        } else {
                          barColor = Colors.red[400]!;
                        }

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: driver['rating'].toDouble(),
                              color: barColor,
                              width: 22,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      maxY: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Driver Performance Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDriverPerformanceTable(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildDriverSummaryCards(isMobile),
      ],
    );
  }

  Widget _buildDriverPerformanceTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Colors.grey[200]!,
        ),
        columns: const [
          DataColumn(label: Text('Driver ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Rating')),
          DataColumn(label: Text('Incidents')),
          DataColumn(label: Text('Fines')),
          DataColumn(label: Text('Trips')),
        ],
        rows: driverReportData.map((data) {
          return DataRow(
            cells: [
              DataCell(Text(data['id'])),
              DataCell(Text(data['name'])),
              DataCell(Row(
                children: [
                  Text(
                    data['rating'].toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: data['rating'] >= 4.5
                          ? Colors.green
                          : data['rating'] >= 4.0
                              ? Colors.blue
                              : data['rating'] >= 3.5
                                  ? Colors.amber
                                  : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                ],
              )),
              DataCell(Text(data['incidents'].toString())),
              DataCell(Text(data['fines'].toString())),
              DataCell(Text(data['tripCount'].toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDriverSummaryCards(bool isMobile) {
    final flexCount = isMobile ? 1 : 3;

    return GridView.count(
      crossAxisCount: flexCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Average Driver Rating',
          '4.45',
          Icons.star,
          Colors.amber[700]!,
          '+0.2 from previous period',
          Colors.green,
        ),
        _buildSummaryCard(
          'Total Incidents',
          '4',
          Icons.report_problem,
          Colors.red[700]!,
          '-25% from previous period',
          Colors.green,
        ),
        _buildSummaryCard(
          'Top Performer',
          'Robert Brown (4.9)',
          Icons.emoji_events,
          Colors.blue[700]!,
          '128 trips with no incidents',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildVehicleUtilizationReport(bool isMobile) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vehicle Utilization Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          tooltip: 'Download Report',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.print),
                          tooltip: 'Print Report',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Fleet Utilization Rate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= monthlyData.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  monthlyData[value.toInt()]['month'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, 76),
                            FlSpot(1, 72),
                            FlSpot(2, 80),
                            FlSpot(3, 85),
                            FlSpot(4, 82),
                            FlSpot(5, 88),
                          ],
                          isCurved: true,
                          color: Colors.purple[700],
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.purple[200]!.withOpacity(0.3),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Vehicle Utilization Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildUtilizationTable(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildUtilizationSummaryCards(isMobile),
      ],
    );
  }

  Widget _buildUtilizationTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Colors.grey[200]!,
        ),
        columns: const [
          DataColumn(label: Text('Vehicle ID')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Utilization Rate')),
          DataColumn(label: Text('Active Days')),
          DataColumn(label: Text('Status')),
        ],
        rows: vehicleReportData.map((data) {
          final utilization = data['utilization'];

          // Determine status
          String status;
          Color statusColor;
          if (utilization >= 85) {
            status = 'Optimal';
            statusColor = Colors.green;
          } else if (utilization >= 75) {
            status = 'Good';
            statusColor = Colors.blue;
          } else if (utilization >= 65) {
            status = 'Average';
            statusColor = Colors.amber;
          } else {
            status = 'Underutilized';
            statusColor = Colors.red;
          }

          return DataRow(
            cells: [
              DataCell(Text(data['id'])),
              DataCell(Text(data['type'])),
              DataCell(
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                        value: utilization / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          utilization >= 85
                              ? Colors.green
                              : utilization >= 75
                                  ? Colors.blue
                                  : utilization >= 65
                                      ? Colors.amber
                                      : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$utilization%'),
                  ],
                ),
              ),
              DataCell(Text('${(utilization * 0.3).round()}')),
              DataCell(Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUtilizationSummaryCards(bool isMobile) {
    final flexCount = isMobile ? 1 : 3;

    return GridView.count(
      crossAxisCount: flexCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Average Utilization',
          '78%',
          Icons.trending_up,
          Colors.blue[700]!,
          '+6% from previous period',
          Colors.green,
        ),
        _buildSummaryCard(
          'Highest Utilization',
          'SUV-9012 (90%)',
          Icons.star,
          Colors.purple[700]!,
          'Excellent performance',
          Colors.blue,
        ),
        _buildSummaryCard(
          'Underutilized Vehicles',
          '1',
          Icons.warning,
          Colors.amber[700]!,
          'Needs attention',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildIncidentsReport(bool isMobile) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Incidents & Fines Report',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          tooltip: 'Download Report',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.print),
                          tooltip: 'Print Report',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Monthly Incidents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          // tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${monthlyData[groupIndex]['month']}: ${monthlyData[groupIndex]['incidents']} incidents',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= monthlyData.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  monthlyData[value.toInt()]['month'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: monthlyData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data['incidents'].toDouble(),
                              color: Colors.red[400],
                              width: 22,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      maxY: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Driver Incidents & Fines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildIncidentsTable(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildIncidentsSummaryCards(isMobile),
      ],
    );
  }

  Widget _buildIncidentsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Colors.grey[200]!,
        ),
        columns: const [
          DataColumn(label: Text('Driver ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Incidents')),
          DataColumn(label: Text('Fines')),
          DataColumn(label: Text('Total Amount (\$)')),
          DataColumn(label: Text('Status')),
        ],
        rows: driverReportData.map((data) {
          final incidents = data['incidents'];
          final fines = data['fines'];
          final totalAmount = fines * 150; // Assuming average fine of $150

          String status;
          Color statusColor;
          if (incidents == 0 && fines == 0) {
            status = 'Excellent';
            statusColor = Colors.green;
          } else if (incidents <= 1 && fines <= 1) {
            status = 'Good';
            statusColor = Colors.blue;
          } else if (incidents <= 1 && fines <= 2) {
            status = 'Average';
            statusColor = Colors.amber;
          } else {
            status = 'Needs Improvement';
            statusColor = Colors.red;
          }

          return DataRow(
            cells: [
              DataCell(Text(data['id'])),
              DataCell(Text(data['name'])),
              DataCell(Text(incidents.toString(),
                  style: TextStyle(
                    color: incidents > 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ))),
              DataCell(Text(fines.toString(),
                  style: TextStyle(
                    color: fines > 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ))),
              DataCell(Text(totalAmount > 0 ? '\$$totalAmount' : '-')),
              DataCell(Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIncidentsSummaryCards(bool isMobile) {
    final flexCount = isMobile ? 1 : 3;

    return GridView.count(
      crossAxisCount: flexCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Incidents',
          '4',
          Icons.warning,
          Colors.red[700]!,
          '-25% from previous period',
          Colors.green,
        ),
        _buildSummaryCard(
          'Total Fines',
          '7',
          Icons.receipt,
          Colors.amber[700]!,
          'Amount: \$1,050',
          Colors.blue,
        ),
        _buildSummaryCard(
          'Perfect Record Drivers',
          '2',
          Icons.verified,
          Colors.green[700]!,
          '33% of total drivers',
          Colors.blue,
        ),
      ],
    );
  }
}

class ReportsPageContent extends StatelessWidget {
  const ReportsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Generate and view detailed reports for your fleet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _reportCard(
                  'Fleet Overview',
                  Icons.directions_car,
                  'Complete overview of all vehicles',
                ),
                _reportCard(
                  'Maintenance Records',
                  Icons.build,
                  'Service history and upcoming maintenance',
                ),
                _reportCard(
                  'Assignment History',
                  Icons.assignment,
                  'Vehicle assignment records',
                ),
                _reportCard(
                  'Fine Records',
                  Icons.warning,
                  'Traffic violations and fines',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(String title, IconData icon, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.blue[800],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
              child: Text('Generate Report'),
            ),
          ],
        ),
      ),
    );
  }
}
