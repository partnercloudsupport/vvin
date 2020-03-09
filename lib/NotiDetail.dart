import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vvin/data.dart';
import 'package:vvin/mainscreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotiDetail extends StatefulWidget {
  final NotificationDetail notification;
  const NotiDetail({Key key, this.notification}) : super(key: key);

  @override
  _NotiDetailState createState() => _NotiDetailState();
}

class _NotiDetailState extends State<NotiDetail> {
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
          // backgroundColor: Color.fromRGBO(235, 235, 255, 1),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(ScreenUtil().setHeight(85),),
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
                "Notification",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: font18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        widget.notification.title,
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            fontSize: font14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        (widget.notification.subtitle2 != "")
                            ? widget.notification.subtitle1 + ","
                            : widget.notification.subtitle1,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: font12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              (widget.notification.subtitle2 != "")
                  ? Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              widget.notification.subtitle2.substring(1),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: font12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              (widget.notification.subtitle2 != "")
                  ? Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              "If you did not perform the action, kindly contact our customer support immediately at support@jtapps.com.my to secure your account.",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: font12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        "Thank you.",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: font12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        "VVIN Team",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: font12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    CurrentIndex index = new CurrentIndex(index: 3);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(
          index: index,
        ),
      ),
    );
    return Future.value(false);
  }

  // Future<bool> _onBackPressAppBar() async {
  //   Navigator.pop(context);
  //   return Future.value(false);
  // }
}
