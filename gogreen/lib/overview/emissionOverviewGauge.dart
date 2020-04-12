/// Gauge chart example, where the data does not cover a full revolution in the
/// chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:gogreen/emissionData/emissionDataService.dart';

class EmissionOverviewGauge extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  EmissionOverviewGauge(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory EmissionOverviewGauge.withSampleData() {
    final personalGoal = new EmissionDataService().getPersonalGoal();
    final monthlyEmission = 337.43;
    return new EmissionOverviewGauge(
      _createSampleData(personalGoal, monthlyEmission),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(
      seriesList,
      animate: animate,
      // Configure the width of the pie slices to 30px. The remaining space in
      // the chart will be left as a hole in the center. Adjust the start
      // angle and the arc length of the pie so it resembles a gauge.
      defaultRenderer: new charts.ArcRendererConfig(
        arcWidth: 30,
        startAngle: 3 / 2 * pi,
        arcRendererDecorators: [new charts.ArcLabelDecorator()],
      ),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> _createSampleData(
      personalGoal, monthlyEmission) {
    final data = [
      new GaugeSegment('Goal', personalGoal),
      new GaugeSegment('Rest', personalGoal - monthlyEmission),
    ];

    return [
      new charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        colorFn: (GaugeSegment segment, _) => segment.size >= 570.0
            ? charts.MaterialPalette.green.shadeDefault
            : charts.MaterialPalette.green.shadeDefault.lighter,
        labelAccessorFn: (GaugeSegment row, _) =>
            '${row.segment}:\n${row.size}',
        data: data,
      ),
    ];
  }
}

/// Sample data type.
class GaugeSegment {
  final String segment;
  final double size;

  GaugeSegment(this.segment, this.size);
}
