import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vvin/data.dart';
import 'package:vvin/mainscreenNotiDB.dart';
import 'package:vvin/more.dart';
import 'package:vvin/vanalytics.dart';
import 'package:vvin/vdata.dart';
import 'package:vvin/myworks.dart';
import 'package:vvin/notifications.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainScreen extends StatefulWidget {
  final CurrentIndex index;
  final int number;
  const MainScreen({
    Key key,
    this.index,
    this.number,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Widget> tabs;
  List<Map> offlineMainNoti;
  int currentTabIndex;
  int index, tap;
  bool gotData;
  String totalNotification, userID, companyID, level, userType;
  String urlNoti = "https://vvinoa.vvin.com/api/notiTotalNumber.php";

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    currentTabIndex = 0;
    index = 0;
    totalNotification = "0";
    gotData = false;
    notification();
    checking();
    super.initState();
    tabs = [
      VAnalytics(),
      VData(),
      MyWorks(),
      Notifications(),
      More(),
    ];
  }

  void checking() {
    try {
      index = widget.index.index;
      onTapped(index);
    } catch (err) {
      print("Main Screen checking error: " + err.toString());
    }
    try {
      if (widget.number != null) {
        setState(() {
          totalNotification = (int.parse(totalNotification) - 1).toString();
        });
      }
    } catch (err) {}
  }

  onTapped(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return Scaffold(
      body: tabs[currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        onTap: onTapped,
        currentIndex: currentTabIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.trending_up,
              size: ScreenUtil().setHeight(40),
            ),
            title: Text(
              "VAnalytics",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24, allowFontScalingSelf: false),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.insert_chart,
              size: ScreenUtil().setHeight(40),
            ),
            title: Text(
              "VData",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24, allowFontScalingSelf: false),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment,
              size: ScreenUtil().setHeight(40),
            ),
            title: Text(
              "My Works",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24, allowFontScalingSelf: false),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: <Widget>[
                Icon(
                  Icons.notifications,
                  size: ScreenUtil().setHeight(40),
                ),
                Positioned(
                    right: 0,
                    child: (totalNotification != "0")
                        ? Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: ScreenUtil().setWidth(20),
                              minHeight: ScreenUtil().setHeight(20),
                            ),
                            child: Text(
                              '$totalNotification',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenUtil()
                                    .setSp(20, allowFontScalingSelf: false),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container())
              ],
            ),
            title: Text(
              "Notifications",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24, allowFontScalingSelf: false),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu,
              size: ScreenUtil().setHeight(40),
            ),
            title: Text(
              "More",
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24, allowFontScalingSelf: false),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> notification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID');
    companyID = prefs.getString('companyID');
    level = prefs.getString('level');
    userType = prefs.getString('user_type');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      http.post(urlNoti, body: {
        "userID": userID,
        "companyID": companyID,
        "level": level,
        "user_type": userType,
      }).then((res) async {
        setState(() {
          totalNotification = res.body;
        });
        setMainNoti();
      }).catchError((err) {
        print("Notification error: " + err.toString());
      });
    } else {
      Database db = await MainScreenNotiDB.instance.database;
      offlineMainNoti = await db.query(MainScreenNotiDB.table);
      setState(() {
        totalNotification = offlineMainNoti[0]['number'].toString();
      });
    }
  }

  Future<void> setMainNoti() async {
    Database db = await MainScreenNotiDB.instance.database;
    await db.rawInsert('DELETE FROM mainnoti WHERE id > 0');
    await db.rawInsert(
        'INSERT INTO mainnoti (number) VALUES ("' + totalNotification + '")');
  }
}
