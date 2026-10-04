/// A country or territory offered in onboarding.
class Country {
  const Country(this.code, this.name);

  /// ISO 3166-1 alpha-2, uppercase. Doubles as the flag asset key.
  final String code;

  /// English display name.
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Country && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$code ($name)';
}
