import 'package:flutter/material.dart' hide MenuTheme;
import 'package:provider/provider.dart';
import 'menu_theme.dart';
import '../../services/session.dart';
import '../../data/menu_data.dart';

class KioskSidebar extends StatelessWidget {
  const KioskSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KioskSession>(
      builder: (context, session, child) {
        return Container(
          width: 216,
          decoration: const BoxDecoration(
            color: MenuTheme.board,
            border: Border(right: BorderSide(color: MenuTheme.line)),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                child: Text('THE MENU', style: MenuTheme.heading(32)),
              ),
              for (final section in kMenuSections)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      selected: session.currentCategoryId == section.id,
                      selectedTileColor: MenuTheme.accent,
                      selectedColor: MenuTheme.cream,
                      textColor: MenuTheme.tan,
                      iconColor: MenuTheme.tan,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: Icon(
                        MenuTheme.categoryIcon(section.id),
                        size: 22,
                      ),
                      minLeadingWidth: 22,
                      title: Text(
                        section.title.toUpperCase(),
                        style: MenuTheme.body(
                          size: 15,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      shape: const RoundedRectangleBorder(),
                      onTap: () => session.setCategory(section.id),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
