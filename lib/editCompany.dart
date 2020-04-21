import 'dart:convert';
import 'dart:io';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:vvin/companyDB.dart';
import 'package:vvin/more.dart';
import 'package:vvin/notifications.dart';
import 'package:vvin/profile.dart';
import 'package:vvin/data.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final ScrollController controller = ScrollController();
final TextEditingController _nameController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _websiteController = TextEditingController();
final TextEditingController _addressController = TextEditingController();

class EditCompany extends StatefulWidget {
  final EditCompanyDetails company;
  const EditCompany({Key key, this.company}) : super(key: key);

  @override
  _EditCompanyState createState() => _EditCompanyState();
}

class _EditCompanyState extends State<EditCompany> {
  double _scaleFactor = 1.0;
  double font13 = ScreenUtil().setSp(29.9, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font15 = ScreenUtil().setSp(34.5, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  double font20 = ScreenUtil().setSp(46, allowFontScalingSelf: false);
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  File _image;
  int number;
  String userID,
      companyID,
      level,
      userType,
      image,
      name,
      phone,
      email,
      website,
      address,
      status;
  String urlEditCompany = "https://vvinoa.vvin.com/api/editCompanyProfile.php";
  String urlUploadImage = "https://vvinoa.vvin.com/api/uploadImage.php";

  @override
  void initState() {
    companyID = widget.company.companyID;
    userID = widget.company.userID;
    level = widget.company.level;
    userType = widget.company.userType;
    image = widget.company.image;
    _nameController.text = widget.company.name;
    _phoneController.text = widget.company.phone;
    _emailController.text = widget.company.email;
    _websiteController.text = widget.company.website;
    _addressController.text = widget.company.address;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white, // Color for Android
    ));
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
                        fontFamily: 'Roboto',
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        // backgroundColor: Color.fromRGBO(220, 220, 220, 1),
        // backgroundColor: Color.fromRGBO(227,231,233, 1),
        backgroundColor: Color.fromRGBO(235, 235, 255, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            ScreenUtil().setHeight(85),
          ),
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
              "Edit Profile",
              style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.black,
                  fontSize: font18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: <Widget>[
              Container(
                padding:
                    EdgeInsets.fromLTRB(0, ScreenUtil().setHeight(20), 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: _camera,
                      child: Stack(
                        children: <Widget>[
                          // Container(
                          //   width: ScreenUtil().setWidth(240),
                          //   height: ScreenUtil().setHeight(240),
                          //   decoration: BoxDecoration(
                          //     color: Color.fromRGBO(211, 211, 211, 1),
                          //     shape: BoxShape.rectangle,
                          //     borderRadius:
                          //         BorderRadius.all(Radius.circular(10.0)),
                          //   ),
                          // ),
                          Positioned(
                            top: ScreenUtil().setHeight(20),
                            left: ScreenUtil().setWidth(20),
                            child: Container(
                              padding: EdgeInsets.all(200.0),
                              width: ScreenUtil().setWidth(200),
                              height: ScreenUtil().setHeight(200),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: NetworkImage(image),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(240),
                            width: ScreenUtil().setWidth(240),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(105, 105, 105, 0.5),
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              margin: EdgeInsets.all(ScreenUtil().setWidth(95)),
                              height: ScreenUtil().setWidth(60),
                              width: ScreenUtil().setWidth(60),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: ScreenUtil().setWidth(50),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(
                  ScreenUtil().setHeight(20),
                ),
                color: Colors.white,
                margin: EdgeInsets.fromLTRB(
                    ScreenUtil().setHeight(60),
                    ScreenUtil().setHeight(20),
                    ScreenUtil().setHeight(60),
                    ScreenUtil().setHeight(20)),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Name",
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: font14),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(55),
                      color: Color.fromRGBO(235, 235, 255, 1),
                      child: TextField(
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          // height: ScreenUtil().setHeight(2),
                          height: 1,
                          fontSize: font15,
                        ),
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all(ScreenUtil().setHeight(10)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Phone",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: font14,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(55),
                      // color: Color.fromARGB(50, 220, 220, 220),
                      color: Color.fromRGBO(235, 235, 255, 1),
                      child: TextField(
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          height: 1,
                          fontSize: font15,
                        ),
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all(ScreenUtil().setHeight(10)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Email",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: font14,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(55),
                      // color: Color.fromARGB(50, 220, 220, 220),
                      color: Color.fromRGBO(235, 235, 255, 1),
                      child: TextField(
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          height: 1,
                          fontSize: font15,
                        ),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all(ScreenUtil().setHeight(10)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Website",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: font14,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(55),
                      color: Color.fromRGBO(235, 235, 255, 1),
                      child: TextField(
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          height: 1,
                          fontSize: font15,
                        ),
                        controller: _websiteController,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all(ScreenUtil().setHeight(10)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Address",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: font14,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(5),
                    ),
                    Container(
                      padding: EdgeInsets.all(
                        ScreenUtil().setHeight(0),
                      ),
                      height: ScreenUtil().setHeight(240),
                      // color: Color.fromARGB(50, 220, 220, 220),
                      color: Color.fromRGBO(235, 235, 255, 1),
                      child: TextField(
                        maxLines: 5,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          height: ScreenUtil().setHeight(2),
                          fontSize: font15,
                        ),
                        controller: _addressController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(20),
                    ),
                    BouncingWidget(
                      scaleFactor: _scaleFactor,
                      onPressed: _saveEditCompany,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: ScreenUtil().setHeight(70),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Color.fromRGBO(34, 175, 240, 1),
                        ),
                        child: Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontSize: font15,
                            ),
                          ),
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
    );
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => Profile(),
        ));
    return Future.value(false);
  }

  void _camera() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Text(
                "Action",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: font13,
                ),
              ),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: font20,
                  ),
                ),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    _saveProfilePicture();
                  },
                  child: Text(
                    "Browse Gallery",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: font20,
                    ),
                  ),
                ),
                CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _image =
                        await ImagePicker.pickImage(source: ImageSource.camera);
                    _saveProfilePicture();
                  },
                  child: Text(
                    "Take Photo",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: font20,
                    ),
                  ),
                ),
              ],
            );
          });
    } else {
      Toast.show("No Internet Connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _saveProfilePicture() async {
    String base64Image = base64Encode(_image.readAsBytesSync());
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      http.post(urlUploadImage, body: {
        "encoded_string": base64Image,
        "companyID": companyID,
        "userID": userID,
        "level": level,
        "user_type": userType,
      }).then((res) {
        if (res.body.toString() != "nodata") {
          if (this.mounted) {
            setState(() {
              imageCache.clear();
              image = res.body.toString();
            });
          }
          Toast.show("Image changed", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          _downloadImage(image, "company", "profile");
        } else {
          Toast.show("Image can't save, please contact VVIN help desk", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }).catchError((err) {
        print("Upload image error: " + err.toString());
      });
    } else {
      Toast.show("No Internet Connection, image can't change", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _saveEditCompany() async {
    name = _nameController.text;
    phone = _phoneController.text;
    email = _emailController.text.toLowerCase();
    website = _websiteController.text;
    address = _addressController.text;

    if (_isEmailValid(email)) {
      if (name != "" &&
          phone != "" &&
          email != "" &&
          website != "" &&
          address != "") {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.wifi ||
            connectivityResult == ConnectivityResult.mobile) {
          http.post(urlEditCompany, body: {
            "companyID": companyID,
            "userID": userID,
            "level": level,
            "user_type": userType,
            "name": name,
            "phone": phone,
            "email": email,
            "website": website,
            "address": address,
          }).then((res) async {
            // print("Update company profile: " + (res.statusCode).toString());
            // print("Return from internet:" + res.body);
            if (res.body == "success") {
              // CurrentIndex index = new CurrentIndex(index: 4);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => More(),
                ),
              );
              setData();
              Toast.show("Update successfully", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            } else {
              Toast.show(
                  "Update failed, please contact VVIN help desk", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            }
          }).catchError((err) {
            Toast.show(err.toString(), context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            print("Save Edit Company error: " + (err).toString());
          });
        } else {
          Toast.show("No Internet Connection, data can't save", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      } else {
        Toast.show("Please fill in all column", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    } else {
      Toast.show("Your email address format is incorrectly", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
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

  Future<String> get _localDevicePath async {
    final _devicePath = await getApplicationDocumentsDirectory();
    return _devicePath.path;
  }

  Future _downloadImage(String url, String path, String name) async {
    final _response = await http.get(url);
    if (_response.statusCode == 200) {
      final _file = await _localImage(path: path, name: name);
      final _saveFile = await _file.writeAsBytes(_response.bodyBytes);
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
