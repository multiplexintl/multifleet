import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Sample data - in a real app, this would come from your API/database
  final List<VehicleStatus> vehicleStatusData = [
    VehicleStatus('Operational', 65, Colors.green),
    VehicleStatus('Maintenance', 20, Colors.orange),
    VehicleStatus('Out of Service', 10, Colors.red),
    VehicleStatus('In Transit', 5, Colors.blue),
  ];

  final List<Map<String, dynamic>> fuelConsumptionData = [
    {'month': 'Jan', 'consumption': 2800},
    {'month': 'Feb', 'consumption': 2200},
    {'month': 'Mar', 'consumption': 2500},
    {'month': 'Apr', 'consumption': 3000},
    {'month': 'May', 'consumption': 2800},
    {'month': 'Jun', 'consumption': 3200},
  ];

  final List<MaintenanceRecord> upcomingMaintenance = [
    MaintenanceRecord(
        'TRK-1234', 'Oil Change', DateTime.now().add(const Duration(days: 2))),
    MaintenanceRecord('VAN-5678', 'Tyre Rotation',
        DateTime.now().add(const Duration(days: 3))),
    MaintenanceRecord('SUV-9012', 'Brake Inspection',
        DateTime.now().add(const Duration(days: 5))),
    MaintenanceRecord('CAR-3456', 'Full Service',
        DateTime.now().add(const Duration(days: 7))),
  ];

  final List<Map<String, dynamic>> monthlyExpenses = [
    {'category': 'Fuel', 'amount': 12500},
    {'category': 'Maintenance', 'amount': 8500},
    {'category': 'Insurance', 'amount': 6500},
    {'category': 'Fines', 'amount': 1200},
    {'category': 'Other', 'amount': 3800},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sticky Header

              _buildDashboardHeader(),
              const SizedBox(height: 24),

              // Top summary cards
              _buildSummaryCards(isMobile, isTablet),
              const SizedBox(height: 24),

              // Charts section
              _buildChartsSection(isMobile, isTablet),
              const SizedBox(height: 24),

              // Bottom section with maintenance and alerts
              _buildBottomSection(isMobile, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fleet Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Overview as of ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(bool isMobile, bool isTablet) {
    final flexCount = isMobile ? 1 : (isTablet ? 2 : 4);

    return GridView.count(
      crossAxisCount: flexCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 2.5 : 1.7,
      children: [
        _buildSummaryCard(
            'Total Vehicles', '143', Icons.directions_car, Colors.blue),
        _buildSummaryCard('Active Drivers', '98', Icons.person, Colors.green),
        _buildSummaryCard(
            'Pending Maintenance', '12', Icons.build, Colors.orange),
        _buildSummaryCard('Alerts', '7', Icons.warning, Colors.red),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fleet Status and Expense charts row
        isMobile
            ? Column(
                children: [
                  _buildVehicleStatusChart(),
                  const SizedBox(height: 16),
                  _buildMonthlyExpensesChart(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildVehicleStatusChart()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMonthlyExpensesChart()),
                ],
              ),
        const SizedBox(height: 24),

        // Fuel consumption chart
        _buildFuelConsumptionChart(),
      ],
    );
  }

  Widget _buildVehicleStatusChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: vehicleStatusData.map((data) {
                    return PieChartSectionData(
                      value: data.percentage.toDouble(),
                      title: '${data.percentage}%',
                      color: data.color,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: vehicleStatusData.map((data) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: data.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        data.status,
                        style: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${data.percentage}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyExpensesChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                      value: 12500,
                      title: '38%',
                      color: Colors.blue[400]!,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 8500,
                      title: '26%',
                      color: Colors.green[400]!,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 6500,
                      title: '20%',
                      color: Colors.purple[400]!,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 1200,
                      title: '4%',
                      color: Colors.red[400]!,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: 3800,
                      title: '12%',
                      color: Colors.orange[400]!,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildExpenseLegendItem('Fuel', Colors.blue[400]!, '\$12,500'),
                _buildExpenseLegendItem(
                    'Maintenance', Colors.green[400]!, '\$8,500'),
                _buildExpenseLegendItem(
                    'Insurance', Colors.purple[400]!, '\$6,500'),
                _buildExpenseLegendItem('Fines', Colors.red[400]!, '\$1,200'),
                _buildExpenseLegendItem(
                    'Other', Colors.orange[400]!, '\$3,800'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseLegendItem(String title, Color color, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelConsumptionChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fuel Consumption (Last 6 Months)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                          '${fuelConsumptionData[groupIndex]['month']}: ${fuelConsumptionData[groupIndex]['consumption']} L',
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
                              value >= fuelConsumptionData.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              fuelConsumptionData[value.toInt()]['month'],
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
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${value.toInt()}L',
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
                    horizontalInterval: 1000,
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: fuelConsumptionData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['consumption'].toDouble(),
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
                  maxY: 4000,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isMobile, bool isTablet) {
    return isMobile
        ? Column(
            children: [
              _buildUpcomingMaintenanceCard(),
              const SizedBox(height: 16),
              _buildRecentAlertsCard(),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildUpcomingMaintenanceCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildRecentAlertsCard()),
            ],
          );
  }

  Widget _buildUpcomingMaintenanceCard() {
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
                const Text(
                  'Upcoming Maintenance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to maintenance page
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...upcomingMaintenance.map((record) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.build, color: Colors.blue[700]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.vehicleId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            record.maintenanceType,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Due in ${record.dueDate.difference(DateTime.now()).inDays} days',
                          style: TextStyle(
                            color: record.dueDate
                                        .difference(DateTime.now())
                                        .inDays <=
                                    3
                                ? Colors.red[700]
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(record.dueDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsCard() {
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
                const Text(
                  'Recent Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to alerts page
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildAlertItem(
              'Engine Check',
              'TRK-1234',
              'High engine temperature detected',
              Colors.red,
              DateTime.now().subtract(const Duration(hours: 2)),
              'high',
            ),
            _buildAlertItem(
              'Low Fuel',
              'VAN-5678',
              'Fuel level below 15%',
              Colors.orange,
              DateTime.now().subtract(const Duration(hours: 5)),
              'medium',
            ),
            _buildAlertItem(
              'Maintenance Due',
              'SUV-9012',
              'Regular maintenance overdue by 2 days',
              Colors.amber,
              DateTime.now().subtract(const Duration(hours: 12)),
              'medium',
            ),
            _buildAlertItem(
              'Tyre Pressure',
              'CAR-3456',
              'Left rear tyre pressure low',
              Colors.blue,
              DateTime.now().subtract(const Duration(hours: 18)),
              'low',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(String title, String vehicleId, String description,
      Color color, DateTime time, String priority) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vehicleId,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getTimeAgo(time),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priority.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red[700]!;
      case 'medium':
        return Colors.orange[700]!;
      case 'low':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _getTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Data classes
class VehicleStatus {
  final String status;
  final int percentage;
  final Color color;

  VehicleStatus(this.status, this.percentage, this.color);
}

class MaintenanceRecord {
  final String vehicleId;
  final String maintenanceType;
  final DateTime dueDate;

  MaintenanceRecord(this.vehicleId, this.maintenanceType, this.dueDate);
}
