import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Views/profile_view.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/Services/mission_provider_calm.dart';
import 'package:flutter_app/Services/mission_provider_fast.dart';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  _ProgressViewState createState() => _ProgressViewState();
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

  // Generate PieChart sections for Calm Bear
  List<PieChartSectionData> generateSectionsCalm(MissionsProviderCalm provider) {
    return List.generate(subjectMapping.length, (i) {
      final symbol = subjectMapping.keys.toList()[i];
      final realSubjectKey = subjectMapping[symbol] ?? symbol;
      final completedMissions =
          provider.getCompletedMissionsCount(realSubjectKey).toDouble();

      final sliceRadius = 15 + (completedMissions * 10);

      return PieChartSectionData(
        value: 1,
        color: const Color(0xffffa400),
        title: completedMissions.toInt().toString(),
        titleStyle: const TextStyle(
          fontFamily: 'Mali',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        titlePositionPercentageOffset: 1.4,
        radius: sliceRadius,
        showTitle: true,
      );
    });
  }

  // Generate PieChart sections for Fast Bee
  List<PieChartSectionData> generateSectionsFast(
      MissionsProviderFast provider) {
    return List.generate(subjectMapping.length, (i) {
      final symbol = subjectMapping.keys.toList()[i];
      final realSubjectKey = subjectMapping[symbol] ?? symbol;
      final completedMissions =
          provider.getCompletedMissionsCount(realSubjectKey).toDouble();

      final sliceRadius = 15 + (completedMissions * 10);

      return PieChartSectionData(
        value: 1,
        color: const Color(0xffffa400),
        title: completedMissions.toInt().toString(),
        titleStyle: const TextStyle(
          fontFamily: 'Mali',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        titlePositionPercentageOffset: 1.4,
        radius: sliceRadius,
        showTitle: true,
      );
    });
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
            fontFamily: 'Mali',
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.account_circle,
                size: 32,
              ),
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
                  _buildChart(
                    tr('progress.calm_bear'),
                    generateSectionsCalm(missionsProviderCalm),
                    chartSize,
                    subjectMapping.keys.toList(),
                  ),
                  _buildChart(
                    tr('progress.fast_bee'),
                    generateSectionsFast(missionsProviderFast),
                    chartSize,
                    subjectMapping.keys.toList(),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    _buildChart(
                      tr('progress.calm_bear'),
                      generateSectionsCalm(missionsProviderCalm),
                      chartSize,
                      subjectMapping.keys.toList(),
                    ),
                    _buildChart(
                      tr('progress.fast_bee'),
                      generateSectionsFast(missionsProviderFast),
                      chartSize,
                      subjectMapping.keys.toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // The chart widget using your honeycomb layout
  Widget _buildChart(String title, List<PieChartSectionData> sections, double size, List<String> subjects) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Mali',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: size,
          width: size,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 6,
                  centerSpaceRadius: size * 0.12,
                  borderData: FlBorderData(show: false),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                ),
              ),
              // Overlay ring of pictograms
              Positioned.fill(
                child: _buildSymbolRing(subjects, size),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymbolRing(List<String> subjects, double size) {
    final List<Widget> symbolWidgets = [];
    final double center = size / 2;
    final double ringRadius = size * 0.10;
    const double rotationOffset = math.pi / 8;

    for (int i = 0; i < subjects.length; i++) {
      final angle = rotationOffset + (2 * math.pi / subjects.length) * i;
      final offsetX = center + ringRadius * math.cos(angle);
      final offsetY = center + ringRadius * math.sin(angle);

      symbolWidgets.add(
        Positioned(
          left: offsetX - 9,
          top: offsetY - 10,
          child: Text(
            subjects[i],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return Stack(children: symbolWidgets);
  }
}