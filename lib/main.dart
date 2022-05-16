import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/dashboard_page.dart';
import 'package:anime_themes_player/views/splash_page.dart';
import 'package:flutter/cupertino.dart';
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
    return GestureDetector(
      onTap: () {
        Get.focusScope?.unfocus();
      },
      child: GetMaterialApp(
        title: Values.title,
        debugShowCheckedModeBanner: false,
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
      ),
    );
  }
}
