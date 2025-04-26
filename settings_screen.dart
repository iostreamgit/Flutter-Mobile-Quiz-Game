import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../screens/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final Map<String, Locale> supportedLanguages = {
      'English': const Locale('en'),
      'Français': const Locale('fr'),
      'العربية': const Locale('ar'),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(localizations.darkMode),
            value: settings.isDarkMode,
            onChanged: notifier.toggleDarkMode,
          ),
          SwitchListTile(
            title: Text(localizations.soundEffects),
            value: settings.soundEnabled,
            onChanged: notifier.toggleSound,
          ),
          SwitchListTile(
            title: Text(localizations.notifications),
            value: settings.notificationsEnabled,
            onChanged: notifier.toggleNotifications,
          ),
          ListTile(
            title: Text(localizations.language),
            trailing: DropdownButton<Locale>(
              value: settings.locale,
              items: supportedLanguages.entries
                  .map((entry) => DropdownMenuItem<Locale>(
                        value: entry.value,
                        child: Text(entry.key),
                      ))
                  .toList(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  notifier.setLocale(newLocale);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}