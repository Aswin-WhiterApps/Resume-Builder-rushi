import 'package:flutter/material.dart';

import '../../../my_singleton.dart';
import '../../resources/assets_manager.dart';
import '../../resources/color_manager.dart';
import '../../resources/font_manager.dart';
import '../../resources/strings_manager.dart';
import '../../resources/values_manager.dart';
import '../create_coverletter.dart';

class CoverLetterTemplatesView extends StatefulWidget {
  const CoverLetterTemplatesView({super.key});

  @override
  State<CoverLetterTemplatesView> createState() =>
      _CoverLetterTemplatesViewState();
}

class _CoverLetterTemplatesViewState extends State<CoverLetterTemplatesView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorManager.tabBackground,
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: AppSize.s16,
        right: AppSize.s16,
        top: AppSize.s16,
        bottom: MediaQuery.of(context).viewPadding.bottom + 84,
      ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppPadding.p8,
                        bottom: AppPadding.p20,
                        top: AppPadding.p8),
                    child: Text(
                      AppStrings.templatesHeader,
                      style: TextStyle(
                          fontSize: FontSize.s20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5,
                          color: Colors.black38,
                          offset: Offset.fromDirection(2, 2))
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: AppSize.s8,
                      right: AppSize.s8,
                      top: AppPadding.p12,
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                              left: AppPadding.p8,
                              right: AppPadding.p8,
                              bottom: AppPadding.p18,
                              top: AppPadding.p18),
                          child: Text(
                            AppStrings.templateScreenText,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: FontSize.s12,
                            ),
                          ),
                        ),
                        GridView.count(
                          childAspectRatio: 0.60,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 30,
                          crossAxisSpacing: 20,
                          crossAxisCount: 2,
                          children: _getListWidgets(),
                        ),
                        SizedBox(
                          height: AppSize.s20,
                        ),
                      ],
                    ),
                  ),
                ),
                  SizedBox(
                    height: AppSize.s20,
                  ),
                ],
              ),
            ),
        ),
        ),
    
    );
  }

  List<Widget> _getListWidgets() => [
        _getTemplateItem(
            item_id: 1, thumbnail: ImageAssets.clTemplate1, isPremium: true),
        _getTemplateItem(
            item_id: 2, thumbnail: ImageAssets.clTemplate2, isPremium: true),
        _getTemplateItem(
            item_id: 3, thumbnail: ImageAssets.clTemplate3, isPremium: true),
        _getTemplateItem(
            item_id: 4, thumbnail: ImageAssets.clTemplate4, isPremium: true),
        _getTemplateItem(
            item_id: 5, thumbnail: ImageAssets.clTemplate5, isPremium: true),
        _getTemplateItem(
            item_id: 6, thumbnail: ImageAssets.clTemplate6, isPremium: true),
        _getTemplateItem(
            item_id: 7, thumbnail: ImageAssets.clTemplate7, isPremium: true),
        _getTemplateItem(
            item_id: 8, thumbnail: ImageAssets.clTemplate8, isPremium: true),
        _getTemplateItem(
            item_id: 9, thumbnail: ImageAssets.clTemplate9, isPremium: true),
        _getTemplateItem(
            item_id: 10, thumbnail: ImageAssets.clTemplate10, isPremium: true),
        _getTemplateItem(
            item_id: 11, thumbnail: ImageAssets.clTemplate11, isPremium: true),
        _getTemplateItem(
            item_id: 12, thumbnail: ImageAssets.clTemplate12, isPremium: true),
        _getTemplateItem(
            item_id: 13, thumbnail: ImageAssets.clTemplate13, isPremium: true),
        _getTemplateItem(
            item_id: 14, thumbnail: ImageAssets.clTemplate14, isPremium: true),
        _getTemplateItem(
            item_id: 15, thumbnail: ImageAssets.clTemplate15, isPremium: true),
        _getTemplateItem(
            item_id: 16, thumbnail: ImageAssets.clTemplate16, isPremium: true),
        _getTemplateItem(
            item_id: 17, thumbnail: ImageAssets.clTemplate17, isPremium: true),
        _getTemplateItem(
            item_id: 18, thumbnail: ImageAssets.clTemplate18, isPremium: true),
        _getTemplateItem(
            item_id: 19, thumbnail: ImageAssets.clTemplate19, isPremium: true),
        _getTemplateItem(
            item_id: 20, thumbnail: ImageAssets.clTemplate20, isPremium: true),
      ];

  Widget _getTemplateItem(
      {required int item_id,
      required String thumbnail,
      required bool isPremium}) {
    return InkWell(
      onTap: () => _onTapListItem(item_id: item_id, isPremium: isPremium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: ColorManager.grey),
            ),
            child: Image.asset(
              fit: BoxFit.cover,
              thumbnail,
              height: 100,
              width: 100,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                ImageAssets.pdfDownloadIc,
                height: 20,
                width: 20,
                color: Colors.blue,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "Download PDF",
                style: TextStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.secondary),
              )
            ],
          )
        ],
      ),
    );
  }

  void _onTapListItem({required int item_id, required bool isPremium}) async {
    // Check if user has entered cover letter data
    final userId = MySingleton.userId;
    final resumeId = MySingleton.resumeId;

    if (userId == null || resumeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a resume first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
    });

    bool dialogShown = false;

    try {
      CreateCoverLetter createPDF = CreateCoverLetter();

      // Show loading dialog
      if (mounted) {
        dialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating PDF...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Generate PDF based on template
      if (item_id == 1) {
        await createPDF.coverLetter1Theme1();
      } else if (item_id == 2) {
        await createPDF.coverLetter1Theme2();
      } else if (item_id == 3) {
        await createPDF.coverLetter1Theme3();
      } else if (item_id == 4) {
        await createPDF.coverLetter2Theme1();
      } else if (item_id == 5) {
        await createPDF.coverLetter2Theme2();
      } else if (item_id == 6) {
        await createPDF.coverLetter2Theme3();
      } else if (item_id == 7) {
        await createPDF.coverLetter3Theme1();
      } else if (item_id == 8) {
        await createPDF.coverLetter3Theme2();
      } else if (item_id == 9) {
        await createPDF.coverLetter3Theme3();
      } else if (item_id == 10) {
        await createPDF.coverLetter4Theme1();
      } else if (item_id == 11) {
        await createPDF.coverLetter4Theme2();
      } else if (item_id == 12) {
        await createPDF.coverLetter4Theme3();
      } else if (item_id == 13) {
        await createPDF.coverLetter5Theme1();
      } else if (item_id == 14) {
        await createPDF.coverLetter5Theme2();
      } else if (item_id == 15) {
        await createPDF.coverLetter5Theme3();
      } else if (item_id == 16) {
        await createPDF.coverLetter5Theme4();
      } else if (item_id == 17) {
        await createPDF.coverLetter6Theme1();
      } else if (item_id == 18) {
        await createPDF.coverLetter6Theme2();
      } else if (item_id == 19) {
        await createPDF.coverLetter6Theme3();
      } else if (item_id == 20) {
        await createPDF.coverLetter6Theme4();
      }

      // Close loading dialog
      if (mounted && dialogShown) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cover letter PDF generated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && dialogShown) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
        });
      }
    }
  }
}
