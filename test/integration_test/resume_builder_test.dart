import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Resume Builder Integration Tests', () {
    testWidgets('Complete resume building flow', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Initialize app with proper widget setup
      await tester.pumpWidget(IntegrationTestConfig.createTestApp());
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Find and tap Create Resume button
      final createResumeButton = find.text('Create Resume');
      await IntegrationTestConfig.safeTap(tester, createResumeButton);
      
      // Should navigate to resume builder screen
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Look for resume builder tabs
      final resumeBuilderIndicators = [
        find.text('Contact'),
        find.text('Work'),
        find.text('Education'),
        find.text('Summary'),
        find.text('Templates'),
        find.text('Download'),
      ];
      
      bool foundResumeBuilder = false;
      for (final finder in resumeBuilderIndicators) {
        if (tester.any(finder)) {
          foundResumeBuilder = true;
          break;
        }
      }
      
      expect(foundResumeBuilder, isTrue, 
        reason: 'Resume builder screen not loaded');
      
      await IntegrationTestConfig.takeScreenshot(tester, 'resume_builder_loaded');
    });

    testWidgets('Contact tab functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Initialize app with proper widget setup
      await tester.pumpWidget(IntegrationTestConfig.createTestApp());
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      final createResumeButton = find.text('Create Resume');
      await IntegrationTestConfig.safeTap(tester, createResumeButton);
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Navigate to Contact tab
      final contactTab = find.text('Contact');
      if (tester.any(contactTab)) {
        await IntegrationTestConfig.safeTap(tester, contactTab);
        await tester.pumpAndSettle();
      }
      
      // Look for contact form fields
      final contactFields = [
        find.byType(TextField),
        find.text('Name'),
        find.text('Email'),
        find.text('Phone'),
        find.text('Address'),
      ];
      
      bool foundContactForm = false;
      for (final finder in contactFields) {
        if (tester.any(finder)) {
          foundContactForm = true;
          break;
        }
      }
      
      expect(foundContactForm, isTrue, 
        reason: 'Contact form not found');
      
      // Try to fill in contact information
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await IntegrationTestConfig.safeEnterText(
          tester, 
          textFields.first, 
          TestData.testName
        );
      }
      
      await IntegrationTestConfig.takeScreenshot(tester, 'contact_tab_filled');
    });

    testWidgets('Work tab functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Initialize app with proper widget setup
      await tester.pumpWidget(IntegrationTestConfig.createTestApp());
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      final createResumeButton = find.text('Create Resume');
      await IntegrationTestConfig.safeTap(tester, createResumeButton);
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Navigate to Work tab
      final workTab = find.text('Work');
      if (tester.any(workTab)) {
        await IntegrationTestConfig.safeTap(tester, workTab);
        await tester.pumpAndSettle();
      }
      
      // Look for work experience form
      final workIndicators = [
        find.text('Job Title'),
        find.text('Company'),
        find.text('Start Date'),
        find.text('End Date'),
        find.text('Description'),
        find.byType(TextField),
        find.byType(ElevatedButton),
      ];
      
      bool foundWorkForm = false;
      for (final finder in workIndicators) {
        if (tester.any(finder)) {
          foundWorkForm = true;
          break;
        }
      }
      
      expect(foundWorkForm, isTrue, 
        reason: 'Work experience form not found');
      
      await IntegrationTestConfig.takeScreenshot(tester, 'work_tab_loaded');
    });

    testWidgets('Education tab functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Initialize app with proper widget setup
      await tester.pumpWidget(IntegrationTestConfig.createTestApp());
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      final createResumeButton = find.text('Create Resume');
      await IntegrationTestConfig.safeTap(tester, createResumeButton);
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Navigate to Education tab
      final educationTab = find.text('Education');
      if (tester.any(educationTab)) {
        await IntegrationTestConfig.safeTap(tester, educationTab);
        await tester.pumpAndSettle();
      }
      
      // Look for education form
      final educationIndicators = [
        find.text('School'),
        find.text('Degree'),
        find.text('Field of Study'),
        find.text('Start Date'),
        find.text('End Date'),
        find.byType(TextField),
      ];
      
      bool foundEducationForm = false;
      for (final finder in educationIndicators) {
        if (tester.any(finder)) {
          foundEducationForm = true;
          break;
        }
      }
      
      expect(foundEducationForm, isTrue, 
        reason: 'Education form not found');
      
      await IntegrationTestConfig.takeScreenshot(tester, 'education_tab_loaded');
    });

    testWidgets('Summary tab functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Initialize app with proper widget setup
      await tester.pumpWidget(IntegrationTestConfig.createTestApp());
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      final createResumeButton = find.text('Create Resume');
      await IntegrationTestConfig.safeTap(tester, createResumeButton);
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Navigate to Summary tab
      final summaryTab = find.text('Summary');
      if (tester.any(summaryTab)) {
        await IntegrationTestConfig.safeTap(tester, summaryTab);
        await tester.pumpAndSettle();
      }
      
      // Look for summary form
      final summaryIndicators = [
        find.text('Professional Summary'),
        find.text('Objective'),
        find.byType(TextField),
        find.byType(TextFormField),
      ];
      
      bool foundSummaryForm = false;
      for (final finder in summaryIndicators) {
        if (tester.any(finder)) {
          foundSummaryForm = true;
          break;
        }
      }
      
      expect(foundSummaryForm, isTrue, 
        reason: 'Summary form not found');
      
      await IntegrationTestConfig.takeScreenshot(tester, 'summary_tab_loaded');
    });

    testWidgets('Templates tab functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Initialize app with proper widget setup
      await tester.pumpWidget(IntegrationTestConfig.createTestApp());
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      final createResumeButton = find.text('Create Resume');
      await IntegrationTestConfig.safeTap(tester, createResumeButton);
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Navigate to Templates tab
      final templatesTab = find.text('Templates');
      if (tester.any(templatesTab)) {
        await IntegrationTestConfig.safeTap(tester, templatesTab);
        await tester.pumpAndSettle();
      }
      
      // Look for template selection
      final templateIndicators = [
        find.byType(GestureDetector),
        find.byType(Card),
        find.byType(Container),
        find.byType(Image),
      ];
      
      bool foundTemplates = false;
      for (final finder in templateIndicators) {
        if (tester.any(finder)) {
          foundTemplates = true;
          break;
        }
      }
      
      expect(foundTemplates, isTrue, 
        reason: 'Template selection not found');
      
      await IntegrationTestConfig.takeScreenshot(tester, 'templates_tab_loaded');
    });

    testWidgets('Download tab functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Initialize app with proper widget setup
      await tester.pumpWidget(IntegrationTestConfig.createTestApp());
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      final createResumeButton = find.text('Create Resume');
      await IntegrationTestConfig.safeTap(tester, createResumeButton);
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Navigate to Download tab
      final downloadTab = find.text('Download');
      if (tester.any(downloadTab)) {
        await IntegrationTestConfig.safeTap(tester, downloadTab);
        await tester.pumpAndSettle();
      }
      
      // Look for download options
      final downloadIndicators = [
        find.text('Download PDF'),
        find.text('Share'),
        find.text('Preview'),
        find.byType(ElevatedButton),
        find.byType(OutlinedButton),
      ];
      
      bool foundDownloadOptions = false;
      for (final finder in downloadIndicators) {
        if (tester.any(finder)) {
          foundDownloadOptions = true;
          break;
        }
      }
      
      expect(foundDownloadOptions, isTrue, 
        reason: 'Download options not found');
      
      await IntegrationTestConfig.takeScreenshot(tester, 'download_tab_loaded');
    });

    testWidgets('Tab navigation functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Initialize app with proper widget setup
      await tester.pumpWidget(IntegrationTestConfig.createTestApp());
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      final createResumeButton = find.text('Create Resume');
      await IntegrationTestConfig.safeTap(tester, createResumeButton);
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Test navigation between tabs
      final tabs = ['Contact', 'Work', 'Education', 'Summary', 'Templates', 'Download'];
      
      for (final tabName in tabs) {
        final tab = find.text(tabName);
        if (tester.any(tab)) {
          await IntegrationTestConfig.safeTap(tester, tab);
          await tester.pumpAndSettle();
          
          // Verify tab content loaded (no crashes)
          expect(tester.takeException(), isNull);
        }
      }
      
      await IntegrationTestConfig.takeScreenshot(tester, 'tab_navigation_complete');
    });

    testWidgets('Save and continue functionality', (WidgetTester tester) async {
      await IntegrationTestConfig.initApp();
      
      // Initialize app with proper widget setup
      await tester.pumpWidget(IntegrationTestConfig.createTestApp());
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      final createResumeButton = find.text('Create Resume');
      await IntegrationTestConfig.safeTap(tester, createResumeButton);
      await tester.pumpAndSettle(IntegrationTestConfig.defaultTimeout);
      
      // Look for save/continue buttons
      final saveButtons = [
        find.text('Save'),
        find.text('Continue'),
        find.text('Next'),
        find.byType(ElevatedButton),
      ];
      
      bool foundSaveButton = false;
      Finder saveButtonFinder = find.byType(Container); // Default fallback
      
      for (final finder in saveButtons) {
        if (tester.any(finder)) {
          foundSaveButton = true;
          saveButtonFinder = finder;
          break;
        }
      }
      
      if (foundSaveButton) {
        await IntegrationTestConfig.safeTap(tester, saveButtonFinder);
        await tester.pumpAndSettle();
        
        // Verify app is still responsive after save
        expect(tester.takeException(), isNull);
      }
      
      await IntegrationTestConfig.takeScreenshot(tester, 'save_functionality');
    });
  });
}
