import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vvin/data.dart';
import 'package:vvin/vanalytics.dart';
import 'package:vvin/vdata.dart';
import 'login.dart';
import 'mainscreen.dart';
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

class Checking extends StatefulWidget {
  @override
  _CheckingState createState() => _CheckingState();
}

class _CheckingState extends State<Checking> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white, // Color for Android
    ));
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Future.delayed(const Duration(seconds: 1), () => mainScreen());
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
              child: Image.asset(
                'assets/images/splash.png',
              ),
            ),
            // Text(
            //   "Results are everything",
            //   style: TextStyle(
            //     fontStyle: FontStyle.italic,
            //     color: Colors.blue,
            //     fontFamily: 'Roboto',
            //     fontSize: ScreenUtil().setSp(45, allowFontScalingSelf: false),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> mainScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userID') != null) {
      if (prefs.getString('level') == "0") {
        CurrentIndex index = new CurrentIndex(index: 0);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              index: index,
            ),
          ),
        );
      } else if (prefs.getString('level') == "3") {
        CurrentIndex index = new CurrentIndex(index: 1);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              index: index,
            ),
          ),
        );
      } else {
        CurrentIndex index = new CurrentIndex(index: 2);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              index: index,
            ),
          ),
        );
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
    // Navigator.push(context, MaterialPageRoute(builder: (context) => Test()));
  }
}
