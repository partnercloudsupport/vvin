import 'dart:convert';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

final ScrollController controller = ScrollController();
final TextEditingController _emcontroller = TextEditingController();
final String urlForget = "https://vvinoa.vvin.com/api/forget_password.php";

class Forgot extends StatefulWidget {
  @override
  _Forgot createState() => _Forgot();
}

class _Forgot extends State<Forgot> {
  double _scaleFactor = 1.0;
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font15 = ScreenUtil().setSp(34.5, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  double font20 = ScreenUtil().setSp(46, allowFontScalingSelf: false);

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black,
    ));
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _emcontroller.text = "";
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    double tWidth = MediaQuery.of(context).size.width * 0.8;
    double stWidth = MediaQuery.of(context).size.width * 0.7;
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              ScreenUtil().setHeight(85),
            ),
            child: AppBar(
                brightness: Brightness.light,
                backgroundColor: Colors.white,
                elevation: 1,
                leading: IconButton(
                  color: Colors.grey,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: ScreenUtil().setWidth(30),
                  ),
                  onPressed: _onBackPressAppBar,
                ),
                centerTitle: true,
                title: Text(
                  "Forget Password",
                  style: TextStyle(color: Colors.black, fontSize: font18),
                )),
          ),
          body: SingleChildScrollView(
            controller: controller,
            child: Container(
              padding: EdgeInsets.all(
                ScreenUtil().setHeight(60),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/logo.png',
                        width: ScreenUtil().setWidth(360),
                        height: ScreenUtil().setHeight(160),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  Container(
                    width: tWidth,
                    alignment: Alignment(0.0, 0.0),
                    child: Text("Recover Your Password",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: font20),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  Container(
                    width: stWidth,
                    alignment: Alignment(0.0, 0.0),
                    child: Text(
                        "Enter email eddress that associated with your VVIN account",
                        style: TextStyle(fontSize: font14, color: Colors.grey),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(50),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "Email address",
                        style: TextStyle(
                            fontSize: font14, fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  Container(
                    height: ScreenUtil().setHeight(80),
                    color: Colors.white,
                    child: TextField(
                      style: TextStyle(
                        height: 1,
                        fontSize: font15,
                      ),
                      controller: _emcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.all(ScreenUtil().setHeight(10)),
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(50),
                  ),
                  BouncingWidget(
                    scaleFactor: _scaleFactor,
                    onPressed: _onForgot,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: ScreenUtil().setHeight(80),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Color.fromRGBO(34, 175, 240, 1),
                      ),
                      child: Center(
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: font15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // MaterialButton(
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(20.0)),
                  //   minWidth: double.infinity,
                  //   height: ScreenUtil().setHeight(80),
                  //   child: Text(
                  //     'Send',
                  //     style: TextStyle(
                  //       fontSize:
                  //           font15,
                  //     ),
                  //   ),
                  //   color: Color.fromRGBO(34, 175, 240, 1),
                  //   textColor: Colors.white,
                  //   elevation: 9,
                  //   onPressed: _onForgot,
                  // ),
                ],
              ),
            ),
          )),
    );
  }

  void _onForgot() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      if (_emcontroller.text == "") {
        Toast.show("Please enter your email", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        http.post(urlForget, body: {
          "email": _emcontroller.text.toLowerCase(),
        }).then((res) async {
          if (res.statusCode == 200) {
            var jsonData = json.decode(res.body);
            if (jsonData['status'].toString() == "1") {
              Toast.show(jsonData['message'].toString(), context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ));
            } else {
              Toast.show(jsonData['message'].toString(), context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
            }
          } else {
            Toast.show("Please contact VVIN IT desk", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
        }).catchError((err) {
          Toast.show(err.toString(), context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          print("On Forgot error: " + (err).toString());
        });
      }
    } else {
      Toast.show("Please check your Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ));
    return Future.value(false);
  }
}
