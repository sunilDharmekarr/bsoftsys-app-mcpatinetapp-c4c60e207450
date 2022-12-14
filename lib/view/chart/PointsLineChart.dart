import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/model/BPModel.dart';
import 'package:mumbaiclinic/model/HeightModel.dart';
import 'package:mumbaiclinic/model/ParameterDetailModel.dart';
import 'package:mumbaiclinic/model/PulseModel.dart';
import 'package:mumbaiclinic/model/Spo2Model.dart';
import 'package:mumbaiclinic/model/TempModel.dart';
import 'package:mumbaiclinic/model/WeightModel.dart';
import 'package:mumbaiclinic/screen/vital/my_vital_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PointsLineChart extends StatefulWidget {
  final List<ChartSeries<LinearSales, String>> graphData;
  final bool visible;
  final double minimumValue, maximumValue;
  PointsLineChart(this.graphData,
      {this.visible = false, this.minimumValue, this.maximumValue});

  factory PointsLineChart.forWeight(List<WeightDatum> weight) {
    return PointsLineChart(
      _createWeightData(weight),
    );
  }

  factory PointsLineChart.forHeight(List<HeightDatum> height) {
    return PointsLineChart(
      _createHeightData(height),
    );
  }

  factory PointsLineChart.forTemperature(List<TempDatum> temp) {
    return PointsLineChart(
      _createTemperatureData(temp),
      minimumValue: 90,
      maximumValue: 110,
    );
  }

  factory PointsLineChart.forPluse(List<PulseDatum> pluse) {
    return PointsLineChart(
      _createPluseData(pluse),
    );
  }

  factory PointsLineChart.forSpo2(List<SpoDatum> spo) {
    return PointsLineChart(
      _createSpo2Data(spo),
      minimumValue: 50,
      maximumValue: 100,
    );
  }

  factory PointsLineChart.forSugar(List<SpoDatum> spo) {
    return PointsLineChart(_createSugarData(spo));
  }

  factory PointsLineChart.forBP(List<BpDatum> bpData, bool visible) {
    return PointsLineChart(
      _createBpData(bpData),
      visible: visible,
    );
  }

  factory PointsLineChart.parameters(List<Parameter> parameters) {
    return PointsLineChart(_createParametersData(parameters));
  }

  @override
  _PointsLineChartState createState() => _PointsLineChartState();

  ///create weight data
  ///

  static List<ChartSeries<LinearSales, String>> _createWeightData(
      List<WeightDatum> weight) {
    List<LinearSales> data = [];

    weight.forEach((element) {
      data.add(LinearSales(Utils.graphDate(element.date),
          double.parse(element.weight.toString()).round()));
    });
    return <LineSeries<LinearSales, String>>[
      LineSeries<LinearSales, String>(
        enableTooltip: false,
        color: ColorTheme.darkGreen,
        legendItemText: '',
        dataSource: data,
        xValueMapper: (LinearSales sales, _) => sales.year,
        yValueMapper: (LinearSales sales, _) => sales.sales,
        markerSettings: MarkerSettings(isVisible: true),
        // Enable data label
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
    ];
  }

  static List<ChartSeries<LinearSales, String>> _createHeightData(
      List<HeightDatum> weight) {
    List<LinearSales> data = [];

    weight.forEach((element) {
      data.add(LinearSales(Utils.graphDate(element.date),
          double.parse(element.height.toString()).round()));
    });
    return <LineSeries<LinearSales, String>>[
      LineSeries<LinearSales, String>(
        enableTooltip: false,
        color: ColorTheme.darkGreen,
        legendItemText: '',
        dataSource: data,
        xValueMapper: (LinearSales sales, _) => sales.year,
        yValueMapper: (LinearSales sales, _) => sales.sales,
        markerSettings: MarkerSettings(isVisible: true),
        // Enable data label
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
    ];
  }

  static List<ChartSeries<LinearSales, String>> _createTemperatureData(
      List<TempDatum> weight) {
    List<LinearSales> data = [];

    weight.forEach((element) {
      data.add(LinearSales(Utils.graphDate(element.date),
          double.parse(element.temp.toString()).round()));
    });
    return <LineSeries<LinearSales, String>>[
      LineSeries<LinearSales, String>(
        enableTooltip: false,
        color: ColorTheme.darkGreen,
        legendItemText: '',
        dataSource: data,
        xValueMapper: (LinearSales sales, _) => sales.year,
        yValueMapper: (LinearSales sales, _) => sales.sales,
        markerSettings: MarkerSettings(isVisible: true),
        // Enable data label
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
    ];
  }

  static List<ChartSeries<LinearSales, String>> _createPluseData(
      List<PulseDatum> pluse) {
    List<LinearSales> data = [];

    pluse.forEach((element) {
      data.add(LinearSales(Utils.graphDate(element.date),
          double.parse(element.pulse.toString()).round()));
    });
    return <LineSeries<LinearSales, String>>[
      LineSeries<LinearSales, String>(
        enableTooltip: false,
        color: ColorTheme.darkGreen,
        legendItemText: '',
        dataSource: data,
        xValueMapper: (LinearSales sales, _) => sales.year,
        yValueMapper: (LinearSales sales, _) => sales.sales,
        markerSettings: MarkerSettings(isVisible: true),
        // Enable data label
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
    ];
  }

  static List<ChartSeries<LinearSales, String>> _createSpo2Data(
      List<SpoDatum> spo) {
    List<LinearSales> data = [];

    spo.forEach((element) {
      data.add(LinearSales(Utils.graphDate(element.date),
          double.parse(element.spo2.toString()).round()));
    });
    return <LineSeries<LinearSales, String>>[
      LineSeries<LinearSales, String>(
        enableTooltip: false,
        color: ColorTheme.darkGreen,
        legendItemText: '',
        dataSource: data,
        xValueMapper: (LinearSales sales, _) => sales.year,
        yValueMapper: (LinearSales sales, _) => sales.sales,
        markerSettings: MarkerSettings(isVisible: true),
        // Enable data label
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
    ];
  }

  static List<ChartSeries<LinearSales, String>> _createSugarData(
      List<SpoDatum> spo) {
    List<LinearSales> data = [];

    spo.forEach((element) {
      data.add(LinearSales(Utils.graphDate(element.date),
          double.parse(element.sugar.toString()).round()));
    });
    return <LineSeries<LinearSales, String>>[
      LineSeries<LinearSales, String>(
        enableTooltip: false,
        color: ColorTheme.darkGreen,
        legendItemText: '',
        dataSource: data,
        xValueMapper: (LinearSales sales, _) => sales.year,
        yValueMapper: (LinearSales sales, _) => sales.sales,
        markerSettings: MarkerSettings(isVisible: true),
        // Enable data label
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
    ];
  }

  static List<ChartSeries<LinearSales, String>> _createBpData(
      List<BpDatum> bp) {
    List<LinearSales> data = [];
    List<LinearSales> data1 = [];

    bp.forEach((element) {
      data.add(LinearSales(Utils.graphDate(element.date),
          double.parse(element.bp1.toString()).round()));
      data1.add(LinearSales(Utils.graphDate(element.date),
          double.parse(element.bp2.toString()).round()));
    });
    return <LineSeries<LinearSales, String>>[
      LineSeries<LinearSales, String>(
        enableTooltip: true,
        color: ColorTheme.darkRed,
        legendItemText: 'Systolic',
        dataSource: data,
        xValueMapper: (LinearSales sales, _) => sales.year,
        yValueMapper: (LinearSales sales, _) => sales.sales,
        markerSettings: MarkerSettings(isVisible: true),
        // Enable data label
        dataLabelSettings: DataLabelSettings(
          isVisible: false,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
      LineSeries<LinearSales, String>(
        enableTooltip: false,
        color: ColorTheme.darkGreen,
        legendItemText: 'Diastolic',
        dataSource: data1,
        xValueMapper: (LinearSales sales, _) => sales.year,
        yValueMapper: (LinearSales sales, _) => sales.sales,
        markerSettings: MarkerSettings(isVisible: true),
        // Enable data label
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
    ];
  }

  static List<ChartSeries<LinearSales, String>> _createParametersData(
      List<Parameter> parameters) {
    List<LinearSales> data = [];

    parameters.forEach((element) {
      data.add(LinearSales(
          Utils.parametersDate(element.testDate),
          double.parse(element.testValue.toString()).round(),
          Utils.getColorFromHex(element.colorCode)));
    });
    return <LineSeries<LinearSales, String>>[
      LineSeries<LinearSales, String>(
        enableTooltip: true,
        legendItemText: '',
        dataSource: data,
        pointColorMapper: (LinearSales data, _) => data.color,
        xValueMapper: (LinearSales sales, _) => sales.year,
        yValueMapper: (LinearSales sales, _) => sales.sales,
        markerSettings: MarkerSettings(
          isVisible: true,
        ),
        // Enable data label
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ),
    ];
  }
}

class _PointsLineChartState extends State<PointsLineChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: RotatedBox(
              quarterTurns: -45,
              child: Text(
                'Values',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'DateTime',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          ),
          SfCartesianChart(
            primaryYAxis: NumericAxis(
              interval: 20,
              labelStyle: TextStyle(
                color: Colors.black,
              ),
              //ANAMOY-TODO
              minimum: widget.minimumValue,
              maximum: widget.maximumValue,
            ),
            primaryXAxis: CategoryAxis(
              rangePadding: ChartRangePadding.none,
              majorGridLines: MajorGridLines(width: 1),
              labelPlacement: LabelPlacement.onTicks,
              labelRotation: 290,
              maximumLabels: 12,
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
            legend: Legend(
              isVisible: widget.visible,
              position: LegendPosition.bottom,
            ),
            series: widget.graphData,
          ),
        ],
      ),
    );
  }
}

/// Sample linear data type.
class LinearSales {
  final String year;
  final int sales;
  final Color color;
  LinearSales(this.year, this.sales, [this.color]);
}
