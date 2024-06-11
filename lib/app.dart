import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:projet_flutter_propre/navigation_menu.dart';
import 'package:projet_flutter_propre/screens/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';




class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String? token;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token=prefs.getString('token');
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if(token!=null)
      return const GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: NavMenu(),
      );
    else
      return const GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          home: OnBoardingScreen()
    );



  }
}