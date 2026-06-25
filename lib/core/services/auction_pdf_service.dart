import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/auction_model.dart';
import '../../data/models/chit_model.dart';
import '../../data/models/member_model.dart';
import '../utils/unicode_to_bamini.dart';

/// Data needed to fill the Tamil auction receipt (மாதாந்திர சீட்டு ஏல விபரம்).
class AuctionPdfData {
  final AuctionModel auction;
  final ChitModel? chit;
  final MemberModel? winner;
  final double previousChitBalance;

  const AuctionPdfData({
    required this.auction,
    this.chit,
    this.winner,
    this.previousChitBalance = 0,
  });

  double get chitTotal => auction.chitAmount;
  double get discount => auction.winningDiscountAmount ?? 0;
  double get prizeAmount => auction.prizeAmount ?? 0;
  double get commission => auction.commissionAmount ?? 0;
  double get balanceAmount => auction.dividendPool ?? 0;
  double get commissionToChit => commission;
  double get netTotalBalance => previousChitBalance + balanceAmount;
  double get deficit {
    final installment = chit?.monthlyInstallment ?? 0;
    final expected = installment * auction.totalMembers;
    if (expected <= 0) return 0;
    final collected = auction.totalCollection > 0
        ? auction.totalCollection
        : expected;
    return (expected - collected).clamp(0, double.infinity);
  }

  int get remainingChits {
    final total = chit?.durationMonths ?? auction.totalMembers;
    return (total - auction.auctionMonth).clamp(0, total);
  }

  String get formattedDate {
    final d = DateTime.tryParse(auction.auctionDate);
    if (d == null) return auction.auctionDate;
    return DateFormat('dd/MM/yyyy').format(d);
  }

  String get formattedTime {
    final t = auction.auctionTime;
    if (t == null || t.isEmpty) return '';
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final ampm = hour < 12 ? 'AM' : 'PM';
    final h12 = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    return '$h12:${minute.toString().padLeft(2, '0')} $ampm';
  }

  String get chitNo {
    final code = chit?.chitCode ?? auction.chitCode;
    if (code != null && code.isNotEmpty) return code;
    return '-';
  }
}

class AuctionPdfService {
  static const _companyName = 'ஸ்ரீ செல்வ மகா கணபதி சேமிப்பு';
  static const _conductorName = 'M. பார்த்திபன்';
  static const _subtitle = 'மாதாந்திர சீட்டு ஏல விபரம் (மடிப்பு)';
  static const _fontAsset = 'assets/fonts/BAMINI-Tamil12.ttf';

  static pw.Font? _cachedFont;

  static final pw.Font _latin = pw.Font.helvetica();
  static final pw.Font _latinBold = pw.Font.helveticaBold();

  static String _b(String text) => UnicodeToBamini.convert(text);

  static String _m(String text) => UnicodeToBamini.convertIfTamil(text);

  static bool _hasTamil(String text) {
    for (final r in text.runes) {
      if (r >= 0x0B80 && r <= 0x0BFF) return true;
    }
    return false;
  }

  static pw.TextStyle _tamilStyle(
    pw.Font font, {
    double size = 9.5,
    bool bold = false,
  }) =>
      pw.TextStyle(
        font: font,
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : null,
      );

  static pw.TextStyle _latinStyle({double size = 9.5, bool bold = false}) =>
      pw.TextStyle(
        font: bold ? _latinBold : _latin,
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : null,
      );

