import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostCategoryPieChart extends StatefulWidget {
  const PostCategoryPieChart({super.key});

  @override
  State<PostCategoryPieChart> createState() => _PostCategoryPieChartState();
}

class _PostCategoryPieChartState extends State<PostCategoryPieChart> {
  Map<String, int> categoryData = {}; // Stores category names and their counts
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPostCategories();
  }

  Future<void> _fetchPostCategories() async {
    try {
      final response =
          await Supabase.instance.client.from('posts').select('category');

      final List<dynamic> data = response;

      final Map<String, int> distribution = {};

      for (var entry in data) {
        // Retrieve the category and group announcements
        String category = entry['category'] ?? 'Unknown';
        if (category.contains('Announcement')) {
          category = 'Announcement';
        }

        if (!distribution.containsKey(category)) {
          distribution[category] = 0;
        }
        distribution[category] = distribution[category]! + 1;
      }

      if (mounted) {
        setState(() {
          categoryData = distribution;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        debugPrint('Error fetching post categories: $e');
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
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: categoryData.entries.map((entry) {
                          final category = entry.key;
                          final count = entry.value;

                          return PieChartSectionData(
                            title: '$category\n$count',
                            value: count.toDouble(),
                            color: _getCategoryColor(category),
                            radius: 150,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Assign a unique color to each category
  Color _getCategoryColor(String category) {
    final List<Color> colors = [
      Colors.red,
      const Color.fromARGB(255, 7, 128, 11),
      Colors.orange,
      const Color.fromARGB(255, 1, 78, 140),
      Colors.purple,
      const Color.fromARGB(255, 221, 199, 0),
      const Color.fromARGB(255, 1, 97, 109),
      Colors.pink,
      const Color.fromARGB(255, 1, 113, 102),
    ];

    return colors[categoryData.keys.toList().indexOf(category) % colors.length];
  }
}
