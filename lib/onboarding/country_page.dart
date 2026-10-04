import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/pressable.dart';
import '../widgets/progress_bar.dart';
import 'countries.dart';
import 'country.dart';

/// First onboarding step: where is the user?
///
/// The selected country is also pinned above the list, so the answer stays
/// visible no matter how far down the 258 entries you have scrolled.
class CountryPage extends StatefulWidget {
  const CountryPage({
    super.key,
    this.progress = 0.15,
    this.selected,
    this.onSelected,
    this.onContinue,
    this.onBack,
    this.onClose,
  });

  final double progress;

  /// Held by the flow rather than this page, so going back and forward keeps
  /// the answer.
  final Country? selected;
  final ValueChanged<Country>? onSelected;

  final VoidCallback? onContinue;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();

  List<Country> _results = kCountries;

  @override
  void initState() {
    super.initState();
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search
      ..removeListener(_applyFilter)
      ..dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _search.text.trim().toLowerCase();

    final next = query.isEmpty
        ? kCountries
        : kCountries.where((c) {
            return c.name.toLowerCase().contains(query) ||
                c.code.toLowerCase() == query;
          }).toList(growable: false);

    // Ranking a prefix match above a mid-word one keeps "ind" showing India
    // before British Indian Ocean Territory.
    if (query.isNotEmpty) {
      final ranked = [...next]..sort((a, b) {
          final aStarts = a.name.toLowerCase().startsWith(query);
          final bStarts = b.name.toLowerCase().startsWith(query);
          if (aStarts != bStarts) return aStarts ? -1 : 1;
          return a.name.compareTo(b.name);
        });
      setState(() => _results = ranked);
    } else {
      setState(() => _results = next);
    }

    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _select(Country country) {
    if (widget.selected == country) return;
    widget.onSelected?.call(country);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;

    return Scaffold(
      backgroundColor: NureColors.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              progress: widget.progress,
              onBack: widget.onBack,
              onClose: widget.onClose,
            ),
            const _Heading(),
            _SearchField(controller: _search),
            if (selected != null) _PinnedSelection(country: selected),
            Expanded(
              child: Stack(
                children: [
                  if (_results.isEmpty)
                    const _NoResults()
                  else
                  ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                    itemCount: _results.length,
                    itemExtent: _CountryTile.extent,
                    itemBuilder: (context, i) {
                      final country = _results[i];
                      return _CountryTile(
                        country: country,
                        selected: country == selected,
                        onTap: () => _select(country),
                      );
                    },
                  ),
                  // The button sits on solid paper with a gradient above it,
                  // rather than floating over the list on a partial fade —
                  // otherwise rows show through behind it.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const IgnorePointer(
                          child: SizedBox(
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00FFFFFF),
                                    NureColors.paper,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        ColoredBox(
                          color: NureColors.paper,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              24 + MediaQuery.paddingOf(context).bottom,
                            ),
                            child: _ContinueButton(
                              enabled: selected != null,
                              onPressed:
                                  selected == null ? null : widget.onContinue,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _Header extends StatelessWidget {
  const _Header({required this.progress, this.onBack, this.onClose});

  final double progress;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _IconButton(icon: Icons.arrow_back, onPressed: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: NureProgressBar(value: progress),
            ),
          ),
          _IconButton(icon: Icons.close, onPressed: onClose),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      scale: 0.82,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          icon,
          size: 26,
          color: onPressed == null ? NureColors.muted : NureColors.ink,
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where are you?', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 12),
          Text(
            'nure shows what is spreading where you are. Live activity data '
            'is UK-only for now, so pick the United Kingdom for the full '
            'experience.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            style: nunito(16, 600),
            cursorColor: NureColors.sageDeep,
            decoration: InputDecoration(
              hintText: 'Search country',
              hintStyle: nunito(16, 500, color: NureColors.muted),
              prefixIcon: const Icon(
                Icons.search,
                size: 22,
                color: NureColors.muted,
              ),
              suffixIcon: value.text.isEmpty
                  ? null
                  : Pressable(
                      onPressed: controller.clear,
                      scale: 0.8,
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: NureColors.muted,
                      ),
                    ),
              filled: true,
              fillColor: NureColors.field,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: NureColors.sageDeep,
                  width: 1.6,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const Icon(Icons.travel_explore_outlined,
              size: 40, color: NureColors.muted),
          const SizedBox(height: 12),
          Text('No countries match that search',
              style: nunito(15, 600, color: NureColors.muted)),
        ],
      ),
    );
  }
}

/// Keeps the current answer on screen above the scrolling list.
class _PinnedSelection extends StatelessWidget {
  const _PinnedSelection({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: TweenAnimationBuilder<double>(
        key: ValueKey(country.code),
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        builder: (context, t, child) => Transform.scale(
          scale: 0.96 + (0.04 * t.clamp(0.0, 1.2)),
          child: child,
        ),
        child: _CountryTile(
          country: country,
          selected: true,
          onTap: null,
          margin: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.selected,
    required this.onTap,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  /// Fixed row height lets the 258-row list use `itemExtent`, so scrolling
  /// does not have to measure every row.
  static const double extent = 72;

  final Country country;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Pressable(
        onPressed: onTap,
        scale: 0.975,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: extent - margin.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: NureColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? NureColors.sageDeep : NureColors.hairline,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3A3A38).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipOval(
                child: CountryFlag.fromCountryCode(
                  country.code,
                  theme: const ImageTheme(
                    shape: Circle(),
                    width: 34,
                    height: 34,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  country.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: nunito(16.5, 700),
                ),
              ),
              const SizedBox(width: 8),
              _Radio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? NureColors.sageDeep : const Color(0xFF8C8C88),
          width: selected ? 2 : 1.6,
        ),
      ),
      // A separate inner dot that grows from nothing, so the ring stays thin
      // and the fill reads as a dot rather than a thickened donut.
      child: AnimatedScale(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutBack,
        scale: selected ? 1 : 0,
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: NureColors.sageDeep,
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.enabled, this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      scale: 0.97,
      // Deliberately opaque when disabled. Fading the whole button with
      // opacity let the list scroll visibly through it.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? NureColors.sageDeep : NureColors.disabled,
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: NureColors.sageDeep.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: nunito(
            17.5,
            800,
            color: enabled ? Colors.white : NureColors.disabledInk,
          ),
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
