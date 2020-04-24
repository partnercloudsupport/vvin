import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_page_transitions/awesome_page_transitions.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:ndialog/ndialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:uni_links/uni_links.dart';
import 'package:vvin/companyDB.dart';
import 'package:vvin/leadsDB.dart';
import 'package:vvin/login.dart';
import 'package:vvin/data.dart';
import 'package:vvin/editCompany.dart';
import 'package:http/http.dart' as http;
import 'package:vvin/mainscreenNotiDB.dart';
import 'package:vvin/more.dart';
import 'package:vvin/myworksDB.dart';
import 'package:vvin/notiDB.dart';
import 'package:vvin/notifications.dart';
import 'package:vvin/topViewDB.dart';
import 'package:vvin/vDataDB.dart';
import 'package:vvin/vanalyticsDB.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final ScrollController controller = ScrollController();

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

enum UniLinksType { string, uri }

class _ProfileState extends State<Profile> {
  double _scaleFactor = 1.0;
  StreamSubscription _sub;
  UniLinksType _type = UniLinksType.string;
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool start, connection, ready;
  int addressLength, emailLength, offLineAddressLength, offLineEmailLength;
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
      nameLocal,
      phoneLocal,
      emailLocal,
      websiteLocal,
      addressLocal,
      location;
  String companyURL = "https://vvinoa.vvin.com/api/companyProfile.php";
  String urlLogout = "https://vvinoa.vvin.com/api/logout.php";

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    check();
    imageCache.clear();
    start = false;
    connection = false;
    offLineAddressLength = 1;
    addressLength = 1;
    offLineEmailLength = 1;
    emailLength = 1;
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        bool noti = false;
        if (noti == false) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => NDialog(
              dialogStyle: DialogStyle(titleDivider: true),
              title: Text("New Notification"),
              content: Text("You have 1 new notification"),
              actions: <Widget>[
                FlatButton(
                    child: Text("View"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => Notifications(),
                        ),
                      );
                    }),
                FlatButton(
                    child: Text("Later"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      if (this.mounted) {
                        setState(() {
                          noti = false;
                        });
                      }
                    }),
              ],
            ),
          );
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
    checkConnection();
    initialize();
    super.initState();
  }

  void check() async {
    if (_type == UniLinksType.string) {
      _sub = getLinksStream().listen((String link) {
        // FlutterWebBrowser.openWebPage(
        //   url: "https://" + link.substring(12),
        // );
      }, onError: (err) {});
    }
  }

  @override
  void dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    double dWidth = MediaQuery.of(context).size.width * 0.8;
    double btnWidth = MediaQuery.of(context).size.width * 0.5;
    double columnWidth = MediaQuery.of(context).size.width * 0.48;
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(235, 235, 255, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            ScreenUtil().setHeight(85),
          ),
          child: AppBar(
            leading: IconButton(
              onPressed: _onBackPressAppBar,
              icon: Icon(
                Icons.arrow_back_ios,
                size: ScreenUtil().setWidth(30),
                color: Colors.grey,
              ),
            ),
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            title: Text(
              "Profile",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: font14,
                  fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              (level == "0" && ready == true)
                  ? FlatButton(
                      textColor: Colors.blue,
                      onPressed: () {
                        if (connection == true) {
                          EditCompanyDetails editCompany =
                              new EditCompanyDetails(
                                  companyID: companyID,
                                  userID: userID,
                                  level: level,
                                  userType: userType,
                                  image: image,
                                  name: name,
                                  phone: phone,
                                  email: email,
                                  website: website,
                                  address: address);
                          Navigator.of(context).push(
                            AwesomePageRoute(
                              transitionDuration: Duration(milliseconds: 600),
                              exitPage: widget,
                              enterPage: EditCompany(company: editCompany),
                              transition: CubeTransition(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: font14,
                        ),
                      ),
                      shape: CircleBorder(
                          side: BorderSide(color: Colors.transparent)),
                    )
                  : Container()
            ],
          ),
        ),
        body: SingleChildScrollView(
          controller: controller,
          child: (start = false)
              ? Container()
              : Container(
                  margin: EdgeInsets.all(
                    ScreenUtil().setWidth(40),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Container(
                                  width: ScreenUtil().setWidth(240),
                                  height: ScreenUtil().setHeight(240),
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
                                          padding: EdgeInsets.all(200.0),
                                          width: ScreenUtil().setWidth(200),
                                          height: ScreenUtil().setHeight(200),
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
                                          width: ScreenUtil().setWidth(200),
                                          height: ScreenUtil().setHeight(200),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                          ),
                                          child: Image.file(
                                            File((location == null)
                                                ? "/data/user/0/com.jtapps.vvin/company/profile.jpg"
                                                : location +
                                                    "/company/profile.jpg"),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            0,
                            ScreenUtil().setWidth(40),
                            0,
                            ScreenUtil().setWidth(40)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding:
                                  EdgeInsets.all(ScreenUtil().setWidth(20)),
                              width: dWidth,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  border: Border.all(
                                      color:
                                          Color.fromARGB(100, 192, 192, 192))),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        width: ScreenUtil().setWidth(150),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              "Name",
                                              style: TextStyle(
                                                  fontSize: font14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: ScreenUtil().setWidth(20),
                                      ),
                                      Container(
                                        width: columnWidth,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: (connection == true)
                                                  ? (nameLocal != null)
                                                      ? Text(
                                                          nameLocal,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: font14,
                                                          ),
                                                        )
                                                      : (name == null)
                                                          ? Text("")
                                                          : Text(
                                                              "$name",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                                fontSize:
                                                                    font14,
                                                              ),
                                                            )
                                                  : (nameLocal != null)
                                                      ? Text(
                                                          nameLocal,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: font14,
                                                          ),
                                                        )
                                                      : Text(""),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(20),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        width: ScreenUtil().setWidth(150),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              "Phone",
                                              style: TextStyle(
                                                  fontSize: font14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: ScreenUtil().setHeight(20),
                                      ),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            (connection == true)
                                                ? (phoneLocal != null)
                                                    ? Text(
                                                        phoneLocal,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize: font14,
                                                        ),
                                                      )
                                                    : (phone == null)
                                                        ? Text("")
                                                        : Text(
                                                            "$phone",
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade600,
                                                              fontSize: font14,
                                                            ),
                                                          )
                                                : (phoneLocal != null)
                                                    ? Text(
                                                        phoneLocal,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize: font14,
                                                        ),
                                                      )
                                                    : Text(""),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(20),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        width: ScreenUtil().setWidth(150),
                                        child: (connection == true)
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  for (var i = 0;
                                                      i < emailLength;
                                                      i++)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        (i == 0)
                                                            ? Text("Email",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        font14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))
                                                            : Text(""),
                                                      ],
                                                    ),
                                                ],
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  for (var i = 0;
                                                      i < offLineEmailLength;
                                                      i++)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        (i == 0)
                                                            ? Text("Email",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        font14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))
                                                            : Text(""),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                      ),
                                      SizedBox(
                                        width: ScreenUtil().setHeight(20),
                                      ),
                                      Container(
                                        width: columnWidth,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: (connection == true)
                                                  ? (emailLocal != null)
                                                      ? Text(
                                                          emailLocal,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: font14,
                                                          ),
                                                        )
                                                      : (email == null)
                                                          ? Text("")
                                                          : Text(
                                                              "$email",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                                fontSize:
                                                                    font14,
                                                              ),
                                                            )
                                                  : (emailLocal != null)
                                                      ? Text(
                                                          emailLocal,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: font14,
                                                          ),
                                                        )
                                                      : Text(""),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setWidth(20),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        width: ScreenUtil().setWidth(150),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                "Website",
                                                style: TextStyle(
                                                    fontSize: font14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: ScreenUtil().setWidth(20),
                                      ),
                                      Container(
                                        width: columnWidth,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: (connection == true)
                                                  ? (websiteLocal != null)
                                                      ? Text(
                                                          websiteLocal,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: font14,
                                                          ),
                                                        )
                                                      : (website == null)
                                                          ? Text("")
                                                          : Text(
                                                              "$website",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                                fontSize:
                                                                    font14,
                                                              ),
                                                            )
                                                  : (websiteLocal != null)
                                                      ? Text(
                                                          websiteLocal,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: font14,
                                                          ),
                                                        )
                                                      : Text(""),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setWidth(20),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      (connection == true)
                                          ? Container(
                                              width: ScreenUtil().setWidth(150),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  for (var i = 0;
                                                      i < addressLength;
                                                      i++)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        (i == 0)
                                                            ? Text(
                                                                "Address",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        font14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            : Text(""),
                                                      ],
                                                    )
                                                ],
                                              ),
                                            )
                                          : Container(
                                              width: ScreenUtil().setWidth(150),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  for (var i = 0;
                                                      i < offLineAddressLength;
                                                      i++)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        (i == 0)
                                                            ? Text(
                                                                "Address",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        font14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )
                                                            : Text(""),
                                                      ],
                                                    )
                                                ],
                                              ),
                                            ),
                                      SizedBox(
                                        width: ScreenUtil().setWidth(20),
                                      ),
                                      Container(
                                        width: columnWidth,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: (connection == true)
                                                  ? (addressLocal != null)
                                                      ? Text(
                                                          addressLocal,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: font14,
                                                          ),
                                                        )
                                                      : (address == null)
                                                          ? Text("")
                                                          : Text(
                                                              address,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                                fontSize:
                                                                    font14,
                                                              ),
                                                            )
                                                  : (addressLocal != null)
                                                      ? Text(
                                                          addressLocal,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: font14,
                                                          ),
                                                        )
                                                      : Text(""),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      BouncingWidget(
                        scaleFactor: _scaleFactor,
                        onPressed: _logout,
                        child: Container(
                          width: btnWidth,
                          height: ScreenUtil().setHeight(80),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(width: 1, color: Colors.blue),
                              top: BorderSide(width: 1, color: Colors.blue),
                              left: BorderSide(width: 1, color: Colors.blue),
                              right: BorderSide(width: 1, color: Colors.blue),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                  fontSize: font14, color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   width: btnWidth,
                      //   height: ScreenUtil().setHeight(80),
                      //   color: Colors.white,
                      //   child: OutlineButton(
                      //     color: Colors.white,
                      //     child: Text(
                      //       'Logout',
                      //       style: TextStyle(
                      //         fontSize: font14,
                      //       ),
                      //     ),
                      //     onPressed: _logout,
                      //     borderSide: BorderSide(
                      //       style: BorderStyle.solid,
                      //       color: Colors.blue,
                      //     ),
                      //     textColor: Colors.blue,
                      //   ),
                      // ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.of(context).pop();
    return Future.value(false);
  }

  void checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      loadData();
    } else {
      if (this.mounted) {
        setState(() {
          start = true;
        });
      }
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
    print(companyID + ", " + userID + ", " + level + ", " + userType);
    http.post(companyURL, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType
    }).then((res) async {
      // print("Get company details status: " + (res.statusCode).toString());
      // print("Company details:" + res.body.toString());
      try {
        final dir = Directory(location + "/company/profile.jpg");
        dir.deleteSync(recursive: true);
      } catch (err) {}
      var jsonData = json.decode(res.body);
      for (var data in jsonData) {
        if (this.mounted) {
          setState(() {
            name = data["name"];
            phone = data["phone"];
            email = data["email"];
            website = data["website"];
            address = data["address"];
            image = data["image"];
            nameLocal = name;
            phoneLocal = phone;
            emailLocal = email;
            websiteLocal = website;
            addressLocal = address;
            setData();
            _downloadImage(image, "company", "profile");
          });
        }
      }
      if (address == null || address == "") {
      } else {
        if (this.mounted) {
          setState(() {
            addressLength = (address.length / 23).ceil();
          });
        }
      }
      if (email == null || email == "") {
      } else {
        if (this.mounted) {
          setState(() {
            emailLength = (email.length / 23).ceil();
          });
        }
      }
      if (this.mounted) {
        setState(() {
          start = true;
          connection = true;
          ready = true;
        });
      }
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
    if (this.mounted) {
      setState(() {
        location = _devicePath.path.toString();
      });
    }

    Database db = await CompanyDB.instance.database;
    List<Map> result = await db.query(CompanyDB.table);
    if (this.mounted) {
      setState(() {
        nameLocal = result[0]['name'];
        phoneLocal = result[0]['phone'];
        emailLocal = result[0]['email'];
        websiteLocal = result[0]['website'];
        addressLocal = result[0]['address'];
      });
    }

    if (addressLocal.length != 0) {
      if (this.mounted) {
        setState(() {
          offLineAddressLength = (addressLocal.length / 23).ceil();
        });
      }
    }
    if (addressLocal.length != 0) {
      if (this.mounted) {
        setState(() {
          offLineEmailLength = (emailLocal.length / 23).ceil();
        });
      }
    }
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
      prefs.setString('companyID', null);
      prefs.setString('userID', null);
      prefs.setString('level', null);
      prefs.setString('user_type', null);
      prefs.setString('totalQR', null);
      prefs.setString('totalLink', null);
      prefs.setString('noti', null);
      prefs.setString('newNoti', null);

      _clearToken();

      Database companyDB = await CompanyDB.instance.database;
      companyDB.rawInsert('DELETE FROM details WHERE id > 0');
      Database leadsDB = await LeadsDB.instance.database;
      leadsDB.rawInsert('DELETE FROM leads WHERE id > 0');
      Database mainscreenNotiDB = await MainScreenNotiDB.instance.database;
      mainscreenNotiDB.rawInsert('DELETE FROM mainnoti WHERE id > 0');
      Database myWorksDB = await MyWorksDB.instance.database;
      myWorksDB.rawInsert('DELETE FROM myworks WHERE id > 0');
      Database notiDB = await NotiDB.instance.database;
      notiDB.rawInsert('DELETE FROM noti WHERE id > 0');
      Database topViewDB = await TopViewDB.instance.database;
      topViewDB.rawInsert('DELETE FROM topview WHERE id > 0');
      Database vanalyticsDB = await VAnalyticsDB.instance.database;
      vanalyticsDB.rawInsert('DELETE FROM analytics WHERE id > 0');
      Database vdataDB = await VDataDB.instance.database;
      vdataDB.rawInsert('DELETE FROM vdata WHERE id > 0');
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
      // Logger().e(_response.statusCode);
    }
  }

  Future<File> _localImage({String path, String name}) async {
    String _path = await _localDevicePath;

    var _newPath = await Directory("$_path/$path").create();
    return File("${_newPath.path}/$name.jpg");
  }
}
