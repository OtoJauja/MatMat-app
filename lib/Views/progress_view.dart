import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/mission_provider_calm.dart';
import 'package:flutter_app/mission_provider_fast.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final missionsProviderCalm = Provider.of<MissionsProviderCalm>(context);
    final missionsProviderFast = Provider.of<MissionsProviderFast>(context);

    final subjects = [
      "Addition",
      "Subtraction",
      "Multiplication",
      "Division",
      "Mixed operations",
      "Exponentiation",
      "Sequences",
      "Percentages"
    ];

    final List<Color> colors = [
      const Color(0xffffa400),
      const Color(0xffffa400),
      const Color(0xffffa400),
      const Color(0xffffa400),
      const Color(0xffffa400),
      const Color(0xffffa400),
      const Color(0xffffa400),
      const Color(0xffffa400)
    ];

    // Function to generate sections for a given provider
    List<PieChartSectionData> generateSectionsCalm(
        MissionsProviderCalm provider) {
      return List.generate(subjects.length, (i) {
        final subject = subjects[i];
        final completedMissions =
            provider.getCompletedMissionsCount(subject).toDouble();

        return PieChartSectionData(
          value: 1,
          color: colors[i],
          title: "${subjects[i]}\n${completedMissions.toInt()}",
          radius: 15 + (completedMissions * 20),
          titleStyle: GoogleFonts.mali(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 50, 50, 50),
          ),
          showTitle: true,
          titlePositionPercentageOffset: 2,
        );
      });
    }

    // Function to generate sections for a given provider
    List<PieChartSectionData> generateSectionsFast(
        MissionsProviderFast provider) {
      return List.generate(subjects.length, (i) {
        final subject = subjects[i];
        final completedMissions =
            provider.getCompletedMissionsCount(subject).toDouble();

        return PieChartSectionData(
          value: 1,
          color: colors[i],
          title: "${subjects[i]}\n${completedMissions.toInt()}",
          radius: 15 + (completedMissions * 20),
          titleStyle: GoogleFonts.mali(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 50, 50, 50),
          ),
          showTitle: true,
          titlePositionPercentageOffset: 2,
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
          'Progress',
          style: GoogleFonts.mali(
            color: const Color.fromARGB(255, 50, 50, 50),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: isLandscape
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChart("Calm Bear",
                    generateSectionsCalm(missionsProviderCalm), chartSize),
                _buildChart("Fast Bee",
                    generateSectionsFast(missionsProviderFast), chartSize),
              ],
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildChart("Calm Bear",
                        generateSectionsCalm(missionsProviderCalm), chartSize),
                    _buildChart("Fast Bee",
                        generateSectionsFast(missionsProviderFast), chartSize),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildChart(
      String title, List<PieChartSectionData> sections, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.mali(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 50, 50, 50),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: size,
          width: size,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 6,
              centerSpaceRadius: size * 0.15,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}
