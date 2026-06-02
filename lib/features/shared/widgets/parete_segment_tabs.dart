import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Tab pill di header biru (Semua / Aktif / …) — gaya referensi pengaduan.
class PareteSegmentTabs extends StatelessWidget {
  const PareteSegmentTabs({
    required this.labels,
    required this.index,
    required this.onChanged,
    super.key,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == index;
          return Expanded(
            child: Material(
              color: selected ? AppColors.yellow : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(11),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: selected
                          ? AppColors.darkBlueText
                          : Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
