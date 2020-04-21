import 'dart:convert';
import 'dart:io';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:vvin/data.dart';
import 'package:vvin/loader.dart';
import 'package:vvin/editVProfile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:vvin/notifications.dart';
import 'package:vvin/vanalytics.dart';
import 'package:vvin/vdata.dart';

class VProfile extends StatefulWidget {
  final VDataDetails vdata;
  const VProfile({Key key, this.vdata}) : super(key: key);

  @override
  _VProfileState createState() => _VProfileState();
}

class _VProfileState extends State<VProfile>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // final SpeechToText speech = SpeechToText();
  double _scaleFactor = 1.0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController _addRemark = TextEditingController();
  TabController controller;
  List handler;
  List vTag;
  List<VProfileData> vProfileDetails = [];
  List<View> vProfileViews = [];
  List<Remarks> vProfileRemarks = [];
  String name,
      phoneNo,
      status,
      companyID,
      userID,
      level,
      userType,
      resultText,
      fromVAnalytics,
      speechText;
  String urlVProfile = "https://vvinoa.vvin.com/api/vprofile.php";
  String urlHandler = "https://vvinoa.vvin.com/api/handler.php";
  String urlVTag = "https://vvinoa.vvin.com/api/vtag.php";
  String urlViews = "https://vvinoa.vvin.com/api/views.php";
  String urlRemarks = "https://vvinoa.vvin.com/api/remarks.php";
  String urlChangeStatus = "https://vvinoa.vvin.com/api/vdataChangeStatus.php";
  String urlSaveRemark = "https://vvinoa.vvin.com/api/saveRemark.php";
  bool vProfileData,
      handlerData,
      viewsData,
      remarksData,
      vTagData,
      hasSpeech,
      start;
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font16 = ScreenUtil().setSp(36.8, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller = TabController(vsync: this, length: 3, initialIndex: 0);
    name = widget.vdata.name;
    phoneNo = widget.vdata.phoneNo;
    status = widget.vdata.status;
    companyID = widget.vdata.companyID;
    userID = widget.vdata.userID;
    level = widget.vdata.level;
    userType = widget.vdata.userType;
    fromVAnalytics = widget.vdata.fromVAnalytics;
    vProfileData = false;
    handlerData = false;
    viewsData = false;
    remarksData = false;
    vTagData = false;
    hasSpeech = false;
    start = false;
    speechText = "";
    resultText = "";
    _addRemark.text = "";
    WidgetsBinding.instance.addObserver(this);
    // PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
    // askPermission();
    // initSpeechState();
    checkConnection();
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Future<void> initSpeechState() async {
  //   bool hasSpeechs = await speech.initialize();
  //   if (!mounted) return;
  //   setState(() {
  //     hasSpeech = hasSpeechs;
  //   });
  // }

  // void startListening() {
  //   speech.listen(onResult: resultListener);
  // }

  // void resultListener(SpeechRecognitionResult result) {
  //   if (result.finalResult == true) {
  //     if (_addRemark.text == "") {
  //       setState(() {
  //         start = false;
  //         _addRemark.text = result.recognizedWords;
  //       });
  //     } else {
  //       setState(() {
  //         _addRemark.text = _addRemark.text + " " + result.recognizedWords;
  //       });
  //     }
  //   }
  // }

  // void askPermission() {
  //   PermissionHandler().requestPermissions([PermissionGroup.microphone]).then(
  //       _onStatusRequested);
  // }

  // void _onStatusRequested(Map<PermissionGroup, PermissionStatus> statuses) {
  //   final status = statuses[PermissionGroup.microphone];
  //   if (status != PermissionStatus.granted) {
  //     PermissionHandler().openAppSettings();
  //   } else {
  //     // _updateStatus(status);
  //   }
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   print(state);
  //   if (state == AppLifecycleState.resumed) {
  //     PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
  //     // .then(_updateStatus);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
          backgroundColor: Color.fromRGBO(235, 235, 255, 1),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(ScreenUtil().setHeight(85)),
            child: AppBar(
              brightness: Brightness.light,
              leading: IconButton(
                onPressed: _onBackPressAppBar,
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: ScreenUtil().setWidth(30),
                  color: Colors.grey,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              centerTitle: true,
              title: Text(
                "VProfile",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: font18,
                    fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[popupMenuButton()],
            ),
          ),
          body: Column(
            children: <Widget>[
              Container(
                margin:
                    EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(15), 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: font18,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil().setHeight(15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  BouncingWidget(
                    scaleFactor: _scaleFactor,
                    onPressed: () async {
                      var connectivityResult =
                          await (Connectivity().checkConnectivity());
                      if (connectivityResult == ConnectivityResult.wifi ||
                          connectivityResult == ConnectivityResult.mobile) {
                        FlutterOpenWhatsapp.sendSingleMessage(phoneNo, "");
                      } else {
                        Toast.show(
                            "This feature need Internet connection", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      }
                    },
                    child: Container(
                      width: ScreenUtil().setWidth(260),
                      height: ScreenUtil().setHeight(60),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: FlatButton.icon(
                        icon: Image.asset(
                          "assets/images/whatsapp.png",
                          height: ScreenUtil().setHeight(35),
                          width: ScreenUtil().setWidth(35),
                        ),
                        color: Color.fromRGBO(37, 211, 102, 1),
                        label: Text(
                          "WhatsApp",
                          style: TextStyle(
                            fontSize: font12,
                          ),
                        ),
                        textColor: Colors.white,
                        onPressed: () async {
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.wifi ||
                              connectivityResult == ConnectivityResult.mobile) {
                            FlutterOpenWhatsapp.sendSingleMessage(phoneNo, "");
                          } else {
                            Toast.show("This feature need Internet connection",
                                context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.BOTTOM);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ScreenUtil().setHeight(20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(320),
                    height: ScreenUtil().setHeight(60),
                    padding: EdgeInsets.all(
                      ScreenUtil().setHeight(10),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.0),
                      border: Border.all(
                          color: Colors.grey.shade400,
                          style: BorderStyle.solid),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        isDense: true,
                        items: data.map((item) {
                          return DropdownMenuItem(
                            child: Text(
                              item.toString(),
                              style: TextStyle(
                                fontSize: font14,
                              ),
                            ),
                            value: item.toString(),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          setStatus(newVal);
                        },
                        value: status,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ScreenUtil().setHeight(20),
              ),
              Expanded(
                child: Scaffold(
                  backgroundColor: Color.fromRGBO(235, 235, 255, 1),
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(
                      ScreenUtil().setHeight(70),
                    ),
                    child: TabBar(
                      controller: controller,
                      indicator: BoxDecoration(color: Colors.white),
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.blue,
                      labelStyle: TextStyle(
                        fontSize: font18,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: font18,
                      ),
                      tabs: <Widget>[
                        Tab(
                          child: Text(
                            'Details',
                            style: TextStyle(
                              fontSize: font18,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Views',
                            style: TextStyle(
                              fontSize: font18,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Remarks',
                            style: TextStyle(
                              fontSize: font18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    controller: controller,
                    children: (vProfileData == false ||
                            handlerData == false ||
                            viewsData == false ||
                            remarksData == false ||
                            vTagData == false)
                        ? <Widget>[
                            Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    JumpingText('Loading...'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
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
                            Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    JumpingText('Loading...'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
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
                            Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    JumpingText('Loading...'),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
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
                          ]
                        : <Widget>[
                            Details(
                              vProfileDetails: vProfileDetails,
                              handler: handler,
                              vdata: widget.vdata,
                              vtag: vTag,
                            ),
                            Views(
                              vProfileViews: vProfileViews,
                            ),
                            Remark(
                              vProfileRemarks: vProfileRemarks,
                            ),
                          ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget popupMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: ScreenUtil().setWidth(40),
        color: Colors.grey,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: "add remark",
          child: Text(
            "Add Remark",
            style: TextStyle(
              fontSize: font14,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: "edit",
          child: Text(
            "Edit",
            style: TextStyle(
              fontSize: font14,
            ),
          ),
        ),
      ],
      onSelected: (selectedItem) {
        switch (selectedItem) {
          case "add remark":
            {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  elevation: 1.0,
                  title: Text(
                    "Add new remark",
                    style: TextStyle(
                      fontSize: font16,
                    ),
                  ),
                  content: Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(235, 235, 255, 1),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: TextField(
                      style: TextStyle(
                        fontSize: font14,
                      ),
                      maxLines: 5,
                      controller: _addRemark,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        // FloatingActionButton(
                        //   child: Icon(
                        //     Icons.mic,
                        //     // color: (start == false) ? Colors.pink : Colors.grey,
                        //   ),
                        //   mini: true,
                        //   onPressed: () {
                        //     initSpeechState();
                        //     startListening();
                        //     // setState(() {
                        //     //   start = true;
                        //     // });
                        //   },
                        //   backgroundColor:
                        //   // Colors.pink,
                        //   (start == false)
                        //   ? Colors.pink
                        //   : Colors.grey,
                        // ),
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width * 0.2,
                        // ),
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: font14,
                            ),
                          ),
                        ),
                        FlatButton(
                          onPressed: _onSubmit,
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: font14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            break;

          case "edit":
            {
              _editVProfile();
            }
            break;
        }
      },
    );
  }

  void _editVProfile() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      VProfileData vprofile = VProfileData(
        name: vProfileDetails[0].name,
        email: vProfileDetails[0].email,
        company: vProfileDetails[0].company,
        ic: vProfileDetails[0].ic,
        dob: vProfileDetails[0].dob,
        gender: (vProfileDetails[0].gender == "")
            ? ""
            : _gender(vProfileDetails[0].gender),
        position: vProfileDetails[0].position,
        industry: vProfileDetails[0].industry,
        occupation: vProfileDetails[0].occupation,
        country: vProfileDetails[0].country,
        state: vProfileDetails[0].state,
        area: vProfileDetails[0].area,
        created: vProfileDetails[0].created,
        lastActive: vProfileDetails[0].lastActive,
      );
      Navigator.of(context)
          .push(_createRoute(vprofile, handler, widget.vdata, vTag));
    } else {
      Toast.show("Please check your Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  String _gender(String gender) {
    switch (gender.toLowerCase()) {
      case "m":
        return "Male";
        break;
      case "f":
        return "Female";
        break;
      case "o":
        return "Other";
        break;
    }
  }

  void _onSubmit() async {
    if (_addRemark.text == "") {
      Toast.show("Please key in something", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.mobile) {
        http.post(urlSaveRemark, body: {
          "companyID": companyID,
          "userID": userID,
          "level": level,
          "user_type": userType,
          "phone_number": phoneNo,
          "remark": _addRemark.text,
        }).then((res) async {
          if (res.body == "success") {
            VDataDetails vdata = new VDataDetails(
              companyID: widget.vdata.companyID,
              userID: widget.vdata.userID,
              level: widget.vdata.level,
              userType: widget.vdata.userType,
              name: widget.vdata.name,
              phoneNo: widget.vdata.phoneNo,
              status: widget.vdata.status,
            );
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VProfile(vdata: vdata)));
            _addRemark.text = "";
          } else {
            Navigator.pop(context);
            _addRemark.text = "";
            Toast.show("Please contact VVIN help desk", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
        }).catchError((err) {
          Navigator.pop(context);
          _addRemark.text = "";
          Toast.show("No Internet Connection, data can't save", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          print("On submit error: " + (err).toString());
        });
      } else {
        Toast.show("Please check your Internet connection", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }
  }

  void checkConnection() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String pathName = dir.path.toString() + "/attachment.png";
    if (File(pathName).existsSync() == true) {
      try {
        final dir = Directory(pathName);
        dir.deleteSync(recursive: true);
      } catch (err) {}
    }
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      // _onLoading();
      getVProfileData();
      getHandler();
      getViews();
      getRemarks();
      getVTag();
    } else {
      // Navigator.pop(context);
      Toast.show("No Internet connection! Can't show", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void getVTag() {
    http.post(urlVTag, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType,
      "phone_number": phoneNo,
    }).then((res) {
      // print("getVTag body: " + res.body);
      if (res.body == "nodata") {
        vTag = [];
      } else {
        var jsonData = json.decode(res.body);
        vTag = jsonData;
      }
      if (this.mounted) {
        setState(() {
          vTagData = true;
        });
      }
    }).catchError((err) {
      Toast.show(err, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get VTag error: " + (err).toString());
    });
  }

  void getVProfileData() {
    http.post(urlVProfile, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType,
      "phone_number": phoneNo,
    }).then((res) {
      // print("VProfile status:" + (res.statusCode).toString());
      // print("VProfile body: " + res.body);
      if (res.body == "nodata") {
        VProfileData vprofile = VProfileData(
          name: name,
          email: "",
          company: "",
          ic: "",
          dob: "",
          gender: "",
          position: "",
          industry: "",
          occupation: "",
          country: "",
          state: "",
          area: "",
          app: "",
          channel: "",
          created: "",
          lastActive: "",
          img: "",
        );
        vProfileDetails.add(vprofile);
      } else {
        var jsonData = json.decode(res.body);
        // print("VProfile body: " + jsonData.toString());
        for (var data in jsonData) {
          VProfileData vprofile = VProfileData(
            name: name,
            email: data['email'] ?? "",
            company: data['company'] ?? "",
            ic: data['ic'] ?? "",
            dob: data['dob'] ?? "",
            gender: data['gender'] ?? "",
            position: data['position'] ?? "",
            industry: data['industry'] ?? "",
            occupation: data['occupation'] ?? "",
            country: data['country'] ?? "",
            state: data['state'] ?? "",
            area: data['area'] ?? "",
            app: data['app'] ?? "",
            channel: data['channel'] ?? "",
            created: data['created'].toString().substring(0, 10) ?? "",
            lastActive: data['lastActive'] ?? "",
            img: data['img'] ?? "",
          );
          vProfileDetails.add(vprofile);
        }
      }
      if (this.mounted) {
        setState(() {
          vProfileData = true;
        });
      }
    }).catchError((err) {
      // Navigator.pop(context);
      Toast.show(err, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get VProfile data error: " + (err).toString());
    });
  }

  void getHandler() {
    http.post(urlHandler, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType,
      "phone_number": phoneNo,
    }).then((res) {
      // print("getHandler body: " + res.body);
      if (res.body == "nodata") {
        handler = [];
      } else {
        var jsonData = json.decode(res.body);
        handler = jsonData;
      }
      if (this.mounted) {
        setState(() {
          handlerData = true;
        });
      }
    }).catchError((err) {
      Toast.show(err, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get handler error: " + (err).toString());
    });
  }

  void getViews() {
    http.post(urlViews, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType,
      "phone_number": phoneNo,
    }).then((res) {
      // print("VProfileViews status:" + (res.statusCode).toString());
      // print("VProfileViews body: " + res.body);
      if (res.body == "nodata") {
        View views = View(
          date: "",
          link: "",
        );
        vProfileViews.add(views);
      } else {
        var jsonData = json.decode(res.body);
        for (var data in jsonData) {
          View views = View(
            date: data['date'],
            link: data['link'],
          );
          vProfileViews.add(views);
        }
      }
      if (this.mounted) {
        setState(() {
          viewsData = true;
        });
      }
    }).catchError((err) {
      Toast.show(err, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get view error: " + (err).toString());
    });
  }

  void getRemarks() {
    http.post(urlRemarks, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType,
      "phone_number": phoneNo,
    }).then((res) {
      // print("VProfileRemarks status:" + (res.statusCode).toString());
      // print("VProfileRemarks body: " + res.body);
      if (res.body == "nodata") {
        Remarks remark = Remarks(
          date: "",
          remark: "",
          system: "",
        );
        vProfileRemarks.add(remark);
      } else {
        var jsonData = json.decode(res.body);
        for (var data in jsonData) {
          Remarks remark = Remarks(
            date: data['date'],
            remark: data['remark'],
            system: data['system'],
          );
          vProfileRemarks.add(remark);
        }
      }
      if (this.mounted) {
        setState(() {
          remarksData = true;
        });
      }
    }).catchError((err) {
      Toast.show(err, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Get remark error: " + (err).toString());
    });
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

  Future<bool> _onBackPressAppBar() async {
    if (fromVAnalytics == "yes") {
      // CurrentIndex index = new CurrentIndex(index: 0);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VAnalytics(),
        ),
      );
    } else {
      // CurrentIndex index = new CurrentIndex(index: 1);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VData(),
        ),
      );
    }

    return Future.value(false);
  }

  void setStatus(newVal) {
    http.post(urlChangeStatus, body: {
      "phone_number": phoneNo,
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType,
      "status": newVal,
    }).then((res) {
      if (res.body == "success") {
        if (this.mounted) {
          setState(() {
            status = newVal;
          });
        }
        Toast.show("Status changed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        if (this.mounted) {
          setState(() {
            status = status;
          });
        }
        Toast.show(
            "Status can't change, please contact VVIN help desk", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      if (this.mounted) {
        setState(() {
          status = status;
        });
      }
      Toast.show(
          "Status can't change, please check your Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Set status error: " + (err).toString());
    });
  }
}

class Details extends StatefulWidget {
  final List<VProfileData> vProfileDetails;
  final List handler;
  final VDataDetails vdata;
  final List vtag;
  const Details({
    Key key,
    this.vProfileDetails,
    this.handler,
    this.vdata,
    this.vtag,
  }) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  double font16 = ScreenUtil().setSp(36.8, allowFontScalingSelf: false);
  int emailLength;
  File file, pickedImage;
  List<String> phoneList = [];
  List<String> otherList = [];
  bool ready = false;

  @override
  void initState() {
    emailLength = (widget.vProfileDetails[0].email.length / 18).ceil();
    setup();
    super.initState();
  }

  void setup() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String pathName = dir.path.toString() + "/attachment.png";
    if (this.mounted) {
      setState(() {
        file = File(pathName);
        ready = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return Scaffold(
      body: (ready == false)
          ? Container()
          : Container(
              padding: EdgeInsets.fromLTRB(
                  0, ScreenUtil().setHeight(20), 0, ScreenUtil().setHeight(20)),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(
                        children: <Widget>[
                          Container(
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
                                    Flexible(
                                      flex: 1,
                                      child: (widget.handler.length == 0)
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  "Handler",
                                                  style: TextStyle(
                                                      fontSize: font16,
                                                      color: Color.fromRGBO(
                                                          128, 128, 128, 1)),
                                                )
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                for (var i = 0;
                                                    i < widget.handler.length;
                                                    i++)
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: <Widget>[
                                                      (i == 0)
                                                          ? Text(
                                                              "Handler",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      font16,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          128,
                                                                          128,
                                                                          128,
                                                                          1)),
                                                            )
                                                          : Text(""),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    (widget.handler.length == 0)
                                        ? Flexible(
                                            flex: 1,
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Text(
                                                      "-",
                                                      style: TextStyle(
                                                        fontSize: font16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Flexible(
                                            flex: 1,
                                            child: Column(
                                              children: <Widget>[
                                                for (var i in widget.handler)
                                                  Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Flexible(
                                                          child: Text(
                                                            i.toString(),
                                                            style: TextStyle(
                                                              fontSize: font16,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: (emailLength == 0)
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  "Email",
                                                  style: TextStyle(
                                                      fontSize: font16,
                                                      color: Color.fromRGBO(
                                                          128, 128, 128, 1)),
                                                )
                                              ],
                                            )
                                          : Column(
                                              children: <Widget>[
                                                for (var i = 0;
                                                    i < emailLength;
                                                    i++)
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: <Widget>[
                                                      (i == 0)
                                                          ? Text(
                                                              "Email",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      font16,
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          128,
                                                                          128,
                                                                          128,
                                                                          1)),
                                                            )
                                                          : Text(""),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                  (widget.vProfileDetails[0]
                                                              .email ==
                                                          "")
                                                      ? "-"
                                                      : widget
                                                          .vProfileDetails[0]
                                                          .email,
                                                  style: TextStyle(
                                                    fontSize: font16,
                                                  ),
                                                  textAlign: TextAlign.left),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Company",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .company ==
                                                        "")
                                                    ? "-"
                                                    : widget.vProfileDetails[0]
                                                        .company,
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                              "IC/Passport",
                                              style: TextStyle(
                                                  fontSize: font16,
                                                  color: Color.fromRGBO(
                                                      128, 128, 128, 1)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0].ic ==
                                                        "")
                                                    ? "-"
                                                    : widget
                                                        .vProfileDetails[0].ic,
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                              "Date of Birth",
                                              style: TextStyle(
                                                  fontSize: font16,
                                                  color: Color.fromRGBO(
                                                      128, 128, 128, 1)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .dob ==
                                                        "")
                                                    ? "-"
                                                    : _dateFormat(widget
                                                        .vProfileDetails[0]
                                                        .dob),
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Gender",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              (widget.vProfileDetails[0]
                                                          .gender ==
                                                      "")
                                                  ? "-"
                                                  : _gender(widget
                                                      .vProfileDetails[0]
                                                      .gender),
                                              style: TextStyle(
                                                fontSize: font16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Position",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .position ==
                                                        "")
                                                    ? "-"
                                                    : widget.vProfileDetails[0]
                                                        .position,
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Industry",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .industry ==
                                                        "")
                                                    ? "-"
                                                    : widget.vProfileDetails[0]
                                                        .industry,
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Occupation",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .occupation ==
                                                        "")
                                                    ? "-"
                                                    : widget.vProfileDetails[0]
                                                        .occupation,
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Country",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .country ==
                                                        "")
                                                    ? "-"
                                                    : widget.vProfileDetails[0]
                                                        .country,
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                (widget.vProfileDetails[0].country ==
                                        "Malaysia")
                                    ? SizedBox(
                                        height: ScreenUtil().setHeight(10),
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ),
                                (widget.vProfileDetails[0].country ==
                                        "Malaysia")
                                    ? Row(
                                        children: <Widget>[
                                          Flexible(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  "State",
                                                  style: TextStyle(
                                                      fontSize: font16,
                                                      color: Color.fromRGBO(
                                                          128, 128, 128, 1)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: ScreenUtil().setWidth(20),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Text(
                                                      (widget.vProfileDetails[0]
                                                                  .state ==
                                                              "")
                                                          ? "-"
                                                          : widget
                                                              .vProfileDetails[
                                                                  0]
                                                              .state,
                                                      style: TextStyle(
                                                        fontSize: font16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Row(),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Area",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .area ==
                                                        "")
                                                    ? "-"
                                                    : widget.vProfileDetails[0]
                                                        .area,
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "App",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .app ==
                                                        "")
                                                    ? "-"
                                                    : widget
                                                        .vProfileDetails[0].app,
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Channel",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .channel ==
                                                        "")
                                                    ? "-"
                                                    : widget.vProfileDetails[0]
                                                        .channel,
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Created",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                _dateFormat(widget
                                                    .vProfileDetails[0]
                                                    .created),
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(10),
                                ),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "Last Active",
                                            style: TextStyle(
                                                fontSize: font16,
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Flexible(
                                              child: Text(
                                                (widget.vProfileDetails[0]
                                                            .lastActive !=
                                                        "")
                                                    ? _dateFormat(widget
                                                        .vProfileDetails[0]
                                                        .lastActive)
                                                    : "-",
                                                style: TextStyle(
                                                  fontSize: font16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtil().setHeight(30),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: ScreenUtil().setHeight(2),
                                    color: Colors.grey.shade300),
                              ),
                            ),
                            child: Container(
                              margin:
                                  EdgeInsets.all(ScreenUtil().setHeight(20)),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "TAGS",
                                        style: TextStyle(
                                          fontSize: font16,
                                          color:
                                              Color.fromRGBO(128, 128, 128, 1),
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(0.5),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                ScreenUtil().setHeight(10),
                                                0,
                                                0,
                                                0),
                                            child: Wrap(
                                              direction: Axis.horizontal,
                                              alignment: WrapAlignment.start,
                                              children: <Widget>[
                                                for (int i = 0;
                                                    i < widget.vtag.length ?? 0;
                                                    i++)
                                                  Container(
                                                    width: ScreenUtil()
                                                        .setWidth((widget
                                                                .vtag[i]
                                                                .length *
                                                            28)),
                                                    margin: EdgeInsets.all(
                                                        ScreenUtil()
                                                            .setHeight(5)),
                                                    decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          235, 235, 255, 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                    ),
                                                    padding: EdgeInsets.all(
                                                      ScreenUtil()
                                                          .setHeight(10),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          widget.vtag[i],
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          (widget.vProfileDetails[0].img == "")
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.all(
                                      ScreenUtil().setHeight(20)),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Attachment",
                                            style: TextStyle(
                                              fontSize: font16,
                                              color: Color.fromRGBO(
                                                  128, 128, 128, 1),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: ScreenUtil().setHeight(20),
                                      ),
                                      Stack(
                                        children: <Widget>[
                                          Container(
                                            height: ScreenUtil().setHeight(500),
                                            width: ScreenUtil().setHeight(500),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                            ),
                                            child: Image(
                                                image: NetworkToFileImage(
                                                    url: widget
                                                        .vProfileDetails[0].img,
                                                    file: file,
                                                    debug: true)),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              _showNameCard();
                                              readText();
                                            },
                                            child: Container(
                                              height:
                                                  ScreenUtil().setHeight(500),
                                              width:
                                                  ScreenUtil().setHeight(500),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          widget
                                                              .vProfileDetails[
                                                                  0]
                                                              .img),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // InkWell(
                                      //   onTap: () {
                                      //     _showNameCard();
                                      //     readText();
                                      //   },
                                      //   child: Container(
                                      //     height: ScreenUtil().setHeight(500),
                                      //     width: ScreenUtil().setHeight(500),
                                      //     decoration: BoxDecoration(
                                      //       shape: BoxShape.rectangle,
                                      //       color: Colors.white,
                                      //       borderRadius: BorderRadius.all(
                                      //           Radius.circular(10.0)),
                                      //       image: DecorationImage(
                                      //         image: NetworkImage(widget
                                      //             .vProfileDetails[0].img),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future readText() async {
    if (file.existsSync() == true) {
      otherList.add("-");
      FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(file);
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
    } else {
      print("File not exits");
      print(file);
    }
  }

  void _showNameCard() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(
                  0, ScreenUtil().setHeight(20), ScreenUtil().setHeight(20), 0),
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              // decoration: BoxDecoration(
              //   shape: BoxShape.rectangle,
              //   color: Colors.white,
              //   borderRadius: BorderRadius.all(Radius.circular(30.0)),
              //   image: DecorationImage(
              //     fit: BoxFit.fitWidth,
              //     image: NetworkImage(widget.vProfileDetails[0].img),
              //   ),
              // ),
              child: PhotoView(
                imageProvider: NetworkImage(widget.vProfileDetails[0].img),
              ),
            ),
            Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateFormat(String fullDate) {
    String result, date, month, year;
    date = fullDate.substring(8, 10);
    month = checkMonth(fullDate.substring(5, 7));
    year = fullDate.substring(0, 4);
    result = date + " " + month + " " + year;
    return result;
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

  String _gender(String gender) {
    switch (gender.toLowerCase()) {
      case "m":
        return "Male";
        break;
      case "f":
        return "Female";
        break;
      case "o":
        return "Other";
        break;
    }
  }
}

class Views extends StatefulWidget {
  final List<View> vProfileViews;
  const Views({Key key, this.vProfileViews}) : super(key: key);

  @override
  _ViewsState createState() => _ViewsState();
}

class _ViewsState extends State<Views> {
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  double font28 = ScreenUtil().setSp(64.4, allowFontScalingSelf: false);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(80),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: (widget.vProfileViews[0].date == "")
                            ? "0"
                            : widget.vProfileViews.length.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: font28,
                            color: Colors.black),
                      ),
                      TextSpan(
                        text: ' Total Views',
                        style: TextStyle(fontSize: font18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            (widget.vProfileViews[0].date == "")
                ? Container()
                : Flexible(
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: ListView.builder(
                        itemCount: widget.vProfileViews.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) =>
                            Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.fromLTRB(
                            ScreenUtil().setHeight(10),
                            ScreenUtil().setHeight(20),
                            ScreenUtil().setHeight(10),
                            ScreenUtil().setHeight(20),
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.vProfileViews[index].date.toString(),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: font12,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(5),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                      child: Text(
                                    widget.vProfileViews[index].link,
                                    style: TextStyle(
                                      fontSize: font14,
                                    ),
                                  ))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class Remark extends StatefulWidget {
  final List<Remarks> vProfileRemarks;
  const Remark({Key key, this.vProfileRemarks}) : super(key: key);

  @override
  _RemarkState createState() => _RemarkState();
}

class _RemarkState extends State<Remark> {
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: widget.vProfileRemarks.length,
                  itemBuilder: (BuildContext context, int index) => Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setHeight(10),
                      vertical: ScreenUtil().setHeight(15),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.vProfileRemarks[index].date
                                  .toUpperCase()
                                  .substring(0, 10),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: font12,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            (widget.vProfileRemarks[index].system == "no")
                                ? Container()
                                : Container(
                                    padding: EdgeInsets.all(0.5),
                                    width: ScreenUtil().setHeight(180),
                                    height: ScreenUtil().setHeight(40),
                                    child: FlatButton(
                                      child: Text(
                                        "System",
                                        style: TextStyle(
                                          fontSize: font12,
                                        ),
                                      ),
                                      textColor: Colors.white,
                                      color: Colors.blue,
                                      onPressed: () {},
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
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
                              child: Text(
                                widget.vProfileRemarks[index].remark,
                                style: TextStyle(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Route _createRoute(
    VProfileData vprofileData, List handler, VDataDetails vdata, List vtag) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => EditVProfile(
      vprofileData: vprofileData,
      handler: handler,
      vdata: vdata,
      vtag: vtag,
    ),
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
