import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerView extends StatefulWidget {
  const PdfViewerView({super.key});

  @override
  State<PdfViewerView> createState() => _PdfViewerViewState();
}

class _PdfViewerViewState extends State<PdfViewerView> {

  Future<File> getFile() async {
    final output = await getExternalStorageDirectories(type: StorageDirectory.downloads);
    final file = File("${output![0].path}/Resume.pdf");
    return file;
  }
  @override
  Widget build(BuildContext context)  {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text("PDF Viewing Page"),
              FutureBuilder(
                future: getFile(),
                builder: (BuildContext context,AsyncSnapshot<File> snapshot){
                  if(snapshot.hasData){
                    return   Container(
                      height: 500,
                      width: 500,
                      // child:SfPdfViewer.file(snapshot.data!),
                    );
                  }else if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator());
                  }else{
                    return Text("Something Went Wrong");
                  }
                },

              ),
            ],
          ),
        ),
      ),
    );
  }
}
