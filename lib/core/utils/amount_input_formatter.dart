import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AmountInputFormatter extends TextInputFormatter {
  final _grouping = NumberFormat('#,##0');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) return newValue;
    if (!RegExp(r'^\d{1,15}(\.\d{0,2})?$').hasMatch(raw)) return oldValue;

    final parts = raw.split('.');
    final whole = _grouping.format(int.parse(parts[0]));
    final text = parts.length == 2 ? '$whole.${parts[1]}' : whole;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
