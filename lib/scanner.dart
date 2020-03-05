import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vvin/data.dart';
import 'package:vvin/mainscreen.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:path_provider/path_provider.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:vvin/myworks.dart';

class Scanner extends StatefulWidget {
  Scanner({Key key}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final ScrollController controller = ScrollController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _companycontroller = TextEditingController();
  final TextEditingController _remarkcontroller = TextEditingController();
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font20 = ScreenUtil().setSp(46, allowFontScalingSelf: false);
  String flutterLogoUrl =
      "https://comps.canstockphoto.com/sample-business-name-card-template-eps-vectors_csp60803431.jpg";
  String flutterLogoFileName = "flutter.png";
  File pickedImage;
  bool isImageLoaded = false;
  List<String> phoneList = [];
  List<String> otherList = [];
  String tempText = "";
  String pathName;
  bool start = false;

  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        backgroundColor: Colors.white,
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
            elevation: 0,
            centerTitle: true,
            title: Text(
              "WhatsApp Forward",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: font20,
                  fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              InkWell(
                onTap: _scanner,
                child: Container(
                  padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30), 0,
                      ScreenUtil().setWidth(30), 0),
                  child: Icon(
                    Icons.contact_phone,
                    color: Colors.blue,
                    size: ScreenUtil().setHeight(35),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          controller: controller,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              ScreenUtil().setHeight(20),
              0,
              ScreenUtil().setHeight(20),
              ScreenUtil().setHeight(20),
            ),
            child: 
            (start == false)
            ? Container()
            : Column(
              children: <Widget>[
                Container(
                    height: 177,
                    width: 280,
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //       image: FileImage(pickedImage), fit: BoxFit.contain),
                    // ),
                    child: Image(
                      image: NetworkToFileImage(
                          url: flutterLogoUrl, file: File(pathName)),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Send your content to your recipient",
                      style: TextStyle(color: Colors.grey.shade500),
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(50),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[Text("Recipient Phone Number")],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(5),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(60),
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
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                      (isImageLoaded == true)
                          ? InkWell(
                              onTap: () {
                                _showBottomSheet("phone");
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
                          : Container()
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[Text("Recipient Name:")],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(5),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(60),
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
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                      (isImageLoaded == true)
                          ? InkWell(
                              onTap: () {
                                _showBottomSheet("_namecontroller");
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
                          : Container()
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[Text("Company Name: (Optional)")],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(5),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(60),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _companycontroller,
                          style: TextStyle(
                            height: 1,
                            fontSize: font14,
                          ),
                          // controller: _positionController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "eg. JTApps Sdn Bhd",
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                      (isImageLoaded == true)
                          ? InkWell(
                              onTap: () {
                                _showBottomSheet("_companycontroller");
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
                          : Container()
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[Text("Remark: (Optional)")],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(5),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(60),
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
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      ),
                      (isImageLoaded == true)
                          ? InkWell(
                              onTap: () {
                                _showBottomSheet("_remarkcontroller");
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
                      width: ScreenUtil().setWidth(200),
                      height: ScreenUtil().setHeight(70),
                      margin: EdgeInsets.fromLTRB(
                          0,
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setHeight(10)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border(
                          top: BorderSide(width: 1, color: Colors.grey),
                          right: BorderSide(width: 1, color: Colors.grey),
                          bottom: BorderSide(width: 1, color: Colors.grey),
                          left: BorderSide(width: 1, color: Colors.grey),
                        ),
                      ),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        onPressed: () {},
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: font14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(20),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(200),
                      height: ScreenUtil().setHeight(70),
                      margin: EdgeInsets.fromLTRB(
                          0,
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setHeight(10),
                          ScreenUtil().setHeight(10)),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                        border: Border(
                          top: BorderSide(width: 1, color: Colors.grey),
                          right: BorderSide(width: 1, color: Colors.grey),
                          bottom: BorderSide(width: 1, color: Colors.grey),
                          left: BorderSide(width: 1, color: Colors.grey),
                        ),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          readText();
                        },
                        child: Text(
                          'Forward',
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
    );
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
                  fontSize: font20,
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
                    fontSize: font20,
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
                    fontSize: font20,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future readText() async {
    otherList.add("-");
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(File(pathName));
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    String patttern = r'[0-9]';
    RegExp regExp = new RegExp(patttern);
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        print("Hi: " + line.text);
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
    Navigator.pop(context);
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //     builder: (context) => MyWorks(),
    //   ),
    // );
    return Future.value(true);
  }
}