  static pw.Widget _valueText(
    String value,
    pw.Font tamilFont, {
    double size = 9.5,
    bool bold = true,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    final tamil = _hasTamil(value);
    return pw.Text(
      tamil ? _m(value) : value,
      textAlign: align,
      style: tamil
          ? _tamilStyle(tamilFont, size: size, bold: bold)
          : _latinStyle(size: size, bold: bold),
    );
  }

  static pw.Widget _amountText(
    String amount,
    pw.Font tamilFont, {
    bool withRupee = false,
  }) {
    if (!withRupee) {
      return pw.Text(
        amount,
        textAlign: pw.TextAlign.right,
        style: _latinStyle(size: 9.5, bold: true),
      );
    }
    return pw.RichText(
      textAlign: pw.TextAlign.right,
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '${_b('ரூ')} : ',
            style: _tamilStyle(tamilFont, size: 9.5, bold: true),
          ),
          pw.TextSpan(
            text: amount,
            style: _latinStyle(size: 9.5, bold: true),
          ),
        ],
      ),
    );
  }

  static Future<void> previewAndExport(AuctionPdfData data) async {
    final doc = await _buildDocument(data);
    await Printing.layoutPdf(
      name:
          'auction_m${data.auction.auctionMonth}_${data.auction.auctionDate}.pdf',
      onLayout: (_) async => doc.save(),
    );
  }

  static Future<Uint8List> generateBytes(AuctionPdfData data) async {
    final doc = await _buildDocument(data);
    return doc.save();
  }

  static Future<pw.Document> _buildDocument(AuctionPdfData data) async {
    final tamilFont = await _loadFont();
    final ganesha = await _loadGaneshaImage();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: tamilFont, bold: tamilFont),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1.2),
            ),
            padding: const pw.EdgeInsets.all(14),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildHeader(ganesha, tamilFont),
                pw.SizedBox(height: 10),
                _buildMetaRow(data, tamilFont),
                pw.SizedBox(height: 10),
                _buildFinancialTable(data, tamilFont),
                pw.SizedBox(height: 12),
                _buildMemberSection(data, tamilFont),
                pw.SizedBox(height: 10),
                _buildDeclaration(data, tamilFont),
                pw.Spacer(),
                _buildFooter(tamilFont),
              ],
            ),
          );
        },
      ),
    );

    return doc;
  }

  static Future<pw.Font> _loadFont() async {
    if (_cachedFont != null) return _cachedFont!;
    final bytes = await rootBundle.load(_fontAsset);
    _cachedFont = pw.Font.ttf(bytes);
    return _cachedFont!;
  }

  static Future<pw.MemoryImage?> _loadGaneshaImage() async {
    try {
      final bytes =
          await rootBundle.load('assets/images/auction_form_reference.png');
      final decoded = img.decodeImage(bytes.buffer.asUint8List());
      if (decoded == null) return null;
      final cropped = img.copyCrop(decoded, x: 8, y: 8, width: 72, height: 72);
      return pw.MemoryImage(Uint8List.fromList(img.encodePng(cropped)));
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _buildHeader(pw.MemoryImage? ganesha, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (ganesha != null)
          pw.Container(
            width: 58,
            height: 58,
            child: pw.Image(ganesha, fit: pw.BoxFit.contain),
          )
        else
          pw.SizedBox(width: 58),
        pw.Expanded(
          child: pw.Column(
            children: [
              pw.Text(
                _b(_companyName),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: pw.BorderRadius.circular(14),
                ),
                child: pw.Text(
                  _b(_subtitle),
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 11,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 58),
      ],
    );
  }

  static pw.Widget _buildMetaRow(AuctionPdfData data, pw.Font font) {
    pw.Widget cell(String label, String value) {
      return pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 0.8),
          ),
          child: pw.Row(
            children: [
              pw.Text(label, style: _tamilStyle(font, size: 9)),
              pw.SizedBox(width: 4),
              pw.Expanded(
                child: _valueText(
                  value,
                  font,
                  size: 9,
                  bold: true,
                  align: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return pw.Row(
      children: [
        cell(_b('ஏல நாள் :'), data.formattedDate),
        cell(_b('நேரம் :'), data.formattedTime),
        cell(_b('Chit No / சீட்டு எண் :'), data.chitNo),
      ],
    );
  }

  static pw.Widget _buildFinancialTable(AuctionPdfData data, pw.Font font) {
    final rows = <(String, String, bool)>[
      (_b('சீட்டு மொத்த தொகை'), _rs(data.chitTotal), false),
      (_b('தள்ளு தொகை'), _rs(data.discount), false),
      (_b('மீதி தொகை'), _rs(data.prizeAmount), false),
      (_b('சென்ற சீட்டு இலாபத் தொகை'), _rs(data.previousChitBalance), true),
      (_b('கமிஷன் தொகை'), _rs(data.commission), true),
      (_b('இலாபத் தொகை'), _rs(data.balanceAmount), true),
      (_b('கமிஷன் சீட்டுக்கு கொடுக்க'), _rs(data.commissionToChit), true),
      (_b('நிகர மொத்த இலாபத் தொகை'), _rs(data.netTotalBalance), true),
      (_b('பற்றாக்குறை'), _rs(data.deficit), true),
    ];

    return pw.Table(
      border: pw.TableBorder.all(width: 0.8),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.2),
        1: const pw.FlexColumnWidth(1.3),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: rows
          .map(
            (r) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 7),
                  child: pw.Text(
                    r.$1,
                    style: pw.TextStyle(font: font, fontSize: 9.5),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 7),
                  child: _amountText(r.$2, font, withRupee: r.$3),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  static pw.Widget _buildMemberSection(AuctionPdfData data, pw.Font font) {
    final winnerName = data.winner?.name ?? data.auction.winnerName ?? '';
    final mobile = data.winner?.mobile ?? '';

    pw.Widget line(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(label, style: pw.TextStyle(font: font, fontSize: 9)),
            pw.SizedBox(width: 4),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 2),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.6),
                  ),
                ),
                child: _valueText(
                  value,
                  font,
                  size: 9.5,
                  bold: true,
                ),
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget photoBox(double height) {
      return pw.Container(
        height: height,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.8),
        ),
      );
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _b('சீட்டு எடுத்த உறுப்பினர் பெயர்'),
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              line(_b('திருமதி / திரு'), winnerName),
              line(_b('கையொப்பம்'), ''),
              pw.SizedBox(height: 6),
              pw.Text(
                _b('ஜாமீன்தாரர் பெயர்'),
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              line(_b('திருமதி / திரு'), ''),
              line(_b('கையொப்பம்'), ''),
              pw.SizedBox(height: 6),
              line(_b('பணம் பெற்றுக்கொண்ட நாள் :'), data.formattedDate),
              line(_b('செல்'), mobile),
            ],
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            children: [
              photoBox(78),
              pw.SizedBox(height: 8),
              photoBox(78),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDeclaration(AuctionPdfData data, pw.Font font) {
    final prize = _rs(data.prizeAmount);
    final remaining = '${data.remainingChits}';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: _b(
                    'நான் கீழ்கண்ட நடத்துனராகிய தங்களிடம் சீட்டு தொகை ரூ. '),
                style: _tamilStyle(font, size: 8.5),
              ),
              pw.TextSpan(
                text: prize,
                style: _latinStyle(size: 8.5, bold: true),
              ),
              pw.TextSpan(
                text: _b(' பெற்றுக் கொண்டேன். மீதம் உள்ள '),
                style: _tamilStyle(font, size: 8.5),
              ),
              pw.TextSpan(
                text: remaining,
                style: _latinStyle(size: 8.5, bold: true),
              ),
              pw.TextSpan(
                text: _b(
                    ' சீட்டுகள் முழுவதையும் தவறாமல் செலுத்தி விடுகிறேன் என்று உறுதி கூறுகிறேன்.'),
                style: _tamilStyle(font, size: 8.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: _valueText(_conductorName, font, size: 10, bold: true),
            ),
            pw.Container(
              width: 28,
              height: 28,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.8),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Text(
                        _b('உறுப்பினர் கையொப்பம்'),
                        style: pw.TextStyle(font: font, fontSize: 9),
                      ),
                      pw.Expanded(
                        child: pw.Container(
                          margin: const pw.EdgeInsets.only(left: 4),
                          height: 1,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.Text(
                        _b('விலாசம்'),
                        style: pw.TextStyle(font: font, fontSize: 9),
                      ),
                      pw.Expanded(
                        child: pw.Container(
                          margin: const pw.EdgeInsets.only(left: 4),
                          height: 1,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Container(
            width: 120,
            height: 1,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  static String _rs(double amount) {
    final fmt = NumberFormat('#,##,###', 'en_IN');
    return fmt.format(amount.round());
  }
}
