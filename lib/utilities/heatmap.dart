import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef DayTapCallback = void Function(DateTime day, int count);

class CalendarHeatMap extends StatelessWidget {
  final Map<DateTime, int> input; // normalized Date => count
  final Map<int, Color> colorThresholds; // e.g. {1: light, 3: mid, 5: dark}
  final double squareSize;
  final double spacing;
  final int numDays; // how many days back from today to show
  final DayTapCallback? onDayTap;
  final bool showWeekdayLabels;

  const CalendarHeatMap({
    Key? key,
    required this.input,
    required this.colorThresholds,
    this.squareSize = 16,
    this.spacing = 4,
    this.numDays = 365,
    this.onDayTap,
    this.showWeekdayLabels = false,
  }) : super(key: key);

  Color _colorForCount(int count, ThemeData theme) {
    if (count <= 0) return Colors.grey.shade200;
    final keys = colorThresholds.keys.toList()..sort();
    Color color = colorThresholds[keys.first] ?? theme.colorScheme.primary;
    for (final k in keys) {
      if (count >= k) color = colorThresholds[k]!;
    }
    return color;
  }

  // normalize a DateTime to only date part (no time)
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = _normalize(DateTime.now());
    final requestedStart = _normalize(today.subtract(Duration(days: numDays - 1)));

    // Align start to Sunday (so weeks start on Sunday). Dart: Monday=1..Sunday=7
    final int weekdayIndex = requestedStart.weekday % 7; // Sunday -> 0
    final start = requestedStart.subtract(Duration(days: weekdayIndex));

    final totalDays = today.difference(start).inDays + 1;
    final weeks = ((totalDays) / 7).ceil();

    // Build grid of weeks (columns) each with 7 day slots
    final List<List<DateTime?>> columns = List.generate(weeks, (w) {
      return List.generate(7, (d) {
        final day = start.add(Duration(days: w * 7 + d));
        if (day.isAfter(today)) return null; // future
        return day;
      });
    });

    Widget buildCell(DateTime? day) {
      if (day == null) {
        return SizedBox(
          width: squareSize,
          height: squareSize,
        );
      }
      final norm = _normalize(day);
      final count = input[norm] ?? 0;
      final color = _colorForCount(count, theme);
      return GestureDetector(
        onTap: () {
          if (onDayTap != null) onDayTap!(norm, count);
        },
        child: Container(
          width: squareSize,
          height: squareSize,
          margin: EdgeInsets.only(bottom: spacing),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.transparent),
          ),
        ),
      );
    }

    // optional weekday labels (S M T W T F S)
    final weekdayLabels = showWeekdayLabels
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(7, (i) {
              const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
              return SizedBox(
                  height: squareSize + spacing,
                  child: Center(child: Text(labels[i], style: TextStyle(fontSize: 10))));
            }),
          )
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (weekdayLabels != null) Padding(padding: EdgeInsets.only(right: 6), child: weekdayLabels),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: columns.map((col) {
                return Padding(
                  padding: EdgeInsets.only(right: spacing),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: col.map((day) => buildCell(day)).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}


