import 'package:flutter/material.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';

class SummaryView extends StatelessWidget {
  const SummaryView({
    super.key,
    required this.summary,
  });

  final Macros summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          child: Text(
            "Macros Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: double.maxFinite,
          height: 80,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _SummaryBlock(
                  key: const ValueKey("calories"),
                  amount: summary.calories,
                  title: "Calories",
                ),
                _SummaryBlock(
                  key: const ValueKey("protein"),
                  amount: summary.protein,
                  title: "Protein",
                ),
                _SummaryBlock(
                  key: const ValueKey("fat"),
                  amount: summary.fats,
                  title: "Fat",
                ),
                _SummaryBlock(
                  key: const ValueKey("carbs"),
                  amount: summary.carbs,
                  title: "Carbs",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({
    super.key,
    required this.amount,
    required this.title,
  });

  final double amount;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 45),
        child: Column(
          children: [
            Text(
              "$amount",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
