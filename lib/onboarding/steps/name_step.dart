import 'package:flutter/material.dart';

import '../../theme.dart';
import '../widgets.dart';

class NameStep extends StatefulWidget {
  const NameStep({
    super.key,
    required this.progress,
    required this.initial,
    required this.onChanged,
    required this.onContinue,
    this.onBack,
    this.onClose,
  });

  final double progress;
  final String initial;
  final ValueChanged<String> onChanged;
  final VoidCallback onContinue;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      progress: widget.progress,
      headline: 'What should we\ncall you?',
      subtitle: 'Only used to address you inside the app.',
      onBack: widget.onBack,
      onClose: widget.onClose,
      // Skippable on purpose: a name is a courtesy, not a requirement, and
      // blocking on it would be the first thing the app got wrong.
      primaryLabel: _controller.text.trim().isEmpty ? 'Skip for now' : 'Continue',
      onPrimary: widget.onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name', style: nunito(13, 700, color: NureColors.muted)),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autocorrect: false,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => widget.onContinue(),
            onChanged: (v) {
              widget.onChanged(v);
              setState(() {}); // Swaps the button label between skip and go.
            },
            style: nunito(17, 700),
            cursorColor: NureColors.sageDeep,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: nunito(17, 500, color: NureColors.muted),
              filled: true,
              fillColor: NureColors.field,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                borderSide:
                    const BorderSide(color: NureColors.sageDeep, width: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const SourceNote(
            text: 'nure does not ask for medical records, NHS numbers or date '
                'of birth. Nothing you enter here identifies you to anyone.',
          ),
        ],
      ),
    );
  }
}
