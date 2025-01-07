import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: currentLocale.languageCode,
              items: [
                DropdownMenuItem(
                  value: 'tr',
                  child: Text('Türkçe'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
              ],
              onChanged: (String? languageCode) {
                if (languageCode != null) {
                  ref.read(localeProvider.notifier).setLocale(languageCode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
