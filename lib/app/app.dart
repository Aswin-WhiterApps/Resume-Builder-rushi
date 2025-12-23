import 'package:flutter/material.dart';

import '../Presentation/resources/route_manager.dart';
import '../Presentation/resources/theme_manager.dart';
import '../services/ai_service_manager.dart';

class MyApp extends StatefulWidget {
  // const MyApp({super.key});
  // MyApp._internal();  //Private Named Constructor
  // int appState = 0;
  // static final MyApp instance = MyApp._internal();  //Single Instance -- Singleton
  // factory MyApp() =>instance; //factory for class Instance
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
      // getSharedData();
    // TODO: implement initState
    super.initState();
    
    // Initialize AI services in the background
    _initializeAIServices();
  }
  
  Future<void> _initializeAIServices() async {
    try {
      await AIServiceManager.instance.initialize();
    } catch (e) {
      // Log error but don't block app startup
      print('AI services initialization failed: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.getRoute,
      initialRoute:
      // userId != null ?
      // Routes.homescreen:
      Routes.splash,
      theme: getApplicationTheme(),
      
      
    );
  }
}