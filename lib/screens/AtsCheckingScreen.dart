import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:resume_builder/Presentation/resources/color_manager.dart';
import 'package:resume_builder/Presentation/resources/values_manager.dart';
import 'package:resume_builder/screens/AtsResultsScreen.dart';
import 'package:resume_builder/services/ats_checking_service.dart';
import 'package:resume_builder/constants/openai_service.dart';

class AtsCheckingScreen extends StatefulWidget {
  final File? initialResumeFile;

  const AtsCheckingScreen({Key? key, this.initialResumeFile}) : super(key: key);

  @override
  _AtsCheckingScreenState createState() => _AtsCheckingScreenState();
}

class _AtsCheckingScreenState extends State<AtsCheckingScreen> {
  File? _selectedFile;
  String? _resumeText;
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialResumeFile != null) {
      _selectedFile = widget.initialResumeFile;
      _extractTextFromFile(_selectedFile!);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
        _resumeText = null; // Reset text until extracted
      });
      _extractTextFromFile(file);
    }
  }

  Future<void> _extractTextFromFile(File file) async {
    try {
      String text = await ReadPdfText.getPDFtext(file.path);
      setState(() {
        _resumeText = text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to read PDF: $e')),
      );
    }
  }

  Future<void> _analyzeResume() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload a resume first')),
      );
      return;
    }

    if (_resumeText == null || _resumeText!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Looking for resume content... please wait')),
      );
      // Try extracting again if empty
      await _extractTextFromFile(_selectedFile!);
      if (_resumeText == null || _resumeText!.isEmpty) return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final atsResult = await ATSCheckingService.instance.analyzeResume(
        resumeContent: _resumeText!,
        jobDescription: _jobDescriptionController.text,
        pdfFile: _selectedFile!,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AtsResultsScreen(atsResult: atsResult),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ATS Resume Checker"),
        backgroundColor: ColorManager.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.p20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Section
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file,
                        size: 30, color: ColorManager.primary),
                    SizedBox(height: 10),
                    Text(
                      _selectedFile != null
                          ? "Selected: ${_selectedFile!.path.split('/').last}"
                          : "Upload Resume (PDF)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedFile != null)
                      Text(
                        "(Tap to change)",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Job Description Section
            Text(
              "Job Description (Optional)",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.black),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _jobDescriptionController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Paste the job description here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue[50],
              ),
            ),
            SizedBox(height: 30),

            // API Key Warning
            if (!OpenAIService.instance.isConfigured)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "OpenAI API Key not found. Using local analysis (less accurate).",
                          style: TextStyle(
                              fontSize: 12, color: Colors.orange[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Check Button
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16), // Taller button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Analyzing with AI...",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    )
                  : Text(
                      "Check ATS",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
