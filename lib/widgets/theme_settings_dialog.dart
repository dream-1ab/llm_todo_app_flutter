import 'package:flutter/cupertino.dart';
import 'package:hello_flutter_llm/providers/app_state.dart';
import 'package:provider/provider.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';

class ThemeSettingsDialog extends StatelessWidget {
  const ThemeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'UKIJ',
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: AppTheme.presets.map((theme) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _ThemePreviewButton(theme: theme),
                    );
                  }).toList(),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey5,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePreviewButton extends StatelessWidget {
  final AppTheme theme;

  const _ThemePreviewButton({
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<AppState>().theme;
    final isSelected = currentTheme.name == theme.name;

    return GestureDetector(
      onTap: () {
        context.read<AppState>().setTheme(theme);
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.accentColor : CupertinoColors.systemGrey5,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      theme.name,
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Preview',
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 60,
              decoration: BoxDecoration(
                color: theme.accentColor,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(11),
                ),
              ),
              child: Center(
                child: Icon(
                  isSelected ? CupertinoIcons.checkmark_alt : CupertinoIcons.chevron_right,
                  color: theme.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 