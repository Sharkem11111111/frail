import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/fitness_models.dart';



class RankCard extends StatelessWidget {
  final FitnessRank rank;
  final bool isCurrentRank;
  final bool isAchieved;

  const RankCard({
    super.key,
    required this.rank,
    required this.isCurrentRank,
    required this.isAchieved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentRank ? rank.color.withOpacity(0.1) : null,
        border: isCurrentRank ? Border.all(color: rank.color, width: 2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: rank.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(
            rank.iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isAchieved ? rank.color : Colors.grey,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          rank.displayName,
          style: TextStyle(
            fontWeight: isCurrentRank ? FontWeight.bold : FontWeight.normal,
            color: isAchieved ? rank.color : Colors.grey,
          ),
        ),
        trailing: isCurrentRank
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rank.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'CURRENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : isAchieved
                ? Icon(Icons.check, color: rank.color)
                : Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }
}
