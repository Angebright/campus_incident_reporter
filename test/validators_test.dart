import 'package:campus_incident_reporter/utils/auth_messages.dart';
import 'package:campus_incident_reporter/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('studentEmail accepts the ALU student format', () {
      expect(Validators.studentEmail('a.muhawenim@alustudent.com'), isNull);
      expect(Validators.studentEmail('A.Muhawenimana@alustudent.com'), isNull);
      expect(Validators.studentEmail('j.doe@alustudent.com'), isNull);
    });

    test('studentEmail rejects wrong domains and shapes', () {
      expect(Validators.studentEmail(''), isNotNull);
      expect(Validators.studentEmail('alice@campuscomfort.app'), isNotNull);
      expect(Validators.studentEmail('amuhawenim@alustudent.com'), isNotNull);
      expect(
        Validators.studentEmail('a.muhawenim@alueducation.com'),
        isNotNull,
      );
      expect(Validators.studentEmail('1.muhawenim@alustudent.com'), isNotNull);
    });

    test('staffEmail accepts the ALU staff domain', () {
      expect(Validators.staffEmail('bernard@alueducation.com'), isNull);
      expect(Validators.staffEmail('a.student@alustudent.com'), isNotNull);
      expect(Validators.staffEmail(''), isNotNull);
    });

    test('aluEmail accepts both ALU domains only', () {
      expect(Validators.aluEmail('a.muhawenim@alustudent.com'), isNull);
      expect(Validators.aluEmail('bernard@alueducation.com'), isNull);
      expect(Validators.aluEmail('someone@gmail.com'), isNotNull);
      expect(Validators.aluEmail(''), isNotNull);
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
