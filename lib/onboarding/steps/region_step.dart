import 'package:flutter/material.dart';

import '../widgets.dart';

/// UK nations and English regions.
///
/// This is the granularity UKHSA reports surveillance at, so it is the
/// smallest area the app can honestly say anything about. Asking for a full
/// postcode would imply a precision the data does not have.
const List<(String, IconData)> kUkRegions = [
  ('North East England', Icons.place_outlined),
  ('North West England', Icons.place_outlined),
  ('Yorkshire and the Humber', Icons.place_outlined),
  ('East Midlands', Icons.place_outlined),
  ('West Midlands', Icons.place_outlined),
  ('East of England', Icons.place_outlined),
  ('London', Icons.location_city_outlined),
  ('South East England', Icons.place_outlined),
  ('South West England', Icons.place_outlined),
  ('Scotland', Icons.flag_outlined),
  ('Wales', Icons.flag_outlined),
  ('Northern Ireland', Icons.flag_outlined),
];

class RegionStep extends StatelessWidget {
  const RegionStep({
    super.key,
    required this.progress,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
    this.onBack,
    this.onClose,
  });

  final double progress;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: progress,
      headline: 'Which part of the UK?',
      subtitle:
          'Illness activity is reported region by region, so this decides '
          'what counts as "near you".',
      onBack: onBack,
      onClose: onClose,
      onPrimary: selected == null ? null : onContinue,
      child: Column(
        children: [
          for (final (name, icon) in kUkRegions)
            OptionCard(
              icon: icon,
              title: name,
              selected: selected == name,
              onTap: () => onSelect(name),
            ),
          const SizedBox(height: 4),
          const SourceNote(
            text: 'Regions follow UKHSA surveillance reporting areas. You can '
                'change this later in settings.',
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
