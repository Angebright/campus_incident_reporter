import 'package:campus_incident_reporter/utils/auth_messages.dart';
import 'package:campus_incident_reporter/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email('alice@campuscomfort.app'), isNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('password', () {
      expect(Validators.password('Campus123'), isNull);
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });

    test('confirmPassword', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
      expect(Validators.confirmPassword('abc124', 'abc123'), isNotNull);
    });

    test('name and required', () {
      expect(Validators.name('Alice'), isNull);
      expect(Validators.name(' '), isNotNull);
      expect(Validators.required('', 'Title'), isNotNull);
      expect(Validators.required('Tap', 'Title'), isNull);
    });
  });

  group('authErrorMessage', () {
    test('maps invalid-credential to a friendly message', () {
      final message = authErrorMessage(
        FirebaseAuthException(code: 'invalid-credential', message: 'raw'),
      );
      expect(message, 'Incorrect email or password.');
    });

    test('maps weak-password', () {
      final message = authErrorMessage(
        FirebaseAuthException(code: 'weak-password', message: 'raw'),
      );
      expect(message, contains('stronger password'));
    });

    test('falls back for non-Firebase errors', () {
      expect(authErrorMessage('boom'), contains('boom'));
    });
  });
}
