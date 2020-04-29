import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/src/text_element.dart' as txt;
import 'package:charts_flutter/src/text_style.dart' as style;
import 'dart:math';

import 'package:intl/intl.dart';

class StackedAreaLineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  static final pointerValue = <String, String>{};

  StackedAreaLineChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(seriesList,
        behaviors: [
          LinePointHighlighter(symbolRenderer: CustomCircleSymbolRenderer()),
          new charts.ChartTitle('CO₂ kg',
              titleStyleSpec: TextStyleSpec(fontSize: 10),
              behaviorPosition: charts.BehaviorPosition.top,
              titleOutsideJustification: charts.OutsideJustification.start,
              // Set a larger inner padding than the default (10) to avoid
              // rendering the text too close to the top measure axis tick label.
              // The top tick label may extend upwards into the top margin region
              // if it is located at the top of the draw area.
              innerPadding: 18),
        ],
        selectionModels: [
          SelectionModelConfig(changedListener: (SelectionModel model) {
            DateTime time;

            if (model.hasDatumSelection) if (model.selectedDatum.isNotEmpty) {
              time = model.selectedDatum.first.datum.month;
              model.selectedDatum.forEach((charts.SeriesDatum datumPair) {
                pointerValue[datumPair.series.displayName] =
                    DateFormat('MMM').format(time) +
                        ": " +
                        datumPair.datum.emission.round().toString() +
                        " kg";
              });
            }
          })
        ],
        defaultRenderer: new charts.LineRendererConfig(includeArea: true),
        animate: animate,
        domainAxis: new charts.DateTimeAxisSpec(
            tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                month: new charts.TimeFormatterSpec(
                    format: 'MMM', transitionFormat: 'MMM-yy'))));
  }
}

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  @override
  void paint(ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      Color fillColor,
      FillPatternType fillPattern,
      Color strokeColor,
      double strokeWidthPx}) {
    {
      super.paint(canvas, bounds,
          dashPattern: dashPattern,
          fillColor: fillColor,
          strokeColor: strokeColor,
          strokeWidthPx: strokeWidthPx);
      var textStyle = style.TextStyle();

      textStyle.color = Color.black;
      textStyle.fontSize = 15;
      canvas.drawText(
          txt.TextElement(
              StackedAreaLineChart.pointerValue[
                  fillColor.toString() == "#4caf50ff"
                      ? "realEmission"
                      : "modifiedEmission"],
              style: textStyle),
          (bounds.left - 50).round(),
          (bounds.top - 28).round());
    }
  }
}
