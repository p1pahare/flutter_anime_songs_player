import 'package:anime_themes_player/views/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    await Future.delayed(const Duration(seconds: 4));
    FlutterNativeSplash.remove();
    Get.offAllNamed(DashboardPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
