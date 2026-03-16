import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multifleet/controllers/dashboard_controller.dart';
import 'package:multifleet/theme/app_theme.dart';

/// ============================================================
/// DASHBOARD CHARTS SECTION
/// ============================================================
/// Chart widgets for fleet management dashboard.
/// All data comes from DashboardController's real computed lists.
/// ============================================================

class DashboardChartsSection extends StatelessWidget {
  final DashboardController controller;
  final bool isMobile;
  final bool isTablet;

  const DashboardChartsSection({
    super.key,
    required this.controller,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Trigger rebuild whenever any underlying list changes.
      controller.vehicles.length;
      controller.fines.length;
      controller.maintenanceRecords.length;

      if (controller.isLoading && controller.vehicles.isEmpty) {
        return const SizedBox.shrink();
      }

      if (isMobile) {
        return _buildMobileLayout();
      } else if (isTablet) {
        return _buildTabletLayout();
      } else {
        return _buildDesktopLayout();
      }
    });
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _UtilizationGaugeCard(controller: controller),
        const SizedBox(height: 16),
        _VehicleStatusChart(controller: controller),
        const SizedBox(height: 16),
        _FineTrendChart(controller: controller),
        const SizedBox(height: 16),
        _MaintenanceCostChart(controller: controller),
        const SizedBox(height: 16),
        _TopVehiclesFinesChart(controller: controller),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _UtilizationGaugeCard(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _VehicleStatusChart(controller: controller)),
          ],
        ),
        const SizedBox(height: 16),
        _FineTrendChart(controller: controller),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _MaintenanceCostChart(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _TopVehiclesFinesChart(controller: controller)),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _UtilizationGaugeCard(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _VehicleStatusChart(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _FineTrendChart(controller: controller)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _MaintenanceCostChart(controller: controller)),
            const SizedBox(width: 16),
            Expanded(child: _TopVehiclesFinesChart(controller: controller)),
          ],
        ),
      ],
    );
  }
}

// ==================== CHART CARD WRAPPER ====================

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final Widget? legend;
  final Widget? action;
  final double? height;

  const _ChartCard({
    required this.title,
    this.subtitle,
    required this.chart,
    this.height,
    this.legend,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h4),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: chart),
          if (legend != null) ...[
            const SizedBox(height: 12),
            legend!,
          ],
        ],
      ),
    );
  }
}

// ==================== UTILIZATION GAUGE ====================

class _UtilizationGaugeCard extends StatelessWidget {
  final DashboardController controller;

