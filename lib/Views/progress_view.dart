import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Views/profile_view.dart';
import 'package:flutter_app/Services/mission_provider_calm.dart';
import 'package:flutter_app/Services/mission_provider_fast.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:easy_localization/easy_localization.dart';

/// Class for each wedge
class ChartData {
  final String subject;
  final double value;
  final Color color;
  ChartData(this.subject, this.value, this.color);
}

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  final List<String> subjects = [
    "Addition",
    "Subtraction",
    "Multiplication",
    "Division",
    "Mixed operations",
    "Exponentiation",
    "Percentages",
    "Sequences",
  ];

  // Mapping from chart symbols to provider keys
  final Map<String, String> subjectMapping = {
    "+": "Addition",
    "-": "Subtraction",
    "x": "Multiplication",
    "÷": "Division",
    "Mix": "Mixed operations",
    "x²": "Exponentiation",
    "Seq": "Sequences",
    "%": "Percentages",
  };

  // A color palette for each subject
  final List<Color> chartColors = [
    const Color(0xffffa400),
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final calmProvider =
        Provider.of<MissionsProviderCalm>(context, listen: false);
    for (var subject in subjects) {
      calmProvider.loadSavedProgress(userId, subject);
    }
    final fastProvider =
        Provider.of<MissionsProviderFast>(context, listen: false);
    for (var subject in subjects) {
      fastProvider.loadSavedProgress(userId, subject);
    }
  }

  /// Build chart data for Calm Bear
  List<ChartData> buildChartDataCalm(MissionsProviderCalm provider) {
    final List<ChartData> data = [];
    final keys = subjectMapping.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      final symbol = keys[i];
      final realSubject = subjectMapping[symbol] ?? symbol;
      final completed =
          provider.getCompletedMissionsCount(realSubject).toDouble();
      data.add(
        ChartData(symbol, completed, chartColors[i % chartColors.length]),
      );
    }
    return data;
  }

  /// Build chart data for Fast Bee
  List<ChartData> buildChartDataFast(MissionsProviderFast provider) {
    final List<ChartData> data = [];
    final keys = subjectMapping.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      final symbol = keys[i];
      final realSubject = subjectMapping[symbol] ?? symbol;
      final completed =
          provider.getCompletedMissionsCount(realSubject).toDouble();
      data.add(
        ChartData(symbol, completed, chartColors[i % chartColors.length]),
      );
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final chartSize = isLandscape ? size.width * 0.35 : size.width * 0.8;

    final missionsProviderCalm = Provider.of<MissionsProviderCalm>(context);
    final missionsProviderFast = Provider.of<MissionsProviderFast>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          tr('progress.title'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.account_circle, size: 32),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileView()),
                );
              },
            ),
          ),
        ],
      ),
      body: isLandscape
          ? SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRoseChart(
                    tr('progress.calm_bear'),
                    buildChartDataCalm(missionsProviderCalm),
                    chartSize,
                  ),
                  _buildRoseChart(
                    tr('progress.fast_bee'),
                    buildChartDataFast(missionsProviderFast),
                    chartSize,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    _buildRoseChart(
                      tr('progress.calm_bear'),
                      buildChartDataCalm(missionsProviderCalm),
                      chartSize,
                    ),
                    _buildRoseChart(
                      tr('progress.fast_bee'),
                      buildChartDataFast(missionsProviderFast),
                      chartSize,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Builds a rose chart donut using DoughnutSeries and pointRadiusMapper
  Widget _buildRoseChart(String title, List<ChartData> data, double size) {
  double maxVal = data.map((d) => d.value).fold(0, math.max);
  if (maxVal == 0) maxVal = 1; // Avoid division by zero

  const double minPercent = 30;  // smallest wedge outer radius
  const double maxPercent = 80;  // largest wedge outer radius
  const String innerRadius = '35%'; // hole size

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              SfCircularChart(
                margin: const EdgeInsets.all(10),
                series: <CircularSeries>[
                  DoughnutSeries<ChartData, String>(
                    dataSource: data,
                    // Each slice gets the same angle by using a constant yValue
                    yValueMapper: (ChartData item, _) => 1,
                    xValueMapper: (ChartData item, _) => item.subject,
                    pointColorMapper: (ChartData item, _) => item.color,
                    innerRadius: innerRadius,
                    pointRadiusMapper: (ChartData item, _) {
                      final ratio = item.value / maxVal;
                      final double scaled =
                          minPercent + ratio * (maxPercent - minPercent);
                      return '${scaled.toStringAsFixed(1)}%';
                    },
                    dataLabelMapper: (ChartData item, _) =>
                        '${item.value.toStringAsFixed(0)}',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      connectorLineSettings: ConnectorLineSettings(
                        type: ConnectorType.curve,
                        length: '20%',
                      ),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              _buildSymbolOverlay(data, size, innerRadius),
            ],
          ),
        ),
      ),
    ],
  );
}
Widget _buildSymbolOverlay(List<ChartData> data, double size, String innerRadiusStr) {
  final double innerRadiusPercent = double.tryParse(innerRadiusStr.replaceAll('%', '')) ?? 35;
  // The inner circle radius in pixels
  final double innerRadiusPixels = (size / 2) * (innerRadiusPercent / 150);

  return Positioned.fill(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        final n = data.length;
        return Stack(
          children: List.generate(n, (i) {
            final double angle = -math.pi / 2 + (2 * math.pi / n) * i + (math.pi / n);
            // Positions the symbols at the inner circle edge
            final Offset offset = center + Offset(
              innerRadiusPixels * math.cos(angle),
              innerRadiusPixels * math.sin(angle),
            );
            return Positioned(
              left: offset.dx - 6, // Offsets to center the text
              top: offset.dy - 10,
              child: Text(
                data[i].subject,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }),
        );
      },
    ),
  );
}
}
