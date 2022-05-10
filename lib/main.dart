import 'package:anime_themes_player/views/dashboard_page.dart';
import 'package:anime_themes_player/views/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case DashboardPage.routeName:
            return CupertinoPageRoute(builder: (context) {
              return const DashboardPage();
            });
          case '/':
          default:
            return CupertinoPageRoute(builder: (context) {
              return const SplashPage();
            });
        }
      },
    );
  }
}
