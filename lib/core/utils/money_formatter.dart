import 'package:intl/intl.dart';

final _naira = NumberFormat.currency(
  locale: 'en_NG',
  symbol: 'NGN ',
  decimalDigits: 2,
);

String formatNaira(int kobo) => _naira.format(kobo / 100);

int? koboFromInput(String? input) {
  if (input == null) return null;

  final cleaned = input.trim().replaceAll(',', '').replaceAll(' ', '');
  if (cleaned.isEmpty) return null;
  if (!RegExp(r'^\d{1,15}(\.\d{1,2})?$').hasMatch(cleaned)) return null;

  final parts = cleaned.split('.');
  final naira = int.parse(parts[0]);
  final kobo = parts.length == 2 ? int.parse(parts[1].padRight(2, '0')) : 0;

  return naira * 100 + kobo;
}
