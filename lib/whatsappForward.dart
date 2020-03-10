import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:toast/toast.dart';
import 'package:vvin/data.dart';
import 'package:vvin/mainscreen.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class WhatsAppForward extends StatefulWidget {
  final WhatsappForward whatsappForward;
  WhatsAppForward({Key key, this.whatsappForward}) : super(key: key);

  @override
  _WhatsAppForwardState createState() => _WhatsAppForwardState();
}

class _WhatsAppForwardState extends State<WhatsAppForward> {
  final ScrollController controller = ScrollController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _companycontroller = TextEditingController();
  final TextEditingController _remarkcontroller = TextEditingController();
  final ScrollController whatsappController = ScrollController();
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  String urlWhatsApp = "https://vvinoa.vvin.com/api/whatsappForward.php";
  File pickedImage;
  bool _phoneEmpty, _nameEmpty, _phoneInvalid, isImageLoaded, isSend;
  List<String> phoneList = [];
  List<String> otherList = [];
  List seletedVTag = [];
  String pathName, base64Image, tempText, number;

  @override
  void initState() {
    isSend = false;
    isImageLoaded = false;
    tempText = "";
    base64Image = "";
    number = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            controller: controller,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.97,
              child: Column(
                children: <Widget>[
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
                                      _onBackPressAppBar();
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
                                        color: Colors.black, fontSize: font14),
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
                                              width: ScreenUtil().setWidth(140),
                                              height:
                                                  ScreenUtil().setHeight(140),
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    100, 220, 220, 220),
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                              ),
                                            ),
                                            Positioned(
                                              top: ScreenUtil().setHeight(20),
                                              left: ScreenUtil().setWidth(20),
                                              child: Container(
                                                  width: ScreenUtil()
                                                      .setWidth(100),
                                                  height: ScreenUtil()
                                                      .setHeight(100),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    color: Colors.transparent,
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
                                                height:
                                                    ScreenUtil().setHeight(20),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  InkWell(
                                                      onTap: () {
                                                        _scanner();
                                                      },
                                                      child: Text(
                                                        "Take Photo",
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
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: ScreenUtil().setHeight(10),
                                              bottom:
                                                  ScreenUtil().setHeight(20),
                                              top: ScreenUtil().setHeight(-15),
                                              right:
                                                  ScreenUtil().setHeight(20)),
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
                                                    duration: Toast.LENGTH_LONG,
                                                    gravity: Toast.BOTTOM);
                                              }
                                            },
                                            child: Container(
                                              height:
                                                  ScreenUtil().setHeight(60),
                                              width: ScreenUtil().setHeight(60),
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
                              (_phoneEmpty == true)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Phone number can't be empty",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: font12),
                                        )
                                      ],
                                    )
                                  : Row(),
                              (_phoneInvalid == true)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Invalid phone number",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: font12),
                                        )
                                      ],
                                    )
                                  : Row(),
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
                                              left: ScreenUtil().setHeight(10),
                                              bottom:
                                                  ScreenUtil().setHeight(20),
                                              top: ScreenUtil().setHeight(-15),
                                              right:
                                                  ScreenUtil().setHeight(20)),
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
                                              height:
                                                  ScreenUtil().setHeight(60),
                                              width: ScreenUtil().setHeight(60),
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
                              (_nameEmpty == true)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Name can't be empty",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: font12),
                                        )
                                      ],
                                    )
                                  : Row(),
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
                                              left: ScreenUtil().setHeight(10),
                                              bottom:
                                                  ScreenUtil().setHeight(20),
                                              top: ScreenUtil().setHeight(-15),
                                              right:
                                                  ScreenUtil().setHeight(20)),
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
                                              height:
                                                  ScreenUtil().setHeight(60),
                                              width: ScreenUtil().setHeight(60),
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
                                        child: (seletedVTag.length == 0)
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
                                                alignment: WrapAlignment.start,
                                                children: <Widget>[
                                                  for (int i = 0;
                                                      i < seletedVTag.length;
                                                      i++)
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          seletedVTag
                                                              .removeAt(i);
                                                        });
                                                      },
                                                      child: Container(
                                                        width: ScreenUtil()
                                                            .setWidth((seletedVTag[
                                                                            i]
                                                                        .length *
                                                                    16.8) +
                                                                62.8),
                                                        margin: EdgeInsets.all(
                                                            ScreenUtil()
                                                                .setHeight(5)),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color.fromRGBO(
                                                              235, 235, 255, 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
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
                                                              seletedVTag[i],
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
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
                                                                  .setHeight(
                                                                      30),
                                                              color:
                                                                  Colors.grey,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _selectVTag();
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
                                          hintText: "eg. from KLCC exhibition",
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: ScreenUtil().setHeight(10),
                                              bottom:
                                                  ScreenUtil().setHeight(20),
                                              top: ScreenUtil().setHeight(-15),
                                              right:
                                                  ScreenUtil().setHeight(20)),
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
                                              height:
                                                  ScreenUtil().setHeight(60),
                                              width: ScreenUtil().setHeight(60),
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
                                      borderRadius: BorderRadius.circular(5),
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
                                      color: (isSend == false)
                                          ? Colors.blue
                                          : Colors.grey,
                                      onPressed: () {
                                        bool send = true;
                                        setState(() {
                                          if (_phonecontroller.text.isEmpty) {
                                            _phoneEmpty = true;
                                            send = false;
                                          } else {
                                            _phoneEmpty = false;
                                          }
                                        });
                                        setState(() {
                                          if (_namecontroller.text.isEmpty) {
                                            _nameEmpty = true;
                                            send = false;
                                          } else {
                                            _nameEmpty = false;
                                          }
                                        });
                                        if (_phoneEmpty == false) {
                                          bool _isNumeric(String phoneNo) {
                                            if (phoneNo.length < 10) {
                                              return false;
                                            }
                                            return num.tryParse(phoneNo) !=
                                                null;
                                          }

                                          bool valid =
                                              _isNumeric(_phonecontroller.text);
                                          if (valid == false) {
                                            setState(() {
                                              _phoneInvalid = true;
                                            });
                                          } else {
                                            setState(() {
                                              _phoneInvalid = false;
                                            });
                                          }

                                          if (valid == true && send == true) {
                                            String vtag;
                                            if (seletedVTag.length == 0) {
                                              vtag = "";
                                            } else {
                                              for (int i = 0;
                                                  i < seletedVTag.length;
                                                  i++) {
                                                if (i == 0) {
                                                  vtag = seletedVTag[i];
                                                } else {
                                                  vtag = vtag +
                                                      "," +
                                                      seletedVTag[i];
                                                }
                                              }
                                            }
                                            _send(vtag);
                                          }
                                        }
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onLoading1() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.1,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                JumpingText('Sending...'),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
    );
  }

  void _send(String vtag) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      // _onLoading();
      if (isSend == false) {
        setState(() {
          isSend = true;
        });
        _onLoading1();
        if (_phonecontroller.text.substring(0, 1) != "6") {
          _phonecontroller.text = "6" + _phonecontroller.text;
        }
        http
            .post(urlWhatsApp, body: {
              "companyID": widget.whatsappForward.companyID,
              "userID": widget.whatsappForward.userID,
              "user_type": widget.whatsappForward.userType,
              "level": widget.whatsappForward.level,
              "phoneNo": _phonecontroller.text,
              "name": _namecontroller.text,
              "companyName": _companycontroller.text,
              "remark": _remarkcontroller.text,
              "vtag": vtag,
              "url": widget.whatsappForward.url,
              "nameCard": "",
              "number": widget.whatsappForward.userID + "_" + number,
            })
            .then((res) {})
            .catchError((err) {
              print("WhatsApp Forward error: " + (err).toString());
            });
        Navigator.pop(context);
        FlutterOpenWhatsapp.sendSingleMessage(
            _phonecontroller.text,
            "Hello " +
                _namecontroller.text +
                "! Reply 'hi' to enable the URL link. " +
                widget.whatsappForward.url);
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
      Toast.show("No Internet Connection", context,
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
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.1,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                JumpingText('Loading...'),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
    );
  }

  void _selectVTag() {
    String selectedTag = "";
    if (widget.whatsappForward.vtagList.length != 0) {
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
                              if (selectedTag != "") {
                                if (seletedVTag.length != 0) {
                                  bool cancelAdd = false;
                                  for (int i = 0; i < seletedVTag.length; i++) {
                                    if (selectedTag == seletedVTag[i]) {
                                      cancelAdd = true;
                                    }
                                  }
                                  if (cancelAdd == false) {
                                    seletedVTag.add(selectedTag);
                                  }
                                } else {
                                  seletedVTag.add(selectedTag);
                                }
                              }
                              Navigator.pop(context);
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
                            if (index != 0) {
                              setState(() {
                                selectedTag =
                                    widget.whatsappForward.vtagList[index];
                              });
                            }
                          },
                          children: <Widget>[
                            for (var each in widget.whatsappForward.vtagList)
                              Text(
                                each,
                                style: TextStyle(
                                  fontSize: font14,
                                ),
                              )
                          ],
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
      Toast.show("VTag list is empty", context,
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
                      // base64Image = base64Encode(pickedImage.readAsBytesSync());
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
                      isImageLoaded = true;
                      // base64Image = base64Encode(pickedImage.readAsBytesSync());
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
    pickedImage = await FlutterNativeImage.compressImage(pickedImage.path,
        quality: 1, percentage: 30);
    base64Image = base64Encode(pickedImage.readAsBytesSync());
    number = Random().nextInt(200).toString();
    http
        .post(urlWhatsApp, body: {
          "companyID": widget.whatsappForward.companyID,
          "userID": widget.whatsappForward.userID,
          "user_type": widget.whatsappForward.userType,
          "level": widget.whatsappForward.level,
          "number": widget.whatsappForward.userID + "_" + number,
          "url": widget.whatsappForward.url,
          "nameCard": base64Image,
        })
        .then((res) {})
        .catchError((err) {
          print("WhatsApp Forward Save Image error: " + (err).toString());
        });
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
  }

  Future<bool> _onBackPressAppBar() async {
    CurrentIndex index = new CurrentIndex(index: 2);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(
          index: index,
        ),
      ),
    );
    return Future.value(false);
  }
}
