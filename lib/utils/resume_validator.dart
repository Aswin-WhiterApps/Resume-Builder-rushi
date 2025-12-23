class ResumeValidator {
  /// Validates if a resume file name is valid (must end with .pdf)
  static bool isValidResumeFile(String fileName) {
    if (fileName.isEmpty) return false;
    return fileName.toLowerCase().endsWith('.pdf');
  }

  /// Validates an email address using a regex
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Checks if the implementation plan is strong based on word count
  /// Returns 'Weak', 'Medium', or 'Strong'
  static String evaluateSummaryStrength(String summary) {
    if (summary.isEmpty) return 'Weak';
    final wordCount = summary.trim().split(RegExp(r'\s+')).length;

    if (wordCount < 10) return 'Weak';
    if (wordCount < 50) return 'Medium';
    return 'Strong';
  }
}
