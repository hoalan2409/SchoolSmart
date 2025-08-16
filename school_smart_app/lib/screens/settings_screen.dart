import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Settings
          _buildSectionHeader(context, AppLocalizations.of(context)!.language),
          _buildLanguageSettings(context),
          
          const SizedBox(height: 24),
          
          // Theme Settings
          _buildSectionHeader(context, AppLocalizations.of(context)!.theme),
          _buildThemeSettings(context),
          
          const SizedBox(height: 24),
          
          // App Info
          _buildSectionHeader(context, AppLocalizations.of(context)!.about),
          _buildAppInfo(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildLanguageSettings(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Card(
          child: Column(
            children: [
              ...languageProvider.getSupportedLanguages().map((language) {
                final isSelected = languageProvider.currentLocale.languageCode == language['code'];
                return RadioListTile<String>(
                  title: Text(language['nativeName']!),
                  subtitle: Text(language['name']!),
                  value: language['code']!,
                  groupValue: languageProvider.currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      languageProvider.changeLanguage(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${AppLocalizations.of(context)!.language} changed to ${language['nativeName']}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  secondary: isSelected 
                    ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                    : null,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: Text(AppLocalizations.of(context)!.light),
            value: 'light',
            groupValue: 'light', // TODO: Implement theme provider
            onChanged: (value) {
              // TODO: Implement theme change
            },
          ),
          RadioListTile<String>(
            title: Text(AppLocalizations.of(context)!.dark),
            value: 'dark',
            groupValue: 'light', // TODO: Implement theme provider
            onChanged: (value) {
              // TODO: Implement theme change
            },
          ),
          RadioListTile<String>(
            title: Text(AppLocalizations.of(context)!.system),
            value: 'system',
            groupValue: 'light', // TODO: Implement theme provider
            onChanged: (value) {
              // TODO: Implement theme change
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context)!.version),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text(AppLocalizations.of(context)!.help),
            onTap: () {
              // TODO: Navigate to help screen
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text(AppLocalizations.of(context)!.privacyPolicy),
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text(AppLocalizations.of(context)!.termsOfService),
            onTap: () {
              // TODO: Navigate to terms of service
            },
          ),
        ],
      ),
    );
  }
}