  const _UtilizationGaugeCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final utilization = controller.fleetUtilizationRate;
    final active = controller.activeVehicles;
    final total = controller.totalVehicles;

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fleet Utilization', style: AppTextStyles.h4),
          const SizedBox(height: 4),
          Text(
            '$active of $total vehicles active',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: _GaugeWidget(
                value: utilization,
                maxValue: 100,
                size: 160,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(utilization).withOpacity(0.1),
                borderRadius: AppRadius.borderFull,
              ),
              child: Text(
                _statusLabel(utilization),
                style:
                    AppTextStyles.label.copyWith(color: _statusColor(utilization)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(double v) {
    if (v >= 80) return AppColors.success;
    if (v >= 60) return AppColors.accent;
    if (v >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _statusLabel(double v) {
    if (v >= 80) return 'Excellent';
    if (v >= 60) return 'Good';
    if (v >= 40) return 'Fair';
    return 'Low';
  }
}

class _GaugeWidget extends StatelessWidget {
  final double value;
  final double maxValue;
  final double size;

  const _GaugeWidget({
    required this.value,
    required this.maxValue,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final color = _gaugeColor(percentage);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          percentage: percentage,
          backgroundColor: AppColors.divider,
          foregroundColor: color,
        ),
        child: Center(
          child: Text(
            '${value.toStringAsFixed(1)}%',
            style: AppTextStyles.h1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Color _gaugeColor(double p) {
    if (p >= 0.8) return AppColors.success;
    if (p >= 0.6) return AppColors.accent;
    if (p >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color backgroundColor;
  final Color foregroundColor;

  _GaugePainter({
    required this.percentage,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 14.0;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    final fgPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * percentage,
      false,
      fgPaint,
    );

    final tickPaint = Paint()
      ..color = AppColors.textMuted.withOpacity(0.3)
      ..strokeWidth = 2;
    for (int i = 0; i <= 10; i++) {
      final tickAngle = startAngle + (sweepAngle * i / 10);
      final innerRadius = radius - strokeWidth / 2 - 8;
      final outerRadius = radius - strokeWidth / 2 - 4;
      canvas.drawLine(
        Offset(center.dx + innerRadius * math.cos(tickAngle),
            center.dy + innerRadius * math.sin(tickAngle)),
        Offset(center.dx + outerRadius * math.cos(tickAngle),
            center.dy + outerRadius * math.sin(tickAngle)),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.percentage != percentage || old.foregroundColor != foregroundColor;
}

// ==================== VEHICLE STATUS DONUT CHART ====================

class _VehicleStatusChart extends StatelessWidget {
  final DashboardController controller;

  const _VehicleStatusChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.vehicleStatusBreakdown;

    if (data.isEmpty) {
      return _ChartCard(
        title: 'Vehicle Status',
        subtitle: 'Distribution by status',
        height: 280,
        chart: const Center(child: Text('No vehicle data')),
      );
    }

    return _ChartCard(
      title: 'Vehicle Status',
      subtitle: 'Distribution by status',
      height: 280,
      chart: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: data.map((item) {
                  final pct = (item['percentage'] as double);
                  return PieChartSectionData(
                    value: pct,
                    title: '${pct.toStringAsFixed(0)}%',
                    color: controller.hexToColor(item['colorHex'] as String),
                    radius: 45,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color:
                              controller.hexToColor(item['colorHex'] as String),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['status'] as String,
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${item['count']}',
                        style: AppTextStyles.label,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== FINE TREND LINE CHART ====================

class _FineTrendChart extends StatelessWidget {
  final DashboardController controller;

  const _FineTrendChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.fineTrendByMonth;

    if (data.isEmpty || data.every((e) => (e['value'] as double) == 0)) {
      return _ChartCard(
        title: 'Fine Trend',
        subtitle: 'Monthly fine amounts',
        height: 280,
        chart: const Center(child: Text('No fine data')),
      );
    }

    final values = data.map((e) => e['value'] as double).toList();
    final maxY = values.reduce(math.max);
    final minY = values.reduce(math.min);
    final range = maxY - minY;
    final adjustedMax = maxY + (range > 0 ? range * 0.1 : maxY * 0.2 + 1);
    final adjustedMin = math.max(0, minY - (range > 0 ? range * 0.1 : 0));

    return _ChartCard(
      title: 'Fine Trend',
      subtitle: 'Monthly fine amounts',
      height: 280,
      chart: Padding(
        padding: const EdgeInsets.only(right: 16, top: 8),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: range > 0 ? range / 4 : adjustedMax / 4,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.divider, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: range > 0 ? range / 4 : adjustedMax / 4,
                  getTitlesWidget: (v, _) =>
                      Text(_formatAxisValue(v), style: AppTextStyles.caption),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i >= 0 && i < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(data[i]['monthShort'] as String,
                            style: AppTextStyles.caption),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: adjustedMin.toDouble(),
            maxY: adjustedMax,
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries
                    .map((e) =>
                        FlSpot(e.key.toDouble(), e.value['value'] as double))
                    .toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppColors.error,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.cardBg,
                    strokeWidth: 2,
                    strokeColor: AppColors.error,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.error.withOpacity(0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.primaryDark,
                getTooltipItems: (spots) => spots.map((spot) {
                  final i = spot.x.toInt();
                  return LineTooltipItem(
                    '${data[i]['month']}\n',
                    AppTextStyles.caption.copyWith(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: controller.formatCurrency(spot.y),
                        style:
                            AppTextStyles.label.copyWith(color: Colors.white),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAxisValue(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}K' : v.toStringAsFixed(0);
}

// ==================== MAINTENANCE COST AREA CHART ====================

class _MaintenanceCostChart extends StatelessWidget {
  final DashboardController controller;

  const _MaintenanceCostChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.maintenanceCostByMonth;

    if (data.isEmpty || data.every((e) => (e['value'] as double) == 0)) {
      return _ChartCard(
        title: 'Maintenance Cost',
        subtitle: 'Monthly trend',
        height: 300,
        chart: const Center(child: Text('No maintenance data')),
      );
    }

    final values = data.map((e) => e['value'] as double).toList();
    final maxY = values.reduce(math.max);
    final minY = values.reduce(math.min);
    final range = maxY - minY;
    final adjustedMax = maxY + (range > 0 ? range * 0.1 : maxY * 0.2 + 1);
    final adjustedMin = math.max(0, minY - (range > 0 ? range * 0.1 : 0));

    return _ChartCard(
      title: 'Maintenance Cost',
      subtitle: 'Monthly trend',
      height: 300,
      chart: Padding(
        padding: const EdgeInsets.only(right: 16, top: 8),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: range > 0 ? range / 4 : adjustedMax / 4,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.divider, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: range > 0 ? range / 4 : adjustedMax / 4,
                  getTitlesWidget: (v, _) =>
                      Text(_formatAxisValue(v), style: AppTextStyles.caption),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i >= 0 && i < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(data[i]['monthShort'] as String,
                            style: AppTextStyles.caption),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: adjustedMin.toDouble(),
            maxY: adjustedMax,
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries
                    .map((e) =>
                        FlSpot(e.key.toDouble(), e.value['value'] as double))
                    .toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppColors.warning,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.cardBg,
                    strokeWidth: 2,
                    strokeColor: AppColors.warning,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.warning.withOpacity(0.3),
                      AppColors.warning.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.primaryDark,
                getTooltipItems: (spots) => spots.map((spot) {
                  final i = spot.x.toInt();
                  final count = data[i]['count'] as int;
                  return LineTooltipItem(
                    '${data[i]['month']}\n',
                    AppTextStyles.caption.copyWith(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: controller.formatCurrency(spot.y),
                        style:
                            AppTextStyles.label.copyWith(color: Colors.white),
                      ),
                      TextSpan(
                        text: '\n$count services',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAxisValue(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}K' : v.toStringAsFixed(0);
}

// ==================== TOP VEHICLES BY FINES ====================

class _TopVehiclesFinesChart extends StatelessWidget {
  final DashboardController controller;

  const _TopVehiclesFinesChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = controller.topFinedVehicles; // List<MapEntry<String, int>>

    if (data.isEmpty) {
      return _ChartCard(
        title: 'Top Vehicles by Fines',
        subtitle: 'Highest fine counts',
        height: 300,
        chart: const Center(child: Text('No fine data')),
      );
    }

    final maxCount = data.map((e) => e.value).reduce(math.max).toDouble();

    return _ChartCard(
      title: 'Top Vehicles by Fines',
      subtitle: 'Highest fine counts',
      height: 300,
      chart: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = data[index];
          final pct = maxCount > 0 ? item.value / maxCount : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _rankColor(index).withOpacity(0.1),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _rankColor(index),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.key, style: AppTextStyles.label),
                  ),
                  Text(
                    '${item.value} fine${item.value == 1 ? '' : 's'}',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.error),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: AppRadius.borderSm,
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation(_rankColor(index)),
                  minHeight: 6,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _rankColor(int index) {
    switch (index) {
      case 0:
        return AppColors.error;
      case 1:
        return const Color(0xFFEA580C);
      case 2:
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }
}
