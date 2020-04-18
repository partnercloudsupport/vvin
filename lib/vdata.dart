import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:vvin/data.dart';
import 'package:vvin/loader.dart';
import 'package:vvin/more.dart';
import 'package:vvin/myworks.dart';
import 'package:vvin/notifications.dart';
import 'package:vvin/vDataDB.dart';
import 'package:vvin/vanalytics.dart';
import 'package:vvin/vprofile.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

class VData extends StatefulWidget {
  const VData({Key key}) : super(key: key);

  @override
  _VDataState createState() => _VDataState();
}

class _VDataState extends State<VData> {
  double font11 = ScreenUtil().setSp(25.3, allowFontScalingSelf: false);
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  GlobalKey<RefreshIndicatorState> refreshKey;
  bool connection, nodata, link, vData, executive;
  List<Links> linksID = [];
  List<VDataDetails> vDataDetails = [];
  List<VDataDetails> vDataDetails1 = [];
  List<VDataDetails> vDataOffline = [];
  List<Map> offlineVData;
  List<Handler> handlerList = [];
  List<String> executiveList = [];
  List<String> links = [];
  Database vdataDB;
  String companyID,
      userID,
      _byLink,
      _byStatus,
      _byExecutive,
      link_id,
      linkID,
      type,
      channel,
      apps,
      level,
      userType,
      search,
      startDate,
      endDate,
      minimumDate,
      maximumDate,
      handlerStatus,
      totalNotification;
  int tap, total, startTime, endTime, currentTabIndex;
  DateTime _startDate,
      _endDate,
      _startDatePicker,
      _endDatePicker,
      startDateTime,
      endDateTime;
  String urlNoti = "https://vvinoa.vvin.com/api/notiTotalNumber.php";
  String urlVData = "https://vvinoa.vvin.com/api/vdata.php";
  String urlChangeStatus = "https://vvinoa.vvin.com/api/vdataChangeStatus.php";
  String urlLinks = "https://vvinoa.vvin.com/api/links.php";
  String urlHandler = "https://vvinoa.vvin.com/api/getHandler.php";
  List<String> data = [
    "New",
    "Contacting",
    "Contacted",
    "Qualified",
    "Converted",
    "Follow-up",
    "Unqualified",
    "Bad Information",
    "No Response"
  ];
  List<String> status = [
    "All Status",
    "New",
    "Contacting",
    "Contacted",
    "Qualified",
    "Converted",
    "Follow-up",
    "Unqualified",
    "Bad Information",
    "No Response"
  ];
  List<String> appsAll = [
    "All",
    "VBot",
    "VBrochure",
    "VCard",
    "VCatalogue",
    "VFlex",
    "VHome",
    "VForm",
  ];
  ScrollController _scrollController = ScrollController();
  final _itemExtent = ScreenUtil().setHeight(260);

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    refreshKey = GlobalKey<RefreshIndicatorState>();
    totalNotification = "0";
    currentTabIndex = 1;
    connection = false;
    nodata = false;
    vData = false;
    link = false;
    executive = false;
    checkConnection();
    _byLink = "All Links";
    _byStatus = "All Status";
    _byExecutive = "All Executives";
    link_id = "All Links";
    type = "all";
    channel = "all";
    apps = "All";
    search = "";
    minimumDate = "2017-12-01";
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (vDataDetails.length != total) {
          _getMoreVData();
        }
      }
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

  void onTapped(int index) {
    if (index != 1) {
      switch (index) {
        case 0:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VAnalytics(),
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
        case 3:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Notifications(),
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
    double remark = MediaQuery.of(context).size.width * 0.30;
    double cWidth = MediaQuery.of(context).size.width * 0.30;
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        // backgroundColor: Color.fromARGB(50, 220, 220, 220),
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
                "VData",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: font18,
                    fontWeight: FontWeight.bold),
              )),
        ),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: _handleRefresh,
          child: Container(
            padding: EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Card(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: ScreenUtil().setHeight(20),
                              left: ScreenUtil().setHeight(20),
                            ),
                            height: ScreenUtil().setHeight(75),
                            child: TextField(
                              onChanged: _search,
                              style: TextStyle(
                                fontSize: font14,
                              ),
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 3),
                                hintText: "Search",
                                suffix: IconButton(
                                  iconSize: ScreenUtil().setHeight(40),
                                  icon: Icon(Icons.keyboard_hide),
                                  onPressed: () {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  },
                                ),
                                suffixIcon: Icon(
                                  Icons.search,
                                  size: ScreenUtil().setHeight(50),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(ScreenUtil().setHeight(10),
                          0, ScreenUtil().setHeight(0), 0),
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: (connection == true) ? _filter : _noInternet,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(
                              ScreenUtil().setHeight(18),
                            ),
                            child: Icon(
                              Icons.tune,
                              size: ScreenUtil().setHeight(40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(5),
                ),
                Container(
                  padding:
                      EdgeInsets.fromLTRB(ScreenUtil().setHeight(10), 0, 0, 0),
                  child: Row(
                    children: <Widget>[
                      Text("Total Entries: ",
                          style:
                              TextStyle(color: Colors.grey, fontSize: font12)),
                      Text(
                          (connection == true)
                              ? (total == null) ? "" : total.toString()
                              : (link == true && vData == true)
                                  ? (offlineVData.length != 0)
                                      ? offlineVData[0]['total']
                                      : "0"
                                  : "data loading...",
                          style: TextStyle(fontSize: font12)),
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(5),
                ),
                (link == true && vData == true)
                    ? (nodata == true)
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    "No Data",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                      fontSize: ScreenUtil().setSp(35,
                                          allowFontScalingSelf: false),
                                    ),
                                  ),
                                ),
                              ],
                            ))
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
                                    ? offlineVData.length
                                    : vDataDetails.length + 1,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, int index) {
                                  if (connection == true &&
                                      index == vDataDetails.length) {
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
                                  return Card(
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () async {
                                              _redirectVProfile(index);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                      width: ScreenUtil()
                                                          .setHeight(2),
                                                      color:
                                                          Colors.grey.shade300),
                                                ),
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  ScreenUtil().setHeight(10),
                                                  ScreenUtil().setHeight(10),
                                                  ScreenUtil().setHeight(10),
                                                  0),
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        (connection == true)
                                                            ? vDataDetails[
                                                                    index]
                                                                .date
                                                            : offlineVData[
                                                                index]['date'],
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: font12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(10),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Container(
                                                        width: cWidth,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Flexible(
                                                                  child: Text(
                                                                    (connection ==
                                                                            true)
                                                                        ? vDataDetails[index]
                                                                            .name
                                                                        : offlineVData[index]
                                                                            [
                                                                            'name'],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontSize:
                                                                            font14,
                                                                        fontWeight:
                                                                            FontWeight.w900),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  ScreenUtil()
                                                                      .setHeight(
                                                                          10),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Flexible(
                                                                  child: Text(
                                                                    (connection ==
                                                                            true)
                                                                        ? vDataDetails[index]
                                                                            .phoneNo
                                                                        : offlineVData[index]
                                                                            [
                                                                            'phone'],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          font12,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: ScreenUtil()
                                                              .setWidth(10)),
                                                      Container(
                                                        width: cWidth,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Center(
                                                                  child: Text(
                                                                    "Link",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            font12,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Flexible(
                                                                  child: Text(
                                                                    (connection ==
                                                                            true)
                                                                        ? vDataDetails[index]
                                                                            .handler
                                                                        : offlineVData[index]
                                                                            [
                                                                            'handler'],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          font12,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: ScreenUtil()
                                                            .setWidth(10),
                                                      ),
                                                      Container(
                                                        width: remark,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  "Remark",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          font12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Flexible(
                                                                  child: Text(
                                                                    (connection ==
                                                                            true)
                                                                        ? vDataDetails[index]
                                                                            .remark
                                                                        : offlineVData[index]
                                                                            [
                                                                            'remark'],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            font12,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: ScreenUtil()
                                                        .setHeight(10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(10),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                              ScreenUtil().setHeight(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    InkWell(
                                                      onTap: () {
                                                        (connection == true)
                                                            ? launch("tel:+" +
                                                                vDataDetails[
                                                                        index]
                                                                    .phoneNo)
                                                            : launch("tel:+" +
                                                                offlineVData[
                                                                        index]
                                                                    ['phone']);
                                                      },
                                                      child: Container(
                                                        height: ScreenUtil()
                                                            .setHeight(60),
                                                        width: ScreenUtil()
                                                            .setWidth(98),
                                                        child: Icon(
                                                          Icons.call,
                                                          size: ScreenUtil()
                                                              .setHeight(32.2),
                                                          color: Colors.white,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: ScreenUtil()
                                                          .setHeight(20),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        _redirectWhatsApp(
                                                            index);
                                                      },
                                                      child: Container(
                                                        height: ScreenUtil()
                                                            .setHeight(60),
                                                        width: ScreenUtil()
                                                            .setWidth(98),
                                                        child: Icon(
                                                          FontAwesomeIcons
                                                              .whatsapp,
                                                          color: Colors.white,
                                                          size: ScreenUtil()
                                                              .setHeight(32.2),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color.fromRGBO(
                                                              37, 211, 102, 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  width: ScreenUtil()
                                                      .setWidth(290),
                                                  height: ScreenUtil()
                                                      .setHeight(60),
                                                  padding: EdgeInsets.all(
                                                    ScreenUtil().setHeight(10),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.0),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        style:
                                                            BorderStyle.solid),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton(
                                                      isExpanded: true,
                                                      isDense: true,
                                                      items: data.map((item) {
                                                        return DropdownMenuItem(
                                                          child: Text(
                                                            item.toString(),
                                                            style: TextStyle(
                                                              fontSize: font12,
                                                            ),
                                                          ),
                                                          value:
                                                              item.toString(),
                                                        );
                                                      }).toList(),
                                                      onChanged: (newVal) {
                                                        (connection == true)
                                                            ? setStatus(
                                                                index, newVal)
                                                            : Toast.show(
                                                                "Status can't changed! Please enter the page again in online mode",
                                                                context,
                                                                duration: Toast
                                                                    .LENGTH_LONG,
                                                                gravity: Toast
                                                                    .BOTTOM);
                                                      },
                                                      value: (connection ==
                                                              true)
                                                          ? vDataDetails[index]
                                                              .status
                                                          : offlineVData[index]
                                                              ['status'],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.6,
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
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _redirectVProfile(int index) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      String name, phoneNo, status;
      if (connection == true) {
        name = vDataDetails[index].name;
        phoneNo = vDataDetails[index].phoneNo;
        status = vDataDetails[index].status;
      } else {
        name = offlineVData[index]['name'];
        phoneNo = offlineVData[index]['phone'];
        status = offlineVData[index]['status'];
      }
      VDataDetails vdata = new VDataDetails(
        companyID: companyID,
        userID: userID,
        level: level,
        userType: userType,
        name: name,
        phoneNo: phoneNo,
        status: status,
        fromVAnalytics: "no",
      );
      Navigator.of(context).push(_createRoute(vdata));
    } else {
      Toast.show("No Internet Connection!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _redirectWhatsApp(int index) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      if (connection == true) {
        FlutterOpenWhatsapp.sendSingleMessage(vDataDetails[index].phoneNo, "");
      } else {
        FlutterOpenWhatsapp.sendSingleMessage(offlineVData[index]['phone'], "");
      }
    } else {
      Toast.show("This feature need Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    return Future.value(false);
  }

  void _filter() async {
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
                height: MediaQuery.of(context).size.height * 0.9,
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
                                  fontSize: font14,
                                  fontWeight: FontWeight.bold),
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
                                    "By Status",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: font14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(5),
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        _showBottomSheet("byStatus");
                                      },
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          0,
                                          ScreenUtil().setHeight(20),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              style: BorderStyle.solid),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                height:
                                                    ScreenUtil().setHeight(60),
                                                padding: EdgeInsets.fromLTRB(
                                                    ScreenUtil().setHeight(10),
                                                    ScreenUtil().setHeight(16),
                                                    0,
                                                    0),
                                                child: Text(
                                                  _byStatus,
                                                  style: TextStyle(
                                                    fontSize: font14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: ScreenUtil().setWidth(10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(15),
                              ),
                              (level != "0")
                                  ? Row()
                                  : Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "By Type",
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Wrap(
                                                children: <Widget>[
                                                  Container(
                                                    width: ScreenUtil()
                                                        .setWidth(115),
                                                    height: ScreenUtil()
                                                        .setHeight(60),
                                                    margin: EdgeInsets.fromLTRB(
                                                        0,
                                                        0,
                                                        ScreenUtil()
                                                            .setWidth(20),
                                                        0),
                                                    decoration: BoxDecoration(
                                                      color: (type == "all")
                                                          ? Colors.blue
                                                          : Colors.white,
                                                      border: Border(
                                                        top: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "all")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                        right: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "all")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                        bottom: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "all")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                        left: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "all")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                      ),
                                                    ),
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        setModalState(() {
                                                          type = "all";
                                                        });
                                                      },
                                                      child: Text(
                                                        'All',
                                                        style: TextStyle(
                                                          fontSize: font12,
                                                          color: (type == "all")
                                                              ? Colors.white
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: ScreenUtil()
                                                        .setWidth(220),
                                                    height: ScreenUtil()
                                                        .setHeight(60),
                                                    margin: EdgeInsets.fromLTRB(
                                                        0,
                                                        0,
                                                        ScreenUtil()
                                                            .setWidth(20),
                                                        0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (type == "assigned")
                                                              ? Colors.blue
                                                              : Colors.white,
                                                      border: Border(
                                                        top: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "assigned")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                        right: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "assigned")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                        bottom: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "assigned")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                        left: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "assigned")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                      ),
                                                    ),
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        setModalState(() {
                                                          type = "assigned";
                                                        });
                                                      },
                                                      child: Text(
                                                        'Assigned',
                                                        style: TextStyle(
                                                          fontSize: font12,
                                                          color: (type ==
                                                                  "assigned")
                                                              ? Colors.white
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: ScreenUtil()
                                                        .setWidth(250),
                                                    height: ScreenUtil()
                                                        .setHeight(60),
                                                    margin: EdgeInsets.fromLTRB(
                                                        0,
                                                        0,
                                                        ScreenUtil()
                                                            .setWidth(10),
                                                        0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (type == "unassigned")
                                                              ? Colors.blue
                                                              : Colors.white,
                                                      border: Border(
                                                        top: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "unassigned")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                        right: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "unassigned")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                        bottom: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "unassigned")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                        left: BorderSide(
                                                            width: 1,
                                                            color: (type ==
                                                                    "unassigned")
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade300),
                                                      ),
                                                    ),
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        setModalState(() {
                                                          type = "unassigned";
                                                        });
                                                      },
                                                      child: Text(
                                                        'Unassigned',
                                                        style: TextStyle(
                                                          fontSize: font12,
                                                          color: (type ==
                                                                  "unassigned")
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
                                        SizedBox(
                                          height: ScreenUtil().setHeight(30),
                                        ),
                                      ],
                                    ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "By Channel",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: font14,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: Wrap(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setWidth(15),
                                              ScreenUtil().setHeight(10)),
                                          width: ScreenUtil().setWidth(115),
                                          height: ScreenUtil().setHeight(60),
                                          decoration: BoxDecoration(
                                            color: (channel == "all")
                                                ? Colors.blue
                                                : Colors.white,
                                            border: Border(
                                              top: BorderSide(
                                                  width: 1,
                                                  color: (channel == "all")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: (channel == "all")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: (channel == "all")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              left: BorderSide(
                                                  width: 1,
                                                  color: (channel == "all")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                            ),
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setModalState(() {
                                                channel = "all";
                                              });
                                            },
                                            child: Text(
                                              'All',
                                              style: TextStyle(
                                                fontSize: font11,
                                                color: (channel == "all")
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(250),
                                          height: ScreenUtil().setHeight(60),
                                          margin: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setWidth(15),
                                              ScreenUtil().setHeight(10)),
                                          decoration: BoxDecoration(
                                            color: (channel == "contact form")
                                                ? Colors.blue
                                                : Colors.white,
                                            border: Border(
                                              top: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "contact form")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "contact form")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "contact form")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              left: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "contact form")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                            ),
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setModalState(() {
                                                channel = "contact form";
                                              });
                                            },
                                            child: Text(
                                              'Contact Form',
                                              style: TextStyle(
                                                fontSize: font11,
                                                color:
                                                    (channel == "contact form")
                                                        ? Colors.white
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(320),
                                          height: ScreenUtil().setHeight(60),
                                          margin: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setWidth(10),
                                              ScreenUtil().setHeight(10)),
                                          decoration: BoxDecoration(
                                            color:
                                                (channel == "whatsapp forward")
                                                    ? Colors.blue
                                                    : Colors.white,
                                            border: Border(
                                              top: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "whatsapp forward")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "whatsapp forward")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "whatsapp forward")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              left: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "whatsapp forward")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                            ),
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setModalState(() {
                                                channel = "whatsapp forward";
                                              });
                                            },
                                            child: Text(
                                              'WhatsApp Forward',
                                              style: TextStyle(
                                                fontSize: font11,
                                                color: (channel ==
                                                        "whatsapp forward")
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(220),
                                          height: ScreenUtil().setHeight(60),
                                          margin: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setWidth(20),
                                              0),
                                          decoration: BoxDecoration(
                                            color: (channel == "messenger")
                                                ? Colors.blue
                                                : Colors.white,
                                            border: Border(
                                              top: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "messenger")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "messenger")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "messenger")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              left: BorderSide(
                                                  width: 1,
                                                  color: (channel ==
                                                          "messenger")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                            ),
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setModalState(() {
                                                channel = "messenger";
                                              });
                                            },
                                            child: Text(
                                              'Messenger',
                                              style: TextStyle(
                                                fontSize: font11,
                                                color: (channel == "messenger")
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: ScreenUtil().setWidth(200),
                                          height: ScreenUtil().setHeight(60),
                                          margin: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setWidth(15),
                                              0),
                                          decoration: BoxDecoration(
                                            color: (channel == "import")
                                                ? Colors.blue
                                                : Colors.white,
                                            border: Border(
                                              top: BorderSide(
                                                  width: 1,
                                                  color: (channel == "import")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              right: BorderSide(
                                                  width: 1,
                                                  color: (channel == "import")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: (channel == "import")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                              left: BorderSide(
                                                  width: 1,
                                                  color: (channel == "import")
                                                      ? Colors.blue
                                                      : Colors.grey.shade300),
                                            ),
                                          ),
                                          child: FlatButton(
                                            onPressed: () {
                                              setModalState(() {
                                                channel = "import";
                                              });
                                            },
                                            child: Text(
                                              'Import',
                                              style: TextStyle(
                                                fontSize: font11,
                                                color: (channel == "import")
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
                              SizedBox(
                                height: ScreenUtil().setHeight(30),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "By Apps",
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
                                children: <Widget>[
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        _showBottomSheet("byApps");
                                      },
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          0,
                                          ScreenUtil().setHeight(20),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              style: BorderStyle.solid),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                height:
                                                    ScreenUtil().setHeight(60),
                                                padding: EdgeInsets.fromLTRB(
                                                    ScreenUtil().setHeight(10),
                                                    ScreenUtil().setHeight(16),
                                                    0,
                                                    0),
                                                child: Text(
                                                  apps,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: font14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: ScreenUtil().setWidth(10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "By Link",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: font14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(5),
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        _showBottomSheet("byLink");
                                      },
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          0,
                                          ScreenUtil().setHeight(20),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              style: BorderStyle.solid),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                height:
                                                    ScreenUtil().setHeight(60),
                                                padding: EdgeInsets.fromLTRB(
                                                    ScreenUtil().setHeight(10),
                                                    ScreenUtil().setHeight(16),
                                                    0,
                                                    0),
                                                child: Text(
                                                  _byLink,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: font14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: ScreenUtil().setWidth(10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              Container(
                                child: (level == "0")
                                    ? Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "By Executive",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: font14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(5),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    _showBottomSheet(
                                                        "byExecutive");
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                      0,
                                                      0,
                                                      0,
                                                      ScreenUtil()
                                                          .setHeight(20),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade400,
                                                          style: BorderStyle
                                                              .solid),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Container(
                                                            height: ScreenUtil()
                                                                .setHeight(60),
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    ScreenUtil()
                                                                        .setHeight(
                                                                            10),
                                                                    ScreenUtil()
                                                                        .setHeight(
                                                                            16),
                                                                    0,
                                                                    0),
                                                            child: Text(
                                                              _byExecutive,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    font14,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.arrow_drop_down,
                                                          color: Colors.black,
                                                        ),
                                                        SizedBox(
                                                          width: ScreenUtil()
                                                              .setWidth(10),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(20),
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Start Date",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: font14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(5),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(200),
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  backgroundColor: Colors.transparent,
                                  minimumDate: DateFormat("yyyy-MM-dd")
                                      .parse(minimumDate),
                                  initialDateTime: _startDate,
                                  maximumDate: (_endDatePicker == null)
                                      ? DateTime.now()
                                      : _endDatePicker,
                                  onDateTimeChanged: (start) {
                                    setModalState(() {
                                      _startDate = start;
                                      _startDatePicker = start;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "End Date",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: font14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(5),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(200),
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  backgroundColor: Colors.transparent,
                                  minimumDate: (_startDatePicker == null)
                                      ? DateFormat("yyyy-MM-dd")
                                          .parse(minimumDate)
                                      : _startDatePicker,
                                  maximumDate: DateTime.now(),
                                  initialDateTime: _endDate,
                                  onDateTimeChanged: (end) {
                                    setModalState(() {
                                      _endDate = end;
                                      _endDatePicker = end;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      Toast.show("Please check your Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _showBottomSheet(String type) {
    switch (type) {
      case "byLink":
        {
          int position;
          if (_byLink == "All Links") {
            position = 0;
          } else {
            for (int i = 0; i < linksID.length; i++) {
              if (_byLink == linksID[i].link_type + linksID[i].link) {
                position = linksID[i].position;
              }
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
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey.shade300),
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
                                  Navigator.pop(context, true);
                                  Navigator.of(context).pop();
                                  _filter();
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
                              scrollController: FixedExtentScrollController(
                                  initialItem: position),
                              onSelectedItemChanged: (int index) {
                                if (this.mounted) {
                                  setState(() {
                                    _byLink = linksID[index].link_type +
                                        linksID[index].link;
                                  });
                                }
                              },
                              children: <Widget>[
                                for (var each in linksID)
                                  Text(
                                    each.link_type + each.link,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: font14,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
        break;

      case "byStatus":
        {
          int position;
          for (int i = 0; i < status.length; i++) {
            if (_byStatus == status[i]) {
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
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey.shade300),
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
                                  Navigator.pop(context, true);
                                  Navigator.of(context).pop();
                                  _filter();
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
                              scrollController: FixedExtentScrollController(
                                  initialItem: position),
                              onSelectedItemChanged: (int index) {
                                if (this.mounted) {
                                  setState(() {
                                    _byStatus = status[index];
                                  });
                                }
                              },
                              children: <Widget>[
                                for (var each in status)
                                  Text(
                                    each,
                                    style: TextStyle(
                                      fontSize: font14,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
        break;

      case "byExecutive":
        {
          int position;
          for (int i = 0; i < executiveList.length; i++) {
            if (_byExecutive == executiveList[i]) {
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
                              bottom: BorderSide(
                                  width: 1, color: Colors.grey.shade300),
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
                                  Navigator.pop(context, true);
                                  Navigator.of(context).pop();
                                  _filter();
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
                              scrollController: FixedExtentScrollController(
                                  initialItem: position),
                              onSelectedItemChanged: (int index) {
                                if (this.mounted) {
                                  setState(() {
                                    _byExecutive = executiveList[index];
                                  });
                                }
                              },
                              children: <Widget>[
                                for (var each in executiveList)
                                  Text(
                                    each,
                                    style: TextStyle(
                                      fontSize: font14,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
        break;

      case "byApps":
        {
          int position;
          if (apps == "All") {
            position = 0;
          } else {
            for (int i = 0; i < appsAll.length; i++) {
              if (apps == appsAll[i]) {
                position = i;
              }
            }
          }
          showModalBottomSheet(
            isDismissible: false,
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.96,
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
                                  Navigator.pop(context, true);
                                  Navigator.of(context).pop();
                                  _filter();
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
                              scrollController: FixedExtentScrollController(
                                  initialItem: position),
                              onSelectedItemChanged: (int index) {
                                if (this.mounted) {
                                  setState(() {
                                    apps = appsAll[index];
                                  });
                                }
                              },
                              children: <Widget>[
                                for (var each in appsAll)
                                  Text(
                                    each,
                                    style: TextStyle(
                                      fontSize: font14,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
        break;
    }
  }

  void checkConnection() async {
    startTime = (DateTime.now()).millisecondsSinceEpoch;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("noti") != null) {
      if (this.mounted) {
        setState(() {
          totalNotification = prefs.getString("noti");
        });
      }
    }
    companyID = prefs.getString('companyID');
    userID = prefs.getString('userID');
    level = prefs.getString('level');
    userType = prefs.getString('user_type');
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      // _onLoading();
      getPreference();
    } else {
      offline();
      Toast.show("No Internet, the data shown is not up to date", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void getPreference() {
    getData();
    getLinks();
    getExecutive();
    notification();
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

  String checkStatus(String status) {
    String realStatus;
    switch (status.toLowerCase()) {
      case "new":
        realStatus = "New";
        break;

      case "contacting":
        realStatus = "Contacting";
        break;

      case "contacted":
        realStatus = "Contacted";
        break;

      case "qualified":
        realStatus = "Qualified";
        break;

      case "converted":
        realStatus = "Converted";
        break;

      case "follow-up":
        realStatus = "Follow-up";
        break;

      case "unqualified":
        realStatus = "Unqualified";
        break;

      case "new":
        realStatus = "New";
        break;

      case "bad information":
        realStatus = "Bad Information";
        break;

      case "no response":
        realStatus = "No Response";
        break;
    }
    return realStatus;
  }

  void getData() {
    http.post(urlVData, body: {
      "companyID": companyID,
      "level": level,
      "userID": userID,
      "user_type": userType,
      "type": type,
      "channel": channel,
      "apps": apps,
      "link_id": link_id,
      "status": _byStatus,
      "executive": _byExecutive,
      "search": search,
      "start_date": minimumDate,
      "end_date": DateTime.now().toString().substring(0, 10),
      "count": "0",
      "offline": "no"
    }).then((res) {
      // print("VData status:" + (res.statusCode).toString());
      // print("VData body: " + res.body.toString());
      if (res.body == "nodata") {
        if (this.mounted) {
          setState(() {
            vData = true;
            connection = true;
            nodata = true;
            total = 0;
          });
        }
      } else {
        var jsonData = json.decode(res.body);
        if (this.mounted) {
          setState(() {
            total = jsonData[0]['total'];
          });
        }
        vDataDetails.clear();
        vDataDetails1.clear();
        for (var data in jsonData) {
          VDataDetails vdata = VDataDetails(
            date: data['date'],
            name: data['name'] ?? "",
            phoneNo: data['phone_number'],
            remark: data['remark'] ?? "-",
            status: checkStatus(data['status']),
            type: data['type'],
            app: data['app'],
            channel: data['channel'],
            link: data['link_type'] ?? "" + data['link'],
            handler: data['link'],
          );
          vDataDetails.add(vdata);
          vDataDetails1.add(vdata);
        }
        if (this.mounted) {
          setState(() {
            vData = true;
            connection = true;
          });
        }
      }
      if (link == true && vData == true && executive == true) {
        getOfflineData();
        endTime = DateTime.now().millisecondsSinceEpoch;
        int result = endTime - startTime;
        print("VAnalytics Loading Time: " + result.toString());
      }
    }).catchError((err) {
      print("Get data error: " + (err).toString());
    });
  }

  void getOfflineData() {
    http.post(urlVData, body: {
      "companyID": companyID,
      "level": level,
      "userID": userID,
      "user_type": userType,
      "type": type,
      "channel": channel,
      "apps": apps,
      "link_id": link_id,
      "status": _byStatus,
      "executive": _byExecutive,
      "search": search,
      "start_date": minimumDate,
      "end_date": DateTime.now().toString().substring(0, 10),
      "count": "0",
      "offline": "yes"
    }).then((res) {
      // print("Save VData status:" + (res.statusCode).toString());
      // print("Save VData body: " + res.body.toString());
      if (res.body != "nodata") {
        var jsonData = json.decode(res.body);
        for (var data in jsonData) {
          VDataDetails vdata = VDataDetails(
            date: data['date'],
            name: data['name'] ?? "",
            phoneNo: data['phone_number'],
            remark: data['remark'] ?? "-",
            status: checkStatus(data['status']),
            type: data['type'],
            app: data['app'],
            channel: data['channel'],
            link: data['link_type'] ?? "" + data['link'],
            handler: data['link'],
          );
          vDataOffline.add(vdata);
        }
        setData();
      }
    }).catchError((err) {
      print("Get offline data error: " + (err).toString());
    });
  }

  void _getMoreVData() {
    http.post(urlVData, body: {
      "companyID": companyID,
      "level": level,
      "userID": userID,
      "user_type": userType,
      "type": type,
      "channel": channel,
      "apps": apps,
      "link_id": link_id,
      "status": _byStatus,
      "executive": _byExecutive,
      "search": search,
      "start_date": _startDate.toString().substring(0, 10),
      "end_date": _endDate.toString().substring(0, 10),
      "count": vDataDetails.length.toString(),
      "offline": "no"
    }).then((res) {
      // print("VData status:" + (res.statusCode).toString());
      // print("Get More VData body: " + res.body.toString());
      if (res.body == "nodata") {
        if (this.mounted) {
          setState(() {
            connection = true;
          });
        }
      } else {
        var jsonData = json.decode(res.body);
        if (this.mounted) {
          setState(() {
            total = jsonData[0]['total'];
          });
        }
        for (var data in jsonData) {
          VDataDetails vdata = VDataDetails(
            date: data['date'],
            name: data['name'] ?? "",
            phoneNo: data['phone_number'],
            remark: data['remark'] ?? "-",
            status: checkStatus(data['status']),
            type: data['type'],
            app: data['app'],
            channel: data['channel'],
            link: data['link_type'] ?? "" + data['link'],
            handler: data['link'],
          );
          vDataDetails.add(vdata);
          vDataDetails1.add(vdata);
        }
        if (this.mounted) {
          setState(() {
            connection = true;
          });
        }
      }
    }).catchError((err) {
      print("Get more data error: " + (err).toString());
    });
  }

  void getLinks() {
    http.post(urlLinks, body: {
      "companyID": companyID,
      "level": level,
      "userID": userID,
      "user_type": userType,
    }).then((res) {
      links.clear();
      links.add("All Links");
      if (res.body != "nodata") {
        var jsonData = json.decode(res.body);
        Links allLinks = Links(
          link_type: "",
          link: "All Links",
          link_id: "All Links",
          position: 0,
        );
        linksID.add(allLinks);
        for (int i = 0; i < jsonData.length; i++) {
          Links linkID = Links(
            link_type: jsonData[i]['link_type'],
            link: jsonData[i]['link'] ?? "",
            link_id: jsonData[i]['link_id'],
            position: i + 1,
          );
          linksID.add(linkID);
          String link = jsonData[i]['link_type'].toString() +
              jsonData[i]['link'].toString();
          links.add(link);
        }
      }
      _startDate = DateFormat("yyyy-MM-dd").parse(minimumDate);
      _endDate = DateTime.now();
      if (this.mounted) {
        setState(() {
          link = true;
        });
      }
      if (link == true && vData == true && executive == true) {
        // Navigator.pop(context);
        getOfflineData();
        endTime = DateTime.now().millisecondsSinceEpoch;
        int result = endTime - startTime;
        print("VAnalytics Loading Time: " + result.toString());
      }
    }).catchError((err) {
      print("Get link error: " + (err).toString());
    });
  }

  void getExecutive() {
    executiveList.clear();
    executiveList.add("All Executives");
    http.post(urlHandler, body: {
      "companyID": companyID,
      "userID": userID,
      "user_type": userType,
      "level": level,
    }).then((res) {
      if (res.body != "nodata") {
        var jsonData = json.decode(res.body);
        for (var data in jsonData) {
          if (data["handler"] != "-") {
            Handler handler = Handler(
              handler: data["handler"],
              position: data["position"],
              handlerID: data["handlerID"],
            );
            executiveList.add(data["handler"]);
            handlerList.add(handler);
          }
        }
      }
      if (this.mounted) {
        setState(() {
          executive = true;
        });
      }
      if (link == true && vData == true && executive == true) {
        // Navigator.pop(context);
        getOfflineData();
        endTime = DateTime.now().millisecondsSinceEpoch;
        int result = endTime - startTime;
        print("VAnalytics Loading Time: " + result.toString());
      }
    }).catchError((err) {
      Toast.show(err.toString(), context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get Executive error: " + (err).toString());
    });
  }

  Future<void> setData() async {
    Database db = await VDataDB.instance.database;
    await db.rawInsert('DELETE FROM vdata WHERE id > 0');
    for (int index = 0; index < vDataOffline.length; index++) {
      await db.rawInsert(
          'INSERT INTO vdata (date, name, phone, handler, remark, status, total) VALUES("' +
              vDataOffline[index].date +
              '","' +
              vDataOffline[index].name +
              '","' +
              vDataOffline[index].phoneNo +
              '","' +
              vDataOffline[index].handler +
              '","' +
              vDataOffline[index].remark +
              '","' +
              vDataOffline[index].status +
              '","' +
              total.toString() +
              '")');
    }
  }

  Future<void> offline() async {
    vdataDB = await VDataDB.instance.database;
    offlineVData = await vdataDB.query(VDataDB.table);
    if (this.mounted) {
      setState(() {
        link = true;
        vData = true;
      });
    }
  }

  setStatus(int index, String newVal) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      http.post(urlChangeStatus, body: {
        "phone_number": vDataDetails[index].phoneNo.toString(),
        "companyID": companyID,
        "userID": userID,
        "level": level,
        "user_type": userType,
        "status": newVal,
      }).then((res) {
        if (res.body == "success") {
          Toast.show("Status changed", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          if (this.mounted) {
            setState(() {
              vDataDetails[index].status = newVal;
              connection = true;
            });
          }
        } else {
          Toast.show(
              "Status can't change, please contact VVIN help desk", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }).catchError((err) {
        Toast.show("Status can't change, please check your Internet connection",
            context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        print("Set status error: " + (err).toString());
      });
    } else {
      Toast.show("This feature need Internet connection", context,
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

  void _noInternet() {
    Toast.show("You are in offline mode, filter feature is not allow", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void _done() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      Navigator.pop(context);

      startDate = _startDate.toString().substring(0, 10);
      endDate = _endDate.toString().substring(0, 10);
      for (int i = 0; i < linksID.length; i++) {
        if (_byLink == linksID[i].link_type + linksID[i].link) {
          linkID = linksID[i].link_type + linksID[i].link_id;
        }
      }
      if (this.mounted) {
        setState(() {
          nodata = false;
          type = type;
          channel = channel;
          linkID = linkID;
          search = search;
          total = null;
        });
      }
      http.post(urlVData, body: {
        "companyID": companyID,
        "level": level,
        "userID": userID,
        "user_type": userType,
        "startDate": startDate,
        "endDate": endDate,
        "type": type,
        "channel": channel,
        "apps": apps,
        "link_id": linkID,
        "status": _byStatus,
        "executive": _byExecutive,
        "search": search,
        "count": "0",
        "offline": "no"
      }).then((res) {
        // print("Filter status:" + (res.statusCode).toString());
        // print("Filter body: " + res.body.toString());
        if (res.body == "nodata") {
          if (this.mounted) {
            setState(() {
              vDataDetails.clear();
              vDataDetails1.clear();
              connection = true;
              nodata = true;
              total = 0;
            });
          }
        } else {
          var jsonData = json.decode(res.body);
          if (this.mounted) {
            setState(() {
              total = jsonData[0]['total'];
            });
          }
          vDataDetails.clear();
          vDataDetails1.clear();
          for (var data in jsonData) {
            VDataDetails vdata = VDataDetails(
              date: data['date'],
              name: data['name'] ?? "",
              phoneNo: data['phone_number'],
              remark: data['remark'] ?? "-",
              status: checkStatus(data['status']),
              type: data['type'],
              app: data['app'],
              channel: data['channel'],
              link: data['link_type'] ?? "" + data['link'],
              handler: data['link'],
            );
            vDataDetails.add(vdata);
            vDataDetails1.add(vdata);
          }
          if (this.mounted) {
            setState(() {
              connection = true;
            });
          }
        }
      }).catchError((err) {
        print("Filter error: " + (err).toString());
      });
    } else {
      Toast.show("Please check your internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<void> _search(String value) async {
    if (this.mounted) {
      setState(() {
        search = value.toLowerCase();
        nodata = false;
      });
    }
    if (connection == true) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.mobile) {
        // print(_startDate.toString() +
        //     ", " +
        //     _endDate.toString() +
        //     ", " +
        //     type.toString() +
        //     ", " +
        //     channel.toString() +
        //     ", " +
        //     apps.toString() +
        //     ", " +
        //     link_id.toString() +
        //     ", " +
        //     _byStatus.toString().substring(0, 10) +
        //     ", " +
        //     _byExecutive.toString() +
        //     ", " +
        //     search.toString());
        http.post(urlVData, body: {
          "companyID": companyID,
          "level": level,
          "userID": userID,
          "user_type": userType,
          "startDate": _startDate.toString().substring(0, 10),
          "endDate": _endDate.toString().substring(0, 10),
          "type": type,
          "channel": channel,
          "apps": apps,
          "link_id": link_id.toString(),
          "status": _byStatus,
          "executive": _byExecutive,
          "search": search,
          "count": "0",
          "offline": "no"
        }).then((res) {
          // print("Filter status:" + (res.statusCode).toString());
          // print("Search body: " + res.body.toString());
          if (res.body == "nodata") {
            if (this.mounted) {
              setState(() {
                vDataDetails.clear();
                vDataDetails1.clear();
                connection = true;
                nodata = true;
                total = 0;
              });
            }
          } else {
            var jsonData = json.decode(res.body);
            if (this.mounted) {
              setState(() {
                total = jsonData[0]['total'];
              });
            }
            vDataDetails.clear();
            vDataDetails1.clear();
            for (var data in jsonData) {
              VDataDetails vdata = VDataDetails(
                date: data['date'],
                name: data['name'] ?? "",
                phoneNo: data['phone_number'],
                remark: data['remark'] ?? "-",
                status: checkStatus(data['status']),
                type: data['type'],
                app: data['app'],
                channel: data['channel'],
                link: data['link_type'] ?? "" + data['link'],
                handler: data['link'],
              );
              vDataDetails.add(vdata);
              vDataDetails1.add(vdata);
            }
            if (this.mounted) {
              setState(() {
                connection = true;
              });
            }
          }
        }).catchError((err) {
          Toast.show("Something wrong, please contact VVIN IT deesk", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          print("Search error: " + (err).toString());
        });
      } else {
        Toast.show("Please check your Internet Connection", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    } else {
      offlineVData = await vdataDB.rawQuery(
          "SELECT * FROM vdata WHERE name LIKE '%" +
              value +
              "%' OR phone LIKE '%" +
              value +
              "%' OR remark LIKE '%" +
              value +
              "%' OR status LIKE '%" +
              value +
              "%'");
      if (this.mounted) {
        setState(() {
          connection = false;
        });
      }
    }
  }

  // String _dateFormat(String fullDate) {
  //   String result, date, month, year;
  //   date = fullDate.substring(8, 10);
  //   month = fullDate.substring(5, 7);
  //   year = fullDate.substring(0, 4);
  //   result = date + "/" + month + "/" + year;
  //   return result;
  // }

  Future<Null> _handleRefresh() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      if (this.mounted) {
        setState(() {
          connection = false;
          vData = false;
          link = false;
          total = null;
        });
      }
      getData();
      getLinks();
    } else {
      Toast.show("No Internet connection, data can't load", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }
}

Route _createRoute(VDataDetails vdata) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        VProfile(vdata: vdata),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
