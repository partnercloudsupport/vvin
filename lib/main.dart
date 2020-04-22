import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:vvin/myworks.dart';
import 'package:vvin/vanalytics.dart';
import 'login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() => runApp(SplashScreen());

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: Checking(),
    );
  }
}

enum UniLinksType { string, uri }

class Checking extends StatefulWidget {
  @override
  _CheckingState createState() => _CheckingState();
}

class _CheckingState extends State<Checking> {
  UniLinksType _type = UniLinksType.string;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white,
    ));
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    mainScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: ScreenUtil().setHeight(300),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'assets/images/main_logo.gif',
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Image.asset(
                      'assets/images/splash.png',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> mainScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userID') != null) {
      if (_type == UniLinksType.string) {
        String initialLink;
        try {
          initialLink = await getInitialLink();
          if (initialLink != null) {
            prefs.setString('url', '1');
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => VAnalytics(),
                ),
              );
            });
          } else {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MyWorks(),
                ),
              );
            });
          }
        } catch (e) {}
      }
    } else {
      if (_type == UniLinksType.string) {
        String initialLink;
        try {
          initialLink = await getInitialLink();
          if (initialLink != null) {
            prefs.setString('url', '1');
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login()));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login()));
          }
        } catch (e) {}
      }
    }
  }
}
