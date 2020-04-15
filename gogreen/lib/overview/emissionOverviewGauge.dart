/// Gauge chart example, where the data does not cover a full revolution in the
/// chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
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
    final _monthlyEmission = monthlyEmission ?? 0.0;
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

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<double> _personalGoal;

  @override
  void initState() {
    super.initState();
    _personalGoal = _prefs.then((SharedPreferences prefs) {
      var storedPersonalGoal = (prefs.getDouble('personalGoal') ?? 0.0);
      var storedMonthlyEmissions = (prefs.getDouble('monthlyEmissions') ?? 0.0);
      _seriesList =
          _createSampleData(storedPersonalGoal, storedMonthlyEmissions);
      return storedPersonalGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

/// Sample data type.
class GaugeSegment {
  final String segment;
  final double size;

  GaugeSegment(this.segment, this.size);
}
