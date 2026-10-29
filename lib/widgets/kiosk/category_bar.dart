import 'package:flutter/material.dart' hide MenuTheme;
import 'package:provider/provider.dart';
import 'menu_theme.dart';
import '../../services/session.dart';
import '../../data/menu_data.dart';

class KioskCategoryBar extends StatelessWidget {
  const KioskCategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Consumer<KioskSession>(
      builder: (context, session, child) {
        return Container(
          height: 44 * scale + 24,
          decoration: const BoxDecoration(
            color: MenuTheme.paper,
            border: Border(bottom: BorderSide(color: MenuTheme.pink, width: 2)),
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: kMenuSections.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final section = kMenuSections[index];
              final selected = session.currentCategoryId == section.id;
              return ChoiceChip(
                label: Text(section.title),
                selected: selected,
                onSelected: (_) => session.setCategory(section.id),
                selectedColor: MenuTheme.plate,
                backgroundColor: MenuTheme.card,
                checkmarkColor: MenuTheme.onPlate,
                labelStyle: MenuTheme.body(
                  size: 14,
                  color: selected ? MenuTheme.onPlate : MenuTheme.ink,
                ).copyWith(fontWeight: FontWeight.w700),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: MenuTheme.radius,
                ),
                side: BorderSide(
                  color: selected ? MenuTheme.plate : MenuTheme.pinkInk,
                  width: 1.5,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
