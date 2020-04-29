/// Gauge chart example, where the data does not cover a full revolution in the
/// chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:gogreen/overview/compareEmissionWidget.dart';
import 'dart:math';

class EmissionOverviewGauge extends StatefulWidget {
  EmissionOverviewGauge(this.seriesList, {this.animate, Key key, this.equivalent}) : super(key: key);
  final List<charts.Series> seriesList;
  final bool animate;
  final bool equivalent;

  /// Creates a [PieChart] with sample data and no transition.
  factory EmissionOverviewGauge.withSampleData({double personalGoal, double monthlyEmission, bool equivalent}) {
    final _personalGoal = personalGoal ?? 580.0;
    final _monthlyEmission = monthlyEmission ?? 0.0;
    return new EmissionOverviewGauge(createSampleData(_personalGoal, _monthlyEmission),
        // Disable animations for image tests.
        animate: false,
        equivalent: equivalent);
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> createSampleData(personalGoal, monthlyEmission) {
    var data = [
      new GaugeSegment('Used', monthlyEmission),
      new GaugeSegment('Rest', (personalGoal - monthlyEmission).abs()),
    ];

    bool extraUsage = monthlyEmission > personalGoal;
    if (extraUsage) {
      data = [
        new GaugeSegment('Overuse', (monthlyEmission - personalGoal).abs()),
        new GaugeSegment('Rest', 0.0),
      ];
    }
    bool equalUsage = monthlyEmission == personalGoal;
    if (equalUsage) {
      data = [
        new GaugeSegment('Overuse', monthlyEmission),
        new GaugeSegment('Rest', 0.0),
      ];
    }

    return [
      new charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        colorFn: (GaugeSegment segment, _) => extraUsage || equalUsage
            ? charts.MaterialPalette.purple.shadeDefault
            : segment.size == monthlyEmission
                ? charts.MaterialPalette.green.shadeDefault
                : charts.MaterialPalette.green.shadeDefault.lighter,
        labelAccessorFn: (GaugeSegment row, _) => '${row.size > 0 ? "${row.segment}:\n${row.size.toInt()} kg" : ""}',
        data: data,
      ),
    ];
  }

  @override
  EmissionOverviewGaugeState createState() =>
      EmissionOverviewGaugeState(seriesList, createSampleData, equivalent: equivalent);
}

class EmissionOverviewGaugeState extends State<EmissionOverviewGauge> {
  List<charts.Series> _seriesList;
  var _createSampleData;
  bool animate;
  bool equivalent;

  EmissionOverviewGaugeState(this._seriesList, this._createSampleData, {this.animate, this.equivalent});

  @override
  Widget build(BuildContext context) {
    bool overuse = _seriesList.first.data.last.size == 0.0;
    var personalGoal = _seriesList.first.data.last.size + _seriesList.first.data.first.size;
    var monthlyEmission = _seriesList.first.data.first.size;
    return Stack(
      children: <Widget>[
        Container(
          child: new charts.PieChart(
            _seriesList,
            animate: animate,
            // Configure the width of the pie slices to 30px. The remaining space in
            // the chart will be left as a hole in the center. Adjust the start
            // angle and the arc length of the pie so it resembles a gauge.
            defaultRenderer: new charts.ArcRendererConfig(
              arcWidth: 30,
              startAngle: 3 / 2 * pi,
              arcRendererDecorators: [new charts.ArcLabelDecorator()],
            ),
          ),
        ),
        equivalent == true
            ? Container()
            : Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.475,
                  vertical: MediaQuery.of(context).size.height * 0.080,
                ),
                child: Icon(
                  Icons.help_outline,
                  color: Colors.grey,
                ),
              ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.405,
            vertical: MediaQuery.of(context).size.height * 0.095,
          ),
          child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                "CO₂",
                style: TextStyle(fontSize: 20.0, color: overuse ? Colors.purple : Colors.green),
              )),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.355,
            vertical: MediaQuery.of(context).size.height * 0.135,
          ),
          child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                "${monthlyEmission.toInt().toString()} kg",
                style: TextStyle(
                    fontSize: 22.0, fontWeight: FontWeight.w600, color: overuse ? Colors.purple : Colors.green),
              )),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.358,
            vertical: MediaQuery.of(context).size.height * 0.140,
          ),
          child: overuse
              ? Container()
              : FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    "_______",
                    style: TextStyle(fontSize: 24.0, color: Colors.green),
                  )),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.355,
            vertical: MediaQuery.of(context).size.height * 0.170,
          ),
          child: overuse
              ? FittedBox(
                  fit: BoxFit.fitWidth, child: Text("overuse", style: TextStyle(fontSize: 20.0, color: Colors.purple)))
              : FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    "${personalGoal.toInt().toString()} kg",
                    style: TextStyle(fontSize: 22.0, color: Colors.green),
                  )),
        ),
        equivalent == true
            ? Container()
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // Go to Compare screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompareEmissionWidget(personalGoal, monthlyEmission),
                      )).then((value) {
                    print("overview page got value: $value");
                    // setState(() {
                    //   _personalGoal = _prefs.then((SharedPreferences prefs) {
                    //     return prefs.getDouble('personalGoal');
                    //   });
                    // });
                  });
                },
              )
      ],
    );
  }
}

/// Sample data type.
class GaugeSegment {
  final String segment;
  final double size;

  GaugeSegment(this.segment, this.size);
}
