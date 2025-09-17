import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../register_screen/model/register_models.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class UserProfileScreen extends StatelessWidget {
  final RegisterModels user;
  const UserProfileScreen({required this.user, super.key});

  Future<Map<DateTime, int>> _getUserContributions() async {
    final snap = await FirebaseFirestore.instance
        .collection("articles")
        .where("authorId", isEqualTo: user.uid)
        .get();

    final contributions = <DateTime, int>{};
    for (var doc in snap.docs) {
      if (doc["createdAt"] != null) {
        final date = (doc["createdAt"] as Timestamp).toDate();
        final day = DateTime(date.year, date.month, date.day);
        contributions[day] = (contributions[day] ?? 0) + 1;
      }
    }

    if (contributions.isEmpty) {
      final now = DateTime.now();
      contributions[now] = 1;
      contributions[now.subtract(const Duration(days: 2))] = 2;
      contributions[now.subtract(const Duration(days: 5))] = 4;
    }

    return contributions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.username)),
      body: FutureBuilder<Map<DateTime, int>>(
        future: _getUserContributions(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!;
          print("Heatmap data: $data");

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(user.email),
                const SizedBox(height: 20),
                const Text("Posting Frequency",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                
           Expanded(
  child: HeatMap(
    datasets: data,
    colorMode: ColorMode.color,
    scrollable: true,
    showColorTip: true, // shows legend
    defaultColor: Colors.grey.shade200,
    size: 16,
    onClick: (date) {
      final count = data[date] ?? 0;

      // Show a formal AlertDialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Post Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade900,
            ),
          ),
          content: Text(
            "Date: ${date.day}-${date.month}-${date.year}\nPosts: $count",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    },
    colorsets: {
      1: Colors.green.shade100,
      3: Colors.green.shade400,
      5: Colors.green.shade700,
    },
  ),
),  ],
            ),
          );
        },
      ),
    );
  }
}