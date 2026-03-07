import 'package:birdle/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth validation', () {
    test('requiredField should reject null and blank values', () {
      expect(Validators.requiredField(null, fieldName: 'Name'), 'Name is required');
      expect(Validators.requiredField('   ', fieldName: 'Name'), 'Name is required');
      expect(Validators.requiredField(' Dipesh ', fieldName: 'Name'), isNull);
    });

    test('email validator should reject invalid email', () {
      expect(Validators.email('wrong-email'), isNotNull);
      expect(Validators.email('student@uni.edu'), isNull);
      expect(Validators.email('  test@example.com  '), isNull);
    });

    test('password validator should require minimum length', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('      '), isNotNull);
    });

    test('confirm password must match password', () {
      expect(Validators.confirmPassword('', 'abc123'), 'Confirm your password');
      expect(Validators.confirmPassword('abc123', 'abc124'), isNotNull);
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });

    test('minLength should validate trimmed text length', () {
      expect(Validators.minLength(' abc ', 3, fieldName: 'Name'), isNull);
      expect(Validators.minLength('  a ', 3, fieldName: 'Name'), isNotNull);
      expect(Validators.minLength(null, 2, fieldName: 'Name'), isNotNull);
    });
  });
}
