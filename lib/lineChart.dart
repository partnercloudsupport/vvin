import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vvin/data.dart';
import 'package:vvin/vanalytics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LineChart extends StatefulWidget {
  final List<LeadData> leadsDatas;
  const LineChart({Key key, this.leadsDatas}) : super(key: key);

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  double font14 = ScreenUtil().setSp(32.2, allowFontScalingSelf: false);

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(ScreenUtil().setHeight(80),),
          child: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            leading: IconButton(
              onPressed: _onBackPressAppBar,
              icon: Icon(
                Icons.arrow_back_ios,
                size: ScreenUtil().setHeight(35),
                color: Colors.grey,
              ),
            ),
            title: Text(
              "Total Leads",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: font14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            return Container(
              height: MediaQuery.of(context).size.width,
              child: SfCartesianChart(
                zoomPanBehavior: ZoomPanBehavior(enablePinching: true),
                tooltipBehavior:
                    TooltipBehavior(enable: true, header: "Total Leads"),
                primaryXAxis: CategoryAxis(),
                series: <ChartSeries>[
                  LineSeries<LeadsData, String>(
                      enableTooltip: true,
                      dataSource: [
                        for (var data in widget.leadsDatas)
                          LeadsData(data.date, double.parse(data.number))
                      ],
                      color: Colors.blue,
                      xValueMapper: (LeadsData sales, _) => sales.x,
                      yValueMapper: (LeadsData sales, _) => sales.y)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => VAnalytics(),
        ));
    return Future.value(false);
  }
}

class LeadsData {
  LeadsData(this.x, this.y);
  final String x;
  final double y;
}
