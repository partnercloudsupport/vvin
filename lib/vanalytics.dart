import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:vvin/data.dart';
import 'package:vvin/leadsDB.dart';
import 'package:vvin/lineChart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vvin/loader.dart';
import 'package:http/http.dart' as http;
import 'package:vvin/mainscreen.dart';
import 'package:vvin/topViewDB.dart';
import 'package:vvin/vanalyticsDB.dart';
import 'package:vvin/vdataNoHandler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vvin/vprofile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

final ScrollController controller = ScrollController();
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.my.jtapps.vvin';

class VAnalytics extends StatefulWidget {
  const VAnalytics({Key key}) : super(key: key);

  @override
  _VAnalyticsState createState() => _VAnalyticsState();
}

class _VAnalyticsState extends State<VAnalytics> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  GlobalKey<RefreshIndicatorState> refreshKey;
  List<Map> offlineVAnalyticsData;
  List<Map> offlineTopViewData;
  List<Map> offlineChartData;
  DateTime _startDate, _endDate, prevDate, _startDatePicker;
  List<TopView> topViews = [];
  List<LeadData> leadsDatas = [];
  List<LeadData> offlineLeadsDatas = [];
  String dateBanner,
      companyID,
      level,
      userID,
      userType,
      startDate,
      _startdate,
      endDate,
      _enddate,
      totalLeads,
      totalLeadsPercentage,
      unassignedLeads,
      newLeads,
      contactingLeads,
      contactedLeads,
      qualifiedLeads,
      convertedLeads,
      followupLeads,
      unqualifiedLeads,
      badInfoLeads,
      noResponseLeads,
      vflex,
      vcard,
      vcatelogue,
      vbot,
      vhome,
      messenger,
      whatsappForward,
      import,
      contactForm,
      minimumDate,
      dateBannerLocal,
      currentVersion,
      newVersion;

  String urlVAnalytics = "https://vvinoa.vvin.com/api/vanalytics.php";
  String urlTopViews = "https://vvinoa.vvin.com/api/topview.php";
  String urlLeads = "https://vvinoa.vvin.com/api/leads.php";
  int load, startTime, endTime;
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  double font16 = ScreenUtil().setSp(36.8, allowFontScalingSelf: false);
  double font25 = ScreenUtil().setSp(57.5, allowFontScalingSelf: false);
  bool connection,
      nodata,
      positive,
      timeBar,
      topView,
      vanalytic,
      chartData,
      refresh,
      editor;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    refreshKey = GlobalKey<RefreshIndicatorState>();
    newVersion = "";
    editor = false;
    connection = false;
    nodata = false;
    refresh = false;
    load = 0;
    _initialize();
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
        // backgroundColor: Color.fromARGB(50, 220, 220, 220),
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
                "VAnalytics",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: font18,
                    fontWeight: FontWeight.bold),
              )),
        ),
        body: (editor == true)
            ? Container(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(
                      "You have no permission to enter this page",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize:
                            ScreenUtil().setSp(35, allowFontScalingSelf: false),
                      ),
                    ),
                  ),
                ],
              ))
            : RefreshIndicator(
                key: refreshKey,
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  controller: controller,
                  child: (timeBar == true &&
                          topView == true &&
                          vanalytic == true &&
                          chartData == true)
                      ? Column(
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                var connectivityResult =
                                    await (Connectivity().checkConnectivity());
                                if (connectivityResult ==
                                        ConnectivityResult.wifi ||
                                    connectivityResult ==
                                        ConnectivityResult.mobile) {
                                  _filterDate();
                                } else {
                                  _noInternet();
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                height: ScreenUtil().setHeight(60),
                                margin: EdgeInsets.all(
                                  ScreenUtil().setHeight(20),
                                ),
                                padding: EdgeInsets.all(
                                  ScreenUtil().setHeight(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              (connection == true)
                                                  ? dateBanner
                                                  : dateBannerLocal,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(
                                ScreenUtil().setHeight(10),
                              ),
                              color: Colors.white,
                              margin: EdgeInsets.fromLTRB(
                                ScreenUtil().setHeight(20),
                                0,
                                ScreenUtil().setHeight(20),
                                ScreenUtil().setHeight(20),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                      ScreenUtil().setHeight(20),
                                      0,
                                      0,
                                      ScreenUtil().setHeight(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "Leads",
                                            style: TextStyle(
                                              fontSize: font16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        FlatButton(
                                          child: Icon(
                                            Icons.aspect_ratio,
                                            size: ScreenUtil().setHeight(50),
                                          ),
                                          shape: CircleBorder(
                                              side: BorderSide(
                                                  color: Colors.transparent)),
                                          onPressed: () {
                                            (connection == true)
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LineChart(
                                                                leadsDatas:
                                                                    leadsDatas)))
                                                : Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          LineChart(
                                                              leadsDatas:
                                                                  offlineLeadsDatas),
                                                    ),
                                                  );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    child: SfCartesianChart(
                                      zoomPanBehavior:
                                          ZoomPanBehavior(enablePinching: true),
                                      tooltipBehavior: TooltipBehavior(
                                          enable: true, header: "Total Leads"),
                                      primaryXAxis: CategoryAxis(),
                                      series: <ChartSeries>[
                                        // Initialize line series
                                        LineSeries<LeadsData, String>(
                                            enableTooltip: true,
                                            dataSource: (connection == true)
                                                ? [
                                                    for (var data in leadsDatas)
                                                      LeadsData(
                                                          data.date,
                                                          double.parse(
                                                              data.number))
                                                  ]
                                                : [
                                                    for (var data
                                                        in offlineChartData)
                                                      LeadsData(
                                                          data['date'],
                                                          double.parse(
                                                              data['number'])),
                                                  ],
                                            color: Colors.blue,
                                            xValueMapper:
                                                (LeadsData sales, _) => sales.x,
                                            yValueMapper:
                                                (LeadsData sales, _) => sales.y)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                  ScreenUtil().setHeight(20),
                                  0,
                                  ScreenUtil().setHeight(20),
                                  0),
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      height: ScreenUtil().setHeight(210),
                                      color: Colors.white,
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "Total Leads",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: font14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: _totalLeads,
                                                child: Text(
                                                  (connection == true)
                                                      ? totalLeads
                                                      : offlineVAnalyticsData[0]
                                                          ['total_leads'],
                                                  style: TextStyle(
                                                      fontSize: font25,
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(4),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                (connection == true)
                                                    ? totalLeadsPercentage
                                                    : offlineVAnalyticsData[0][
                                                        'total_leads_percentage'],
                                                style: TextStyle(
                                                    fontSize: font14,
                                                    color: (positive == true)
                                                        ? Colors.greenAccent
                                                        : Colors.red),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setHeight(20),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      height: ScreenUtil().setHeight(210),
                                      color: Colors.white,
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Flexible(
                                                  child: Text(
                                                "Unassigned Leads",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: font14,
                                                ),
                                              ))
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                (connection == true)
                                                    ? unassignedLeads
                                                    : offlineVAnalyticsData[0]
                                                        ['unassigned_leads'],
                                                style: TextStyle(
                                                    fontSize: font25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: ScreenUtil().setHeight(4),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              var connectivityResult =
                                                  await (Connectivity()
                                                      .checkConnectivity());
                                              if (connectivityResult ==
                                                      ConnectivityResult.wifi ||
                                                  connectivityResult ==
                                                      ConnectivityResult
                                                          .mobile) {
                                                _assignedNow();
                                              } else {
                                                _noInternet();
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  ScreenUtil().setHeight(20),
                                                  ScreenUtil().setHeight(10),
                                                  0),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    "Assign now",
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: font12,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: ScreenUtil()
                                                        .setHeight(6),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: ScreenUtil()
                                                        .setHeight(20),
                                                    color: Colors.blue,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(
                                ScreenUtil().setHeight(20),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(
                                      ScreenUtil().setHeight(20),
                                    ),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Top 10 Views",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: font16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: (nodata == true)
                                        ? Container(
                                            height: ScreenUtil().setHeight(155),
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: ListView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    children: <Widget>[
                                                      Column(
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.45,
                                                                padding: EdgeInsets.all(
                                                                    ScreenUtil()
                                                                        .setHeight(
                                                                            20)),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          235,
                                                                          235,
                                                                          255,
                                                                          1),
                                                                  border:
                                                                      Border(
                                                                    right: BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  "Name",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        font14,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            height: ScreenUtil()
                                                                .setHeight(70),
                                                            padding: EdgeInsets
                                                                .all(ScreenUtil()
                                                                    .setHeight(
                                                                        20)),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border(
                                                                right: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white,
                                                  margin: EdgeInsets.fromLTRB(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.45,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  child: Theme(
                                                    data: ThemeData(
                                                      highlightColor:
                                                          Colors.blue,
                                                    ),
                                                    child: Scrollbar(
                                                        child: ListView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      children: <Widget>[
                                                        Column(
                                                          children: <Widget>[
                                                            Container(
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          345),
                                                              padding: EdgeInsets
                                                                  .all(ScreenUtil()
                                                                      .setHeight(
                                                                          20)),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        235,
                                                                        235,
                                                                        255,
                                                                        1),
                                                                border: Border(
                                                                  right: BorderSide(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                "Status",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      font14,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              height:
                                                                  ScreenUtil()
                                                                      .setHeight(
                                                                          70),
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          345),
                                                              padding: EdgeInsets
                                                                  .all(ScreenUtil()
                                                                      .setHeight(
                                                                          20)),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border: Border(
                                                                  right: BorderSide(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Column(
                                                          children: <Widget>[
                                                            Container(
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          330),
                                                              padding: EdgeInsets
                                                                  .all(ScreenUtil()
                                                                      .setHeight(
                                                                          20)),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        235,
                                                                        235,
                                                                        255,
                                                                        1),
                                                                border: Border(
                                                                  right: BorderSide(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                "Channel",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      font14,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              height:
                                                                  ScreenUtil()
                                                                      .setHeight(
                                                                          70),
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          330),
                                                              padding: EdgeInsets
                                                                  .all(ScreenUtil()
                                                                      .setHeight(
                                                                          20)),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border: Border(
                                                                  right: BorderSide(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Column(
                                                          children: <Widget>[
                                                            Container(
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          180),
                                                              padding: EdgeInsets
                                                                  .all(ScreenUtil()
                                                                      .setHeight(
                                                                          20)),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color
                                                                    .fromRGBO(
                                                                        235,
                                                                        235,
                                                                        255,
                                                                        1),
                                                                border: Border(
                                                                  right: BorderSide(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                "Views",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      font14,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              height:
                                                                  ScreenUtil()
                                                                      .setHeight(
                                                                          70),
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          180),
                                                              padding: EdgeInsets
                                                                  .all(ScreenUtil()
                                                                      .setHeight(
                                                                          20)),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border: Border(
                                                                  right: BorderSide(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            // height: ScreenUtil().setHeight(847),
                                            height: (connection == true)
                                                ? ScreenUtil().setHeight(
                                                    85 + 77 * topViews.length)
                                                : ScreenUtil().setHeight(85 +
                                                    77 *
                                                        offlineTopViewData
                                                            .length),
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45,
                                                  child: (connection == true)
                                                      ? Column(
                                                          children: <Widget>[
                                                            for (var i = 0;
                                                                i <
                                                                    topViews.length +
                                                                        1;
                                                                i++)
                                                              (i == 0)
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.45,
                                                                          padding:
                                                                              EdgeInsets.all(ScreenUtil().setHeight(20)),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: Color.fromRGBO(
                                                                                235,
                                                                                235,
                                                                                255,
                                                                                1),
                                                                            border:
                                                                                Border(
                                                                              right: BorderSide(width: 1, color: Colors.grey.shade300),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            "Name",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: font14,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        var connectivityResult =
                                                                            await (Connectivity().checkConnectivity());
                                                                        if (connectivityResult == ConnectivityResult.wifi ||
                                                                            connectivityResult ==
                                                                                ConnectivityResult.mobile) {
                                                                          _redirectVProfile(i -
                                                                              1);
                                                                        } else {
                                                                          Toast.show(
                                                                              "This feature need Internet connection",
                                                                              context,
                                                                              duration: Toast.LENGTH_LONG,
                                                                              gravity: Toast.BOTTOM);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height: (i ==
                                                                                topViews.length)
                                                                            ? ScreenUtil().setHeight(80)
                                                                            : ScreenUtil().setHeight(77),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border(
                                                                            right:
                                                                                BorderSide(width: ScreenUtil().setWidth(2), color: Colors.grey.shade300),
                                                                          ),
                                                                        ),
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                          ScreenUtil()
                                                                              .setHeight(20),
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              topViews[i - 1].name,
                                                                              style: TextStyle(
                                                                                color: Colors.blue,
                                                                                fontSize: font14,
                                                                              ),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                          ],
                                                        )
                                                      : Column(
                                                          children: <Widget>[
                                                            for (var i = 0;
                                                                i <
                                                                    offlineTopViewData
                                                                            .length +
                                                                        1;
                                                                i++)
                                                              (i == 0)
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Container(
                                                                          width:
                                                                              MediaQuery.of(context).size.width * 0.45,
                                                                          padding:
                                                                              EdgeInsets.all(ScreenUtil().setHeight(20)),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: Color.fromRGBO(
                                                                                235,
                                                                                235,
                                                                                255,
                                                                                1),
                                                                            border:
                                                                                Border(
                                                                              right: BorderSide(width: 1, color: Colors.grey.shade300),
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            "Name",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.grey,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: font14,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Container(
                                                                      height: (i ==
                                                                              offlineTopViewData
                                                                                  .length)
                                                                          ? ScreenUtil().setHeight(
                                                                              80)
                                                                          : ScreenUtil()
                                                                              .setHeight(77),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border(
                                                                          right: BorderSide(
                                                                              width: ScreenUtil().setWidth(2),
                                                                              color: Colors.grey.shade300),
                                                                        ),
                                                                      ),
                                                                      padding:
                                                                          EdgeInsets
                                                                              .all(
                                                                        ScreenUtil()
                                                                            .setHeight(20),
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            (connection == true)
                                                                                ? topViews[i - 1].name
                                                                                : offlineTopViewData[i - 1]['name'],
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.blue,
                                                                              fontSize: font14,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                          ],
                                                        ),
                                                ),
                                                Container(
                                                  color: Colors.white,
                                                  margin: EdgeInsets.fromLTRB(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.45,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  child: Theme(
                                                    data: ThemeData(
                                                      highlightColor:
                                                          Colors.blue,
                                                    ),
                                                    child: Scrollbar(
                                                      child:
                                                          (connection == true)
                                                              ? ListView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  children: <
                                                                      Widget>[
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        for (var i =
                                                                                0;
                                                                            i < topViews.length + 1;
                                                                            i++)
                                                                          (i == 0)
                                                                              ? Container(
                                                                                  width: ScreenUtil().setWidth(345),
                                                                                  padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Color.fromRGBO(235, 235, 255, 1),
                                                                                    border: Border(
                                                                                      right: BorderSide(width: 1, color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    "Status",
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    Container(
                                                                                      height: ScreenUtil().setHeight(77),
                                                                                      width: ScreenUtil().setWidth(345),
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border(
                                                                                          right: BorderSide(width: ScreenUtil().setHeight(2), color: Colors.grey.shade300),
                                                                                        ),
                                                                                      ),
                                                                                      padding: EdgeInsets.all(
                                                                                        ScreenUtil().setHeight(20),
                                                                                      ),
                                                                                      child: Text(
                                                                                        topViews[i - 1].status,
                                                                                        style: TextStyle(
                                                                                          color: Colors.grey,
                                                                                          fontSize: font14,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        for (var i =
                                                                                0;
                                                                            i < topViews.length + 1;
                                                                            i++)
                                                                          (i == 0)
                                                                              ? Container(
                                                                                  width: ScreenUtil().setWidth(345),
                                                                                  padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Color.fromRGBO(235, 235, 255, 1),
                                                                                    border: Border(
                                                                                      right: BorderSide(width: 1, color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    "Channel",
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container(
                                                                                  height: ScreenUtil().setHeight(77),
                                                                                  width: ScreenUtil().setWidth(345),
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border(
                                                                                      right: BorderSide(width: ScreenUtil().setHeight(2), color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  padding: EdgeInsets.all(
                                                                                    ScreenUtil().setHeight(20),
                                                                                  ),
                                                                                  child: Text(
                                                                                    topViews[i - 1].channel,
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        for (var i =
                                                                                0;
                                                                            i < topViews.length + 1;
                                                                            i++)
                                                                          (i == 0)
                                                                              ? Container(
                                                                                  width: ScreenUtil().setWidth(180),
                                                                                  padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Color.fromRGBO(235, 235, 255, 1),
                                                                                    border: Border(
                                                                                      right: BorderSide(width: 1, color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    "Views",
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container(
                                                                                  height: ScreenUtil().setHeight(77),
                                                                                  width: ScreenUtil().setWidth(180),
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border(
                                                                                      right: BorderSide(width: ScreenUtil().setHeight(2), color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  padding: EdgeInsets.all(
                                                                                    ScreenUtil().setHeight(20),
                                                                                  ),
                                                                                  child: Text(
                                                                                    topViews[i - 1].views,
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                )
                                                              : ListView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  children: <
                                                                      Widget>[
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        for (var i =
                                                                                0;
                                                                            i < offlineTopViewData.length + 1;
                                                                            i++)
                                                                          (i == 0)
                                                                              ? Container(
                                                                                  width: ScreenUtil().setWidth(345),
                                                                                  padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Color.fromRGBO(235, 235, 255, 1),
                                                                                    border: Border(
                                                                                      right: BorderSide(width: 1, color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    "Status",
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    Container(
                                                                                      height: ScreenUtil().setHeight(77),
                                                                                      width: ScreenUtil().setWidth(345),
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border(
                                                                                          right: BorderSide(width: ScreenUtil().setHeight(2), color: Colors.grey.shade300),
                                                                                        ),
                                                                                      ),
                                                                                      padding: EdgeInsets.all(
                                                                                        ScreenUtil().setHeight(20),
                                                                                      ),
                                                                                      child: Text(
                                                                                        offlineTopViewData[i - 1]['status'],
                                                                                        style: TextStyle(
                                                                                          color: Colors.grey,
                                                                                          fontSize: font14,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        for (var i =
                                                                                0;
                                                                            i < offlineTopViewData.length + 1;
                                                                            i++)
                                                                          (i == 0)
                                                                              ? Container(
                                                                                  width: ScreenUtil().setWidth(345),
                                                                                  padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Color.fromRGBO(235, 235, 255, 1),
                                                                                    border: Border(
                                                                                      right: BorderSide(width: 1, color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    "Channel",
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container(
                                                                                  height: ScreenUtil().setHeight(77),
                                                                                  width: ScreenUtil().setWidth(345),
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border(
                                                                                      right: BorderSide(width: ScreenUtil().setHeight(2), color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  padding: EdgeInsets.all(
                                                                                    ScreenUtil().setHeight(20),
                                                                                  ),
                                                                                  child: Text(
                                                                                    offlineTopViewData[i - 1]['channel'],
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      children: <
                                                                          Widget>[
                                                                        for (var i =
                                                                                0;
                                                                            i < offlineTopViewData.length + 1;
                                                                            i++)
                                                                          (i == 0)
                                                                              ? Container(
                                                                                  width: ScreenUtil().setWidth(180),
                                                                                  padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                                                                                  decoration: BoxDecoration(
                                                                                    color: Color.fromRGBO(235, 235, 255, 1),
                                                                                    border: Border(
                                                                                      right: BorderSide(width: 1, color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    "Views",
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container(
                                                                                  height: ScreenUtil().setHeight(77),
                                                                                  width: ScreenUtil().setWidth(180),
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border(
                                                                                      right: BorderSide(width: ScreenUtil().setHeight(2), color: Colors.grey.shade300),
                                                                                    ),
                                                                                  ),
                                                                                  padding: EdgeInsets.all(
                                                                                    ScreenUtil().setHeight(20),
                                                                                  ),
                                                                                  child: Text(
                                                                                    offlineTopViewData[i - 1]['views'],
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey,
                                                                                      fontSize: font14,
                                                                                    ),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(
                                        0, ScreenUtil().setHeight(20), 0, 0),
                                    padding: EdgeInsets.all(
                                      ScreenUtil().setHeight(20),
                                    ),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Leads Status",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: font16,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(2),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.wifi ||
                                          connectivityResult ==
                                              ConnectivityResult.mobile) {
                                        _leadsStatus("New");
                                      } else {
                                        Toast.show(
                                            "This feature need Internet connection",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "New",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (connection == true)
                                                ? newLeads
                                                : offlineVAnalyticsData[0]
                                                    ['new_leads'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.wifi ||
                                          connectivityResult ==
                                              ConnectivityResult.mobile) {
                                        _leadsStatus("Contacting");
                                      } else {
                                        Toast.show(
                                            "This feature need Internet connection",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      color: Color.fromRGBO(232, 244, 248, 1),
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "Contacting",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (connection == true)
                                                ? contactingLeads
                                                : offlineVAnalyticsData[0]
                                                    ['contacting_leads'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.wifi ||
                                          connectivityResult ==
                                              ConnectivityResult.mobile) {
                                        _leadsStatus("Contacted");
                                      } else {
                                        Toast.show(
                                            "This feature need Internet connection",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "Contacted",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (connection == true)
                                                ? contactedLeads
                                                : offlineVAnalyticsData[0]
                                                    ['contacted_leads'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.wifi ||
                                          connectivityResult ==
                                              ConnectivityResult.mobile) {
                                        _leadsStatus("Qualified");
                                      } else {
                                        Toast.show(
                                            "This feature need Internet connection",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      color: Color.fromRGBO(232, 244, 248, 1),
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "Qualified",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (connection == true)
                                                ? qualifiedLeads
                                                : offlineVAnalyticsData[0]
                                                    ['qualified_leads'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.wifi ||
                                          connectivityResult ==
                                              ConnectivityResult.mobile) {
                                        _leadsStatus("Converted");
                                      } else {
                                        Toast.show(
                                            "This feature need Internet connection",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "Converted",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (connection == true)
                                                ? convertedLeads
                                                : offlineVAnalyticsData[0]
                                                    ['converted_leads'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.wifi ||
                                          connectivityResult ==
                                              ConnectivityResult.mobile) {
                                        _leadsStatus("Follow-up");
                                      } else {
                                        Toast.show(
                                            "This feature need Internet connection",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      color: Color.fromRGBO(232, 244, 248, 1),
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "Follow-up",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (connection == true)
                                                ? followupLeads
                                                : offlineVAnalyticsData[0]
                                                    ['followup_leads'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.wifi ||
                                          connectivityResult ==
                                              ConnectivityResult.mobile) {
                                        _leadsStatus("Unqualified");
                                      } else {
                                        Toast.show(
                                            "This feature need Internet connection",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "Unqualified",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (connection == true)
                                                ? unqualifiedLeads
                                                : offlineVAnalyticsData[0]
                                                    ['unqualified_leads'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.wifi ||
                                          connectivityResult ==
                                              ConnectivityResult.mobile) {
                                        _leadsStatus("Bad Information");
                                      } else {
                                        Toast.show(
                                            "This feature need Internet connection",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      color: Color.fromRGBO(232, 244, 248, 1),
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "Bad Information",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (connection == true)
                                                ? badInfoLeads
                                                : offlineVAnalyticsData[0]
                                                    ['bad_info_leads'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult ==
                                              ConnectivityResult.wifi ||
                                          connectivityResult ==
                                              ConnectivityResult.mobile) {
                                        _leadsStatus("No Response");
                                      } else {
                                        Toast.show(
                                            "This feature need Internet connection",
                                            context,
                                            duration: Toast.LENGTH_LONG,
                                            gravity: Toast.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.all(
                                        ScreenUtil().setHeight(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "No Response",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: font14,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            (connection == true)
                                                ? noResponseLeads
                                                : offlineVAnalyticsData[0]
                                                    ['no_response_leads'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: font14,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(20),
                                  ),
                                  Container(
                                    color: Colors.white,
                                    height: ScreenUtil().setHeight(820),
                                    child: SfCircularChart(
                                      onPointTapped: (PointTapArgs args) {
                                        _redirectAppChart(args.pointIndex);
                                      },
                                      // tooltipBehavior: TooltipBehavior(enable: true),
                                      // Enables the legend
                                      legend: Legend(
                                          title: LegendTitle(
                                              text: "App",
                                              textStyle: ChartTextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: font16,
                                              )),
                                          isVisible: true,
                                          overflowMode:
                                              LegendItemOverflowMode.wrap),
                                      series: <CircularSeries>[
                                        PieSeries<AppData, String>(
                                          enableSmartLabels: true,
                                          dataSource: [
                                            // Bind data source
                                            AppData(
                                                'VFlex',
                                                (connection == true)
                                                    ? double.parse(vflex)
                                                    : double.parse(
                                                        offlineVAnalyticsData[0]
                                                            ['vflex']),
                                                Color.fromRGBO(
                                                    175, 238, 238, 1)),
                                            AppData(
                                                'VCard',
                                                (connection == true)
                                                    ? double.parse(vcard)
                                                    : double.parse(
                                                        offlineVAnalyticsData[0]
                                                            ['vcard']),
                                                Color.fromRGBO(0, 0, 205, 1)),
                                            AppData(
                                                'VCatelogue',
                                                (connection == true)
                                                    ? double.parse(vcatelogue)
                                                    : double.parse(
                                                        offlineVAnalyticsData[0]
                                                            ['vcatelogue']),
                                                Color.fromRGBO(
                                                    30, 144, 255, 1)),
                                            AppData(
                                                'VBot',
                                                (connection == true)
                                                    ? double.parse(vbot)
                                                    : double.parse(
                                                        offlineVAnalyticsData[0]
                                                            ['vbot']),
                                                Color.fromRGBO(0, 128, 255, 1)),
                                            AppData(
                                                'VHome',
                                                (connection == true)
                                                    ? double.parse(vhome)
                                                    : double.parse(
                                                        offlineVAnalyticsData[0]
                                                            ['vhome']),
                                                Color.fromRGBO(
                                                    15, 128, 196, 1)),
                                          ],
                                          pointColorMapper: (AppData data, _) =>
                                              data.color,
                                          xValueMapper: (AppData data, _) =>
                                              data.x,
                                          yValueMapper: (AppData data, _) =>
                                              data.y,
                                          dataLabelSettings: DataLabelSettings(
                                              isVisible: true,
                                              labelPosition:
                                                  LabelPosition.inside),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtil().setHeight(20),
                                  ),
                                  Container(
                                    height: ScreenUtil().setHeight(820),
                                    color: Colors.white,
                                    child: SfCircularChart(
                                      onPointTapped: (PointTapArgs args) {
                                        _redirectChannelChart(args.pointIndex);
                                      },
                                      // tooltipBehavior: TooltipBehavior(enable: true),
                                      // Enables the legend
                                      legend: Legend(
                                          title: LegendTitle(
                                              text: "Channel",
                                              textStyle: ChartTextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: font16,
                                              )),
                                          isVisible: true,
                                          overflowMode:
                                              LegendItemOverflowMode.wrap),
                                      series: <CircularSeries>[
                                        PieSeries<ChannelData, String>(
                                          enableSmartLabels: true,
                                          dataSource: [
                                            // Bind data source
                                            ChannelData(
                                                'WhatsApp Forward',
                                                (connection == true)
                                                    ? double.parse(
                                                        whatsappForward)
                                                    : double.parse(
                                                        offlineVAnalyticsData[0]
                                                            [
                                                            'whatsapp_forward']),
                                                Color.fromRGBO(
                                                    72, 209, 204, 1)),
                                            ChannelData(
                                                'Contact Form',
                                                (connection == true)
                                                    ? double.parse(contactForm)
                                                    : double.parse(
                                                        offlineVAnalyticsData[0]
                                                            ['contact_form']),
                                                Color.fromRGBO(255, 165, 0, 1)),
                                            ChannelData(
                                                'Messenger',
                                                (connection == true)
                                                    ? double.parse(messenger)
                                                    : double.parse(
                                                        offlineVAnalyticsData[0]
                                                            ['messenger']),
                                                Color.fromRGBO(
                                                    135, 206, 250, 1)),
                                            ChannelData(
                                                'Import',
                                                (connection == true)
                                                    ? double.parse(import)
                                                    : double.parse(
                                                        offlineVAnalyticsData[0]
                                                            ['import']),
                                                Color.fromRGBO(
                                                    225, 225, 255, 1)),
                                          ],
                                          pointColorMapper:
                                              (ChannelData data, _) =>
                                                  data.color,
                                          xValueMapper: (ChannelData data, _) =>
                                              data.x,
                                          yValueMapper: (ChannelData data, _) =>
                                              data.y,
                                          dataLabelSettings: DataLabelSettings(
                                              isVisible: true,
                                              labelPosition:
                                                  LabelPosition.inside),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      : Container(
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
                        ),
                ),
              ),
      ),
    );
  }

  void _redirectVProfile(int position) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      VDataDetails vdata = new VDataDetails(
          companyID: companyID,
          userID: userID,
          level: level,
          userType: userType,
          name: topViews[position].name,
          phoneNo: topViews[position].phoneNo,
          status: topViews[position].status,
          fromVAnalytics: "yes");
      Navigator.of(context).push(_createRoute(vdata));
    } else {
      Toast.show("No Internet Connection!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _redirectAppChart(int position) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      String app;
      switch (position) {
        case 0:
          app = "VFlex";
          break;
        case 1:
          app = "VCard";
          break;
        case 2:
          app = "VCatalogue";
          break;
        case 3:
          app = "VBot";
          break;
        case 4:
          app = "VHome";
          break;
      }

      VDataFilter vDataFilter = VDataFilter(
          startDate: startDate,
          endDate: endDate,
          type: "all",
          status: "All Status",
          app: app,
          channel: "all");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VDataNoHandler(
            vDataFilter: vDataFilter,
          ),
        ),
      );
    } else {
      Toast.show("No Internet Connection!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _redirectChannelChart(int position) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      String channel;
      switch (position) {
        case 0:
          channel = "whatsApp forward";
          break;
        case 1:
          channel = "contact form";
          break;
        case 2:
          channel = "messenger";
          break;
        case 3:
          channel = "import";
          break;
      }
      VDataFilter vDataFilter = VDataFilter(
          startDate: startDate,
          endDate: endDate,
          type: "all",
          status: "All Status",
          app: "All",
          channel: channel);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VDataNoHandler(
            vDataFilter: vDataFilter,
          ),
        ),
      );
    } else {
      Toast.show("No Internet Connection!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    return Future.value(false);
  }

  void _noInternet() {
    Toast.show("This feature need Internet connection", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void _assignedNow() {
    VDataFilter vDataFilter = VDataFilter(
        startDate: startDate,
        endDate: endDate,
        type: "unassigned",
        status: "All Status",
        app: "All",
        channel: "all");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => VDataNoHandler(
          vDataFilter: vDataFilter,
        ),
      ),
    );
  }

  void _totalLeads() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      VDataFilter vDataFilter = VDataFilter(
          startDate: startDate,
          endDate: endDate,
          type: "all",
          status: "All Status",
          app: "All",
          channel: "all");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VDataNoHandler(
            vDataFilter: vDataFilter,
          ),
        ),
      );
    } else {
      Toast.show("This feature need Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _leadsStatus(String status) {
    VDataFilter vDataFilter = VDataFilter(
        startDate: startDate,
        endDate: endDate,
        type: "all",
        status: status,
        app: "All",
        channel: "all");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => VDataNoHandler(
          vDataFilter: vDataFilter,
        ),
      ),
    );
  }

  void _filterDate() {
    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: Colors.grey.shade300),
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
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Container(
                      padding: EdgeInsets.all(
                        ScreenUtil().setHeight(20),
                      ),
                      child: Column(
                        children: <Widget>[
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
                            height: ScreenUtil().setHeight(4),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(200),
                            child: CupertinoDatePicker(
                              minimumDate:
                                  DateFormat("yyyy-MM-dd").parse(minimumDate),
                              maximumDate: DateTime.now(),
                              mode: CupertinoDatePickerMode.date,
                              backgroundColor: Colors.transparent,
                              initialDateTime: _startDate,
                              onDateTimeChanged: (startDate) {
                                setModalState(() {
                                  _startDate = startDate;
                                  _startDatePicker = startDate;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(90),
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
                            height: ScreenUtil().setHeight(4),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(200),
                            child: CupertinoDatePicker(
                              minimumDate: (_startDatePicker == null)
                                  ? DateFormat("yyyy-MM-dd").parse(minimumDate)
                                  : _startDatePicker,
                              maximumDate: DateTime.now(),
                              mode: CupertinoDatePickerMode.date,
                              backgroundColor: Colors.transparent,
                              initialDateTime: _endDate,
                              onDateTimeChanged: (endDate) {
                                setModalState(() {
                                  _endDate = endDate;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("level") != "1") {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.mobile) {
        // _onLoading();
        startTime = (DateTime.now()).millisecondsSinceEpoch;
        getPreference();
      } else {
        offline();
        Toast.show("No Internet, the data shown is not up to date", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    } else {
      setState(() {
        editor = true;
      });
    }
  }

  Future<void> offline() async {
    Database vanalyticsDB = await VAnalyticsDB.instance.database;
    offlineVAnalyticsData = await vanalyticsDB.query(VAnalyticsDB.table);
    Database topViewDB = await TopViewDB.instance.database;
    offlineTopViewData = await topViewDB.query(TopViewDB.table);
    if (offlineTopViewData.length == 0) {
      setState(() {
        nodata = true;
      });
    }
    Database leadsDB = await LeadsDB.instance.database;
    offlineChartData = await leadsDB.query(LeadsDB.table);
    for (var data in offlineChartData) {
      LeadData leadsData = LeadData(
        date: data["date"],
        number: data["number"],
      );
      offlineLeadsDatas.add(leadsData);
    }
    String startDateLocal = offlineVAnalyticsData[0]['start_date'];
    String endDateLocal = offlineVAnalyticsData[0]['end_date'];
    String startYear = startDateLocal.toString().substring(0, 4);
    String endYear = endDateLocal.toString().substring(0, 4);
    String startMonth = checkMonth(startDateLocal.toString().substring(5, 7));
    String endMonth = checkMonth(endDateLocal.toString().substring(5, 7));
    String startDay = startDateLocal.toString().substring(8, 10);
    String endDay = endDateLocal.toString().substring(8, 10);
    dateBannerLocal = startMonth +
        " " +
        startDay +
        ", " +
        startYear +
        " - " +
        endMonth +
        " " +
        endDay +
        ", " +
        endYear;
    setState(() {
      timeBar = true;
      topView = true;
      vanalytic = true;
      chartData = true;
    });
  }

  String checkMonth(String month) {
    String monthInEnglishFormat;
    switch (month) {
      case "01":
        monthInEnglishFormat = "Jan";
        break;

      case "02":
        monthInEnglishFormat = "Feb";
        break;

      case "03":
        monthInEnglishFormat = "Mar";
        break;

      case "04":
        monthInEnglishFormat = "Apr";
        break;

      case "05":
        monthInEnglishFormat = "May";
        break;

      case "06":
        monthInEnglishFormat = "Jun";
        break;

      case "07":
        monthInEnglishFormat = "Jul";
        break;

      case "08":
        monthInEnglishFormat = "Aug";
        break;

      case "09":
        monthInEnglishFormat = "Sep";
        break;

      case "10":
        monthInEnglishFormat = "Oct";
        break;

      case "11":
        monthInEnglishFormat = "Nov";
        break;

      case "12":
        monthInEnglishFormat = "Dec";
        break;
    }
    return monthInEnglishFormat;
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

  Future<void> getPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    companyID = prefs.getString('companyID');
    level = prefs.getString('level');
    userID = prefs.getString('userID');
    userType = prefs.getString('user_type');
    minimumDate = "2017-12-01";
    _startDate = DateTime(
        DateTime.now().year, DateTime.now().month - 1, DateTime.now().day + 1);
    _startdate = _startDate.toString();
    _endDate = DateTime.now();
    _enddate = _endDate.toString();
    startDate = _startDate.toString().substring(0, 10);
    endDate = _endDate.toString().substring(0, 10);
    setupDateTimeBar();
    getTopViewData();
    getVanalyticsData();
    getChartData();
  }

  void getTopViewData() {
    setState(() {
      topView = false;
    });
    http.post(urlTopViews, body: {
      "companyID": companyID,
      "level": level,
      "userID": userID,
      "user_type": userType,
      "startDate": _startDate.toString().substring(0, 10),
      "endDate": _endDate.toString().substring(0, 10)
    }).then((res) {
      // print("VAnalytics top view status:" + (res.statusCode).toString());
      // print("VAnalytics top view body: " + res.body);
      if (res.body == "nodata") {
        setState(() {
          connection = true;
          topView = true;
          nodata = true;
        });
      } else {
        var jsonData = json.decode(res.body);
        topViews.clear();
        for (var data in jsonData) {
          TopView topView = TopView(
            name: data["name"],
            status: data["status"],
            channel: data["channel"],
            views: data["views"],
            phoneNo: data["phone_number"],
          );
          topViews.add(topView);
        }
        setState(() {
          topView = true;
          connection = true;
          load += 1;
        });
      }
      if (timeBar == true &&
          topView == true &&
          vanalytic == true &&
          chartData == true) {
        endTime = DateTime.now().millisecondsSinceEpoch;
        int result = endTime - startTime;
        print("VAnalytics Loading Time: " + result.toString());
      }
      setTopViewData();
    }).catchError((err) {
      Toast.show("GetTopViewData: " + err, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get Top View Data error: " + (err).toString());
    });
  }

  String calculatePercentage(String number) {
    String percentage;
    if (double.parse(number) >= 0) {
      percentage = "+" + number + "%";
    } else {
      percentage = number + "%";
    }
    return percentage;
  }

  Future<void> setAnalyticsData() async {
    Database db = await VAnalyticsDB.instance.database;
    await db.rawInsert('DELETE FROM analytics WHERE id > 0');
    await db.rawInsert(
        'INSERT INTO analytics (start_date, end_date, total_leads, total_leads_percentage, unassigned_leads, new_leads, contacting_leads, contacted_leads, qualified_leads, converted_leads, followup_leads, unqualified_leads, bad_info_leads, no_response_leads, vflex, vcard, vcatelogue, vbot, vhome, messenger, whatsapp_forward, import, contact_form, minimum_date) VALUES("' +
            startDate +
            '","' +
            endDate +
            '","' +
            totalLeads +
            '","' +
            totalLeadsPercentage +
            '","' +
            unassignedLeads +
            '","' +
            newLeads +
            '","' +
            contactingLeads +
            '","' +
            contactedLeads +
            '","' +
            qualifiedLeads +
            '","' +
            convertedLeads +
            '","' +
            followupLeads +
            '","' +
            unqualifiedLeads +
            '","' +
            badInfoLeads +
            '","' +
            noResponseLeads +
            '","' +
            vflex +
            '","' +
            vcard +
            '","' +
            vcatelogue +
            '","' +
            vbot +
            '","' +
            vhome +
            '","' +
            messenger +
            '","' +
            whatsappForward +
            '","' +
            import +
            '","' +
            contactForm +
            '","' +
            minimumDate +
            '")');
  }

  Future<void> setTopViewData() async {
    Database db = await TopViewDB.instance.database;
    await db.rawInsert('DELETE FROM topview WHERE id > 0');
    if (nodata != true) {
      for (int index = 0; index < topViews.length; index++) {
        await db.rawInsert(
            'INSERT INTO topview (name, status, channel, views) VALUES("' +
                topViews[index].name +
                '","' +
                topViews[index].status +
                '","' +
                topViews[index].channel +
                '","' +
                topViews[index].views +
                '")');
      }
    }
  }

  Future<void> setLeadsData() async {
    Database db = await LeadsDB.instance.database;
    await db.rawInsert('DELETE FROM leads WHERE id > 0');
    for (int index = 0; index < leadsDatas.length; index++) {
      await db.rawInsert('INSERT INTO leads (date, number) VALUES("' +
          leadsDatas[index].date +
          '","' +
          leadsDatas[index].number +
          '")');
    }
  }

  void getChartData() {
    setState(() {
      chartData = false;
    });
    http.post(urlLeads, body: {
      "companyID": companyID,
      "level": level,
      "userID": userID,
      "user_type": userType,
      "startDate": _startDate.toString().substring(0, 10),
      "endDate": _endDate.toString().substring(0, 10),
    }).then((res) {
      // print("VAnalytics total leads status:" + (res.statusCode).toString());
      // print("VAnalytics total leads body: " + res.body);
      if (res.body == "nodata") {
        LeadData leadsData = LeadData(
          date: DateTime.now().toString().substring(0, 10),
          number: "0",
        );
        leadsDatas.add(leadsData);
      } else {
        var jsonData = json.decode(res.body);
        leadsDatas.clear();
        for (var data in jsonData) {
          LeadData leadsData = LeadData(
            date: data["date"],
            number: data["number"],
          );
          leadsDatas.add(leadsData);
        }
      }

      setState(() {
        chartData = true;
        connection = true;
        _startdate = _startDate.toString();
      });
      if (timeBar == true &&
          topView == true &&
          vanalytic == true &&
          chartData == true) {
        endTime = DateTime.now().millisecondsSinceEpoch;
        int result = endTime - startTime;
        print("VAnalytics Loading Time: " + result.toString());
      }
      setLeadsData();
    }).catchError((err) {
      Toast.show("GetLeadsData: " + err, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get chart data error: " + (err).toString());
    });
  }

  void getVanalyticsData() {
    setState(() {
      vanalytic = false;
    });
    http.post(urlVAnalytics, body: {
      "companyID": companyID,
      "level": level,
      "userID": userID,
      "user_type": userType,
      "startDate": _startDate.toString().substring(0, 10),
      "endDate": _endDate.toString().substring(0, 10),
    }).then((res) {
      // print("VAnalytics status:" + (res.statusCode).toString());
      // print("VAnalytics body: " + res.body);
      var jsonData = json.decode(res.body);
      if (jsonData[0] == "nodata") {
        newVersion = jsonData[1];
        totalLeads = "0";
        totalLeadsPercentage = "0";
        unassignedLeads = "0";
        newLeads = "0";
        contactingLeads = "0";
        contactedLeads = "0";
        qualifiedLeads = "0";
        convertedLeads = "0";
        followupLeads = "0";
        unqualifiedLeads = "0";
        badInfoLeads = "0";
        noResponseLeads = "0";
        vflex = "0";
        vcard = "0";
        vcatelogue = "0";
        vbot = "0";
        vhome = "0";
        messenger = "0";
        whatsappForward = "0";
        import = "0";
        contactForm = "0";
        minimumDate = "2017-12-01";
      } else {
        for (var data in jsonData) {
          newVersion = data["version"];
          totalLeads = data["total_leads"];
          totalLeadsPercentage =
              calculatePercentage(data["total_leads_percentage"].toString());
          unassignedLeads = data["unassigned_leads"].toString();
          newLeads = data["new_leads"].toString();
          contactingLeads = data["contacting_leads"].toString();
          contactedLeads = data["contacted_leads"].toString();
          qualifiedLeads = data["qualified_leads"].toString();
          convertedLeads = data["converted_leads"].toString();
          followupLeads = data["followup_leads"].toString();
          unqualifiedLeads = data["unqualified_leads"].toString();
          badInfoLeads = data["bad_info_leads"].toString();
          noResponseLeads = data["no_response_leads"].toString();
          vflex = data["vflex"].toString();
          vcard = data["vcard"].toString();
          vcatelogue = data["vcatelogue"].toString();
          vbot = data["vbot"].toString();
          vhome = data["vhome"].toString();
          messenger = data["messenger"].toString();
          whatsappForward = data["whatsapp_forward"].toString();
          import = data["import"].toString();
          contactForm = data["contact_form"].toString();

          if (double.parse(data["total_leads_percentage"]) >= 0) {
            positive = true;
          } else {
            positive = false;
          }
        }
      }
      try {
        versionCheck(context);
      } catch (e) {
        print("VersionCheck error: " + e.toString());
      }
      setState(() {
        vanalytic = true;
        connection = true;
      });
      if (timeBar == true &&
          topView == true &&
          vanalytic == true &&
          chartData == true) {
        endTime = DateTime.now().millisecondsSinceEpoch;
        int result = endTime - startTime;
        print("VAnalytics Loading Time: " + result.toString());
      }
      setAnalyticsData();
    }).catchError((err) {
      Toast.show("GetAnalyticsData: " + err, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get Vanalytics Data error: " + (err).toString());
    });
  }

  void setupDateTimeBar() {
    setState(() {
      timeBar = false;
    });
    String startYear = _startDate.toString().substring(0, 4);
    String endYear = _endDate.toString().substring(0, 4);
    String startMonth = checkMonth(_startDate.toString().substring(5, 7));
    String endMonth = checkMonth(_endDate.toString().substring(5, 7));
    String startDay = _startDate.toString().substring(8, 10);
    String endDay = _endDate.toString().substring(8, 10);
    dateBanner = startMonth +
        " " +
        startDay +
        ", " +
        startYear +
        " - " +
        endMonth +
        " " +
        endDay +
        ", " +
        endYear;
    setState(() {
      connection = true;
      timeBar = true;
    });
    if (timeBar == true &&
        topView == true &&
        vanalytic == true &&
        chartData == true) {
      endTime = DateTime.now().millisecondsSinceEpoch;
      int result = endTime - startTime;
      print("VAnalytics Loading Time: " + result.toString());
    }
  }

  void _done() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      if (_startDate.toString() == _startdate &&
          _endDate.toString() == _enddate) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          startDate = _startDate.toString().substring(0, 10);
          endDate = _endDate.toString().substring(0, 10);
        });
        Navigator.of(context).pop();
        // _onLoading();
        getTopViewData();
        getVanalyticsData();
        getChartData();
        String startYear = _startDate.toString().substring(0, 4);
        String endYear = _endDate.toString().substring(0, 4);
        String startMonth = checkMonth(_startDate.toString().substring(5, 7));
        String endMonth = checkMonth(_endDate.toString().substring(5, 7));
        String startDay = _startDate.toString().substring(8, 10);
        String endDay = _endDate.toString().substring(8, 10);
        setState(() {
          dateBanner = startMonth +
              " " +
              startDay +
              ", " +
              startYear +
              " - " +
              endMonth +
              " " +
              endDay +
              ", " +
              endYear;
        });
      }
    } else {
      Navigator.pop(context);
      Toast.show("Please check your Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<Null> _handleRefresh() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        refresh = true;
        load = 0;
        timeBar = false;
        topView = false;
        vanalytic = false;
        chartData = false;
      });
      // _onLoading();
      _startDate = DateTime(DateTime.now().year, DateTime.now().month - 1,
          DateTime.now().day + 1);
      _startdate = _startDate.toString();
      _endDate = DateTime.now();
      _enddate = _endDate.toString();
      startDate = _startDate.toString().substring(0, 10);
      endDate = _endDate.toString().substring(0, 10);
      setupDateTimeBar();
      getTopViewData();
      getVanalyticsData();
      getChartData();
    } else {
      Toast.show("No Internet connection, data can't load", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  versionCheck(context) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    currentVersion = info.version.trim();
    if (newVersion != currentVersion) {
      _showVersionDialog(context);
    }
  }

  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Update Now"),
                    onPressed: () => _launchURL(
                        'https://play.google.com/store/apps/details?id=com.my.jtapps.vvin'),
                  ),
                  FlatButton(
                    child: Text("Later"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            : new AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Update Now"),
                    onPressed: () => _launchURL(
                        'https://play.google.com/store/apps/details?id=com.my.jtapps.vvin'),
                  ),
                  FlatButton(
                    child: Text("Later"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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

class LeadsData {
  LeadsData(this.x, this.y);
  final String x;
  final double y;
}

class AppData {
  AppData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color color;
}

class ChannelData {
  ChannelData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color color;
}
