import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:vvin/companyDB.dart';
import 'package:vvin/data.dart';
import 'package:vvin/leadsDB.dart';
import 'package:vvin/mainscreen.dart';
import 'package:vvin/mainscreenNotiDB.dart';
import 'package:vvin/myworksDB.dart';
import 'package:vvin/notiDB.dart';
import 'package:vvin/profile.dart';
import 'package:vvin/settings.dart';
import 'package:vvin/topViewDB.dart';
import 'package:vvin/vDataDB.dart';
import 'package:vvin/vanalyticsDB.dart';

import 'login.dart';

class More extends StatefulWidget {
  More({Key key}) : super(key: key);

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
  final ScrollController controller = ScrollController();
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool start, connection, ready;
  String companyURL = "https://vvinoa.vvin.com/api/companyProfile.php";
  String urlLogout = "https://vvinoa.vvin.com/api/logout.php";
  String level,
      companyID,
      userID,
      userType,
      name,
      phone,
      email,
      website,
      address,
      image,
      unassign,
      assign,
      nameLocal,
      location;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    connection = false;
    checkConnection();
    initialize();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        bool noti = false;
        if (noti == false) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text(
                      "You have 1 new notification",
                      style: TextStyle(
                        fontSize: font14,
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          setState(() {
                            noti = false;
                          });
                        },
                      ),
                      FlatButton(
                        child: Text("View"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          CurrentIndex index = new CurrentIndex(index: 3);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MainScreen(
                                index: index,
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ));
          noti = true;
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            ScreenUtil().setHeight(85),
          ),
          child: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            title: Text(
              "More",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: font18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(20), ScreenUtil().setWidth(20), 0, 0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        width: ScreenUtil().setHeight(2),
                        color: Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              width: ScreenUtil().setWidth(200),
                              height: ScreenUtil().setHeight(200),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(100, 220, 220, 220),
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                            (connection == true)
                                ? Positioned(
                                    top: ScreenUtil().setHeight(20),
                                    left: ScreenUtil().setWidth(20),
                                    child: Container(
                                      padding: EdgeInsets.all(160.0),
                                      width: ScreenUtil().setWidth(160),
                                      height: ScreenUtil().setHeight(160),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        image: DecorationImage(
                                          fit: BoxFit.fitWidth,
                                          image: NetworkImage(image),
                                        ),
                                      ),
                                    ),
                                  )
                                : Positioned(
                                    top: ScreenUtil().setHeight(20),
                                    left: ScreenUtil().setWidth(20),
                                    child: Container(
                                      width: ScreenUtil().setWidth(160),
                                      height: ScreenUtil().setHeight(160),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                      ),
                                      child: Image.file(
                                        File((location == null)
                                            ? "/data/user/0/com.jtapps.vvin/app_flutter/company/profile.jpg"
                                            : location +
                                                "/company/profile.jpg"),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              ScreenUtil().setHeight(220),
                              ScreenUtil().setHeight(50),
                              0,
                              0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                    child: (connection == true)
                                        ? (nameLocal != null)
                                            ? Text(
                                                nameLocal,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: font14,
                                                ),
                                              )
                                            : (name == null)
                                                ? Text("")
                                                : Text(
                                                    "$name",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: font14,
                                                    ),
                                                  )
                                        : (nameLocal != null)
                                            ? Text(
                                                nameLocal,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: font14,
                                                ),
                                              )
                                            : Text(""),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Profile()));
                                      },
                                      child: Text(
                                        "View Profile",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: font14),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setWidth(20),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setting();
                },
                child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          width: ScreenUtil().setHeight(2),
                          color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: ScreenUtil().setWidth(40),
                            child: Icon(
                              Icons.settings,
                              color: Colors.grey,
                              size: ScreenUtil().setWidth(40),
                            ),
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(20),
                          ),
                          Expanded(
                            child: Text(
                              "Settings",
                              style: TextStyle(
                                  fontSize: font14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: ScreenUtil().setWidth(60),
                          ),
                          Flexible(
                            child: Text(
                              "View all settings for notifications here",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: font14,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: _vbusiness,
                child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          width: ScreenUtil().setHeight(2),
                          color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: ScreenUtil().setWidth(40),
                            child: Icon(
                              FontAwesomeIcons.graduationCap,
                              color: Colors.grey,
                              size: ScreenUtil().setWidth(35),
                            ),
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(20),
                          ),
                          Expanded(
                            child: Text(
                              "VBusiness Academy",
                              style: TextStyle(
                                  fontSize: font14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: ScreenUtil().setWidth(60),
                          ),
                          Flexible(
                            child: Text(
                              "Learn more on how you can improve your business",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: font14,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: _logout,
                child: Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          width: ScreenUtil().setHeight(2),
                          color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: ScreenUtil().setWidth(40),
                        child: Icon(
                          FontAwesomeIcons.signOutAlt,
                          color: Colors.grey,
                          size: ScreenUtil().setWidth(35),
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(20),
                      ),
                      Expanded(
                        child: Text(
                          "Log Out",
                          style: TextStyle(
                              fontSize: font14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setting() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      print(connection);
      if (connection == true) {
        Setting setting = Setting(
            companyID: companyID,
            userID: userID,
            level: level,
            userType: userType,
            assign: assign,
            unassign: unassign);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Settings(
                      setting: setting,
                    )));
      } else {
        Toast.show("Data is loading. Please try again.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    } else {
      Toast.show("No Internet Connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _vbusiness() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      FlutterWebBrowser.openWebPage(
        url: "http://cyps.wgxscn.com/mlxy/index/index",
      );
    } else {
      Toast.show("No Internet Connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      loadData();
    } else {
      setState(() {
        start = true;
      });
      Toast.show("No Internet, the data shown is not up to date", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    companyID = prefs.getString('companyID');
    userID = prefs.getString('userID');
    level = prefs.getString('level');
    userType = prefs.getString('user_type');
    http.post(companyURL, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType
    }).then((res) async {
      // print("Get company details status: " + (res.statusCode).toString());
      // print("Company details:" + res.body);
      try {
        final dir = Directory(location + "/company/profile.jpg");
        dir.deleteSync(recursive: true);
      } catch (err) {}
      var jsonData = json.decode(res.body);
      for (var data in jsonData) {
        name = data["name"];
        phone = data["phone"];
        email = data["email"];
        website = data["website"];
        address = data["address"];
        image = data["image"];
        unassign = data["unassign"].toString();
        assign = data["assign"].toString();
      }
      setState(() {
        start = true;
        connection = true;
      });

      final _devicePath = await getApplicationDocumentsDirectory();
      location = _devicePath.path.toString();
      try {
        final dir = Directory(location + "/company/profile.jpg");
        dir.deleteSync(recursive: true);
      } catch (err) {}
      _downloadImage(image, "company", "profile");
    }).catchError((err) {
      print("Load data error: " + (err).toString());
    });
  }

  Future<void> setData() async {
    Database db = await CompanyDB.instance.database;
    await db.rawInsert('DELETE FROM details WHERE id > 0');
    await db.rawInsert(
        'INSERT INTO details (name, phone, email, website, address) VALUES("' +
            name +
            '","' +
            phone +
            '","' +
            email +
            '","' +
            website +
            '","' +
            address +
            '")');
  }

  Future<void> initialize() async {
    final _devicePath = await getApplicationDocumentsDirectory();
    setState(() {
      location = _devicePath.path.toString();
    });
    Database db = await CompanyDB.instance.database;
    List<Map> result = await db.query(CompanyDB.table);
    setState(() {
      nameLocal = result[0]['name'];
    });
  }

  Future<void> _logout() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      final _devicePath = await getApplicationDocumentsDirectory();
      location = _devicePath.path.toString();
      try {
        final dir = Directory(location + "/company/profile.jpg");
        dir.deleteSync(recursive: true);
      } catch (err) {}

      Database db = await MyWorksDB.instance.database;
      List<Map> offlineLink = await db.query(MyWorksDB.table);
      for (int i = 0; i < offlineLink.length; i++) {
        try {
          final dir = Directory(location +
              "/" +
              offlineLink[i]['type'] +
              offlineLink[i]['linkid'] +
              "/VVIN.html");
          dir.deleteSync(recursive: true);
        } catch (err) {}
        try {
          final dir = Directory(location +
              "/" +
              offlineLink[i]['type'] +
              offlineLink[i]['linkid'] +
              "/VVIN.jpg");
          dir.deleteSync(recursive: true);
        } catch (err) {}
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('companyID', null);
      await prefs.setString('userID', null);
      await prefs.setString('level', null);
      await prefs.setString('user_type', null);
      await prefs.setString('totalQR', null);
      await prefs.setString('totalLink', null);

      _clearToken();

      Database companyDB = await CompanyDB.instance.database;
      await companyDB.rawInsert('DELETE FROM details WHERE id > 0');
      Database leadsDB = await LeadsDB.instance.database;
      await leadsDB.rawInsert('DELETE FROM leads WHERE id > 0');
      Database mainscreenNotiDB = await MainScreenNotiDB.instance.database;
      await mainscreenNotiDB.rawInsert('DELETE FROM mainnoti WHERE id > 0');
      Database myWorksDB = await MyWorksDB.instance.database;
      await myWorksDB.rawInsert('DELETE FROM myworks WHERE id > 0');
      Database notiDB = await NotiDB.instance.database;
      await notiDB.rawInsert('DELETE FROM noti WHERE id > 0');
      Database topViewDB = await TopViewDB.instance.database;
      await topViewDB.rawInsert('DELETE FROM topview WHERE id > 0');
      Database vanalyticsDB = await VAnalyticsDB.instance.database;
      await vanalyticsDB.rawInsert('DELETE FROM analytics WHERE id > 0');
      Database vdataDB = await VDataDB.instance.database;
      await vdataDB.rawInsert('DELETE FROM vdata WHERE id > 0');
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      Toast.show("Please connect to Internet first", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _clearToken() {
    http.post(urlLogout, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType,
    }).then((res) async {
      if (res.body == "success") {
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => Login()));
      } else {
        Toast.show(
            "Something wrong, please contact VVIN sales support", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      Toast.show("Something wrong, please contact VVIN help desk", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Logout error: " + (err).toString());
    });
  }

  Future<String> get _localDevicePath async {
    final _devicePath = await getApplicationDocumentsDirectory();
    return _devicePath.path;
  }

  Future _downloadImage(String url, String path, String name) async {
    final _response = await http.get(url);
    if (_response.statusCode == 200) {
      final _file = await _localImage(path: path, name: name);
      await _file.writeAsBytes(_response.bodyBytes);
      // Logger().i("File write complete. File Path ${_saveFile.path}");
    } else {
      Logger().e(_response.statusCode);
    }
  }

  Future<File> _localImage({String path, String name}) async {
    String _path = await _localDevicePath;
    var _newPath = await Directory("$_path/$path").create();
    return File("${_newPath.path}/$name.jpg");
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    return Future.value(false);
  }
}
