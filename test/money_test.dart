import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/money.dart';

void main() {
  group('formatInr (formatting only, no arithmetic on amounts)', () {
    test('groups Indian style and shows paise only when present', () {
      expect(formatInr(0), '₹0');
      expect(formatInr(5), '₹0.05');
      expect(formatInr(99900), '₹999');
      expect(formatInr(842050), '₹8,420.50');
      expect(formatInr(12345678900), '₹12,34,56,789');
      expect(formatInr(-113450 * 100, showPaise: false), '−₹1,13,450');
    });

    test('compact form for big numerals', () {
      expect(formatInrCompact(985000), '₹9,850');
      expect(formatInrCompact(12300000), '₹1.2L');
      expect(formatInrCompact(345000000), '₹34.5L');
      expect(formatInrCompact(34500000000), '₹34.5Cr');
    });
  });

  group('parseInrToMinor (input parsing, no floats)', () {
    test('accepts rupees with up to two decimals', () {
      expect(parseInrToMinor('250'), 25000);
      expect(parseInrToMinor('99.5'), 9950);
      expect(parseInrToMinor('₹1,234.05'), 123405);
    });

    test('rejects invalid input', () {
      expect(parseInrToMinor(''), isNull);
      expect(parseInrToMinor('12.345'), isNull);
      expect(parseInrToMinor('-5'), isNull);
      expect(parseInrToMinor('abc'), isNull);
    });

    test('round trips with minorToInput', () {
      for (final v in [0, 5, 100, 9950, 123405]) {
        expect(parseInrToMinor(minorToInput(v)), v);
      }
    });
  });

  group('discount percent input (integer basis points, no floats)', () {
    test('parses whole and decimal percents', () {
      expect(parsePercentToBp('10'), 1000);
      expect(parsePercentToBp('12.5'), 1250);
      expect(parsePercentToBp('0.25%'), 25);
      expect(parsePercentToBp('100'), 10000);
    });
    test('rejects nonsense and out of range', () {
      for (final bad in ['', 'ten', '0', '100.01', '101', '1.234', '-5']) {
        expect(parsePercentToBp(bad), isNull, reason: bad);
      }
    });
    test('labels', () {
      expect(percentLabel(1000), '10%');
      expect(percentLabel(1250), '12.5%');
      expect(percentLabel(25), '0.25%');
      expect(percentLabel(0), '0%');
    });
  });
}
