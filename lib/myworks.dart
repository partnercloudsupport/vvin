import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:vvin/data.dart';
import 'package:vvin/loader.dart';
import 'package:http/http.dart' as http;
import 'package:vvin/myworksDB.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:vvin/mainscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:vvin/whatsappForward.dart';

final ScrollController controller = ScrollController();
final ScrollController whatsappController = ScrollController();

class MyWorks extends StatefulWidget {
  const MyWorks({Key key}) : super(key: key);

  @override
  _MyWorksState createState() => _MyWorksState();
}

class _MyWorksState extends State<MyWorks> {
  double font10 = ScreenUtil().setSp(23, allowFontScalingSelf: false);
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font13 = ScreenUtil().setSp(30, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font15 = ScreenUtil().setSp(34.5, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _companycontroller = TextEditingController();
  final TextEditingController _remarkcontroller = TextEditingController();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  GlobalKey<RefreshIndicatorState> refreshKey;
  String filePath = "";
  List<Map> offlineLink;
  List<String> vtagList = [];
  Database db;
  int total, startTime, endTime, imageIndex, linkIndex, totalQR, totalLink;
  bool isOffline, status, connection, nodata, link, image, send;
  String search,
      companyID,
      userID,
      level,
      userType,
      category,
      dateInternet,
      titleInternet,
      linkInternet,
      typeInternet,
      location;
  String urlMyWorks = "https://vvinoa.vvin.com/api/myWorks.php";
  List<Myworks> myWorks = [];
  List<Myworks> myWorks1 = [];
  SharedPreferences prefs;
  File pickedImage;
  bool isImageLoaded;
  bool _validate = false;
  List<String> scanner = [];
  List<String> phoneList = [];
  List<String> otherList = [];
  String tempText = "";
  ScrollController _scrollController = ScrollController();
  final _itemExtent = ScreenUtil().setHeight(280);

  @override
  void initState() {
    imageCache.clear();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    refreshKey = GlobalKey<RefreshIndicatorState>();
    vtagList.add("value");
    vtagList.add("valuedsfgf");
    vtagList.add("345678");
    send = true;
    isOffline = false;
    status = false;
    connection = false;
    nodata = false;
    link = false;
    image = false;
    isImageLoaded = false;
    _phonecontroller.text = "";
    _namecontroller.text = "";
    _companycontroller.text = "";
    _remarkcontroller.text = "";
    search = "";
    category = "all";
    total = 0;
    imageIndex = 0;
    linkIndex = 0;
    checkConnection();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        send = false;
      });
    });
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
              "My Works",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: font18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: _handleRefresh,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
            child: Column(
              children: <Widget>[
                (send == false)
                    ? Container()
                    : Container(
                        margin: EdgeInsets.fromLTRB(
                            ScreenUtil().setHeight(20),
                            0,
                            ScreenUtil().setHeight(20),
                            ScreenUtil().setHeight(20)),
                        padding: EdgeInsets.all(ScreenUtil().setHeight(5)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.green, style: BorderStyle.solid),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                  ScreenUtil().setHeight(10),
                                  0,
                                  ScreenUtil().setHeight(20),
                                  0),
                              child: Icon(FontAwesomeIcons.checkCircle,
                                  size: ScreenUtil().setHeight(20),
                                  color: Colors.green),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Your recipient should receive the content.",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: font12),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Data has been recorded to VData",
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: font12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Card(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                ScreenUtil().setHeight(20),
                                0,
                                ScreenUtil().setHeight(20),
                                0),
                            height: ScreenUtil().setHeight(80),
                            child: TextField(
                              onChanged: _search,
                              style: TextStyle(
                                fontSize: font14,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: ScreenUtil().setHeight(6),
                                ),
                                hintText: "Search",
                                suffix: IconButton(
                                  iconSize: ScreenUtil().setHeight(35),
                                  icon: Icon(Icons.keyboard_hide),
                                  onPressed: () {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  },
                                ),
                                suffixIcon: Icon(
                                  Icons.search,
                                  size: ScreenUtil().setHeight(45),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(10), 0,
                          ScreenUtil().setHeight(0), 0),
                      child: Card(
                        child: InkWell(
                          onTap: _myWorkfilter,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(
                              ScreenUtil().setHeight(15),
                            ),
                            child: Icon(
                              Icons.tune,
                              size: ScreenUtil().setHeight(45),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(10),
                ),
                (status == true)
                    ? Container(
                        padding: EdgeInsets.all(
                          ScreenUtil().setHeight(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "QR downloaded: " + totalQR.toString(),
                              style: TextStyle(fontSize: font12),
                            ),
                            Text(
                              "Link downloaded: " + totalLink.toString(),
                              style: TextStyle(fontSize: font12),
                            )
                          ],
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: ScreenUtil().setHeight(10),
                ),
                (status == true)
                    ? (nodata == true)
                        ? Container(
                            height: ScreenUtil().setHeight(200),
                            child: Center(
                              child: Text(
                                "No Data",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                  fontSize: ScreenUtil()
                                      .setSp(50, allowFontScalingSelf: false),
                                ),
                              ),
                            ),
                          )
                        : Flexible(
                            child: DraggableScrollbar.arrows(
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
                                itemCount: (connection == false)
                                    ? offlineLink.length
                                    : myWorks.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, int index) {
                                  return Card(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.fromLTRB(
                                              ScreenUtil().setHeight(20),
                                              ScreenUtil().setHeight(20),
                                              ScreenUtil().setHeight(20),
                                              ScreenUtil().setHeight(10)),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                height:
                                                    ScreenUtil().setHeight(40),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      (connection == false)
                                                          ? _dateFormat(
                                                              offlineLink[index]
                                                                  ['date'])
                                                          : _dateFormat(
                                                              myWorks[index]
                                                                  .date),
                                                      style: TextStyle(
                                                        fontSize: font12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    PopupMenuButton<String>(
                                                        padding:
                                                            EdgeInsets.all(0.1),
                                                        child: Container(
                                                          height: ScreenUtil()
                                                              .setHeight(40),
                                                          width: ScreenUtil()
                                                              .setHeight(30),
                                                          child: Icon(
                                                            Icons.more_vert,
                                                            size: ScreenUtil()
                                                                .setHeight(38),
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        itemBuilder: (BuildContext
                                                                context) =>
                                                            <
                                                                PopupMenuEntry<
                                                                    String>>[
                                                              PopupMenuItem<
                                                                  String>(
                                                                value: "assign",
                                                                child: Text(
                                                                  "Assign",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        font14,
                                                                  ),
                                                                ),
                                                              ),
                                                              PopupMenuItem<
                                                                  String>(
                                                                value:
                                                                    "visit url",
                                                                child: Text(
                                                                  "Visit URL",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        font14,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                        onSelected:
                                                            (selectedItem) async {
                                                          switch (
                                                              selectedItem) {
                                                            case "assign":
                                                              {
                                                                _assign();
                                                              }
                                                              break;
                                                            case "visit url":
                                                              {
                                                                _visitURL(
                                                                    index);
                                                              }
                                                              break;
                                                          }
                                                        }),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    (connection == false)
                                                        ? offlineLink[index]
                                                            ['type']
                                                        : myWorks[index]
                                                            .category,
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: font12,
                                                    ),
                                                  ),
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
                                                  Text(
                                                    (connection == false)
                                                        ? offlineLink[index]
                                                            ['title']
                                                        : myWorks[index].title,
                                                    style: TextStyle(
                                                        fontSize: font15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height:
                                                    ScreenUtil().setHeight(10),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        (connection == true)
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    "Available Offline",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            font12),
                                                                  )
                                                                ],
                                                              )
                                                            : Container(),
                                                        (connection == true)
                                                            ? Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Transform
                                                                      .scale(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    scale: ScreenUtil()
                                                                        .setWidth(
                                                                            1.5),
                                                                    child:
                                                                        CupertinoSwitch(
                                                                      activeColor:
                                                                          Colors
                                                                              .blue,
                                                                      value: myWorks[
                                                                              index]
                                                                          .offLine,
                                                                      onChanged:
                                                                          (bool
                                                                              value) {
                                                                        setState(
                                                                            () {
                                                                          myWorks[index].offLine =
                                                                              value;
                                                                        });
                                                                      },
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                            : Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    "Offline Mode",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          font12,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(70),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                    child: OutlineButton(
                                                      borderSide: BorderSide(
                                                        style:
                                                            BorderStyle.solid,
                                                        color: Colors.blue,
                                                      ),
                                                      textColor: Colors.blue,
                                                      onPressed:
                                                          _whatsappForward,
                                                      padding: EdgeInsets.all(
                                                        ScreenUtil()
                                                            .setHeight(1),
                                                      ),
                                                      color: Colors.white,
                                                      child: Text(
                                                        'Forward',
                                                        style: TextStyle(
                                                            fontSize: font12,
                                                            color: Colors.blue,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: ScreenUtil()
                                                        .setWidth(20),
                                                  ),
                                                  SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(70),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.25,
                                                    child: OutlineButton(
                                                      padding: EdgeInsets.all(
                                                        ScreenUtil()
                                                            .setHeight(1),
                                                      ),
                                                      color: Colors.white,
                                                      child: Text(
                                                        'QR Code',
                                                        style: TextStyle(
                                                            fontSize: font12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      onPressed: () async {
                                                        if (connection ==
                                                            true) {
                                                          if (myWorks[index]
                                                                  .offLine ==
                                                              false) {
                                                            if (myWorks[index]
                                                                    .qr ==
                                                                "") {
                                                              Toast.show(
                                                                  "No QR generated for this link",
                                                                  context,
                                                                  duration: Toast
                                                                      .LENGTH_LONG,
                                                                  gravity: Toast
                                                                      .BOTTOM);
                                                            } else {
                                                              FlutterWebBrowser
                                                                  .openWebPage(
                                                                url: myWorks[
                                                                        index]
                                                                    .qr,
                                                              );
                                                            }
                                                          } else {
                                                            var path = location +
                                                                "/" +
                                                                myWorks[index]
                                                                    .category +
                                                                myWorks[index]
                                                                    .id +
                                                                "/VVIN.jpg";
                                                            if (File(path)
                                                                    .existsSync() ==
                                                                true) {
                                                              await OpenFile
                                                                  .open(path);
                                                            } else {
                                                              Toast.show(
                                                                  "This offline QR still in downloading or not available",
                                                                  context,
                                                                  duration: Toast
                                                                      .LENGTH_LONG,
                                                                  gravity: Toast
                                                                      .BOTTOM);
                                                            }
                                                          }
                                                        } else {
                                                          var path = location +
                                                              "/" +
                                                              offlineLink[index]
                                                                  ['type'] +
                                                              offlineLink[index]
                                                                  ['linkid'] +
                                                              "/VVIN.jpg";
                                                          if (File(path)
                                                                  .existsSync() ==
                                                              true) {
                                                            await OpenFile.open(
                                                                path);
                                                          } else {
                                                            Toast.show(
                                                                "This offline QR is not available.",
                                                                context,
                                                                duration: Toast
                                                                    .LENGTH_LONG,
                                                                gravity: Toast
                                                                    .BOTTOM);
                                                          }
                                                        }
                                                      },
                                                      borderSide: BorderSide(
                                                        style:
                                                            BorderStyle.solid,
                                                        color: Colors.blue,
                                                      ),
                                                      textColor: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Data loading..."),
                              CupertinoActivityIndicator()
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _assign() {
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(
                            ScreenUtil().setHeight(10),
                          ),
                          child: Text(
                            "Assign",
                            style: TextStyle(
                                fontSize: font14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  padding: EdgeInsets.all(
                                    ScreenUtil().setHeight(20),
                                  ),
                                  child: Text(
                                    "Done",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: font14,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(ScreenUtil().setHeight(10)),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil().setHeight(10),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                  "Assign handler for the leads generated by this work",
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: font13)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(5),
                        ),
                        Container(
                          padding: EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Colors.grey.shade400,
                                style: BorderStyle.solid),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(
                                      ScreenUtil().setHeight(10), 0, 0, 0),
                                  child: (vtagList.length == 0)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Handler",
                                              style: TextStyle(
                                                  fontSize: font13,
                                                  color: Colors.grey),
                                            )
                                          ],
                                        )
                                      : Wrap(
                                          direction: Axis.horizontal,
                                          alignment: WrapAlignment.start,
                                          children: <Widget>[
                                            for (int i = 0;
                                                i < vtagList.length;
                                                i++)
                                              Container(
                                                width: ScreenUtil().setWidth(
                                                    (vtagList[i].length * 18) +
                                                        62.8),
                                                margin: EdgeInsets.all(
                                                    ScreenUtil().setHeight(5)),
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      235, 235, 255, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                padding: EdgeInsets.all(
                                                  ScreenUtil().setHeight(10),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      vtagList[i],
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: font13,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: ScreenUtil()
                                                          .setHeight(5),
                                                    ),
                                                    Icon(
                                                      FontAwesomeIcons
                                                          .timesCircle,
                                                      size: ScreenUtil()
                                                          .setHeight(30),
                                                      color: Colors.grey,
                                                    )
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _selectHandler();
                                },
                                child: Container(
                                  height: ScreenUtil().setHeight(60),
                                  width: ScreenUtil().setHeight(60),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  void _selectHandler() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(
                            ScreenUtil().setHeight(20),
                          ),
                          child: Text(
                            "Select",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: font14,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: EdgeInsets.all(
                              ScreenUtil().setHeight(20),
                            ),
                            child: Text(
                              "Done",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: font14,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _assign();
                          },
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                      child: Container(
                    color: Colors.white,
                    child: CupertinoPicker(
                      backgroundColor: Colors.white,
                      itemExtent: 28,
                      scrollController:
                          FixedExtentScrollController(initialItem: 0),
                      onSelectedItemChanged: (int index) {},
                      children: <Widget>[],
                    ),
                  ))
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _whatsappForward() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      showModalBottomSheet(
          isScrollControlled: true,
          isDismissible: false,
          context: context,
          builder: (context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                  height: MediaQuery.of(context).size.height * 0.97,
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 1, color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Container(
                            //   padding: EdgeInsets.all(
                            //     ScreenUtil().setHeight(10),
                            //   ),
                            //   child: Text(
                            //     "WhatsApp Forward",
                            //     style: TextStyle(
                            //         fontSize: font14,
                            //         fontWeight: FontWeight.bold),
                            //   ),
                            // ),
                            // Container(
                            //   child: Row(
                            //     children: <Widget>[
                            //       InkWell(
                            //         borderRadius: BorderRadius.circular(20),
                            //         child: Container(
                            //           decoration: BoxDecoration(
                            //             borderRadius:
                            //                 BorderRadius.circular(100),
                            //           ),
                            //           padding: EdgeInsets.all(
                            //             ScreenUtil().setHeight(20),
                            //           ),
                            //           child: Text(
                            //             "Add Name Card",
                            //             style: TextStyle(
                            //               color: Colors.blue,
                            //               fontSize: font14,
                            //             ),
                            //           ),
                            //         ),
                            //         onTap: _scanner,
                            //       ),
                            //       InkWell(
                            //         borderRadius: BorderRadius.circular(20),
                            //         child: Container(
                            //           decoration: BoxDecoration(
                            //             borderRadius:
                            //                 BorderRadius.circular(100),
                            //           ),
                            //           padding: EdgeInsets.all(
                            //             ScreenUtil().setHeight(20),
                            //           ),
                            //           child: Icon(
                            //             FontAwesomeIcons.timesCircle,
                            //             color: Colors.blue,
                            //             size: ScreenUtil().setHeight(32.2),
                            //           ),
                            //           // Text(
                            //           //   "Cancel",
                            //           //   style: TextStyle(
                            //           //     color: Colors.blue,
                            //           //     fontSize: font14,
                            //           //   ),
                            //           // ),
                            //         ),
                            //         onTap: () {
                            //           Navigator.of(context).pop();
                            //         },
                            //       )
                            //     ],
                            //   ),
                            // )
                          ],
                        ),
                      ),
                      Flexible(
                        child: Scaffold(
                          resizeToAvoidBottomInset: true,
                          body: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            controller: whatsappController,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(
                                  ScreenUtil().setHeight(30),
                                  ScreenUtil().setHeight(20),
                                  ScreenUtil().setHeight(30),
                                  ScreenUtil().setHeight(30)),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Icon(
                                          FontAwesomeIcons.timesCircle,
                                          color: Colors.blue,
                                          size: ScreenUtil().setHeight(40),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Whatsapp Forward",
                                        style: TextStyle(
                                            fontSize: font18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(50),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Recipient Name Card",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: font14),
                                      ),
                                    ],
                                  ),
                                  (isImageLoaded)
                                      ? Container()
                                      : Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: ScreenUtil().setHeight(5),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Flexible(
                                                  child: Text(
                                                    "Snap a photo of the recipient’s name card to fill form faster.",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: font14),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(10),
                                  ),
                                  (isImageLoaded)
                                      ? Center(
                                          child: Container(
                                            height: 177,
                                            width: 280,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: FileImage(pickedImage),
                                                  fit: BoxFit.contain),
                                            ),
                                          ),
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            Stack(
                                              children: <Widget>[
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(140),
                                                  height: ScreenUtil()
                                                      .setHeight(140),
                                                  decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        100, 220, 220, 220),
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: ScreenUtil()
                                                      .setHeight(20),
                                                  left:
                                                      ScreenUtil().setWidth(20),
                                                  child: Container(
                                                      width: ScreenUtil()
                                                          .setWidth(100),
                                                      height: ScreenUtil()
                                                          .setHeight(100),
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                      ),
                                                      child: Icon(
                                                        FontAwesomeIcons
                                                            .addressCard,
                                                        color: Colors.grey,
                                                        size: ScreenUtil()
                                                            .setHeight(40),
                                                      )),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  ScreenUtil().setHeight(150),
                                                  ScreenUtil().setHeight(40),
                                                  0,
                                                  0),
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[],
                                                  ),
                                                  SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(20),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      InkWell(
                                                          onTap: _scanner,
                                                          child: Text(
                                                            "Take Photo",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize:
                                                                    font14),
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(30),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Recipient Phone Number",
                                          style: TextStyle(fontSize: font14)),
                                      Text(" - Required",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                              fontStyle: FontStyle.italic))
                                    ],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(5),
                                  ),
                                  Container(
                                    height: ScreenUtil().setHeight(60),
                                    padding: EdgeInsets.all(0.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          style: BorderStyle.solid),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: TextField(
                                            controller: _phonecontroller,
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: font14,
                                            ),
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              hintText: "eg. 6012XXXXXXXX",
                                              // labelText: 'Enter the Value',
                                              // errorText: _validate ? 'Value Can\'t Be Empty' : null,
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: ScreenUtil()
                                                      .setHeight(10),
                                                  bottom: ScreenUtil()
                                                      .setHeight(20),
                                                  top: ScreenUtil()
                                                      .setHeight(-15),
                                                  right: ScreenUtil()
                                                      .setHeight(20)),
                                            ),
                                          ),
                                        ),
                                        (isImageLoaded == true)
                                            ? InkWell(
                                                onTap: () {
                                                  if (phoneList.length != 0) {
                                                    _showBottomSheet("phone");
                                                  } else {
                                                    Toast.show(
                                                        "No phone number detected",
                                                        context,
                                                        duration:
                                                            Toast.LENGTH_LONG,
                                                        gravity: Toast.BOTTOM);
                                                  }
                                                },
                                                child: Container(
                                                  height: ScreenUtil()
                                                      .setHeight(60),
                                                  width: ScreenUtil()
                                                      .setHeight(60),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(30),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Recipient Name"),
                                      Text(" - Required",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                              fontStyle: FontStyle.italic))
                                    ],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(5),
                                  ),
                                  Container(
                                    height: ScreenUtil().setHeight(60),
                                    padding: EdgeInsets.all(0.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          style: BorderStyle.solid),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: TextField(
                                            controller: _namecontroller,
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: font14,
                                            ),
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              hintText: "eg. David",
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: ScreenUtil()
                                                      .setHeight(10),
                                                  bottom: ScreenUtil()
                                                      .setHeight(20),
                                                  top: ScreenUtil()
                                                      .setHeight(-15),
                                                  right: ScreenUtil()
                                                      .setHeight(20)),
                                            ),
                                          ),
                                        ),
                                        (isImageLoaded == true)
                                            ? InkWell(
                                                onTap: () {
                                                  _showBottomSheet(
                                                      "_namecontroller");
                                                },
                                                child: Container(
                                                  height: ScreenUtil()
                                                      .setHeight(60),
                                                  width: ScreenUtil()
                                                      .setHeight(60),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(30),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[Text("Company Name")],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(5),
                                  ),
                                  Container(
                                    height: ScreenUtil().setHeight(60),
                                    padding: EdgeInsets.all(0.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          style: BorderStyle.solid),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: TextField(
                                            controller: _companycontroller,
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: font14,
                                            ),
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              hintText: "eg. JTApps Sdn Bhd",
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: ScreenUtil()
                                                      .setHeight(10),
                                                  bottom: ScreenUtil()
                                                      .setHeight(20),
                                                  top: ScreenUtil()
                                                      .setHeight(-15),
                                                  right: ScreenUtil()
                                                      .setHeight(20)),
                                            ),
                                          ),
                                        ),
                                        (isImageLoaded == true)
                                            ? InkWell(
                                                onTap: () {
                                                  _showBottomSheet(
                                                      "_companycontroller");
                                                },
                                                child: Container(
                                                  height: ScreenUtil()
                                                      .setHeight(60),
                                                  width: ScreenUtil()
                                                      .setHeight(60),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(30),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[Text("Remark")],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(5),
                                  ),
                                  Container(
                                    height: ScreenUtil().setHeight(60),
                                    padding: EdgeInsets.all(0.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          style: BorderStyle.solid),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: TextField(
                                            controller: _remarkcontroller,
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: font14,
                                            ),
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "eg. from KLCC exhibition",
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: ScreenUtil()
                                                      .setHeight(10),
                                                  bottom: ScreenUtil()
                                                      .setHeight(20),
                                                  top: ScreenUtil()
                                                      .setHeight(-15),
                                                  right: ScreenUtil()
                                                      .setHeight(20)),
                                            ),
                                          ),
                                        ),
                                        (isImageLoaded == true)
                                            ? InkWell(
                                                onTap: () {
                                                  _showBottomSheet(
                                                      "_remarkcontroller");
                                                },
                                                child: Container(
                                                  height: ScreenUtil()
                                                      .setHeight(60),
                                                  width: ScreenUtil()
                                                      .setHeight(60),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(30),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[Text("VTag")],
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(5),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(0.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          style: BorderStyle.solid),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                ScreenUtil().setHeight(10),
                                                0,
                                                0,
                                                0),
                                            child: (vtagList.length == 0)
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        "Please Select",
                                                        style: TextStyle(
                                                            fontSize: font14,
                                                            color: Colors
                                                                .grey.shade600),
                                                      )
                                                    ],
                                                  )
                                                : Wrap(
                                                    direction: Axis.horizontal,
                                                    alignment:
                                                        WrapAlignment.start,
                                                    children: <Widget>[
                                                      for (int i = 0;
                                                          i < vtagList.length;
                                                          i++)
                                                        Container(
                                                          width: ScreenUtil()
                                                              .setWidth((vtagList[
                                                                              i]
                                                                          .length *
                                                                      16.8) +
                                                                  62.8),
                                                          margin: EdgeInsets
                                                              .all(ScreenUtil()
                                                                  .setHeight(
                                                                      5)),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Color.fromRGBO(
                                                                    235,
                                                                    235,
                                                                    255,
                                                                    1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                            ScreenUtil()
                                                                .setHeight(10),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Text(
                                                                vtagList[i],
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: ScreenUtil()
                                                                    .setHeight(
                                                                        5),
                                                              ),
                                                              Icon(
                                                                FontAwesomeIcons
                                                                    .timesCircle,
                                                                size: ScreenUtil()
                                                                    .setHeight(
                                                                        30),
                                                                color:
                                                                    Colors.grey,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {},
                                          child: Container(
                                            height: ScreenUtil().setHeight(60),
                                            width: ScreenUtil().setHeight(60),
                                            child: Center(
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(50),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: ScreenUtil().setWidth(500),
                                        height: ScreenUtil().setHeight(80),
                                        margin: EdgeInsets.fromLTRB(
                                            0,
                                            ScreenUtil().setHeight(10),
                                            ScreenUtil().setHeight(10),
                                            ScreenUtil().setHeight(10)),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border(
                                            top: BorderSide(
                                                width: 1, color: Colors.grey),
                                            right: BorderSide(
                                                width: 1, color: Colors.grey),
                                            bottom: BorderSide(
                                                width: 1, color: Colors.grey),
                                            left: BorderSide(
                                                width: 1, color: Colors.grey),
                                          ),
                                        ),
                                        child: FlatButton(
                                          onPressed: () {
                                            // Navigator.of(context)
                                            //     .pushReplacement(
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         WhatsappForward(),
                                            //   ),
                                            // );
                                            setState(() {
                                              _phonecontroller.text.isEmpty ? _validate = true : _validate = false;
                                            });
                                          },
                                          child: Text(
                                            'Send',
                                            style: TextStyle(
                                              fontSize: font14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ));
            });
          });
    } else {
      Toast.show("This feature need Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _showBottomSheet(String type) {
    if (type == "phone") {
      int position;
      for (int i = 0; i < phoneList.length; i++) {
        if (_phonecontroller.text == phoneList[i]) {
          position = i;
        }
      }
      showModalBottomSheet(
        isDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(width: 1, color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(
                              ScreenUtil().setHeight(20),
                            ),
                            child: Text(
                              "Select",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: font14,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: EdgeInsets.all(
                                ScreenUtil().setHeight(20),
                              ),
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: font14,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _phonecontroller.text = phoneList[position];
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                        child: Container(
                      color: Colors.white,
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 28,
                        scrollController:
                            FixedExtentScrollController(initialItem: position),
                        onSelectedItemChanged: (int index) {
                          if (position != index) {
                            setState(() {
                              position = index;
                            });
                          }
                        },
                        children: <Widget>[
                          for (var each in phoneList)
                            Text(
                              each,
                              style: TextStyle(
                                fontSize: font14,
                              ),
                            )
                        ],
                      ),
                    ))
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      showModalBottomSheet(
        isDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(width: 1, color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(
                              ScreenUtil().setHeight(20),
                            ),
                            child: Text(
                              "Select",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: font14,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: EdgeInsets.all(
                                ScreenUtil().setHeight(20),
                              ),
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: font14,
                                ),
                              ),
                            ),
                            onTap: () {
                              if (tempText != "-") {
                                Navigator.pop(context);
                                setState(() {
                                  _checkTextField(type).text =
                                      _checkTextField(type).text + tempText;
                                  tempText = "";
                                });
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                        child: Container(
                      color: Colors.white,
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 28,
                        scrollController:
                            FixedExtentScrollController(initialItem: 0),
                        onSelectedItemChanged: (int index) {
                          tempText = otherList[index];
                        },
                        children: <Widget>[
                          for (var each in otherList)
                            Text(
                              each,
                              style: TextStyle(
                                fontSize: font14,
                              ),
                            )
                        ],
                      ),
                    ))
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  TextEditingController _checkTextField(String textfield) {
    TextEditingController controller;
    switch (textfield) {
      case "_namecontroller":
        controller = _namecontroller;
        break;
      case "_companycontroller":
        controller = _companycontroller;
        break;
      case "_remarkcontroller":
        controller = _remarkcontroller;
        break;
    }
    return controller;
  }

  void _scanner() async {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(
              "Action",
              style: TextStyle(
                fontSize: font14,
              ),
            ),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: font18,
                ),
              ),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.of(context).pop();
                  var tempStore =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  if (tempStore != null) {
                    setState(() {
                      pickedImage = tempStore;
                      isImageLoaded = true;
                    });
                    readText();
                  }
                },
                child: Text(
                  "Browse Gallery",
                  style: TextStyle(
                    fontSize: font18,
                  ),
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () async {
                  Navigator.of(context).pop();
                  var tempStore =
                      await ImagePicker.pickImage(source: ImageSource.camera);
                  if (tempStore != null) {
                    setState(() {
                      pickedImage = tempStore;
                    });
                    readText();
                  }
                },
                child: Text(
                  "Take Photo",
                  style: TextStyle(
                    fontSize: font18,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future readText() async {
    Navigator.of(context).pop();
    otherList.add("-");
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    String patttern = r'[0-9]';
    RegExp regExp = new RegExp(patttern);
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        String temPhone = "";
        for (int i = 0; i < line.text.length; i++) {
          if (regExp.hasMatch(line.text[i])) {
            temPhone = temPhone + line.text[i];
          }
        }
        if (temPhone.length >= 10) {
          if (temPhone.substring(0, 1).toString() != "6") {
            phoneList.add("6" + temPhone);
          } else {
            phoneList.add(temPhone);
          }
        } else {
          otherList.add(line.text);
        }
      }
    }
    setState(() {
      isImageLoaded = true;
      _phonecontroller.text = phoneList[0];
    });
    _whatsappForward();
  }

  Future pickImage() async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.camera);
    if (tempStore != null) {
      setState(() {
        pickedImage = tempStore;
        isImageLoaded = true;
      });
      readText();
    }
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    return Future.value(false);
  }

  void _myWorkfilter() {
    if (status == true) {
      showModalBottomSheet(
          isDismissible: false,
          context: context,
          builder: (context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(width: 1, color: Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(
                              ScreenUtil().setHeight(10),
                            ),
                            child: Text(
                              "Filter",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: font14,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: font14,
                                ),
                              ),
                            ),
                            onTap: _done,
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setHeight(10),
                              ScreenUtil().setHeight(20),
                              ScreenUtil().setHeight(10),
                              ScreenUtil().setHeight(10)),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "By Category",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: font14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(10),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                    child: Wrap(
                                      children: <Widget>[
                                        Container(
                                          width: ScreenUtil().setWidth(115),
                                          height: ScreenUtil().setHeight(70),
                                          margin: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setHeight(10)),
                                          decoration: BoxDecoration(
                                            color: (category == "all")
                                                ? Colors.blue
                                                : Colors.white,
                                            border: Border(
                                              top: BorderSide(
                                                  width: 1,
                                                  color: (category == "all")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: (category == "all")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: (category == "all")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              left: BorderSide(
                                                  width: 1,
                                                  color: (category == "all")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                            ),
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setModalState(() {
                                                category = "all";
                                              });
                                            },
                                            child: Text(
                                              'All',
                                              style: TextStyle(
                                                fontSize: font10,
                                                color: (category == "all")
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(155),
                                          height: ScreenUtil().setHeight(70),
                                          margin: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setHeight(10)),
                                          decoration: BoxDecoration(
                                            color: (category == "vcard")
                                                ? Colors.blue
                                                : Colors.white,
                                            border: Border(
                                              top: BorderSide(
                                                  width: 1,
                                                  color: (category == "vcard")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: (category == "vcard")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: (category == "vcard")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              left: BorderSide(
                                                  width: 1,
                                                  color: (category == "vcard")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                            ),
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setModalState(() {
                                                category = "vcard";
                                              });
                                            },
                                            child: Text(
                                              'VCard',
                                              style: TextStyle(
                                                fontSize: font10,
                                                color: (category == "vcard")
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(145),
                                          height: ScreenUtil().setHeight(70),
                                          margin: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setHeight(10)),
                                          decoration: BoxDecoration(
                                            color: (category == "vflex")
                                                ? Colors.blue
                                                : Colors.white,
                                            border: Border(
                                              top: BorderSide(
                                                  width: 1,
                                                  color: (category == "vflex")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: (category == "vflex")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: (category == "vflex")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              left: BorderSide(
                                                  width: 1,
                                                  color: (category == "vflex")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                            ),
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setModalState(() {
                                                category = "vflex";
                                              });
                                            },
                                            child: Text(
                                              'VFlex',
                                              style: TextStyle(
                                                fontSize: font10,
                                                color: (category == "vflex")
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setHeight(215),
                                          height: ScreenUtil().setHeight(70),
                                          margin: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setHeight(10),
                                              0),
                                          decoration: BoxDecoration(
                                            color: (category == "vcatalogue")
                                                ? Colors.blue
                                                : Colors.white,
                                            border: Border(
                                              top: BorderSide(
                                                  width: 1,
                                                  color: (category ==
                                                          "vcatalogue")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: (category ==
                                                          "vcatalogue")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: (category ==
                                                          "vcatalogue")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              left: BorderSide(
                                                  width: 1,
                                                  color: (category ==
                                                          "vcatalogue")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                            ),
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setModalState(() {
                                                category = "vcatalogue";
                                              });
                                            },
                                            child: Text(
                                              'VCatalogue',
                                              style: TextStyle(
                                                fontSize: font10,
                                                color:
                                                    (category == "vcatalogue")
                                                        ? Colors.white
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          });
    } else {
      Toast.show("Please wait for laoding", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<void> _done() async {
    switch (category) {
      case "all":
        {
          Navigator.pop(context);
          myWorks.clear();
          if (connection == true) {
            for (int i = 0; i < myWorks1.length; i++) {
              if (search == "") {
                Myworks mywork = Myworks(
                  date: myWorks1[i].date,
                  title: myWorks1[i].title,
                  url: myWorks1[i].url,
                  urlName: myWorks1[i].urlName,
                  link: myWorks1[i].link,
                  category: myWorks1[i].category,
                  qr: myWorks1[i].qr,
                  id: myWorks1[i].id,
                  offLine: false,
                );
                myWorks.add(mywork);
              } else {
                if (myWorks1[i]
                    .title
                    .toLowerCase()
                    .contains(search.toLowerCase())) {
                  Myworks mywork = Myworks(
                      date: myWorks1[i].date,
                      title: myWorks1[i].title,
                      url: myWorks1[i].url,
                      urlName: myWorks1[i].urlName,
                      link: myWorks1[i].link,
                      category: myWorks1[i].category,
                      qr: myWorks1[i].qr,
                      id: myWorks1[i].id,
                      offLine: false);
                  myWorks.add(mywork);
                }
              }
            }
            setState(() {
              connection = true;
            });
          } else {
            if (search == "") {
              offlineLink = await db.rawQuery("SELECT * FROM myworks");
            } else {
              offlineLink = await db.rawQuery(
                  "SELECT * FROM myworks WHERE title LIKE '%" + search + "%'");
            }
            setState(() {
              connection = false;
            });
          }
        }
        break;

      case "vcard":
        {
          Navigator.pop(context);
          myWorks.clear();
          if (connection == true) {
            for (int i = 0; i < myWorks1.length; i++) {
              if (search == "" && myWorks1[i].category == "VCard") {
                Myworks mywork = Myworks(
                    date: myWorks1[i].date,
                    title: myWorks1[i].title,
                    url: myWorks1[i].url,
                    urlName: myWorks1[i].urlName,
                    link: myWorks1[i].link,
                    category: myWorks1[i].category,
                    qr: myWorks1[i].qr,
                    id: myWorks1[i].id,
                    offLine: false);
                myWorks.add(mywork);
              } else {
                if (myWorks1[i]
                        .title
                        .toLowerCase()
                        .contains(search.toLowerCase()) &&
                    myWorks1[i].category == "VCard") {
                  Myworks mywork = Myworks(
                      date: myWorks1[i].date,
                      title: myWorks1[i].title,
                      url: myWorks1[i].url,
                      urlName: myWorks1[i].urlName,
                      link: myWorks1[i].link,
                      category: myWorks1[i].category,
                      qr: myWorks1[i].qr,
                      id: myWorks1[i].id,
                      offLine: false);
                  myWorks.add(mywork);
                }
              }
            }
            setState(() {
              connection = true;
            });
          } else {
            if (search == "") {
              offlineLink = await db
                  .rawQuery("SELECT * FROM myworks WHERE type = 'VCard'");
            } else {
              offlineLink = await db.rawQuery(
                  "SELECT * FROM myworks WHERE type = 'VCard' AND title LIKE '%" +
                      search +
                      "%'");
            }
            setState(() {
              connection = false;
            });
          }
        }
        break;

      case "vflex":
        {
          Navigator.pop(context);
          myWorks.clear();
          if (connection == true) {
            for (int i = 0; i < myWorks1.length; i++) {
              if (search == "" && myWorks1[i].category == "VFlex") {
                Myworks mywork = Myworks(
                    date: myWorks1[i].date,
                    title: myWorks1[i].title,
                    url: myWorks1[i].url,
                    urlName: myWorks1[i].urlName,
                    link: myWorks1[i].link,
                    category: myWorks1[i].category,
                    qr: myWorks1[i].qr,
                    id: myWorks1[i].id,
                    offLine: false);
                myWorks.add(mywork);
              } else {
                if (myWorks1[i]
                        .title
                        .toLowerCase()
                        .contains(search.toLowerCase()) &&
                    myWorks1[i].category == "VFlex") {
                  Myworks mywork = Myworks(
                      date: myWorks1[i].date,
                      title: myWorks1[i].title,
                      url: myWorks1[i].url,
                      urlName: myWorks1[i].urlName,
                      link: myWorks1[i].link,
                      category: myWorks1[i].category,
                      qr: myWorks1[i].qr,
                      id: myWorks1[i].id,
                      offLine: false);
                  myWorks.add(mywork);
                }
              }
            }
            setState(() {
              connection = true;
            });
          } else {
            if (search == "") {
              offlineLink = await db
                  .rawQuery("SELECT * FROM myworks WHERE type = 'VFlex'");
            } else {
              offlineLink = await db.rawQuery(
                  "SELECT * FROM myworks WHERE type = 'VFlex' AND title LIKE '%" +
                      search +
                      "%'");
            }
            setState(() {
              connection = false;
            });
          }
        }
        break;

      case "vcatalogue":
        {
          Navigator.pop(context);
          myWorks.clear();
          if (connection == true) {
            for (int i = 0; i < myWorks1.length; i++) {
              if (search == "" && myWorks1[i].category == "VCatalogue") {
                Myworks mywork = Myworks(
                    date: myWorks1[i].date,
                    title: myWorks1[i].title,
                    url: myWorks1[i].url,
                    urlName: myWorks1[i].urlName,
                    link: myWorks1[i].link,
                    category: myWorks1[i].category,
                    qr: myWorks1[i].qr,
                    id: myWorks1[i].id,
                    offLine: false);
                myWorks.add(mywork);
              } else {
                if (myWorks1[i]
                        .title
                        .toLowerCase()
                        .contains(search.toLowerCase()) &&
                    myWorks1[i].category == "VCatalogue") {
                  Myworks mywork = Myworks(
                      date: myWorks1[i].date,
                      title: myWorks1[i].title,
                      url: myWorks1[i].url,
                      urlName: myWorks1[i].urlName,
                      link: myWorks1[i].link,
                      category: myWorks1[i].category,
                      qr: myWorks1[i].qr,
                      id: myWorks1[i].id,
                      offLine: false);
                  myWorks.add(mywork);
                }
              }
            }
            setState(() {
              connection = true;
            });
          } else {
            if (search == "") {
              offlineLink = await db
                  .rawQuery("SELECT * FROM myworks WHERE type = 'VCatalogue'");
            } else {
              offlineLink = await db.rawQuery(
                  "SELECT * FROM myworks WHERE type = 'VCatalogue' AND title LIKE '%" +
                      search +
                      "%'");
            }
            setState(() {
              connection = false;
            });
          }
        }
        break;
    }
  }

  void _visitURL(int index) async {
    if (connection == true) {
      if (myWorks[index].offLine == false) {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.wifi ||
            connectivityResult == ConnectivityResult.mobile) {
          FlutterWebBrowser.openWebPage(
            url: myWorks[index].link,
          );
        } else {
          Toast.show("No Internet Connection", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      } else {
        var path = location +
            "/" +
            myWorks[index].category +
            myWorks[index].id +
            "/VVIN.html";
        if (File(path).existsSync() == true) {
          await OpenFile.open(path);
        } else {
          Toast.show("This offline link still in downloading", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }
    } else {
      var path = location +
          "/" +
          offlineLink[index]['type'] +
          offlineLink[index]['linkid'] +
          "/VVIN.html";
      if (File(path).existsSync() == true) {
        await OpenFile.open(path);
      } else {
        Toast.show(
            "This offline link not in your device, please enter the page again in online mode to complete the offline link download.",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM);
      }
    }
  }

  Future<void> setData() async {
    Database db = await MyWorksDB.instance.database;
    await db.rawInsert('DELETE FROM myworks WHERE id > 0');
    for (int index = 0; index < myWorks.length; index++) {
      await db.rawInsert(
          'INSERT INTO myworks (date, title, link, type, linkid) VALUES("' +
              myWorks[index].date +
              '","' +
              myWorks[index].title +
              '","' +
              myWorks[index].link +
              '","' +
              myWorks[index].category +
              '","' +
              myWorks[index].id +
              '")');
    }
    endTime = DateTime.now().millisecondsSinceEpoch;
    int result = endTime - startTime;
    print("MyWork Loading Time: " + result.toString());
  }

  void checkConnection() async {
    startTime = DateTime.now().millisecondsSinceEpoch;
    final _devicePath = await getApplicationDocumentsDirectory();
    location = _devicePath.path.toString();
    db = await MyWorksDB.instance.database;
    offlineLink = await db.query(MyWorksDB.table);
    prefs = await SharedPreferences.getInstance();
    totalQR = int.parse(prefs.getString('totalQR') ?? "0");
    totalLink = int.parse(prefs.getString('totalLink') ?? "0");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      // _onLoading();
      companyID = prefs.getString('companyID');
      userID = prefs.getString('userID');
      level = prefs.getString('level');
      userType = prefs.getString('user_type');
      myWorks.clear();
      myWorks1.clear();
      getLink();
    } else {
      initialize();
      Toast.show("No Internet, the data shown is not up to date", context,
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

  void getLink() {
    http.post(urlMyWorks, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType,
      "count": myWorks.length.toString(),
    }).then((res) {
      // print("MyWorks status:" + (res.statusCode).toString());
      // print("MyWorks body: " + res.body);
      if (res.body == "nodata") {
        nodata = true;
        status = true;
        // Navigator.pop(context);
        Toast.show("No Data", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        var jsonData = json.decode(res.body);
        if (total == 0) {
          setState(() {
            total = int.parse(jsonData[0]);
          });
          for (int i = 1; i < jsonData.length; i++) {
            Myworks mywork = Myworks(
                date: jsonData[i]['date'],
                title: jsonData[i]['title'],
                url: jsonData[i]['url'],
                urlName: jsonData[i]['urlName'],
                link: jsonData[i]['link'],
                category: jsonData[i]['category'],
                qr: jsonData[i]['qr'],
                id: jsonData[i]['id'],
                offLine: false);
            myWorks.add(mywork);
            myWorks1.add(mywork);
          }
          if (myWorks.length != total) {
            getLink();
          } else {
            setState(() {
              status = true;
              connection = true;
            });
            _save();
          }
        } else {
          for (int i = 0; i < jsonData.length; i++) {
            Myworks mywork = Myworks(
                date: jsonData[i]['date'],
                title: jsonData[i]['title'],
                url: jsonData[i]['url'],
                urlName: jsonData[i]['urlName'],
                link: jsonData[i]['link'],
                category: jsonData[i]['category'],
                qr: jsonData[i]['qr'],
                id: jsonData[i]['id'],
                offLine: false);
            myWorks.add(mywork);
            myWorks1.add(mywork);
          }
          if (myWorks.length != total) {
            getLink();
          } else {
            setState(() {
              status = true;
              connection = true;
            });
            _save();
          }
        }
      }
    }).catchError((err) {
      print("Get Link error: " + (err).toString());
    });
  }

  Future<void> _save() async {
    if (offlineLink.length == 0) {
      _download();
      _downloadImage();
      setData();
    } else {
      int totalQRcount = 0;
      int totalLinkcount = 0;
      for (int i = 0; i < myWorks.length; i++) {
        var imagePath =
            location + "/" + myWorks[i].category + myWorks[i].id + "/VVIN.jpg";
        var linkPath =
            location + "/" + myWorks[i].category + myWorks[i].id + "/VVIN.html";

        if (File(imagePath).existsSync() == true) {
          totalQRcount += 1;
          if (totalQRcount > totalQR && totalQRcount < myWorks.length) {
            setState(() {
              totalQR = totalQRcount;
            });
            await prefs.setString('totalQR', totalQRcount.toString());
          }
        } else {
          _downloadImage1(
              myWorks[i].qr, myWorks[i].category + myWorks[i].id, "VVIN", i);
        }

        if (File(linkPath).existsSync() == true) {
          totalLinkcount += 1;
          if (totalLinkcount > totalLink && totalLinkcount < myWorks.length) {
            setState(() {
              totalLink = totalLinkcount;
            });
            await prefs.setString('totalLink', totalLinkcount.toString());
          }
        } else {
          _download1(
              myWorks[i].link, myWorks[i].category + myWorks[i].id, "VVIN", i);
        }

        for (int j = 0; j < offlineLink.length; j++) {
          if (myWorks[i].category + myWorks[i].id ==
                  offlineLink[j]['type'] + offlineLink[j]['linkid'] &&
              myWorks[i].date != offlineLink[j]['date']) {
            String linkLocation = location +
                "/" +
                offlineLink[i]['type'] +
                offlineLink[i]['linkid'] +
                "/VVIN.html";
            if (File(linkLocation).existsSync() == true) {
              final dir = Directory(linkLocation);
              dir.deleteSync(recursive: true);
              _editDownload1(myWorks[i].link,
                  myWorks[i].category + myWorks[i].id, "VVIN", i);
            }
            String imageLocation = location +
                "/" +
                offlineLink[i]['type'] +
                offlineLink[i]['linkid'] +
                "/VVIN.jpg";
            if (File(imageLocation).existsSync() == true) {
              final dir1 = Directory(imageLocation);
              dir1.deleteSync(recursive: true);
              _editDownloadImage1(myWorks[i].qr,
                  myWorks[i].category + myWorks[i].id, "VVIN", i);
            }
          }
        }
      }
      setData();
    }
  }

  Future<void> initialize() async {
    if (offlineLink.length == 0) {
      setState(() {
        nodata = true;
      });
    } else {
      setState(() {
        status = true;
      });
    }
  }

  Future<void> _search(String value) async {
    if (status == false) {
      Toast.show("Please wait for loading", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    } else {
      setState(() {
        search = value;
      });
      switch (category) {
        case "all":
          {
            myWorks.clear();
            if (connection == true) {
              for (int i = 0; i < myWorks1.length; i++) {
                if (myWorks1[i]
                    .title
                    .toLowerCase()
                    .contains(value.toLowerCase())) {
                  Myworks mywork = Myworks(
                      date: myWorks1[i].date,
                      title: myWorks1[i].title,
                      url: myWorks1[i].url,
                      urlName: myWorks1[i].urlName,
                      link: myWorks1[i].link,
                      category: myWorks1[i].category,
                      qr: myWorks1[i].qr,
                      id: myWorks1[i].id,
                      offLine: false);
                  myWorks.add(mywork);
                }
              }
              setState(() {
                connection = true;
              });
            } else {
              offlineLink = await db.rawQuery(
                  "SELECT * FROM myworks WHERE title LIKE '%" + value + "%'");
              setState(() {
                connection = false;
              });
            }
          }
          break;

        case "vcard":
          {
            myWorks.clear();
            if (connection == true) {
              for (int i = 0; i < myWorks1.length; i++) {
                if (myWorks1[i]
                        .title
                        .toLowerCase()
                        .contains(value.toLowerCase()) &&
                    myWorks1[i].category == "VCard") {
                  Myworks mywork = Myworks(
                      date: myWorks1[i].date,
                      title: myWorks1[i].title,
                      url: myWorks1[i].url,
                      urlName: myWorks1[i].urlName,
                      link: myWorks1[i].link,
                      category: myWorks1[i].category,
                      qr: myWorks1[i].qr,
                      id: myWorks1[i].id,
                      offLine: false);
                  myWorks.add(mywork);
                }
              }
              setState(() {
                connection = true;
              });
            } else {
              offlineLink = await db.rawQuery(
                  "SELECT * FROM myworks WHERE type = 'VCard' AND title LIKE '%" +
                      value +
                      "%'");
              setState(() {
                connection = false;
              });
            }
          }
          break;

        case "vflex":
          {
            myWorks.clear();
            if (connection == true) {
              for (int i = 0; i < myWorks1.length; i++) {
                if (myWorks1[i]
                        .title
                        .toLowerCase()
                        .contains(value.toLowerCase()) &&
                    myWorks1[i].category == "VFlex") {
                  Myworks mywork = Myworks(
                      date: myWorks1[i].date,
                      title: myWorks1[i].title,
                      url: myWorks1[i].url,
                      urlName: myWorks1[i].urlName,
                      link: myWorks1[i].link,
                      category: myWorks1[i].category,
                      qr: myWorks1[i].qr,
                      id: myWorks1[i].id,
                      offLine: false);
                  myWorks.add(mywork);
                }
              }
              setState(() {
                connection = true;
              });
            } else {
              offlineLink = await db.rawQuery(
                  "SELECT * FROM myworks WHERE type = 'VFlex' AND title LIKE '%" +
                      value +
                      "%'");
              setState(() {
                connection = false;
              });
            }
          }
          break;

        case "vcatalogue":
          {
            myWorks.clear();
            if (connection == true) {
              for (int i = 0; i < myWorks1.length; i++) {
                if (myWorks1[i]
                        .title
                        .toLowerCase()
                        .contains(value.toLowerCase()) &&
                    myWorks1[i].category == "VCatalogue") {
                  Myworks mywork = Myworks(
                      date: myWorks1[i].date,
                      title: myWorks1[i].title,
                      url: myWorks1[i].url,
                      urlName: myWorks1[i].urlName,
                      link: myWorks1[i].link,
                      category: myWorks1[i].category,
                      qr: myWorks1[i].qr,
                      id: myWorks1[i].id,
                      offLine: false);
                  myWorks.add(mywork);
                }
              }
              setState(() {
                connection = true;
              });
            } else {
              offlineLink = await db.rawQuery(
                  "SELECT * FROM myworks WHERE type = 'VCatalogue' AND title LIKE '%" +
                      value +
                      "%'");
              setState(() {
                connection = false;
              });
            }
          }
          break;
      }
    }
  }

  String _dateFormat(String fullDate) {
    String result, date, month, year;
    date = fullDate.substring(8, 10);
    month = fullDate.substring(5, 7);
    year = fullDate.substring(0, 4);
    result = date + "/" + month + "/" + year;
    return result;
  }

  Future<String> get _localDevicePath async {
    final _devicePath = await getApplicationDocumentsDirectory();
    return _devicePath.path;
  }

  Future _download() async {
    for (int i = 0; i < myWorks.length; i++) {
      final _response = await http.get(myWorks[i].link + "/hide");
      if (_response.statusCode == 200) {
        final _file = await _localFile(
            path: myWorks[i].category + myWorks[i].id, name: "VVIN");
        final _saveFile = await _file.writeAsBytes(_response.bodyBytes);
        // Logger().i("File write complete. File Path ${_saveFile.path}");
        setState(() {
          filePath = _saveFile.path;
          totalLink += 1;
        });
        await prefs.setString('totalLink', totalLink.toString());
        // print("Link " + i.toString());
      } else {
        // print("Download link error at " + i.toString());
        Logger().e(_response.statusCode);
      }
    }
  }

  Future<File> _localFile({String path, String name}) async {
    String _path = await _localDevicePath;
    var _newPath = await Directory("$_path/$path").create();
    return File("${_newPath.path}/$name.html");
  }

  Future _download1(String url, String path, String name, int index) async {
    final _response = await http.get(url + "/hide");
    if (_response.statusCode == 200) {
      final _file = await _localFile1(path: path, name: name);
      final _saveFile = await _file.writeAsBytes(_response.bodyBytes);
      // Logger().i("File write complete. File Path ${_saveFile.path}");
      setState(() {
        filePath = _saveFile.path;
      });
      if (totalLink < myWorks.length) {
        setState(() {
          totalLink += 1;
        });
        await prefs.setString('totalLink', totalLink.toString());
      }
      // print("Link " + index.toString());
    } else {
      // print("Download link error at " + index.toString());
      Logger().e(_response.statusCode);
    }
  }

  Future<File> _localFile1({String path, String name}) async {
    String _path = await _localDevicePath;
    var _newPath = await Directory("$_path/$path").create();
    return File("${_newPath.path}/$name.html");
  }

  Future _editDownload1(String url, String path, String name, int index) async {
    final _response = await http.get(url + "/hide");
    if (_response.statusCode == 200) {
      final _file = await _editLocalFile1(path: path, name: name);
      final _saveFile = await _file.writeAsBytes(_response.bodyBytes);
      // Logger().i("File write complete. File Path ${_saveFile.path}");
      setState(() {
        filePath = _saveFile.path;
      });
    } else {
      Logger().e(_response.statusCode);
    }
  }

  Future<File> _editLocalFile1({String path, String name}) async {
    String _path = await _localDevicePath;
    var _newPath = await Directory("$_path/$path").create();
    return File("${_newPath.path}/$name.html");
  }

  Future _downloadImage() async {
    for (int i = 0; i < myWorks.length; i++) {
      if (myWorks[i].qr != "") {
        final _response = await http.get(myWorks[i].qr);
        if (_response.statusCode == 200) {
          final _file = await _localImage(
              path: myWorks[i].category + myWorks[i].id, name: "VVIN");
          final _saveFile = await _file.writeAsBytes(_response.bodyBytes);
          // Logger().i("File write complete. File Path ${_saveFile.path}");
          setState(() {
            filePath = _saveFile.path;
            totalQR += 1;
          });
          await prefs.setString('totalQR', totalQR.toString());
          // print("Image " + i.toString());
        } else {
          Logger().e(_response.statusCode);
          print("Image error at: " + i.toString());
        }
      }
    }
  }

  Future<File> _localImage({String path, String name}) async {
    String _path = await _localDevicePath;
    var _newPath = await Directory("$_path/$path").create();
    return File("${_newPath.path}/$name.jpg");
  }

  Future _downloadImage1(
      String url, String path, String name, int index) async {
    if (url != "") {
      final _response = await http.get(url);
      if (_response.statusCode == 200) {
        final _file = await _localImage1(path: path, name: name);
        final _saveFile = await _file.writeAsBytes(_response.bodyBytes);
        // Logger().i("File write complete. File Path ${_saveFile.path}");
        setState(() {
          filePath = _saveFile.path;
        });
        if (totalQR < myWorks.length) {
          setState(() {
            totalQR += 1;
          });
          await prefs.setString('totalQR', totalQR.toString());
        }
        // print("Image " + index.toString());
      } else {
        Logger().e(_response.statusCode);
        print("Image error at: " + index.toString());
      }
    }
  }

  Future<File> _localImage1({String path, String name}) async {
    String _path = await _localDevicePath;
    var _newPath = await Directory("$_path/$path").create();
    return File("${_newPath.path}/$name.jpg");
  }

  Future _editDownloadImage1(
      String url, String path, String name, int index) async {
    final _response = await http.get(url);
    if (_response.statusCode == 200) {
      final _file = await _editLocalImage1(path: path, name: name);
      final _saveFile = await _file.writeAsBytes(_response.bodyBytes);
      // Logger().i("File write complete. File Path ${_saveFile.path}");
      setState(() {
        filePath = _saveFile.path;
      });
    } else {
      Logger().e(_response.statusCode);
      print("Image error at: " + index.toString());
    }
  }

  Future<File> _editLocalImage1({String path, String name}) async {
    String _path = await _localDevicePath;
    var _newPath = await Directory("$_path/$path").create();
    return File("${_newPath.path}/$name.jpg");
  }

  Future<Null> _handleRefresh() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      // _onLoading();
      setState(() {
        status = false;
        total = 0;
        category = "all";
      });
      myWorks.clear();
      myWorks1.clear();
      getLink();
    } else {
      Toast.show("No Internet connection, data can't load", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }
}
