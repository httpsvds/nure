import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/pressable.dart';
import '../widgets/progress_bar.dart';

/// Shared chrome for every onboarding step.
///
/// One scaffold rather than per-step layouts keeps the progress bar, headline
/// rhythm and footer in exactly the same place as the user moves through, so
/// only the content appears to change.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.progress,
    required this.headline,
    required this.child,
    this.subtitle,
    this.onBack,
    this.onClose,
    this.primaryLabel = 'Continue',
    this.onPrimary,
    this.footnote,
    this.aboveButton,
    this.scrollable = true,
    this.centerHeadline = true,
  });

  final double progress;
  final String headline;
  final String? subtitle;
  final Widget child;

  final VoidCallback? onBack;
  final VoidCallback? onClose;

  final String primaryLabel;

  /// Null disables the primary button.
  final VoidCallback? onPrimary;

  final String? footnote;

  /// Pinned directly above the primary button, outside the scroll area.
  ///
  /// For anything that gates the button: a disabled action whose unlock sits
  /// below the fold reads as a broken screen.
  final Widget? aboveButton;

  /// False when [child] manages its own scrolling, e.g. a long list.
  final bool scrollable;

  final bool centerHeadline;

  @override
  Widget build(BuildContext context) {
    final align =
        centerHeadline ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    final heading = Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            headline,
            textAlign: centerHeadline ? TextAlign.center : TextAlign.start,
            style: nunito(32, 800, height: 1.12, letterSpacing: -0.9),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              textAlign: centerHeadline ? TextAlign.center : TextAlign.start,
              style: nunito(14.5, 500, color: NureColors.muted, height: 1.45),
            ),
          ],
          const SizedBox(height: 22),
        ],
      ),
    );

    final body = scrollable
        ? SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: child,
          )
        : child;

    return Scaffold(
      backgroundColor: NureColors.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(progress: progress, onBack: onBack, onClose: onClose),
            heading,
            Expanded(child: body),
            _Footer(
              primaryLabel: primaryLabel,
              onPrimary: onPrimary,
              onBack: onBack,
              footnote: footnote,
              aboveButton: aboveButton,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, this.onBack, this.onClose});

  final double progress;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          IconAction(icon: Icons.arrow_back, onPressed: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: NureProgressBar(value: progress),
            ),
          ),
          IconAction(icon: Icons.close, onPressed: onClose),
        ],
      ),
    );
  }
}

class IconAction extends StatelessWidget {
  const IconAction({super.key, required this.icon, this.onPressed});

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
          size: 25,
          color: onPressed == null
              ? NureColors.hairline
              : NureColors.ink.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.primaryLabel,
    this.onPrimary,
    this.onBack,
    this.footnote,
    this.aboveButton,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onBack;
  final String? footnote;
  final Widget? aboveButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NureColors.paper,
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (aboveButton != null) ...[
            aboveButton!,
            const SizedBox(height: 12),
          ],
          PrimaryButton(label: primaryLabel, onPressed: onPrimary),
          if (onBack != null) ...[
            const SizedBox(height: 6),
            Pressable(
              onPressed: onBack,
              scale: 0.94,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                // An Icon rather than a "←" character: Nunito has no glyph
                // for U+2190 and renders it as an empty box.
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      size: 15,
                      color: NureColors.muted,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Back',
                      style: nunito(14, 700, color: NureColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (footnote != null) ...[
            const SizedBox(height: 4),
            Text(
              footnote!,
              textAlign: TextAlign.center,
              style: nunito(11.5, 500, color: NureColors.muted, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Pressable(
      onPressed: onPressed,
      scale: 0.97,
      // Opaque when disabled rather than faded, so content cannot show
      // through it.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        height: 60,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? NureColors.sageDeep : NureColors.disabled,
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: NureColors.sageDeep.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 240),
          style: nunito(
            17,
            800,
            color: enabled ? Colors.white : NureColors.disabledInk,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

/// A selectable card: icon, title, optional blurb, and a tick or radio.
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.blurb,
    this.multi = false,
  });

  final IconData icon;
  final String title;
  final String? blurb;
  final bool selected;
  final VoidCallback? onTap;

  /// Multi-select shows a tick box; single-select shows a radio.
  final bool multi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Pressable(
        onPressed: onTap,
        scale: 0.975,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: NureColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? NureColors.sageDeep : NureColors.hairline,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3A3A38).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? NureColors.sageTrack
                      : NureColors.field,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: selected ? NureColors.sageDeep : NureColors.muted,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: nunito(16, 700)),
                    if (blurb != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        blurb!,
                        style: nunito(12.5, 500, color: NureColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SelectionIndicator(selected: selected, multi: multi),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectionIndicator extends StatelessWidget {
  const SelectionIndicator({
    super.key,
    required this.selected,
    this.multi = false,
  });

  final bool selected;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: multi ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: multi ? BorderRadius.circular(7) : null,
        color: selected && multi ? NureColors.sageDeep : Colors.transparent,
        border: Border.all(
          color: selected ? NureColors.sageDeep : const Color(0xFF8C8C88),
          width: selected ? 2 : 1.6,
        ),
      ),
      child: multi
          ? AnimatedScale(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              scale: selected ? 1 : 0,
              child: const Icon(Icons.check, size: 15, color: Colors.white),
            )
          : AnimatedScale(
              duration: const Duration(milliseconds: 220),
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

/// Small pill used where answers are short enough to sit several to a row.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onTap,
      scale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? NureColors.sageTrack : NureColors.field,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? NureColors.sageDeep : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 17,
                color: selected ? NureColors.sageDeep : NureColors.muted,
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: nunito(
                14,
                700,
                color: selected ? NureColors.sageDeep : NureColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Attribution strip. Every screen that states a health fact carries one, so
/// the source is never more than a glance away.
class SourceNote extends StatelessWidget {
  const SourceNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: NureColors.field,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_outlined,
            size: 17,
            color: NureColors.sageDeep,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: nunito(12.5, 600, color: NureColors.muted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
