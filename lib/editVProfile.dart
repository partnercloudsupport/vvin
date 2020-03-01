import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:progress_indicators/progress_indicators.dart';
import 'package:toast/toast.dart';
import 'package:vvin/VProfile.dart';
import 'package:vvin/data.dart';
import 'package:vvin/loader.dart';
import 'package:vvin/mainscreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final ScrollController controller = ScrollController();
final TextEditingController _nameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _companyController = TextEditingController();
final TextEditingController _icController = TextEditingController();
final TextEditingController _positionController = TextEditingController();
final TextEditingController _occupationController = TextEditingController();
final TextEditingController _areaController = TextEditingController();

class EditVProfile extends StatefulWidget {
  final VProfileData vprofileData;
  final List handler;
  final List vtag;
  final VDataDetails vdata;
  const EditVProfile(
      {Key key, this.vprofileData, this.handler, this.vdata, this.vtag})
      : super(key: key);

  @override
  _EditVProfileState createState() => _EditVProfileState();
}

class _EditVProfileState extends State<EditVProfile> {
  double font12 = ScreenUtil().setSp(27.6, allowFontScalingSelf: false);
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);
  double font18 = ScreenUtil().setSp(41.4, allowFontScalingSelf: false);
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  int genderIndex, industryIndex, countryIndex, handlerIndex;
  String handler, email, companyID, userID, level, userType, selectedTag;
  bool saveHandler, saveData, allHandler, allTag;
  String urlHandler = "https://vvinoa.vvin.com/api/getHandler.php";
  String urlVTag = "https://vvinoa.vvin.com/api/vtag.php";
  String urlSaveEditVProfile =
      "https://vvinoa.vvin.com/api/saveEditVProfile.php";
  String urlSaveHandler = "https://vvinoa.vvin.com/api/saveHandler.php";
  List<Gender> genderList = [];
  List<Handler> handlerList = [];
  List<Handler> handlerList1 = [];
  List<Industry> industryList = [];
  List<Country> countryList = [];
  List<States> statesList = [];
  List vtagList = [];

  List<String> industry = [
    "-",
    "Architecture",
    "Banking & Finance",
    "Construction",
    "Construction Service",
    "Creative",
    "Dealer",
    "Distributor",
    "Education",
    "Fashion",
    "Food & Beverages",
    "Health Care",
    "Hospitality",
    "Information Technology",
    "Interior Design",
    "Manufacturing",
    "Media",
    "Non-Profit Organisation",
    "Property & Real Estate",
    "Public Service",
    "Retail",
    "Telecommunication",
    "Transportation & Logistics",
    "Others"
  ];

  List<String> gender = ["-", "Female", "Male", "Other"];

  List<String> country = [
    "-",
    "Malaysia",
    "Afghanistan",
    "Albania",
    "Algeria",
    "American Samoa",
    "Andorra",
    "Angola",
    "Anguilla",
    "Antarctica",
    "Antigua and/or Barbuda",
    "Argentina",
    "Armenia",
    "Aruba",
    "Australia",
    "Austria",
    "Azerbaijian",
    "Bahamas",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "Belize",
    "Benin",
    "Bermuda",
    "Bhutan",
    "Bolivia",
    "Bosnia and Herzegovina",
    "Botswana",
    "Bouvet Island",
    "Brazil",
    "British lndian Ocean Territory",
    "Brunei Darussalam",
    "Bulgaria",
    "Burkina Faso",
    "Burundi",
    "Cambodia",
    "Cameroon",
    "Canada",
    "Cape Verde",
    "Cayman Islands",
    "Central African Republic",
    "Chad",
    "Chile",
    "China",
    "Christmas Island",
    "Cocos (Keeling) Islands",
    "Colombia",
    "Comoros",
    "Congo",
    "Cook Islands",
    "Costa Rica",
    "Croatia (Hrvatska)",
    "Cuba",
    "Cyprus",
    "Czech Republic",
    "Denmark",
    "Djibouti",
    "Dominica",
    "Dominican Republic",
    "East Timor",
    "Ecudaor",
    "Egypt",
    "El Salvador",
    "Equatorial Guinea",
    "Eritrea",
    "Estonia",
    "Ethiopia",
    "Falkland Islands (Malvinas)",
    "Faroe Islands",
    "Fiji",
    "Finland",
    "France",
    "France, Metropolitan",
    "French Guiana",
    "French Polynesia",
    "French Southern Territories",
    "Gabon",
    "Gambia",
    "Georgia",
    "Germany",
    "Ghana",
    "Gibraltar",
    "Greece",
    "Greenland",
    "Grenada",
    "Guadeloupe",
    "Guam",
    "Guatemala",
    "Guinea",
    "Guinea-Bissau",
    "Guyana",
    "Haiti",
    "Heard and Mc Donald Islands",
    "Honduras",
    "Hong Kong",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran (Islamic Republic of)",
    "Iraq",
    "Ireland",
    "Israel",
    "Italy",
    "Ivory Coast",
    "Jamaica",
    "Japan",
    "Jordan",
    "Kazakhstan",
    "Kenya",
    "Kiribati",
    "Korea, Democratic Republic of (North Korea)",
    "Korea, Republic of (South Korea)",
    "Kuwait",
    "Kyrgyzstan",
    "Laos",
    "Latvia",
    "Lebanon",
    "Lesotho",
    "Liberia",
    "Libyan Arab Jamahiriya",
    "Liechtenstein",
    "Lithuania",
    "Luxembourg",
    "Macau",
    "Macedonia",
    "Madagascar",
    "Malawi",
    "Maldives",
    "Mali",
    "Malta",
    "Marshall Islands",
    "Martinique",
    "Mauritania",
    "Mauritius",
    "Mayotte",
    "Mexico",
    "Micronesia, Federated States of",
    "Moldova, Republic of",
    "Monaco",
    "Mongolia",
    "Montserrat",
    "Morocco",
    "Mozambique",
    "Myanmar",
    "Namibia",
    "Nauru",
    "Nepal",
    "Netherlands",
    "Netherlands Antilles",
    "New Caledonia",
    "New Zealand",
    "Nicaragua",
    "Niger",
    "Nigeria",
    "Niue",
    "Norfork Island",
    "Northern Mariana Islands",
    "Norway",
    "Oman",
    "Pakistan",
    "Palau",
    "Panama",
    "Papua New Guinea",
    "Paraguay",
    "Peru",
    "Philippines",
    "Pitcairn",
    "Poland",
    "Portugal",
    "Puerto Rico",
    "Qatar",
    "Reunion",
    "Romania",
    "Russian Federation",
    "Rwanda",
    "Saint Kitts and Nevis",
    "Saint Lucia",
    "Saint Vincent and the Grenadines",
    "Samoa",
    "San Marino",
    "Sao Tome and Principe",
    "Saudi Arabia",
    "Senegal",
    "Seychelles",
    "Sierra Leone",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "Solomon Islands",
    "Somalia",
    "South Africa",
    "South Georgia South Sandwich Islands",
    "Spain",
    "Sri Lanka",
    "St. Helena",
    "St. Pierre and Miquelon",
    "Sudan",
    "Suriname",
    "Svalbarn and Jan Mayen Islands",
    "Swaziland",
    "Sweden",
    "Switzerland",
    "Syrian Arab Republic",
    "Taiwan",
    "Tajikistan",
    "Tanzania, United Republic of",
    "Thailand",
    "Togo",
    "Tokelau",
    "Tonga",
    "Trinidad and Tobago",
    "Tunisia",
    "Turkey",
    "Turkmenistan",
    "Turks and Caicos Islands",
    "Tuvalu",
    "Uganda",
    "Ukraine",
    "United Arab Emirates",
    "United Kingdom",
    "United States",
    "United States minor outlying islands",
    "Uruguay",
    "Uzbekistan",
    "Vanuatu",
    "Vatican City State",
    "Venezuela",
    "Vietnam",
    "Virgin Islands (U.S.)",
    "Virigan Islands (British)",
    "Wallis and Futuna Islands",
    "Western Sahara",
    "Yemen",
    "Yugoslavia",
    "Zaire",
    "Zambia",
    "Zimbabwe",
  ];

  List<String> states = [
    "-",
    "Johor",
    "Kedah",
    "Kelantan",
    "Melaka",
    "Negeri Sembilan",
    "Pahang",
    "Perak",
    "Perlis",
    "Pulau Pinang",
    "Sabah",
    "Sarawak",
    "Selangor",
    "Terengganu",
    "WP Kuala Lumpur",
    "WP Labuan",
    "WP Putrajaya"
  ];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white, // Color for Android
    ));
    _nameController.text = widget.vprofileData.name;
    _emailController.text = widget.vprofileData.email;
    _companyController.text = widget.vprofileData.company;
    _icController.text = widget.vprofileData.ic;
    _positionController.text = widget.vprofileData.position;
    _occupationController.text = widget.vprofileData.occupation;
    _areaController.text = widget.vprofileData.area;
    handlerIndex = 0;
    handler = "";
    selectedTag = "";
    saveData = false;
    saveHandler = false;
    allHandler = false;
    allTag = false;
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
                      style: TextStyle(fontSize: font14),
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
              "Edit VProfile",
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
              padding: EdgeInsets.fromLTRB(
                ScreenUtil().setHeight(10),
                0,
                ScreenUtil().setHeight(10),
                ScreenUtil().setHeight(10),
              ),
              child: Center(
                child: SizedBox(
                  height: ScreenUtil().setHeight(60),
                  child: TextField(
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: font18,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.all(ScreenUtil().setHeight(10)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setHeight(40),
                    ScreenUtil().setHeight(20),
                    ScreenUtil().setHeight(40),
                    ScreenUtil().setHeight(40),
                  ),
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Handler",
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
                      (widget.vdata.level == "0")
                          ? (widget.handler.length > 0)
                              ? Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      for (int i = 0;
                                          i < widget.handler.length;
                                          i++)
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            ScreenUtil().setHeight(20),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  height: ScreenUtil()
                                                      .setHeight(60),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        style:
                                                            BorderStyle.solid),
                                                  ),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Flexible(
                                                        child: Text(
                                                          widget.handler[i],
                                                          style: TextStyle(
                                                            fontSize: font14,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    ScreenUtil().setWidth(20),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  _deleteHandler(i);
                                                },
                                                child: Container(
                                                  height: ScreenUtil()
                                                      .setHeight(60),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade500,
                                                        style:
                                                            BorderStyle.solid),
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                )
                              : Container()
                          : (widget.handler.length > 0)
                              ? Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      for (int i = 0;
                                          i < widget.handler.length;
                                          i++)
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            ScreenUtil().setHeight(20),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                  height: ScreenUtil()
                                                      .setHeight(60),
                                                  padding: EdgeInsets.fromLTRB(
                                                      ScreenUtil()
                                                          .setHeight(20),
                                                      0,
                                                      0,
                                                      0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        style:
                                                            BorderStyle.solid),
                                                  ),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Flexible(
                                                        child: Text(
                                                          widget.handler[i],
                                                          style: TextStyle(
                                                            fontSize: font14,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                )
                              : Container(),
                      (widget.vdata.level == "0")
                          ? Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    height: 30,
                                    margin: EdgeInsets.fromLTRB(
                                      0,
                                      0,
                                      0,
                                      ScreenUtil().setHeight(20),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          style: BorderStyle.solid),
                                    ),
                                    child: InkWell(
                                      child: OutlineButton.icon(
                                        color: Colors.white,
                                        label: Text(
                                          'Add Handler',
                                          style: TextStyle(
                                              fontSize: font14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: _addHandler,
                                        textColor: Colors.blue,
                                        icon: Icon(
                                          Icons.add,
                                          size: ScreenUtil().setHeight(40),
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Email",
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
                        height: ScreenUtil().setHeight(60),
                        child: TextField(
                          style: TextStyle(
                            fontSize: font14,
                          ),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
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
                            "Company",
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
                        height: ScreenUtil().setHeight(60),
                        child: TextField(
                          style: TextStyle(
                            height: 1,
                            fontSize: font14,
                          ),
                          controller: _companyController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
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
                            "IC/Passport Number",
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
                        height: ScreenUtil().setHeight(60),
                        child: TextField(
                          style: TextStyle(
                            height: 1,
                            fontSize: font14,
                          ),
                          controller: _icController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
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
                            "Date of Birth",
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
                              onTap: _dobBottomSheet,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                  0,
                                  0,
                                  0,
                                  ScreenUtil().setHeight(20),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey,
                                      style: BorderStyle.solid),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        height: ScreenUtil().setHeight(60),
                                        padding: EdgeInsets.fromLTRB(
                                            ScreenUtil().setHeight(10),
                                            ScreenUtil().setHeight(16),
                                            0,
                                            0),
                                        child: Text(
                                          widget.vprofileData.dob,
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
                        height: ScreenUtil().setHeight(10),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Gender",
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
                                _showBottomSheet("gender");
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
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey,
                                      style: BorderStyle.solid),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        height: ScreenUtil().setHeight(60),
                                        padding: EdgeInsets.fromLTRB(
                                            ScreenUtil().setHeight(10),
                                            ScreenUtil().setHeight(16),
                                            0,
                                            0),
                                        child: Text(
                                          widget.vprofileData.gender,
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
                                      width: ScreenUtil().setHeight(10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Position",
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
                        height: ScreenUtil().setHeight(60),
                        child: TextField(
                          style: TextStyle(
                            height: 1,
                            fontSize: font14,
                          ),
                          controller: _positionController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
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
                            "Industry",
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
                                _showBottomSheet("industry");
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
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey,
                                      style: BorderStyle.solid),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        height: ScreenUtil().setHeight(60),
                                        padding: EdgeInsets.fromLTRB(
                                            ScreenUtil().setHeight(10),
                                            ScreenUtil().setHeight(16),
                                            0,
                                            0),
                                        child: Text(
                                          widget.vprofileData.industry,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Occupation",
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
                        height: ScreenUtil().setHeight(60),
                        child: TextField(
                          style: TextStyle(
                            height: 1,
                            fontSize: font14,
                          ),
                          controller: _occupationController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
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
                            "Country",
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
                                _showBottomSheet("country");
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
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey,
                                      style: BorderStyle.solid),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        height: ScreenUtil().setHeight(60),
                                        padding: EdgeInsets.fromLTRB(
                                            ScreenUtil().setHeight(10),
                                            ScreenUtil().setHeight(16),
                                            0,
                                            0),
                                        child: Text(
                                          widget.vprofileData.country,
                                          overflow: TextOverflow.ellipsis,
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
                      (widget.vprofileData.country == "Malaysia")
                          ? Container(
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "State",
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
                                            _showBottomSheet("state");
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
                                                  color: Colors.grey,
                                                  style: BorderStyle.solid),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    height: ScreenUtil()
                                                        .setHeight(60),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            ScreenUtil()
                                                                .setHeight(10),
                                                            ScreenUtil()
                                                                .setHeight(16),
                                                            0,
                                                            0),
                                                    child: Text(
                                                      widget.vprofileData.state,
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
                                                  width:
                                                      ScreenUtil().setWidth(10),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Area",
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
                      Container(
                        height: ScreenUtil().setHeight(60),
                        child: TextField(
                          style: TextStyle(
                            height: 1,
                            fontSize: font14,
                          ),
                          controller: _areaController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.all(ScreenUtil().setHeight(10)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
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
                            "Tags",
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
                                child: (widget.vtag.length == 0)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "",
                                            style: TextStyle(
                                                fontSize: font14,
                                                color: Colors.grey),
                                          )
                                        ],
                                      )
                                    : Wrap(
                                        direction: Axis.horizontal,
                                        alignment: WrapAlignment.start,
                                        children: <Widget>[
                                          for (int i = 0;
                                              i < widget.vtag.length;
                                              i++)
                                            InkWell(
                                              onTap: () {
                                                _deleteTag(i);
                                              },
                                              child: Container(
                                                width: ScreenUtil().setWidth(
                                                    (widget.vtag[i].length *
                                                            20) +
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
                                                      widget.vtag[i],
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: font14,
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
                      SizedBox(
                        height: ScreenUtil().setHeight(40),
                      ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        minWidth: MediaQuery.of(context).size.width * 0.5,
                        height: ScreenUtil().setHeight(80),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: font14,
                          ),
                        ),
                        color: Color.fromRGBO(34, 175, 240, 1),
                        textColor: Colors.white,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _deleteTag(int index) {
    String vtag = widget.vtag[index];
    setState(() {
      widget.vtag.removeAt(index);
      vtagList.insert(1, vtag);
    });
  }

  void _selectHandler() {
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
                            if (selectedTag != "") {
                              for (int j = 0; j < vtagList.length; j++) {
                                if (vtagList[j] == selectedTag) {
                                  vtagList.removeAt(j);
                                }
                              }
                              setState(() {
                                widget.vtag.add(selectedTag);
                                selectedTag = "";
                              });
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
                        if (index != 0) {
                          selectedTag = vtagList[index];
                        }
                      },
                      children: <Widget>[
                        for (var each in vtagList)
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

  Future<bool> _onBackPressAppBar() async {
    Navigator.pop(context, true);
    Navigator.pop(context, true);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VProfile(
            vdata: widget.vdata,
          ),
        ));
    return Future.value(false);
  }

  void _dobBottomSheet() {
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
                          padding: EdgeInsets.all(10),
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
                            padding: EdgeInsets.all(10),
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
                          },
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      color: Colors.white,
                      child: CupertinoDatePicker(
                        maximumDate: DateTime.now(),
                        mode: CupertinoDatePickerMode.date,
                        backgroundColor: Colors.transparent,
                        initialDateTime: (widget.vprofileData.dob == "")
                            ? DateTime.parse("1970-01-01")
                            : DateTime.parse(widget.vprofileData.dob),
                        onDateTimeChanged: (dob) {
                          setState(() {
                            widget.vprofileData.dob =
                                dob.toString().substring(0, 10);
                          });
                        },
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
  }

  void _addHandler() {
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
                            if (handlerIndex != 0) {
                              Navigator.pop(context);
                              setState(() {
                                widget.handler.add(handler);
                                handlerList.removeAt(handlerIndex);
                                handlerIndex = 0;
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
                        setState(() {
                          handlerIndex = index;
                          handler = handlerList[index].handler;
                        });
                      },
                      children: <Widget>[
                        for (var each in handlerList)
                          Text(
                            each.handler,
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

  void _showBottomSheet(String type) {
    switch (type) {
      case "gender":
        {
          int position;
          if (widget.vprofileData.gender == "") {
            position = 0;
          } else {
            for (int i = 0; i < genderList.length; i++) {
              if (widget.vprofileData.gender == genderList[i].gender) {
                position = genderList[i].position;
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
                            scrollController: FixedExtentScrollController(
                                initialItem: position),
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                widget.vprofileData.gender =
                                    genderList[index].gender;
                              });
                            },
                            children: <Widget>[
                              for (var each in genderList)
                                Text(
                                  each.gender,
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
        break;
      case "industry":
        {
          int position;
          if (widget.vprofileData.industry == "") {
            position = 0;
          } else {
            for (int i = 0; i < industryList.length; i++) {
              if (widget.vprofileData.industry == industryList[i].industry) {
                position = industryList[i].position;
              }
            }
          }
          if (position == null) {
            position = 0;
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
                            scrollController: FixedExtentScrollController(
                                initialItem: position),
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                widget.vprofileData.industry =
                                    industryList[index].industry;
                              });
                            },
                            children: <Widget>[
                              for (var data in industryList)
                                Text(
                                  data.industry,
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
        break;
      case "country":
        {
          int position;
          if (widget.vprofileData.industry == "") {
            position = 0;
          } else {
            for (int i = 0; i < countryList.length; i++) {
              if (widget.vprofileData.country == countryList[i].country) {
                position = countryList[i].position;
              }
            }
          }
          if (position == null) {
            position = 0;
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
                            scrollController: FixedExtentScrollController(
                                initialItem: position),
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                widget.vprofileData.country =
                                    countryList[index].country;
                              });
                            },
                            children: <Widget>[
                              for (var each in countryList)
                                Text(
                                  each.country,
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
        break;
      case "state":
        {
          int position;
          if (widget.vprofileData.state == "") {
            position = 0;
          } else {
            for (int i = 0; i < statesList.length; i++) {
              if (widget.vprofileData.state == statesList[i].state) {
                position = statesList[i].position;
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
                            scrollController: FixedExtentScrollController(
                                initialItem: position),
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                widget.vprofileData.state =
                                    statesList[index].state;
                              });
                            },
                            children: <Widget>[
                              for (var each in statesList)
                                Text(
                                  each.state,
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
        break;
    }
  }

  void checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      _onLoading1();
      setupData();
      getTag();
    }
  }

  void setupData() {
    companyID = widget.vdata.companyID;
    userID = widget.vdata.userID;
    level = widget.vdata.level;
    userType = widget.vdata.userType;
    http.post(urlHandler, body: {
      "companyID": companyID,
      "userID": userID,
      "user_type": userType,
      "level": level,
    }).then((res) {
      if (res.body != "nodata") {
        var jsonData = json.decode(res.body);
        for (var data in jsonData) {
          Handler handler = Handler(
            handler: data["handler"],
            position: data["position"],
            handlerID: data["handlerID"],
          );
          handlerList.add(handler);
          handlerList1.add(handler);
        }
        for (int i = 0; i < widget.handler.length; i++) {
          for (int j = 0; j < handlerList.length; j++) {
            if (widget.handler[i] == handlerList[j].handler) {
              handlerList.removeAt(j);
            }
          }
        }
        for (int i = 0; i < gender.length; i++) {
          Gender genderforEach = Gender(gender: gender[i], position: i);
          genderList.add(genderforEach);
        }
        for (int i = 0; i < industry.length; i++) {
          Industry industryforEach =
              Industry(industry: industry[i], position: i);
          industryList.add(industryforEach);
        }
        for (int i = 0; i < country.length; i++) {
          Country countryforEach = Country(country: country[i], position: i);
          countryList.add(countryforEach);
        }
        for (int i = 0; i < states.length; i++) {
          States stateforEach = States(state: states[i], position: i);
          statesList.add(stateforEach);
        }
      } else {
        Toast.show("Something wrong, please contact VVIN IT help desk", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
      setState(() {
        allHandler = true;
      });
      if (allHandler == true && allTag == true) {
        Navigator.pop(context);
      }
    }).catchError((err) {
      Toast.show("No Internet Connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Setup Data error: " + (err).toString());
    });
  }

  void getTag() {
    companyID = widget.vdata.companyID;
    userID = widget.vdata.userID;
    level = widget.vdata.level;
    userType = widget.vdata.userType;
    http.post(urlVTag, body: {
      "companyID": companyID,
      "userID": userID,
      "level": level,
      "user_type": userType,
      "phone_number": "all",
    }).then((res) {
      if (res.body != "nodata") {
        var jsonData = json.decode(res.body);
        vtagList = jsonData;
        vtagList.insert(0, "-");
      } else {
        vtagList.add("-");
      }
      for (int i = 0; i < widget.vtag.length; i++) {
        for (int j = 0; j < vtagList.length; j++) {
          if (vtagList[j] == widget.vtag[i]) {
            vtagList.removeAt(j);
          }
        }
      }
      setState(() {
        allTag = true;
      });
      if (allHandler == true && allTag == true) {
        Navigator.pop(context);
      }
    }).catchError((err) {
      Toast.show("No Internet Connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print("Setup Data error: " + (err).toString());
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
                JumpingText('Loading...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteHandler(int i) {
    setState(() {
      widget.handler.removeAt(i);
    });

    handlerList.clear();
    for (int i = 0; i < handlerList1.length; i++) {
      Handler handler = Handler(
        handler: handlerList1[i].handler,
        position: handlerList1[i].position,
        handlerID: handlerList1[i].handlerID,
      );
      handlerList.add(handler);
    }

    if (widget.handler.length != 0) {
      for (int i = 0; i < widget.handler.length; i++) {
        for (int j = 0; j < handlerList.length; j++) {
          if (widget.handler[i] == handlerList[j].handler) {
            handlerList.removeAt(j);
          }
        }
      }
    }
  }

  void _save() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      _onLoading1();
      String vtag = "";
      if (widget.vprofileData.gender == "-" ||
          widget.vprofileData.gender == "") {
        setState(() {
          widget.vprofileData.gender = "";
        });
      } else {
        widget.vprofileData.gender =
            widget.vprofileData.gender.toUpperCase().substring(0, 1);
      }
      if (widget.vprofileData.industry == "-") {
        setState(() {
          widget.vprofileData.industry = "";
        });
      }
      if (widget.vprofileData.state == "-") {
        setState(() {
          widget.vprofileData.state = "";
        });
      }
      if (widget.vprofileData.country == "-") {
        setState(() {
          widget.vprofileData.country = "";
        });
      }
      for (int i = 0; i < widget.vtag.length; i++) {
        if (i == 0) {
          vtag = widget.vtag[i];
        } else {
          vtag = vtag + "," + widget.vtag[i];
        }
      }

      http.post(urlSaveEditVProfile, body: {
        "companyID": companyID,
        "userID": userID,
        "level": level,
        "user_type": userType,
        "phoneNo": widget.vdata.phoneNo,
        "name": _nameController.text ?? "",
        "email": _emailController.text ?? "",
        "company": _companyController.text ?? "",
        "ic": _icController.text ?? "",
        "dob": widget.vprofileData.dob ?? "",
        "gender": widget.vprofileData.gender ?? "",
        "position": _positionController.text ?? "",
        "industry": widget.vprofileData.industry ?? "",
        "occupation": _occupationController.text ?? "",
        "country": widget.vprofileData.country ?? "",
        "state": widget.vprofileData.state ?? "",
        "area": _areaController.text ?? "",
        "vtag": vtag,
      }).then((res) {
        // print("VProfile data: " + res.body);
        if (res.body == "success") {
          _saveHandler();
        } else {
          Toast.show(
              "Something wrong, please contact VVIN IT help desk", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }).catchError((err) {
        Toast.show(err.toString(), context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        print("Save error: " + (err).toString());
      });
    } else {
      Toast.show("Please check your Internet connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _saveHandler() {
    if (widget.handler.length == 0) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      VDataDetails vdata1 = new VDataDetails(
        companyID: companyID,
        userID: userID,
        level: level,
        userType: userType,
        date: widget.vdata.date,
        name: _nameController.text,
        phoneNo: widget.vdata.phoneNo,
        status: widget.vdata.status,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VProfile(
            vdata: vdata1,
          ),
        ),
      );
    } else {
      for (int i = 0; i < widget.handler.length; i++) {
        for (int j = 0; j < handlerList1.length; j++) {
          if (widget.handler[i] == handlerList1[j].handler) {
            http.post(urlSaveHandler, body: {
              "companyID": companyID,
              "userID": userID,
              "handlerID": handlerList1[j].handlerID,
              "level": level,
              "user_type": userType,
              "phoneNo": widget.vdata.phoneNo,
            }).then((res) {
              // print("Add handler: " + res.body.toString());
              if (i == widget.handler.length - 1 && res.body == "success") {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                VDataDetails vdata1 = new VDataDetails(
                  companyID: companyID,
                  userID: userID,
                  level: level,
                  userType: userType,
                  date: widget.vdata.date,
                  name: _nameController.text,
                  phoneNo: widget.vdata.phoneNo,
                  status: widget.vdata.status,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VProfile(
                      vdata: vdata1,
                    ),
                  ),
                );
              }
            }).catchError((err) {
              Toast.show("No Internet Connection", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              print("Save Handler error: " + (err).toString());
            });
          }
        }
      }
    }
  }
}
