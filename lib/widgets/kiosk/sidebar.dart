import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'kiosk_theme.dart';
import '../../services/session.dart';
import '../../data/menu_data.dart';

class KioskSidebar extends StatelessWidget {
  const KioskSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KioskSession>(
      builder: (context, session, child) {
        return Container(
          width: 120,
          decoration: BoxDecoration(
            color: KioskTheme.lunaCream,
            border: Border(right: BorderSide(color: KioskTheme.lunaBrown.withOpacity(0.05), width: 1)),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: kMenuSections.length,
            itemBuilder: (context, index) {
              final section = kMenuSections[index];
              final isSelected = session.currentCategoryId == section.id;

              return GestureDetector(
                onTap: () => session.setCategory(section.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? KioskTheme.lunaBrown : Colors.transparent,
                    borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
                    boxShadow: isSelected ? KioskTheme.shadowPrimary : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        section.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? KioskTheme.textOnPrimary : KioskTheme.textMuted,
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
