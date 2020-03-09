import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:vvin/data.dart';
import 'package:vvin/mainscreen.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final ScrollController controller = ScrollController();
  String flutterLogoUrl = "https://vvin.com/william/5.jpg";
  String flutterLogoFileName = "flutter.png";
  File file;

  @override
  void initState() {
    test(flutterLogoFileName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            
          ),
        ),
      body: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Image(
                    image: NetworkToFileImage(
                        url: flutterLogoUrl, file: file, debug: false)),
              ),
              Container(
                padding: EdgeInsets.all(160.0),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: NetworkImage("https://vvin.com/william/5.jpg"),
                  ),
                ),
              ),
              Container(
                width: 100,
                height: ScreenUtil().setHeight(80),
                color: Colors.white,
                child: OutlineButton(
                  color: Colors.white,
                  child: Text(
                    'test',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () {
                    readText();
                  },
                  borderSide: BorderSide(
                    style: BorderStyle.solid,
                    color: Colors.blue,
                  ),
                  textColor: Colors.blue,
                ),
              ),
            ],
          )),
    );
  }

  void test(String filename) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String pathName = dir.path.toString() + "/" + filename;
    try {
      final dir = Directory(pathName);
      dir.deleteSync(recursive: true);
    } catch (err) {}
    setState(() {
      file = File(pathName);
    });
    // readText();
  }

  Future<bool> _onBackPressAppBar() async {
    CurrentIndex index = new CurrentIndex(index: 4);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(
          index: index,
        ),
      ),
    );
    return Future.value(false);
  }

  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(file);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    String patttern = r'[0-9]';
    RegExp regExp = new RegExp(patttern);
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        print(line.text);
        // String temPhone = "";
        // for (int i = 0; i < line.text.length; i++) {
        //   if (regExp.hasMatch(line.text[i])) {
        //     temPhone = temPhone + line.text[i];
        //   }
        // }
        // if (temPhone.length >= 10) {
        //   if (temPhone.substring(0, 1).toString() != "6") {
        //     phoneList.add("6" + temPhone);
        //   } else {
        //     phoneList.add(temPhone);
        //   }
        // } else {
        //   otherList.add(line.text);
        // }
      }
    }
  }
}