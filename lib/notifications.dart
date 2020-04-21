import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:empty_widget/empty_widget.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:vvin/NotiDetail.dart';
import 'package:vvin/data.dart';
import 'package:vvin/loader.dart';
import 'package:vvin/more.dart';
import 'package:vvin/myworks.dart';
import 'package:vvin/notiDB.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vvin/vanalytics.dart';
import 'package:vvin/vdata.dart';

final ScrollController controller = ScrollController();

class Notifications extends StatefulWidget {
  const Notifications({Key key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  // FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  String urlNoti = "https://vvinoa.vvin.com/api/notiTotalNumber.php";
  String urlNotification = "https://vvinoa.vvin.com/api/notification.php";
  String urlNotiChangeStatus =
      "https://vvinoa.vvin.com/api/notificationAction.php";
  String userID,
      companyID,
      level,
      userType,
      title,
      subtitle1,
      subtitle2,
      totalNotification;
  List<Noti> notifications = [];
  bool status, connection, nodata;
  List<Map> offlineNoti;
  int total, startTime, endTime, currentTabIndex;
  ScrollController _scrollController = ScrollController();
  GlobalKey<RefreshIndicatorState> refreshKey;
  SharedPreferences prefs;
  final _itemExtent = ScreenUtil().setHeight(245);

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    refreshKey = GlobalKey<RefreshIndicatorState>();
    setTime();
    totalNotification = "0";
    currentTabIndex = 3;
    status = false;
    connection = false;
    nodata = false;
    checkConnection();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreNoti();
      }
    });
    super.initState();
  }

  void setTime() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'newNoti', (DateTime.now().millisecondsSinceEpoch).toString());
    print(DateTime.now().millisecondsSinceEpoch);
  }

  void onTapped(int index) {
    if (index != 3) {
      switch (index) {
        case 0:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VAnalytics(),
            ),
          );
          break;
        case 1:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VData(),
            ),
          );
          break;
        case 2:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyWorks(),
            ),
          );
          break;

        case 4:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => More(),
            ),
          );
          break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(235, 235, 255, 1),
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
                                minWidth: 12,
                                minHeight: 12,
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
        // backgroundColor: Color.fromARGB(50, 220, 220, 220),
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
              "Notifications",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: font18,
                  fontWeight: FontWeight.bold),
            ),
            // actions: <Widget>[popupMenuButton()],
          ),
        ),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: _handleRefresh,
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (status == false)
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              JumpingText('Loading...'),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              SpinKitRing(
                                lineWidth: 3,
                                color: Colors.blue,
                                size: 30.0,
                                duration: Duration(milliseconds: 600),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Flexible(
                        child: (nodata == false)
                            ? DraggableScrollbar.arrows(
                                alwaysVisibleScrollThumb: false,
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.only(right: 1.0),
                                labelTextBuilder: (double offset) => Text(
                                    "${(offset ~/ _itemExtent) + 1}",
                                    style: TextStyle(color: Colors.white)),
                                controller: _scrollController,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemExtent: _itemExtent,
                                  scrollDirection: Axis.vertical,
                                  itemCount: (connection == false)
                                      ? offlineNoti.length
                                      : notifications.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (connection == true &&
                                        index == notifications.length) {
                                      if (index != total) {
                                        // return CupertinoActivityIndicator();
                                        return SpinKitRing(
                                            lineWidth: 3,
                                            color: Colors.blue,
                                            size: 30.0,
                                            duration:
                                                Duration(milliseconds: 600));
                                      } else {
                                        return null;
                                      }
                                    }
                                    return InkWell(
                                      onTap: () {
                                        changeStatus(index);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(
                                          ScreenUtil().setHeight(25),
                                          ScreenUtil().setHeight(20),
                                          ScreenUtil().setHeight(25),
                                          ScreenUtil().setHeight(20),
                                        ),
                                        decoration: BoxDecoration(
                                          color: (connection == false)
                                              ? (offlineNoti[index]['status'] ==
                                                      "1")
                                                  ? Colors.white
                                                  : Color.fromRGBO(
                                                      232, 244, 248, 1)
                                              : (notifications[index].status ==
                                                      "1")
                                                  ? Colors.white
                                                  : Color.fromRGBO(
                                                      232, 244, 248, 1),
                                          border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    (connection == false)
                                                        ? checkTitle(
                                                            offlineNoti[index]
                                                                    ['title']
                                                                .toString()
                                                                .substring(7))
                                                        : checkTitle(
                                                            notifications[index]
                                                                .title
                                                                .toString()
                                                                .substring(7)),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: font14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      ScreenUtil().setWidth(10),
                                                ),
                                                Text(
                                                    (connection == false)
                                                        ? offlineNoti[index]
                                                                ['date']
                                                            .toString()
                                                            .substring(0, 10)
                                                        : notifications[index]
                                                            .date
                                                            .toString()
                                                            .substring(0, 10),
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: font12,
                                                    )),
                                              ],
                                            ),
                                            SizedBox(
                                              height:
                                                  ScreenUtil().setHeight(10),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Text(
                                                    (connection == false)
                                                        ? checkSubtitle(
                                                            offlineNoti[index]
                                                                ['subtitle'])
                                                        : checkSubtitle(
                                                            notifications[index]
                                                                .subtitle),
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: font14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: EmptyListWidget(
                                      packageImage: PackageImage.Image_2,
                                      // title: 'No Data',
                                      subTitle: 'No Data',
                                      titleTextStyle: Theme.of(context)
                                          .typography
                                          .dense
                                          .display1
                                          .copyWith(color: Color(0xff9da9c7)),
                                      subtitleTextStyle: Theme.of(context)
                                          .typography
                                          .dense
                                          .body2
                                          .copyWith(color: Color(0xffabb8d6))),
                                ),
                              )
                        // Container(
                        //     height: ScreenUtil().setHeight(200),
                        //     child: Center(
                        //       child: Text(
                        //         "No Data",
                        //         style: TextStyle(
                        //           fontStyle: FontStyle.italic,
                        //           color: Colors.grey,
                        //           fontSize: ScreenUtil().setSp(50,
                        //               allowFontScalingSelf: false),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    if (connection == true) {
      return PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          size: ScreenUtil().setWidth(40),
          color: Colors.grey,
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: "markall",
            child: Text(
              "Mark all as read",
              style: TextStyle(
                fontSize: font14,
              ),
            ),
          ),
        ],
        onSelected: (selectedItem) {
          switch (selectedItem) {
            case "markall":
              {
                markAllAsRead();
              }
              break;
          }
        },
      );
    } else {
      return Container();
    }
  }

  void markAllAsRead() {
    // http
    //     .post(urlNotiChangeStatus, body: {
    //       "userID": userID,
    //       "companyID": companyID,
    //       "level": level,
    //       "user_type": userType,
    //       "id": notifications[index].notiID,
    //       "actionType": "read",
    //     })
    //     .then((res) {})
    //     .catchError((err) {
    //       print("Notification change status error: " + (err).toString());
    //     });
    for (int i = 0; i < notifications.length; i++) {
      if (this.mounted) {
        setState(() {
          notifications[i].status = "1";
        });
      }
    }
    if (this.mounted) {
      setState(() {
        totalNotification = "0";
      });
    }
  }

  void changeStatus(int index) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      String subtitle1, subtitle2;
      List subtitleDetail;
      if (connection == true) {
        subtitleDetail = notifications[index].subtitle.toString().split(",");
      } else {
        subtitleDetail = offlineNoti[index]['subtitle'].toString().split(",");
      }

      if (subtitleDetail.length == 1) {
        subtitle1 = subtitleDetail[0];
        subtitle2 = "";
      } else {
        subtitle1 = subtitleDetail[0];
        subtitle2 = subtitleDetail[1];
      }

      String titleNoti;
      if (connection == true) {
        titleNoti = notifications[index].title;
      } else {
        titleNoti = offlineNoti[index]['title'];
      }

      NotificationDetail notification = new NotificationDetail(
        title: titleNoti,
        subtitle1: subtitle1,
        subtitle2: subtitle2,
      );
      Navigator.of(context).push(_createRoute(notification));

      if (notifications[index].status == "0" && connection == true) {
        http
            .post(urlNotiChangeStatus, body: {
              "userID": userID,
              "companyID": companyID,
              "level": level,
              "user_type": userType,
              "id": notifications[index].notiID,
              "actionType": "read",
            })
            .then((res) {})
            .catchError((err) {
              print("Notification change status error: " + (err).toString());
            });
        if (this.mounted) {
          setState(() {
            notifications[index].status = "1";
            totalNotification = (int.parse(totalNotification) - 1).toString();
          });
        }
        prefs.setString('noti', totalNotification);
      }
    } else {
      Toast.show("Please check your Internet Connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  String checkTitle(String title) {
    String confirmedTitle;
    if (title.substring(0, 1) == "r") {
      confirmedTitle = "You've " + title;
    } else {
      confirmedTitle = title;
    }
    return confirmedTitle;
  }

  String checkSubtitle(String subtitle) {
    String confirmedSubtitle;
    if (subtitle.substring(0, 7) == "Details") {
      confirmedSubtitle = subtitle.substring(8, subtitle.length - 9);
    } else {
      confirmedSubtitle = subtitle;
    }
    return confirmedSubtitle;
  }

  Future<bool> _onBackPressAppBar() async {
    if (!mounted) {
      return null;
    }
    SystemNavigator.pop();
    return Future.value(false);
  }

  void checkConnection() async {
    startTime = (DateTime.now()).millisecondsSinceEpoch;
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString("noti") != null) {
      if (this.mounted) {
        setState(() {
          totalNotification = prefs.getString("noti");
        });
      }
    }
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      getNotifications();
    } else {
      initialize();
      Toast.show("No Internet, the data shown is not up to date", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void getNotifications() async {
    userID = prefs.getString('userID');
    companyID = prefs.getString('companyID');
    level = prefs.getString('level');
    userType = prefs.getString('user_type');
    notification();
    http.post(urlNotification, body: {
      "userID": userID,
      "companyID": companyID,
      "level": level,
      "user_type": userType,
      "count": "0",
    }).then((res) async {
      if (res.body == "nodata") {
        if (this.mounted) {
          setState(() {
            nodata = true;
            status = true;
            connection = true;
          });
        }
        Toast.show("No Data", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        var jsonData = json.decode(res.body);
        total = jsonData[0]['total'];
        String subtitle, subtitle1;
        String subtitle2 = "";
        for (int i = 0; i < jsonData.length; i++) {
          if (jsonData[i]['subtitle'].toString().contains(",")) {
            List subtitleList = jsonData[i]['subtitle'].toString().split(",");
            subtitle1 = subtitleList[0] + ", ";
            List secondSubtitle = subtitleList[1].toString().split(".");

            if (secondSubtitle.length < 3) {
              int match = 0;
              for (int k = 0; k < secondSubtitle[0].length; k++) {
                if (secondSubtitle[0]
                        .toString()
                        .substring(k, k + 1)
                        .contains(new RegExp(r'[A-Z]')) ||
                    secondSubtitle[0]
                        .toString()
                        .substring(k, k + 1)
                        .contains(new RegExp(r'[a-z]'))) {
                  if (match == 0) {
                    subtitle2 = secondSubtitle[0].toString().substring(k) + ".";
                    match++;
                  }
                }
              }
            } else {
              int match = 0;
              if (secondSubtitle.length - 4 != 0) {
                for (int j = 0; j < secondSubtitle.length - 4; j++) {
                  if (j == 0) {
                    for (int k = 0; k < secondSubtitle[0].length; k++) {
                      if (secondSubtitle[0]
                              .toString()
                              .substring(k, k + 1)
                              .contains(new RegExp(r'[A-Z]')) ||
                          secondSubtitle[0]
                              .toString()
                              .substring(k, k + 1)
                              .contains(new RegExp(r'[a-z]'))) {
                        if (match == 0) {
                          subtitle2 =
                              secondSubtitle[0].toString().substring(k) + ".";
                          match++;
                        }
                      }
                    }
                  } else {
                    subtitle2 += secondSubtitle[j] + ".";
                  }
                }
              } else {
                for (int j = 0; j < secondSubtitle.length; j++) {
                  if (j == 0) {
                    for (int k = 0; k < secondSubtitle[0].length; k++) {
                      if (secondSubtitle[0]
                              .toString()
                              .substring(k, k + 1)
                              .contains(new RegExp(r'[A-Z]')) ||
                          secondSubtitle[0]
                              .toString()
                              .substring(k, k + 1)
                              .contains(new RegExp(r'[a-z]'))) {
                        if (match == 0) {
                          subtitle2 =
                              secondSubtitle[0].toString().substring(k) + ".";
                          match++;
                        }
                      }
                    }
                  } else {
                    subtitle2 += secondSubtitle[j] + ".";
                  }
                }
              }
            }
            subtitle = subtitle1 + subtitle2;
          } else {
            subtitle = jsonData[i]['subtitle'];
          }

          Noti notification = Noti(
              title: jsonData[i]['title'],
              subtitle: subtitle,
              date: jsonData[i]['date'],
              notiID: jsonData[i]['id'],
              status: jsonData[i]['status']);
          notifications.add(notification);
        }
        if (this.mounted) {
          setState(() {
            status = true;
            connection = true;
          });
        }
        setNoti();
      }
      endTime = DateTime.now().millisecondsSinceEpoch;
      int result = endTime - startTime;
      print("VAnalytics Loading Time: " + result.toString());
    }).catchError((err) {
      Toast.show(err.toString(), context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get Notifications error: " + (err).toString());
    });
  }

  void notification() {
    http.post(urlNoti, body: {
      "userID": userID,
      "companyID": companyID,
      "level": level,
      "user_type": userType,
    }).then((res) async {
      if (this.mounted) {
        setState(() {
          totalNotification = res.body;
        });
      }
    }).catchError((err) {
      print("Notification error: " + err.toString());
    });
  }

  void _getMoreNoti() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      http.post(urlNotification, body: {
        "userID": userID,
        "companyID": companyID,
        "level": level,
        "user_type": userType,
        "count": notifications.length.toString(),
      }).then((res) {
        var jsonData = json.decode(res.body);

        // print("Notifications body: " + jsonData.toString());
        String subtitle, subtitle1;
        String subtitle2 = "";
        for (int i = 0; i < jsonData.length; i++) {
          if (jsonData[i]['subtitle'].toString().contains(",")) {
            List subtitleList = jsonData[i]['subtitle'].toString().split(",");
            subtitle1 = subtitleList[0] + ", ";
            List secondSubtitle = subtitleList[1].toString().split(".");
            if (secondSubtitle.length < 3) {
              int match = 0;
              for (int k = 0; k < secondSubtitle[0].length; k++) {
                if (secondSubtitle[0]
                        .toString()
                        .substring(k, k + 1)
                        .contains(new RegExp(r'[A-Z]')) ||
                    secondSubtitle[0]
                        .toString()
                        .substring(k, k + 1)
                        .contains(new RegExp(r'[a-z]'))) {
                  if (match == 0) {
                    subtitle2 = secondSubtitle[0].toString().substring(k) + ".";
                    match++;
                  }
                }
              }
            } else {
              int match = 0;
              for (int j = 0; j < secondSubtitle.length - 4; j++) {
                if (j == 0) {
                  for (int k = 0; k < secondSubtitle[0].length; k++) {
                    if (secondSubtitle[0]
                            .toString()
                            .substring(k, k + 1)
                            .contains(new RegExp(r'[A-Z]')) ||
                        secondSubtitle[0]
                            .toString()
                            .substring(k, k + 1)
                            .contains(new RegExp(r'[a-z]'))) {
                      if (match == 0) {
                        subtitle2 =
                            secondSubtitle[0].toString().substring(k) + ".";
                        match++;
                      }
                    }
                  }
                } else {
                  subtitle2 += secondSubtitle[j] + ".";
                }
              }
            }
            subtitle = subtitle1 + subtitle2;
          } else {
            subtitle = jsonData[i]['subtitle'];
          }

          Noti notification = Noti(
              title: jsonData[i]['title'],
              subtitle: subtitle,
              date: jsonData[i]['date'],
              notiID: jsonData[i]['id'],
              status: jsonData[i]['status']);
          notifications.add(notification);
        }
        if (this.mounted) {
          setState(() {
            status = true;
            connection = true;
          });
        }
      }).catchError((err) {
        Toast.show(err, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        print("Get More Notification error: " + (err).toString());
      });
    } else {
      Toast.show(
          "Data can't load, please check your Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 50.0,
          height: 50.0,
          child: Loader(),
        ),
      ),
    );
  }

  Future<void> initialize() async {
    Database db = await NotiDB.instance.database;
    offlineNoti = await db.query(NotiDB.table);
    if (offlineNoti.length == 0) {
      nodata = true;
    }
    if (this.mounted) {
      setState(() {
        status = true;
      });
    }
  }

  Future<void> setNoti() async {
    if (!mounted) {
      return null;
    }
    Database db = await NotiDB.instance.database;
    await db.rawInsert('DELETE FROM noti WHERE id > 0');
    for (int index = 0; index < notifications.length; index++) {
      await db.rawInsert(
          'INSERT INTO noti (title, subtitle, notiid, date, status) VALUES("' +
              notifications[index].title +
              '","' +
              notifications[index].subtitle +
              '","' +
              notifications[index].notiID +
              '","' +
              notifications[index].date +
              '","' +
              notifications[index].status +
              '")');
    }
  }

  Route _createRoute(NotificationDetail notification) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          NotiDetail(notification: notification),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<Null> _handleRefresh() async {
    if (!mounted) {
      return null;
    }
    Completer<Null> completer = Completer<Null>();
    notifications.clear();
    http.post(urlNotification, body: {
      "userID": userID,
      "companyID": companyID,
      "level": level,
      "user_type": userType,
      "count": "0",
    }).then((res) async {
      if (res.body == "nodata") {
        Toast.show("No Data", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        var jsonData = json.decode(res.body);
        total = jsonData[0]['total'];

        String subtitle, subtitle1;
        String subtitle2 = "";
        for (int i = 0; i < jsonData.length; i++) {
          if (jsonData[i]['subtitle'].toString().contains(",")) {
            List subtitleList = jsonData[i]['subtitle'].toString().split(",");
            subtitle1 = subtitleList[0] + ", ";
            List secondSubtitle = subtitleList[1].toString().split(".");
            if (secondSubtitle.length < 3) {
              int match = 0;
              for (int k = 0; k < secondSubtitle[0].length; k++) {
                if (secondSubtitle[0]
                        .toString()
                        .substring(k, k + 1)
                        .contains(new RegExp(r'[A-Z]')) ||
                    secondSubtitle[0]
                        .toString()
                        .substring(k, k + 1)
                        .contains(new RegExp(r'[a-z]'))) {
                  if (match == 0) {
                    subtitle2 = secondSubtitle[0].toString().substring(k) + ".";
                    match++;
                  }
                }
              }
            } else {
              int match = 0;
              for (int j = 0; j < secondSubtitle.length - 4; j++) {
                if (j == 0) {
                  for (int k = 0; k < secondSubtitle[0].length; k++) {
                    if (secondSubtitle[0]
                            .toString()
                            .substring(k, k + 1)
                            .contains(new RegExp(r'[A-Z]')) ||
                        secondSubtitle[0]
                            .toString()
                            .substring(k, k + 1)
                            .contains(new RegExp(r'[a-z]'))) {
                      if (match == 0) {
                        subtitle2 =
                            secondSubtitle[0].toString().substring(k) + ".";
                        match++;
                      }
                    }
                  }
                } else {
                  subtitle2 += secondSubtitle[j] + ".";
                }
              }
            }
            subtitle = subtitle1 + subtitle2;
          } else {
            subtitle = jsonData[i]['subtitle'];
          }

          Noti notification = Noti(
              title: jsonData[i]['title'],
              subtitle: subtitle,
              date: jsonData[i]['date'],
              notiID: "00",
              status: jsonData[i]['status']);
          notifications.add(notification);
        }
        if (this.mounted) {
          setState(() {
            status = true;
            connection = true;
          });
        }
        setNoti();
      }
    }).catchError((err) {
      Toast.show("No Internet connection, data can't load", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get Notifications error: " + (err).toString());
    });
    completer.complete();
    return completer.future;
  }
}
