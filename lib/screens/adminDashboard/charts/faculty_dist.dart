import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FacultyDistributionWidget extends StatefulWidget {
  const FacultyDistributionWidget({super.key});

  @override
  State<FacultyDistributionWidget> createState() =>
      _FacultyDistributionWidgetState();
}

class _FacultyDistributionWidgetState extends State<FacultyDistributionWidget> {
  Map<String, int> facultyData = {}; // Faculty name and user count
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFacultyDistribution();
  }

  Future<void> _fetchFacultyDistribution() async {
    try {
      final response =
          await Supabase.instance.client.from('profile').select('faculty');

      // Parse the data
      final List<dynamic> data = response;
      final Map<String, int> distribution = {};

      for (var entry in data) {
        final faculty = entry['faculty'] ?? 'Unknown';

        if (!distribution.containsKey(faculty)) {
          distribution[faculty] = 0;
        }
        distribution[faculty] = distribution[faculty]! + 1;
      }

      if (mounted) {
        setState(() {
          facultyData = distribution;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        debugPrint('Error fetching faculty distribution data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        interval: 1,
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 16),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 ||
                              value.toInt() >= facultyData.keys.length) {
                            return const Text('');
                          }
                          final facultyList = facultyData.keys.toList();
                          return Text(
                            facultyList[value.toInt()],
                            style: const TextStyle(fontSize: 16),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: facultyData.entries.map((entry) {
                    final index = facultyData.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: const Color(0xFF005597),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  maxY: facultyData.values
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble(), // Set the Y-axis max value
                ),
              ),
            ),
    );
  }
}
