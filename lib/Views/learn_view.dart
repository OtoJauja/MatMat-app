import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:flutter_app/Views/profile_view.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnView extends StatelessWidget {
  const LearnView({super.key});

  Widget _buildHexagonGrid(
      BuildContext context, List<Map<String, dynamic>> topics) {
    final orientation = MediaQuery.of(context).orientation;
    final columns = orientation == Orientation.portrait ? 2 : 5;
    final rows = (topics.length / columns).ceil();

    return SingleChildScrollView(
      child: HexagonOffsetGrid.oddFlat(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          columns: columns,
          rows: rows,
          buildTile: (col, row) {
            final topicIndex = row * columns + col;
            if (topicIndex >= topics.length) {
              // If there is no topic for this tile, return an empty hexagon.
              return HexagonWidgetBuilder(
                color: Theme.of(context).colorScheme.surface,
                child: Container(),
              );
            }

            final topic = topics[topicIndex];

            return HexagonWidgetBuilder(
              padding: 4.0,
              cornerRadius: 24.0,
              color: const Color(0xffffee9ae),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipsView(
                          topicTitle: topic['title'],
                          topicSubtitle: topic['subtitle'],
                          tips: topic['tips'],
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      topic['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 40, 40, 40),
                      fontSize: 14),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define topics using translation keys
    final List<Map<String, dynamic>> topics = [
      {
        'title': tr('learn.x_times_y'),
        'subtitle': tr('learn.multiplication'),
        'tips': [
          {
            'name': tr('learn.tip1.name'),
            'url': 'https://www.boredteachers.com/post/multiplication-tricks'
          },
          {
            'name': tr('learn.tip2.name'),
            'url': 'https://www.youtube.com/watch?v=eW2dRLyoyds&t=159s'
          },
          {
            'name': tr('learn.tip3.name'),
            'url':
                'https://cf.ltkcdn.net/home-school/files/4425-times-tables-1-to-20.pdf'
          },
        ],
      },
      {
        'title': tr('learn.x_divide_y'),
        'subtitle': tr('learn.division'),
        'tips': [
          {
            'name': tr('learn.tip4.name'),
            'url': 'https://www.youtube.com/watch?v=rGMecZ_aERo'
          },
          {
            'name': tr('learn.tip5.name'),
            'url':
                'https://suncatcherstudio.com/uploads/printables/math/division-charts/pdf-png/printable-division-chart-filled-in-1-10-portrait-2288ee-44aaff.pdf'
          },
        ],
      },
      {
        'title': tr('learn.sequences'),
        'subtitle': tr('learn.sequences_subtitle'),
        'tips': [
          {
            'name': tr('learn.tip6.name'),
            'url': 'https://www.youtube.com/watch?v=tfU1tNf_65s'
          },
          {
            'name': tr('learn.tip7.name'),
            'url': 'https://www.youtube.com/watch?v=xtvJwaYfXss&t=1s'
          },
        ],
      },
      {
        'title': tr('learn.exponentiation'),
        'subtitle': tr('learn.exponentiation_subtitle'),
        'tips': [
          {
            'name': tr('learn.tip8.name'),
            'url':
                'https://countontricia.com/2019/06/how-to-teach-exponents-to-beginners.html'
          },
          {
            'name': tr('learn.tip9.name'),
            'url': 'https://www.youtube.com/watch?v=XZRQhkii0h0'
          },
          {
            'name': tr('learn.tip10.name'),
            'url': 'https://www.k8worksheets.com/pdfs/square-root/charts-4.pdf'
          },
          {
            'name': tr('learn.tip11.name'),
            'url':
                'https://math-drills.com/numbersense/cubes_and_cube_roots_001.1360994964.pdf'
          },
        ],
      },
      {
        'title': tr('learn.percentages'),
        'subtitle': tr('learn.percentages_subtitle'),
        'tips': [
          {
            'name': tr('learn.tip12.name'),
            'url': 'https://byjus.com/maths/percentage/'
          },
          {
            'name': tr('learn.tip13.name'),
            'url':
                'https://www.smartboardingschool.com/_files/ugd/e99b9e_3d29122850c042189b087d1ca64e8999.pdf?index=true'
          },
          {
            'name': tr('learn.tip14.name'),
            'url': 'https://www.mathsisfun.com/percentage.html'
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          tr('learn.title'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
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
      body: _buildHexagonGrid(context, topics),
    );
  }
}

class TipsView extends StatelessWidget {
  final String topicTitle;
  final String topicSubtitle;
  final List<dynamic> tips;

  const TipsView({
    super.key,
    required this.topicTitle,
    required this.topicSubtitle,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          topicTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: tips.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final tip = tips[index];
          return ListTile(
            title: Text(
              tip['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              final url = Uri.parse(tip['url']);
              if (await canLaunchUrl(url)) {
                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        tr('learn.could_not_open_link', args: [tip['url']])),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
