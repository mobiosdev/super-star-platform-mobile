import 'package:flutter_test/flutter_test.dart';
import 'package:super_star_platform/core/constants/app_colors.dart';

void main() {
  test('AppColors primary matches sky blue', () {
    expect(AppColors.primary.value, 0xFF38BDF8);
  });
}
