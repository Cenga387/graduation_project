import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserGrowthChart extends StatefulWidget {
  const UserGrowthChart({super.key});

  @override
  State<UserGrowthChart> createState() => _UserGrowthChartState();
}

class _UserGrowthChartState extends State<UserGrowthChart> {
  List<FlSpot> userGrowthData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserGrowthData();
  }

  Future<void> _fetchUserGrowthData() async {
    try {
      final response = await Supabase.instance.client
        .from('profile')
        .select('created_at');

      // Process data
      Map<DateTime, int> userCountByDate = {};
      for (var user in response) {
        DateTime createdAt = DateTime.parse(user['created_at']);
        DateTime key = DateTime(createdAt.year, createdAt.month, createdAt.day);
        userCountByDate[key] = (userCountByDate[key] ?? 0) + 1;
      }

      // Convert to cumulative growth
      List<FlSpot> spots = [];
      int cumulativeCount = 0;
      List<DateTime> sortedDates = userCountByDate.keys.toList()..sort();
      for (var date in sortedDates) {
        cumulativeCount += userCountByDate[date]!;
        spots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), cumulativeCount.toDouble()));
      }

      setState(() {
        userGrowthData = spots;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user growth data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles( sideTitles: SideTitles(showTitles: true, interval: 1)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                        DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Text(
                          style: const TextStyle(fontSize: 10),
                          "${date.month}/${date.day}");
                      }),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: userGrowthData,
                      isCurved: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                      color: const Color(0xFF005597),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
