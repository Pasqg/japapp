import 'package:flutter_test/flutter_test.dart';
import 'package:japapp/core/practice_stats.dart';

void main() {
  test('Test serialisation round trip', () {
    final stat = Stat(1, 2, {
      'a': 2,
      'b': 3,
    });

    final json = stat.toJson();
    expect(stat, Stat.fromJson(json));
  });
}
