import 'package:flutter/material.dart';
import 'package:flutter_app/Views/profile_view.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/mission_provider_calm.dart';
import 'package:flutter_app/mission_provider_fast.dart';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final missionsProviderCalm = Provider.of<MissionsProviderCalm>(context);
    final missionsProviderFast = Provider.of<MissionsProviderFast>(context);

    // Map chart symbols to provider keys
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

    // Subject "pictograms"
    final subjects = ["+", "-", "x", "÷", "Mix", "x²", "Seq", "%"];

    // All slices use the same color
    final List<Color> colors =
        List.generate(subjects.length, (i) => const Color(0xffffa400));

    // Generate PieChartSectionData for Calm Bear
    List<PieChartSectionData> generateSectionsCalm(
        MissionsProviderCalm provider) {
      return List.generate(subjects.length, (i) {
        final symbol = subjects[i];
        final realSubjectKey = subjectMapping[symbol] ?? symbol;
        final completedMissions =
            provider.getCompletedMissionsCount(realSubjectKey).toDouble();

        final sliceRadius = 15 + (completedMissions * 10);

        return PieChartSectionData(
          value: 1,
          color: colors[i],
          title: completedMissions.toInt().toString(),
          titleStyle: const TextStyle(
            fontFamily: 'Mali',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 50, 50, 50),
          ),
          titlePositionPercentageOffset: 1.4,
          radius: sliceRadius,
          showTitle: true,
        );
      });
    }

    // Generate PieChartSectionData for Fast Bee
    List<PieChartSectionData> generateSectionsFast(
        MissionsProviderFast provider) {
      return List.generate(subjects.length, (i) {
        final symbol = subjects[i];
        final realSubjectKey = subjectMapping[symbol] ?? symbol;
        final completedMissions =
            provider.getCompletedMissionsCount(realSubjectKey).toDouble();

        final sliceRadius = 15 + (completedMissions * 10);

        return PieChartSectionData(
          value: 1,
          color: colors[i],
          title: completedMissions.toInt().toString(),
          titleStyle: const TextStyle(
            fontFamily: 'Mali',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 50, 50, 50),
          ),
          titlePositionPercentageOffset: 1.4,
          radius: sliceRadius,
          showTitle: true,
        );
      });
    }

    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final chartSize = isLandscape ? size.width * 0.35 : size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          tr('progress.title'),
          style: const TextStyle(
            fontFamily: 'Mali',
            color: Color.fromARGB(255, 50, 50, 50),
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
                color: Color.fromARGB(255, 50, 50, 50),
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
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChart(
                  tr('progress.calm_bear'),
                  generateSectionsCalm(missionsProviderCalm),
                  chartSize,
                  subjects,
                ),
                _buildChart(
                  tr('progress.fast_bee'),
                  generateSectionsFast(missionsProviderFast),
                  chartSize,
                  subjects,
                ),
              ],
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
                      subjects,
                    ),
                    _buildChart(
                      tr('progress.fast_bee'),
                      generateSectionsFast(missionsProviderFast),
                      chartSize,
                      subjects,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // The chart widget
  Widget _buildChart(
    String title,
    List<PieChartSectionData> sections,
    double size,
    List<String> subjects,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Mali',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 50, 50, 50),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: size,
          width: size,
          child: Stack(
            children: [
              // The Piechart at the bottom
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

    // 30 degrees in radians
    const double rotationOffset = math.pi / 8;

    for (int i = 0; i < subjects.length; i++) {
      // Add rotationOffset to rotate the ring to fit the sections
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
              color: Color.fromARGB(255, 50, 50, 50),
            ),
          ),
        ),
      );
    }
    return Stack(children: symbolWidgets);
  }
}