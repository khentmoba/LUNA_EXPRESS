import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'kiosk_theme.dart';
import '../../services/session.dart';
import '../../data/menu_data.dart';


class KioskCategoryBar extends StatelessWidget {
  const KioskCategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KioskSession>(
      builder: (context, session, child) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: KioskTheme.lunaCream,
            border: Border(bottom: BorderSide(color: KioskTheme.lunaBrown.withOpacity(0.05), width: 1)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: kMenuSections.length,
            itemBuilder: (context, index) {
              final section = kMenuSections[index];
              final isSelected = session.currentCategoryId == section.id;
              
              return GestureDetector(
                onTap: () => session.setCategory(section.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? KioskTheme.lunaBrown : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: KioskTheme.lunaBrown.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        section.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        section.title.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected ? KioskTheme.lunaTan : KioskTheme.lunaBrown.withOpacity(0.4),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
