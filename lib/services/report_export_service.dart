import 'dart:io';
import 'dart:math' as math;

import 'package:excel/excel.dart' as xl;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/reports/report_config.dart';
import '../models/reports/report_data.dart';
import '../models/reports/report_types.dart';

/// ============================================================
/// REPORT EXPORT SERVICE
/// ============================================================

class ReportExportService {
  ReportExportService._();
  static final instance = ReportExportService._();

  static const _palette = [
    PdfColors.teal700,
    PdfColors.orange700,
    PdfColors.blue700,
    PdfColors.purple700,
    PdfColors.red700,
    PdfColors.cyan700,
    PdfColors.amber700,
    PdfColors.green700,
  ];

  // ==================== PUBLIC API ====================

  Future<void> exportExcel(GeneratedReport report) async {
    final bytes = _buildExcel(report);
    final fileName = _buildFileName(report, 'xlsx');
    await _shareBytes(bytes, fileName,
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  Future<void> exportPdf(GeneratedReport report) async {
    final doc = await _buildPdf(report);
    final bytes = await doc.save();
    final fileName = _buildFileName(report, 'pdf');
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } else {
      await _shareBytes(bytes, fileName, 'application/pdf');
    }
  }

  // ==================== FILE NAMING ====================

  String _buildFileName(GeneratedReport report, String ext) {
    final typePart = _safeName(report.config.reportType.label);
    final datePart = _dateRangePart(report.config);
    final stamp = DateFormat('yyyyMMdd').format(report.generatedAt);
    return '${typePart}_${datePart}_$stamp.$ext';
  }

  String _dateRangePart(ReportConfig config) {
    if (config.dateRange == ReportDateRange.custom &&
        config.customStartDate != null &&
        config.customEndDate != null) {
      final s = DateFormat('ddMMM').format(config.customStartDate!);
      final e = DateFormat('ddMMMyyyy').format(config.customEndDate!);
      return '${s}_to_$e';
    }
    return _safeName(config.dateRange.label);
  }

  // ==================== EXCEL ====================

  Uint8List _buildExcel(GeneratedReport report) {
    final excel = xl.Excel.createExcel();
    final rawName = _safeName(report.title);
    final sheetName = rawName.length > 31 ? rawName.substring(0, 31) : rawName;
    excel.rename('Sheet1', sheetName);

    final sheet = excel[sheetName];
    final vis = report.columns.where((c) => c.isVisible).toList();
    final numIdx = _numericColIndices(vis);
    final totals = <int, double>{for (final i in numIdx) i: 0.0};

    int row = 0;

    // Title
    _exCell(sheet, row, 0, xl.TextCellValue(report.title),
        style: xl.CellStyle(
          bold: true, fontSize: 14,
          backgroundColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
          fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        ), mergeEnd: vis.length - 1);
    row++;

    // Subtitle
    final dateLabel = _configDateLabel(report.config);
    _exCell(
        sheet, row, 0,
        xl.TextCellValue(
            'Period: $dateLabel   |   Records: ${report.dataRowCount}'
            '   |   Generated: ${DateFormat('dd MMM yyyy HH:mm').format(report.generatedAt)}'),
        style: xl.CellStyle(
          italic: true, fontSize: 10,
          fontColorHex: xl.ExcelColor.fromHexString('#555555'),
        ), mergeEnd: vis.length - 1);
    row++;
    row++; // blank

    // Header
    for (int c = 0; c < vis.length; c++) {
      sheet
          .cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
        ..value = xl.TextCellValue(vis[c].label)
        ..cellStyle = xl.CellStyle(
          bold: true, fontSize: 11,
          backgroundColorHex: xl.ExcelColor.fromHexString('#2E7D32'),
          fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
          horizontalAlign: xl.HorizontalAlign.Center,
        );
    }
    row++;

    // Data rows
    bool alt = false;
    for (final r in report.rows) {
      if (r.isGroupHeader) {
        final label = r.data.values.isNotEmpty
            ? r.data.values.first?.toString() ?? ''
            : '';
        _exCell(sheet, row, 0, xl.TextCellValue(label),
            style: xl.CellStyle(
              bold: true, italic: true,
              backgroundColorHex: xl.ExcelColor.fromHexString('#E8F5E9'),
              fontColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
            ), mergeEnd: vis.length - 1);
        row++;
        continue;
      }
      if (r.isSubtotal) {
        for (int c = 0; c < vis.length; c++) {
          sheet
              .cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
            ..value = _cellValue(r.data[vis[c].key], vis[c])
            ..cellStyle = xl.CellStyle(
              bold: true, italic: true,
              backgroundColorHex: xl.ExcelColor.fromHexString('#F1F8E9'),
            );
        }
        row++;
        continue;
      }

      final bg = alt ? '#F5F5F5' : '#FFFFFF';
      for (int c = 0; c < vis.length; c++) {
        final val = r.data[vis[c].key];
        if (numIdx.contains(c) && val is num) {
          totals[c] = (totals[c] ?? 0) + val.toDouble();
        }
        sheet
            .cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
          ..value = _cellValue(val, vis[c])
          ..cellStyle = xl.CellStyle(
            backgroundColorHex: xl.ExcelColor.fromHexString(bg),
            horizontalAlign: _colAlign(vis[c].dataType),
          );
      }
      alt = !alt;
      row++;
    }

    // Totals row
    if (numIdx.isNotEmpty) {
      for (int c = 0; c < vis.length; c++) {
        final isNum = numIdx.contains(c);
        sheet
            .cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
          ..value = c == 0
              ? xl.TextCellValue('TOTAL')
              : isNum
                  ? xl.DoubleCellValue(totals[c] ?? 0.0)
                  : xl.TextCellValue('')
          ..cellStyle = xl.CellStyle(
            bold: true,
            backgroundColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
            fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
            horizontalAlign:
                isNum ? xl.HorizontalAlign.Right : xl.HorizontalAlign.Left,
          );
      }
      row++;
    }

    // Column widths
    for (int c = 0; c < vis.length; c++) {
      sheet.setColumnWidth(c, vis[c].width / 7.0);
    }

    // Chart data sheet
    if (report.hasChart && report.chartData != null) {
      _buildChartDataSheet(excel, report, sheetName);
    }

    return Uint8List.fromList(excel.save()!);
  }

  /// Builds an Excel chart sheet with:
  /// - Left section: data table (label + value + %)
  /// - Right section: visual cell-shaded horizontal bar chart
  ///   (colored cells proportional to value, max = 30 cells wide)
  void _buildChartDataSheet(
      xl.Excel excel, GeneratedReport report, String mainSheet) {
    final cd = report.chartData!;
    const name = 'Chart Data';
    excel[name];
    final sheet = excel[name];

    final pts = cd.singleSeriesData;
    final total = pts.fold<double>(0, (a, p) => a + p.value);
    final maxVal = pts.isEmpty ? 1.0 : pts.map((p) => p.value).reduce(math.max);
    const barCols = 30; // max bar width in cells
    const dataStartCol = 0;
    const barStartCol = 4; // bar starts at column E
    const rowOffset = 3; // data rows start at row 3 (0-indexed)

    // Chart palette as hex strings (matches _palette order)
    const palHex = [
      '#00796B', '#E65100', '#1565C0', '#6A1B9A',
      '#B71C1C', '#00838F', '#FF6F00', '#2E7D32',
    ];

    // ---- Title (merged across data + bar area) ----
    _exCell(sheet, 0, 0,
        xl.TextCellValue(
            '${cd.title ?? report.config.chartConfig.type.label}  —  ${report.title}'),
        style: xl.CellStyle(
          bold: true, fontSize: 13,
          backgroundColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
          fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        ),
        mergeEnd: barStartCol + barCols - 1);

    // ---- Subtitle ----
    _exCell(sheet, 1, 0,
        xl.TextCellValue(
            'Total: ${_fmtRaw(total)}   |   ${pts.length} items   |   ${report.config.dateRange.label}'),
        style: xl.CellStyle(
          italic: true, fontSize: 9,
          fontColorHex: xl.ExcelColor.fromHexString('#555555'),
        ),
        mergeEnd: barStartCol + barCols - 1);

    // ---- Column headers ----
    final headers = ['Label', 'Value', '%', ''];
    for (int c = 0; c < headers.length; c++) {
      sheet
          .cell(xl.CellIndex.indexByColumnRow(
              columnIndex: dataStartCol + c, rowIndex: 2))
        ..value = xl.TextCellValue(headers[c])
        ..cellStyle = xl.CellStyle(
          bold: true,
          backgroundColorHex: xl.ExcelColor.fromHexString('#2E7D32'),
          fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
          horizontalAlign: c == 0 ? xl.HorizontalAlign.Left : xl.HorizontalAlign.Right,
        );
    }
    // Bar header
    _exCell(sheet, 2, barStartCol, xl.TextCellValue('Chart (proportional)'),
        style: xl.CellStyle(
          bold: true,
          backgroundColorHex: xl.ExcelColor.fromHexString('#2E7D32'),
          fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        ),
        mergeEnd: barStartCol + barCols - 1);

    // ---- Data rows + bar ----
    for (int i = 0; i < pts.length; i++) {
      final pt = pts[i];
      final pct = total > 0 ? pt.value / total * 100 : 0.0;
      final filledCells =
          maxVal > 0 ? (pt.value / maxVal * barCols).round() : 0;
      final rowIdx = rowOffset + i;
      final rowBg = i % 2 == 0 ? '#F5F5F5' : '#FFFFFF';
      final colorHex = palHex[i % palHex.length];

      // Label
      sheet
          .cell(xl.CellIndex.indexByColumnRow(
              columnIndex: dataStartCol, rowIndex: rowIdx))
        ..value = xl.TextCellValue(pt.label)
        ..cellStyle = xl.CellStyle(
          backgroundColorHex: xl.ExcelColor.fromHexString(rowBg),
        );
      // Value
      sheet
          .cell(xl.CellIndex.indexByColumnRow(
              columnIndex: dataStartCol + 1, rowIndex: rowIdx))
        ..value = xl.DoubleCellValue(pt.value)
        ..cellStyle = xl.CellStyle(
          backgroundColorHex: xl.ExcelColor.fromHexString(rowBg),
          horizontalAlign: xl.HorizontalAlign.Right,
        );
      // %
      sheet
          .cell(xl.CellIndex.indexByColumnRow(
              columnIndex: dataStartCol + 2, rowIndex: rowIdx))
        ..value = xl.TextCellValue('${pct.toStringAsFixed(1)}%')
        ..cellStyle = xl.CellStyle(
          backgroundColorHex: xl.ExcelColor.fromHexString(rowBg),
          horizontalAlign: xl.HorizontalAlign.Right,
        );
      // Gap column (col 3) — empty
      sheet
          .cell(xl.CellIndex.indexByColumnRow(
              columnIndex: dataStartCol + 3, rowIndex: rowIdx))
        ..cellStyle =
            xl.CellStyle(backgroundColorHex: xl.ExcelColor.fromHexString(rowBg));

      // Bar cells
      for (int b = 0; b < barCols; b++) {
        final cellColor = b < filledCells ? colorHex : rowBg;
        sheet
            .cell(xl.CellIndex.indexByColumnRow(
                columnIndex: barStartCol + b, rowIndex: rowIdx))
          ..cellStyle = xl.CellStyle(
            backgroundColorHex: xl.ExcelColor.fromHexString(cellColor),
          );
      }
    }

    // ---- Totals row ----
    final totRow = rowOffset + pts.length;
    _exCell(sheet, totRow, dataStartCol, xl.TextCellValue('TOTAL'),
        style: xl.CellStyle(
          bold: true,
          backgroundColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
          fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        ));
    sheet
        .cell(xl.CellIndex.indexByColumnRow(
            columnIndex: dataStartCol + 1, rowIndex: totRow))
      ..value = xl.DoubleCellValue(total)
      ..cellStyle = xl.CellStyle(
        bold: true,
        backgroundColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
        fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: xl.HorizontalAlign.Right,
      );
    sheet
        .cell(xl.CellIndex.indexByColumnRow(
            columnIndex: dataStartCol + 2, rowIndex: totRow))
      ..value = xl.TextCellValue('100%')
      ..cellStyle = xl.CellStyle(
        bold: true,
        backgroundColorHex: xl.ExcelColor.fromHexString('#1B5E20'),
        fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: xl.HorizontalAlign.Right,
      );

    // ---- Column widths ----
    sheet.setColumnWidth(0, 22); // Label
    sheet.setColumnWidth(1, 12); // Value
    sheet.setColumnWidth(2, 8);  // %
    sheet.setColumnWidth(3, 2);  // gap
    for (int b = 0; b < barCols; b++) {
      sheet.setColumnWidth(barStartCol + b, 1.5); // bar cells (narrow)
    }

    // ---- Row heights ----
    for (int i = 0; i < pts.length + 1; i++) {
      sheet.setRowHeight(rowOffset + i, 16);
    }
  }

  String _fmtRaw(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  }

  // ==================== PDF ====================

  Future<pw.Document> _buildPdf(GeneratedReport report) async {
    // Pre-load fonts once
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final fontItalic = await PdfGoogleFonts.notoSansItalic();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
      ),
    );

