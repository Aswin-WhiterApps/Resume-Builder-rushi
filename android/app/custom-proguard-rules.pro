# Fix for R8 missing class error related to PDFBox and JP2 dependencies
-dontwarn com.gemalto.jp2.**
-keep class com.gemalto.jp2.** { *; }

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Prevent warnings for other potential missing optional dependencies in PDFBox/Android
-dontwarn com.tom_roush.pdfbox.**

# Play Core warnings found in missing_rules.txt
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.**
