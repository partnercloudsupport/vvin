import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vvin/data.dart';
import 'package:http/http.dart' as http;
import 'package:vvin/more.dart';
import 'package:vvin/notifications.dart';

class Settings extends StatefulWidget {
  final Setting setting;
  const Settings({Key key, this.setting}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final ScrollController controller = ScrollController();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  String urlNotiChangeStatus =
      "https://vvinoa.vvin.com/api/notificationAction.php";
  String assign, unassign;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    assign = widget.setting.assign;
    unassign = widget.setting.unassign;
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
                          if (this.mounted) {
                            setState(() {
                              noti = false;
                            });
                          }
                        },
                      ),
                      FlatButton(
                        child: Text("View"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          // CurrentIndex index = new CurrentIndex(index: 3);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => Notifications(),
                            ),
                          );
                        },
                      )
                    ],
                  ));
          noti = true;
        }
      },
      onResume: (Map<String, dynamic> message) async {
        List time = message.toString().split('google.sent_time: ');
        String noti = time[1].toString().substring(0, 13);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.getString('newNoti') != noti) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Notifications(),
            ),
          );
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
        // backgroundColor: Color.fromRGBO(235, 235, 255, 1),
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            ScreenUtil().setHeight(85),
          ),
          child: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: _onBackPressAppBar,
              icon: Icon(
                Icons.arrow_back_ios,
                size: ScreenUtil().setWidth(30),
                color: Colors.grey,
              ),
            ),
            elevation: 1,
            centerTitle: true,
            title: Text(
              "Settings",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: font18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: SingleChildScrollView(
          controller: controller,
          child: Container(
            padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Notifications",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: font12,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(20),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "New Unassign Leads",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: font14),
                              ),
                            ],
                          ),
                          SizedBox(height: ScreenUtil().setHeight(10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                    "Notifies you when a there is a new unassign lead in the system",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: font14,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      alignment: Alignment.centerRight,
                      scale: ScreenUtil().setWidth(1.5),
                      child: CupertinoSwitch(
                        activeColor: Colors.blue,
                        value: checkStatus(unassign),
                        onChanged: (bool value) {
                          _changeStatus(value, "unassign");
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(20),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Leads assigned to you",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: font14),
                              ),
                            ],
                          ),
                          SizedBox(height: ScreenUtil().setHeight(10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                    "Notifies you when a lead is assigned to you",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: font14,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      alignment: Alignment.centerRight,
                      scale: ScreenUtil().setWidth(1.5),
                      child: CupertinoSwitch(
                        activeColor: Colors.blue,
                        value: checkStatus(assign),
                        onChanged: (bool value) {
                          _changeStatus(value, "assign");
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeStatus(bool value, String type) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      String status;
      if (value == false) {
        status = "0";
      } else {
        status = "1";
      }
      if (type == "unassign") {
        http.post(urlNotiChangeStatus, body: {
          "userID": widget.setting.userID,
          "companyID": widget.setting.companyID,
          "level": widget.setting.level,
          "user_type": widget.setting.userType,
          "actionType": "updateSetting",
          "unassign": status,
          "assign": assign,
        }).then((res) {
          if (res.body == "1") {
            if (this.mounted) {
              setState(() {
                unassign = status;
              });
            }
            Toast.show("Status changed", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          } else {
            Toast.show(
                "Status can't changed, please check you Internet connection",
                context,
                duration: Toast.LENGTH_LONG,
                gravity: Toast.BOTTOM);
          }
        }).catchError((err) {
          print("Change unassign error: " + (err).toString());
        });
      } else {
        http.post(urlNotiChangeStatus, body: {
          "userID": widget.setting.userID,
          "companyID": widget.setting.companyID,
          "level": widget.setting.level,
          "user_type": widget.setting.userType,
          "actionType": "updateSetting",
          "unassign": unassign,
          "assign": status,
        }).then((res) {
          if (res.body == "1") {
            if (this.mounted) {
              setState(() {
                assign = status;
              });
            }
            Toast.show("Status changed", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          } else {
            Toast.show(
                "Status can't changed, please check you Internet connection",
                context,
                duration: Toast.LENGTH_LONG,
                gravity: Toast.BOTTOM);
          }
        }).catchError((err) {
          print("Change assign error: " + (err).toString());
        });
      }
    }
  }

  bool checkStatus(String checking) {
    bool status;
    if (checking == "1") {
      status = true;
    } else {
      status = false;
    }
    return status;
  }

  Future<bool> _onBackPressAppBar() async {
    // CurrentIndex index = new CurrentIndex(index: 4);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => More(),
      ),
    );
    return Future.value(false);
  }
}
