import 'country.dart';

/// Why someone is here. Drives what the app surfaces first.
enum Motivation {
  stayInformed('Stay informed', 'Know what is going around locally'),
  protectSomeone('Protect someone', 'Someone close to me is vulnerable'),
  travelling('I travel', 'Check activity in places I visit'),
  unwellNow('I am unwell now', 'I think I have caught something');

  const Motivation(this.label, this.blurb);

  final String label;
  final String blurb;
}

/// Who the user is looking out for.
///
/// This maps onto the "who is most at risk" content on each disease page, so
/// the answer changes which risk notes get pulled to the top rather than
/// being a vanity question.
enum Household {
  justMe('Just me', 'Only my own health'),
  youngChildren('Young children', 'Under-fives at home or school'),
  olderAdult('An older adult', 'Someone over 65'),
  pregnancy('Someone pregnant', 'Pregnancy changes the risk picture'),
  immunocompromised('Someone immunocompromised', 'Weakened immune system');

  const Household(this.label, this.blurb);

  final String label;
  final String blurb;
}

/// Everything onboarding collects.
///
/// Deliberately a plain value object: onboarding should not know how it will
/// be stored. Persisting it to Supabase is a separate concern, done once at
/// the end of the flow.
class OnboardingAnswers {
  OnboardingAnswers();

  Country? country;

  /// UK nation or English region. Coverage is UK-only for now, so this is the
  /// granularity live activity data is reported at.
  String? region;

  String name = '';

  final Set<Motivation> motivations = {};
  final Set<Household> household = {};

  /// Whether to warn when activity rises nearby. The feature itself comes
  /// later; capturing the intent now avoids asking again.
  bool? wantsAlerts;

  /// The user has read what nure is and is not. Required to finish.
  bool acceptedScope = false;

  String get displayName => name.trim().isEmpty ? 'there' : name.trim();

  Map<String, dynamic> toJson() => {
        'country': country?.code,
        'region': region,
        'name': name.trim(),
        'motivations': motivations.map((m) => m.name).toList(),
        'household': household.map((h) => h.name).toList(),
        'wants_alerts': wantsAlerts,
        'accepted_scope': acceptedScope,
      };
}
