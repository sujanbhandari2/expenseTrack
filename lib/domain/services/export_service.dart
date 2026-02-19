import 'dart:io';
import 'dart:typed_data';

import 'package:daily_finance_tracker/core/constants/app_constants.dart';
import 'package:daily_finance_tracker/domain/models/dashboard_stats.dart';
import 'package:daily_finance_tracker/domain/models/transaction_item.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class ExportService {
  Future<Directory> _targetDirectory() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final dir = await getExternalStorageDirectory();
        if (dir != null) return dir;
      }
    }

    final docs = await getApplicationDocumentsDirectory();
    return docs;
  }

  Future<String> exportPdfReport({
    required DateTime start,
    required DateTime end,
    required DashboardStats stats,
    required Map<String, double> categoryBreakdown,
    required List<TransactionItem> transactions,
    Uint8List? chartImage,
  }) async {
    final doc = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd');

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            AppConstants.appName,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Period: ${dateFormat.format(start)} to ${dateFormat.format(end)}',
          ),
          pw.SizedBox(height: 12),
          pw.Text('Total Income: ${stats.totalIncome.toStringAsFixed(2)}'),
          pw.Text('Total Expense: ${stats.totalExpense.toStringAsFixed(2)}'),
          pw.Text('Balance: ${stats.balance.toStringAsFixed(2)}'),
          pw.Text('Savings Rate: ${stats.savingsRate.toStringAsFixed(2)}%'),
          pw.SizedBox(height: 12),
          pw.Text(
            'Category Breakdown',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Category'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('Expense'),
                  ),
                ],
              ),
              ...categoryBreakdown.entries.map(
                (e) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(e.key),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(e.value.toStringAsFixed(2)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (chartImage != null) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Chart Snapshot',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Image(pw.MemoryImage(chartImage), height: 180),
          ],
          pw.SizedBox(height: 12),
          pw.Text(
            'Transactions',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                children: ['Date', 'Title', 'Type', 'Category', 'Amount']
                    .map(
                      (v) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(v),
                      ),
                    )
                    .toList(),
              ),
              ...transactions.map(
                (t) => pw.TableRow(
                  children:
                      [
                            DateFormat('yyyy-MM-dd').format(t.createdAt),
                            t.title,
                            t.type.name,
                            t.category,
                            t.amount.toStringAsFixed(2),
                          ]
                          .map(
                            (v) => pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(v),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final dir = await _targetDirectory();
    final filePath = p.join(
      dir.path,
      'finance_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    final file = File(filePath);
    await file.writeAsBytes(await doc.save());
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: p.basename(filePath),
    );
    return filePath;
  }

  Future<String> exportExcelReport({
    required List<TransactionItem> transactions,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Title'),
      TextCellValue('Category'),
      TextCellValue('Type'),
      TextCellValue('Amount'),
      TextCellValue('Note'),
    ]);

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    for (final tx in transactions) {
      sheet.appendRow([
        TextCellValue(dateFormat.format(tx.createdAt)),
        TextCellValue(tx.title),
        TextCellValue(tx.category),
        TextCellValue(tx.type.name),
        DoubleCellValue(tx.amount),
        TextCellValue(tx.note ?? ''),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to generate excel.');
    }

    final dir = await _targetDirectory();
    final filePath = p.join(
      dir.path,
      'finance_report_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }
}