    final vis = report.columns.where((c) => c.isVisible).toList();
    final numIdx = _numericColIndices(vis);
    final primary = PdfColor.fromHex('#2E7D32');
    final lightGreen = PdfColor.fromHex('#E8F5E9');
    final altRow = PdfColor.fromHex('#F5F5F5');

    // Compute totals
    final totals = <int, double>{for (final i in numIdx) i: 0.0};
    for (final r in report.rows) {
      if (r.isGroupHeader || r.isSubtotal) continue;
      for (final i in numIdx) {
        final val = r.data[vis[i].key];
        if (val is num) totals[i] = (totals[i] ?? 0) + val.toDouble();
      }
    }

    // ---- Page 1+: Data table ----
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => _pdfHeader(report, primary),
        footer: (ctx) => _pdfFooter(ctx),
        build: (ctx) => [
          _pdfInfoBar(report, primary, lightGreen),
          pw.SizedBox(height: 8),
          if (report.summary.aggregations.isNotEmpty) ...[
            _pdfSummaryBox(report, primary, lightGreen),
            pw.SizedBox(height: 8),
          ],
          pw.Table(
            columnWidths: _pdfColWidths(vis),
            border:
                pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(color: primary),
                children: vis.map((c) => _phCell(c.label)).toList(),
              ),
              // Data
              ...() {
                int di = 0;
                return report.rows.map((r) {
                  if (r.isGroupHeader) {
                    final label = r.data.values.isNotEmpty
                        ? r.data.values.first?.toString() ?? ''
                        : '';
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: lightGreen),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 5, vertical: 4),
                          child: pw.Text(label,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 8,
                                  color: primary)),
                        ),
                        ...List.generate(vis.length - 1, (_) => pw.SizedBox()),
                      ],
                    );
                  }
                  if (r.isSubtotal) {
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F1F8E9')),
                      children: vis
                          .map((c) => _pdCell(
                              _fmt(r.data[c.key], c), c.dataType,
                              bold: true, italic: true))
                          .toList(),
                    );
                  }
                  final isAlt = di++ % 2 == 1;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                        color: isAlt ? altRow : PdfColors.white),
                    children: vis
                        .map((c) => _pdCell(_fmt(r.data[c.key], c), c.dataType))
                        .toList(),
                  );
                }).toList();
              }(),
              // Totals row
              if (numIdx.isNotEmpty)
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: primary),
                  children: List.generate(vis.length, (c) {
                    if (c == 0) return _phCell('TOTAL');
                    if (numIdx.contains(c)) {
                      return _pdCell(_fmt(totals[c], vis[c]), vis[c].dataType,
                          bold: true, color: PdfColors.white);
                    }
                    return _phCell('');
                  }),
                ),
            ],
          ),
        ],
      ),
    );

    // ---- Chart page ----
    if (report.hasChart && report.chartData != null) {
      _addPdfChartPage(doc, report, primary, lightGreen);
    }

    return doc;
  }

  void _addPdfChartPage(
    pw.Document doc,
    GeneratedReport report,
    PdfColor primary,
    PdfColor lightGreen,
  ) {
    final cd = report.chartData!;
    final chartType = report.config.chartConfig.type;
    final pts = cd.singleSeriesData;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfHeader(report, primary),
            pw.SizedBox(height: 12),
            pw.Text(
              cd.title ?? chartType.label,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: primary,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Chart — fixed large size so it fills the page
                  pw.Expanded(
                    flex: 3,
                    child: pw.CustomPaint(
                      size: const PdfPoint(420, 340),
                      painter: (canvas, size) {
                        if (chartType == ChartType.pie ||
                            chartType == ChartType.donut) {
                          _drawPie(canvas, size, pts,
                              isDonut: chartType == ChartType.donut);
                        } else {
                          _drawBar(canvas, size, pts,
                              horizontal:
                                  chartType == ChartType.horizontalBar);
                        }
                      },
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // Legend + data table
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Data',
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: primary)),
                        pw.SizedBox(height: 6),
                        _pdfChartTable(cd, primary, lightGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Chart drawing (PdfGraphics) ----

  void _drawBar(
    PdfGraphics canvas,
    PdfPoint size,
    List<ChartDataPoint> pts, {
    required bool horizontal,
  }) {
    if (pts.isEmpty) return;
    final maxVal = pts.map((p) => p.value).reduce(math.max);
    if (maxVal == 0) return;
    final n = pts.length;
    const axisSize = 36.0;
    const labelSize = 18.0;
    const padding = 8.0;

    if (!horizontal) {
      final chartH = size.y - labelSize - padding;
      final chartW = size.x - axisSize - padding;
      final slot = chartW / n;
      final barW = slot * 0.65;

      // Grid lines
      for (int g = 0; g <= 4; g++) {
        final y = labelSize + chartH * g / 4;
        canvas
          ..setStrokeColor(PdfColors.grey300)
          ..setLineWidth(0.5)
          ..drawLine(axisSize, y, size.x - padding, y)
          ..strokePath();
      }

      // Bars
      for (int i = 0; i < n; i++) {
        final barH = (pts[i].value / maxVal) * chartH;
        final x = axisSize + slot * i + (slot - barW) / 2;
        final y = labelSize + chartH - barH;
        canvas
          ..setFillColor(_palette[i % _palette.length])
          ..drawRect(x, y, barW, barH)
          ..fillPath();
      }
    } else {
      final chartH = size.y - padding * 2;
      final chartW = size.x - axisSize - padding;
      final slot = chartH / n;
      final barH = slot * 0.6;

      for (int g = 0; g <= 4; g++) {
        final x = axisSize + chartW * g / 4;
        canvas
          ..setStrokeColor(PdfColors.grey300)
          ..setLineWidth(0.5)
          ..drawLine(x, padding, x, size.y - padding)
          ..strokePath();
      }

      for (int i = 0; i < n; i++) {
        final bW = (pts[i].value / maxVal) * chartW;
        final y = size.y - padding - slot * (i + 1) + (slot - barH) / 2;
        canvas
          ..setFillColor(_palette[i % _palette.length])
          ..drawRect(axisSize, y, bW, barH)
          ..fillPath();
      }
    }
  }

  void _drawPie(
    PdfGraphics canvas,
    PdfPoint size,
    List<ChartDataPoint> pts, {
    required bool isDonut,
  }) {
    if (pts.isEmpty) return;
    final total = pts.fold<double>(0, (s, p) => s + p.value);
    if (total == 0) return;

    final cx = size.x / 2;
    final cy = size.y / 2;
    final r = math.min(cx, cy) - 12;
    final innerR = isDonut ? r * 0.45 : 0.0;
    double angle = -math.pi / 2;

    for (int i = 0; i < pts.length; i++) {
      final sweep = (pts[i].value / total) * 2 * math.pi;
      final color = _palette[i % _palette.length];

      // Draw slice using bezierArc
      canvas.setFillColor(color);
      canvas.moveTo(cx + innerR * math.cos(angle),
          cy + innerR * math.sin(angle));
      canvas.lineTo(
          cx + r * math.cos(angle), cy + r * math.sin(angle));
      canvas.bezierArc(
          cx + r * math.cos(angle), cy + r * math.sin(angle),
          r, r,
          cx + r * math.cos(angle + sweep),
          cy + r * math.sin(angle + sweep),
          large: sweep > math.pi);
      if (isDonut) {
        canvas.lineTo(cx + innerR * math.cos(angle + sweep),
            cy + innerR * math.sin(angle + sweep));
        canvas.bezierArc(
            cx + innerR * math.cos(angle + sweep),
            cy + innerR * math.sin(angle + sweep),
            innerR, innerR,
            cx + innerR * math.cos(angle),
            cy + innerR * math.sin(angle),
            large: sweep > math.pi, sweep: false);
      } else {
        canvas.lineTo(cx, cy);
      }
      canvas.fillPath();

      // White separator line
      canvas
        ..setStrokeColor(PdfColors.white)
        ..setLineWidth(0.8)
        ..moveTo(cx, cy)
        ..lineTo(cx + r * math.cos(angle), cy + r * math.sin(angle))
        ..strokePath();

      angle += sweep;
    }
  }

  pw.Widget _pdfChartTable(
      ChartData cd, PdfColor primary, PdfColor bg) {
    final pts = cd.singleSeriesData;
    final total = pts.fold<double>(0, (s, p) => s + p.value);

    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
      },
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primary),
          children: [_phCell('Label'), _phCell('Value'), _phCell('%')],
        ),
        ...pts.asMap().entries.map((e) {
          final pct =
              total > 0 ? (e.value.value / total * 100) : 0.0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
                color: e.key % 2 == 0 ? bg : PdfColors.white),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4, vertical: 3),
                child: pw.Row(children: [
                  pw.Container(
                    width: 7,
                    height: 7,
                    decoration: pw.BoxDecoration(
                      color: _palette[e.key % _palette.length],
                      borderRadius: pw.BorderRadius.circular(2),
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Flexible(
                      child: pw.Text(e.value.label,
                          style: const pw.TextStyle(fontSize: 7.5))),
                ]),
              ),
              _pdCell(
                  e.value.value.toStringAsFixed(
                      e.value.value.truncateToDouble() == e.value.value
                          ? 0
                          : 2),
                  ColumnDataType.number),
              _pdCell('${pct.toStringAsFixed(1)}%', ColumnDataType.text),
            ],
          );
        }),
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primary),
          children: [
            _phCell('TOTAL'),
            _pdCell(
                total.toStringAsFixed(
                    total.truncateToDouble() == total ? 0 : 2),
                ColumnDataType.number,
                bold: true,
                color: PdfColors.white),
            _phCell('100%'),
          ],
        ),
      ],
    );
  }

  // ---- PDF shared widgets ----

  pw.Widget _pdfHeader(GeneratedReport report, PdfColor primary) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primary, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(report.title,
                style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primary)),
            pw.SizedBox(height: 2),
            pw.Text(_configDateLabel(report.config),
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('MultiFleet',
                style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: primary)),
            pw.Text(
                '${report.dataRowCount} records  •  '
                '${DateFormat('dd MMM yyyy HH:mm').format(report.generatedAt)}',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          ]),
        ],
      ),
    );
  }

  pw.Widget _pdfInfoBar(
      GeneratedReport report, PdfColor primary, PdfColor bg) {
    final items = {
      'Report': report.config.reportType.label,
      'Period': _configDateLabel(report.config),
      'Records': '${report.dataRowCount}',
      if (report.config.groupBy != GroupByOption.none)
        'Grouped By': report.config.groupBy.label,
    };
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(3),
        border: pw.Border.all(color: primary, width: 0.5),
      ),
      child: pw.Wrap(
        spacing: 16,
        runSpacing: 2,
        children: items.entries
            .map((e) => pw.RichText(
                  text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: '${e.key}: ',
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                        text: e.value,
                        style: const pw.TextStyle(fontSize: 8)),
                  ]),
                ))
            .toList(),
      ),
    );
  }

  pw.Widget _pdfSummaryBox(
      GeneratedReport report, PdfColor primary, PdfColor bg) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(3),
        border: pw.Border.all(color: primary, width: 0.5),
      ),
      child: pw.Wrap(
        spacing: 20,
        runSpacing: 2,
        children: report.summary.aggregations.entries
            .map((e) => pw.RichText(
                  text: pw.TextSpan(children: [
                    pw.TextSpan(
                        text: '${e.key}: ',
                        style: pw.TextStyle(
                            fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(
                        text: e.value?.toString() ?? '-',
                        style: const pw.TextStyle(fontSize: 8.5)),
                  ]),
                ))
            .toList(),
      ),
    );
  }

  pw.Widget _pdfFooter(pw.Context ctx) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 5),
      child: pw.Text(
        'Page ${ctx.pageNumber} of ${ctx.pagesCount}  •  MultiFleet',
        style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
      ),
    );
  }

  /// PDF header cell (dark green bg, white bold text)
  pw.Widget _phCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white),
            textAlign: pw.TextAlign.center),
      );

  /// PDF data cell
  pw.Widget _pdCell(String text, ColumnDataType type,
      {bool bold = false, bool italic = false, PdfColor? color}) {
    final right = type == ColumnDataType.currency ||
        type == ColumnDataType.number ||
        type == ColumnDataType.percentage;
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal,
          color: color,
        ),
        textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  Map<int, pw.TableColumnWidth> _pdfColWidths(List<ReportColumn> cols) {
    final total = cols.fold<double>(0, (s, c) => s + c.width);
    return {
      for (int i = 0; i < cols.length; i++)
        i: pw.FlexColumnWidth(cols[i].width / total * cols.length)
    };
  }

  // ==================== HELPERS ====================

  /// Only columns with aggregation=sum or currency type warrant a grand total.
  /// Pure numeric IDs (year, count-style numbers) are excluded unless
  /// they explicitly declare sum aggregation.
  List<int> _numericColIndices(List<ReportColumn> cols) => [
        for (int i = 0; i < cols.length; i++)
          if (_colNeedsTotal(cols[i])) i
      ];

  bool _colNeedsTotal(ReportColumn col) {
    // Currency columns always get totalled
    if (col.dataType == ColumnDataType.currency) return true;
    // Percentage columns — only if explicitly marked sum
    if (col.dataType == ColumnDataType.percentage) {
      return col.aggregation == AggregationType.sum;
    }
    // Plain numeric — only if explicitly marked sum (excludes year, id, odo etc.)
    if (col.dataType == ColumnDataType.number) {
      return col.aggregation == AggregationType.sum ||
          col.aggregation == AggregationType.count;
    }
    return false;
  }

  xl.CellValue _cellValue(dynamic val, ReportColumn col) {
    if (val == null) return xl.TextCellValue('-');
    if ((col.dataType == ColumnDataType.currency ||
            col.dataType == ColumnDataType.number ||
            col.dataType == ColumnDataType.percentage) &&
        val is num) {
      return xl.DoubleCellValue(val.toDouble());
    }
    return xl.TextCellValue(_fmtExcel(val, col));
  }

  String _fmtExcel(dynamic val, ReportColumn col) {
    if (val == null) return '-';
    return switch (col.dataType) {
      ColumnDataType.currency =>
        'AED ${val is num ? val.toStringAsFixed(2) : val}',
      ColumnDataType.percentage =>
        '${val is num ? val.toStringAsFixed(1) : val}%',
      ColumnDataType.date =>
        val is DateTime ? DateFormat('dd/MM/yyyy').format(val) : val.toString(),
      ColumnDataType.dateTime => val is DateTime
          ? DateFormat('dd/MM/yyyy HH:mm').format(val)
          : val.toString(),
      ColumnDataType.boolean => val == true ? 'Yes' : 'No',
      ColumnDataType.list => val is List ? val.join(', ') : val.toString(),
      _ => val.toString(),
    };
  }

  String _fmt(dynamic val, ReportColumn col) {
    if (val == null) return '-';
    return switch (col.dataType) {
      ColumnDataType.currency =>
        'AED ${val is num ? val.toStringAsFixed(2) : val}',
      ColumnDataType.percentage =>
        '${val is num ? val.toStringAsFixed(1) : val}%',
      ColumnDataType.number => val is num
          ? val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 2)
          : val.toString(),
      ColumnDataType.date =>
        val is DateTime ? DateFormat('dd/MM/yyyy').format(val) : val.toString(),
      ColumnDataType.dateTime => val is DateTime
          ? DateFormat('dd/MM/yyyy HH:mm').format(val)
          : val.toString(),
      ColumnDataType.boolean => val == true ? 'Yes' : 'No',
      ColumnDataType.list => val is List ? val.join(', ') : val.toString(),
      _ => val.toString(),
    };
  }

  xl.HorizontalAlign _colAlign(ColumnDataType type) =>
      (type == ColumnDataType.currency ||
              type == ColumnDataType.number ||
              type == ColumnDataType.percentage)
          ? xl.HorizontalAlign.Right
          : xl.HorizontalAlign.Left;

  String _configDateLabel(ReportConfig config) {
    if (config.dateRange == ReportDateRange.custom &&
        config.customStartDate != null &&
        config.customEndDate != null) {
      return '${DateFormat('dd MMM yyyy').format(config.customStartDate!)} → '
          '${DateFormat('dd MMM yyyy').format(config.customEndDate!)}';
    }
    return config.dateRange.label;
  }

  void _exCell(xl.Sheet sheet, int row, int col, xl.CellValue value,
      {xl.CellStyle? style, int? mergeEnd}) {
    final cell =
        sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = value;
    if (style != null) cell.cellStyle = style;
    if (mergeEnd != null && mergeEnd > col) {
      sheet.merge(
        xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
        xl.CellIndex.indexByColumnRow(columnIndex: mergeEnd, rowIndex: row),
      );
    }
  }

  String _safeName(String title) =>
      title.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(RegExp(r'\s+'), '_');

  Future<void> _shareBytes(
      Uint8List bytes, String fileName, String mimeType) async {
    if (kIsWeb) {
      await Share.shareXFiles(
        [XFile.fromData(bytes, name: fileName, mimeType: mimeType)],
        subject: fileName,
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      subject: fileName,
    );
  }
}
