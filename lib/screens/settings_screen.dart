import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Logging rules'),
            _RuleText('• Weeks run Monday through Sunday.'),
            _RuleText('• You can log for the current week only.'),
            _RuleText(
              '• The previous week locks at midnight between Sunday and Monday.',
            ),
            _RuleText(
              '• Weekly summaries appear the first time you open the app on Monday.',
            ),
            _RuleText('• Future dates cannot be logged.'),
            SizedBox(height: 16),
            _SectionTitle('Habit rules'),
            _RuleText('• Build habits count only when logged.'),
            _RuleText('• Avoid habits count as clean only when logged.'),
            _RuleText('• Missing a past avoid day counts as a slip.'),
            _RuleText('• Paused habits do not count against your streaks.'),
            SizedBox(height: 16),
            _SectionTitle('About'),
            _RuleText('Habit Tracker'),
            _RuleText('Version: TBD'),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RuleText extends StatelessWidget {
  final String text;

  const _RuleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text),
    );
  }
}