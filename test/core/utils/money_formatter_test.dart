import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/money_formatter.dart';

void main() {
  group('formatNaira', () {
    test('formats whole naira with thousands separators', () {
      expect(formatNaira(1250000), 'NGN 12,500.00');
    });

    test('formats zero', () {
      expect(formatNaira(0), 'NGN 0.00');
    });

    test('formats sub-naira amounts without losing kobo', () {
      expect(formatNaira(7), 'NGN 0.07');
    });

    test('formats amounts with a kobo remainder', () {
      expect(formatNaira(1255050), 'NGN 12,550.50');
    });
  });

  group('koboFromInput', () {
    test('parses two decimal places', () {
      expect(koboFromInput('12.50'), 1250);
    });

    test('pads a single decimal place', () {
      expect(koboFromInput('12.5'), 1250);
    });

    test('parses whole naira', () {
      expect(koboFromInput('12'), 1200);
    });

    test('parses sub-naira amounts exactly', () {
      expect(koboFromInput('0.07'), 7);
    });

    test('strips thousands separators and whitespace', () {
      expect(koboFromInput('1,250.00'), 125000);
      expect(koboFromInput('  12.50  '), 1250);
    });

    test('rejects empty and null input', () {
      expect(koboFromInput(''), isNull);
      expect(koboFromInput(null), isNull);
    });

    test('rejects non-numeric input', () {
      expect(koboFromInput('abc'), isNull);
      expect(koboFromInput('1.2.3'), isNull);
    });

    test('rejects negatives, which the API returns 400 for', () {
      expect(koboFromInput('-5'), isNull);
    });

    test('rejects more precision than kobo allows', () {
      expect(koboFromInput('12.999'), isNull);
    });

    test('rejects amounts too large to store instead of throwing', () {
      expect(koboFromInput('99999999999999999999'), isNull);
    });
  });
}
