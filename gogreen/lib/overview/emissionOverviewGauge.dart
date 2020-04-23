/// Gauge chart example, where the data does not cover a full revolution in the
/// chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:gogreen/overview/compareEmissionWidget.dart';
import 'package:gogreen/overview/overviewWidget.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class EmissionOverviewGauge extends StatefulWidget {
  EmissionOverviewGauge(this.seriesList, {this.animate, Key key})
      : super(key: key);
  final List<charts.Series> seriesList;
  final bool animate;

  /// Creates a [PieChart] with sample data and no transition.
  factory EmissionOverviewGauge.withSampleData(
      {double personalGoal, double monthlyEmission}) {
    final _personalGoal = personalGoal ?? 580.0;
    final _monthlyEmission = monthlyEmission;
    return new EmissionOverviewGauge(
      createSampleData(_personalGoal, _monthlyEmission),
      // Disable animations for image tests.
      animate: false,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> createSampleData(
      personalGoal, monthlyEmission) {
    var data = [
      new GaugeSegment('Used', monthlyEmission),
      new GaugeSegment('Rest', (personalGoal - monthlyEmission).abs()),
    ];

    bool extraUsage = monthlyEmission > personalGoal;
    if (extraUsage) {
      data = [new GaugeSegment('Overuse', monthlyEmission)];
    }

    return [
      new charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        colorFn: (GaugeSegment segment, _) => extraUsage
            ? charts.MaterialPalette.purple.shadeDefault
            : segment.size == monthlyEmission
                ? charts.MaterialPalette.green.shadeDefault
                : charts.MaterialPalette.green.shadeDefault.lighter,
        labelAccessorFn: (GaugeSegment row, _) =>
            '${row.segment}:\n${row.size.toInt()} kg',
        data: data,
      ),
    ];
  }

  @override
  EmissionOverviewGaugeState createState() =>
      EmissionOverviewGaugeState(seriesList, createSampleData);
}

class EmissionOverviewGaugeState extends State<EmissionOverviewGauge> {
  List<charts.Series> _seriesList;
  var _createSampleData;
  bool animate;
  EmissionOverviewGaugeState(this._seriesList, this._createSampleData,
      {this.animate});

  @override
  Widget build(BuildContext context) {
    var personalGoal =
        _seriesList.first.data.last.size + _seriesList.first.data.first.size;
    var monthlyEmission = _seriesList.first.data.first.size;
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.5,
            vertical: MediaQuery.of(context).size.height * 0.095,
          ),
          child: Icon(
            Icons.help_outline,
            color: Colors.grey,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.400,
            vertical: MediaQuery.of(context).size.height * 0.105,
          ),
          child: Text(
            "CO₂",
            style: TextStyle(fontSize: 20.0, color: Colors.green),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.355,
            vertical: MediaQuery.of(context).size.height * 0.145,
          ),
          child: Text(
            "${monthlyEmission.toInt().toString()} kg",
            style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.355,
            vertical: MediaQuery.of(context).size.height * 0.152,
          ),
          child: Text(
            "_______",
            style: TextStyle(fontSize: 24.0, color: Colors.green),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.355,
            vertical: MediaQuery.of(context).size.height * 0.184,
          ),
          child: Text(
            "${personalGoal.toInt().toString()} kg",
            style: TextStyle(fontSize: 22.0, color: Colors.green),
          ),
        ),
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
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // Go to Settings screen
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CompareEmissionWidget(personalGoal, monthlyEmission),
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
