import 'package:flutter_test/flutter_test.dart';
import 'package:resume_builder/utils/resume_validator.dart';

void main() {
  group('ResumeValidator Tests', () {
    // Grouping file validation tests
    group('isValidResumeFile', () {
      test('returns true for files ending with .pdf', () {
        expect(ResumeValidator.isValidResumeFile('my_resume.pdf'), isTrue);
        expect(ResumeValidator.isValidResumeFile('CV.PDF'),
            isTrue); // Case insensitive check
      });

      test('returns false for non-pdf files', () {
        expect(ResumeValidator.isValidResumeFile('image.png'), isFalse);
        expect(ResumeValidator.isValidResumeFile('doc.docx'), isFalse);
      });

      test('returns false for empty string', () {
        expect(ResumeValidator.isValidResumeFile(''), isFalse);
      });
    });

    // Grouping email validation tests
    group('isValidEmail', () {
      test('returns true for valid emails', () {
        expect(ResumeValidator.isValidEmail('test@example.com'), isTrue);
        expect(ResumeValidator.isValidEmail('user.name@domain.co.uk'), isTrue);
      });

      test('returns false for invalid emails', () {
        expect(ResumeValidator.isValidEmail('plainaddress'), isFalse);
        expect(ResumeValidator.isValidEmail('@missingusername.com'), isFalse);
        expect(ResumeValidator.isValidEmail('username@.com.my'), isFalse);
      });
    });

    // Grouping summary strength tests
    group('evaluateSummaryStrength', () {
      test('returns Weak for empty or very short summary', () {
        expect(ResumeValidator.evaluateSummaryStrength(''), 'Weak');
        expect(ResumeValidator.evaluateSummaryStrength('Too short'), 'Weak');
      });

      test('returns Medium for moderate length summary', () {
        String mediumSummary = List.generate(20, (index) => 'word').join(' ');
        expect(
            ResumeValidator.evaluateSummaryStrength(mediumSummary), 'Medium');
      });

      test('returns Strong for long summary', () {
        String longSummary = List.generate(60, (index) => 'word').join(' ');
        expect(ResumeValidator.evaluateSummaryStrength(longSummary), 'Strong');
      });
    });
  });
}
