import 'package:intl/intl.dart';

class DateFormatter {
  static final _displayFormat = DateFormat('dd MMM yyyy');
  static final _inputFormat = DateFormat('dd/MM/yyyy');
  static final _apiFormat = DateFormat('yyyy-MM-dd');
  static final _monthYearFormat = DateFormat('MMM yyyy');

  static String toDisplay(DateTime? date) {
    if (date == null) return '-';
    return _displayFormat.format(date);
  }

  static String toApi(DateTime date) => _apiFormat.format(date);

  static String toMonthYear(DateTime? date) {
    if (date == null) return '-';
    return _monthYearFormat.format(date);
  }

  static DateTime? fromApi(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static String toInput(DateTime? date) {
    if (date == null) return '';
    return _inputFormat.format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 30) return _displayFormat.format(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
