import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassFormKit {
  static const double kBlur = 18;
  static const double kFieldFill = 0.12;
  static const double kCardFill = 0.12;

  static const TextStyle kLabelStyle = TextStyle(
    color: Colors.white70,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle kHintStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );

  static InputDecoration decoration(
    BuildContext context, {
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      label: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      labelStyle: kLabelStyle,
      floatingLabelStyle: kLabelStyle.copyWith(fontSize: 12),

      hint: (hint == null || hint.trim().isEmpty)
          ? null
          : Text(
              hint,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: kHintStyle,
            ),

      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, color: Colors.white70, size: 18),
      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white.withOpacity(kFieldFill),

      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.42)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.85)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.95)),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
    );
  }
}

class GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<dynamic>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const GlassInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters?.cast<TextInputFormatter>(),
      decoration: GlassFormKit.decoration(
        context,
        label: label,
        hint: hint,
        prefixIcon: icon,
      ),
    );
  }
}

class GlassTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final int minLines;
  final int maxLines;

  const GlassTextArea({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.minLines = 4,
    this.maxLines = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      decoration: GlassFormKit.decoration(
        context,
        label: label,
        hint: hint,
        prefixIcon: Icons.notes_outlined,
      ).copyWith(alignLabelWithHint: true),
    );
  }
}

class GlassDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final bool enabled;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? icon;

  const GlassDropdownField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    this.enabled = true,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      hint: (hint == null || hint!.trim().isEmpty)
          ? null
          : Text(
              hint!,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: GlassFormKit.kHintStyle,
            ),
      items: items,
      dropdownColor: const Color(0xFF0E1B2A).withOpacity(0.96),
      iconEnabledColor: Colors.white70,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: GlassFormKit.decoration(
        context,
        label: label,
        hint: hint,
        prefixIcon: icon,
      ),
    );
  }
}

class GlassCardSection extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const GlassCardSection({super.key, required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassFormKit.kBlur,
          sigmaY: GlassFormKit.kBlur,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(GlassFormKit.kCardFill),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (borderColor ?? Colors.white.withOpacity(0.25)),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;

  final TextInputType? keyboardType;
  final List<dynamic>? inputFormatters;
  final String? Function(String?)? validator;

  final int maxLines;
  final bool enabled;
  final bool obscureText;
  final int? maxLength;

  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  final Widget? suffixIcon;

  const GlassInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.obscureText = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      obscureText: obscureText,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters?.cast<TextInputFormatter>(),
      decoration:
          GlassFormKit.decoration(
            context,
            label: label,
            hint: hint,
            prefixIcon: icon,
            suffixIcon: suffixIcon,
          ).copyWith(
            counterStyle: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 11,
            ),
          ),
    );
  }
}

class GlassTextAreaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;

  final String? Function(String?)? validator;
  final int minLines;
  final int maxLines;

  final bool enabled;
  final int? maxLength;
  final void Function(String)? onChanged;

  const GlassTextAreaField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.validator,
    this.minLines = 4,
    this.maxLines = 8,
    this.enabled = true,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      minLines: minLines,
      maxLines: maxLines,
      enabled: enabled,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      decoration:
          GlassFormKit.decoration(
            context,
            label: label,
            hint: hint,
            prefixIcon: icon ?? Icons.notes_outlined,
          ).copyWith(
            alignLabelWithHint: true,
            counterStyle: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 11,
            ),
          ),
    );
  }
}

class GlassOptionsGrid extends StatefulWidget {
  final String label;
  final String? hint;

  final List<String> options;
  final Set<String> selectedValues;
  final String Function(String key)? optionLabel;

  final ValueChanged<Set<String>> onChanged;

  final bool enableSearch;
  final String searchHint;

  final int minCrossAxisCount;
  final double chipHeight;

  const GlassOptionsGrid({
    super.key,
    required this.label,
    this.hint,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.optionLabel,
    this.enableSearch = false,
    this.searchHint = 'Rechercher…',
    this.minCrossAxisCount = 2,
    this.chipHeight = 44,
  });

  @override
  State<GlassOptionsGrid> createState() => _GlassOptionsGridState();
}

class _GlassOptionsGridState extends State<GlassOptionsGrid> {
  String _q = '';

  String _labelOf(String k) =>
      (widget.optionLabel != null) ? widget.optionLabel!(k) : k;

  List<String> get _filtered {
    final q = _q.trim().toLowerCase();
    if (!widget.enableSearch || q.isEmpty) return widget.options;
    return widget.options
        .where((k) => _labelOf(k).toLowerCase().contains(q))
        .toList();
  }

  void _toggle(String k) {
    final next = Set<String>.from(widget.selectedValues);
    if (next.contains(k)) {
      next.remove(k);
    } else {
      next.add(k);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    final w = MediaQuery.of(context).size.width;
    final cross = (w >= 720)
        ? 4
        : (w >= 520)
        ? 3
        : widget.minCrossAxisCount;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassFormKit.kBlur,
          sigmaY: GlassFormKit.kBlur,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(GlassFormKit.kCardFill),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.selectedValues.length}/${widget.options.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              if (widget.hint != null && widget.hint!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.hint!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
              if (widget.enableSearch) ...[
                const SizedBox(height: 12),
                _GlassSearchField(
                  hint: widget.searchHint,
                  onChanged: (v) => setState(() => _q = v),
                ),
              ],
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: (w >= 520) ? 3.2 : 2.7,
                ),
                itemBuilder: (ctx, i) {
                  final k = filtered[i];
                  final selected = widget.selectedValues.contains(k);

                  return _GlassChip(
                    height: widget.chipHeight,
                    selected: selected,
                    text: _labelOf(k).replaceAll('_', ' '),
                    onTap: () => _toggle(k),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final bool selected;
  final String text;
  final VoidCallback onTap;
  final double height;

  const _GlassChip({
    required this.selected,
    required this.text,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(selected ? 0.40 : 0.32);
    final br = Colors.white.withOpacity(selected ? 0.70 : 0.45);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: br, width: 1.1),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? Colors.white : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _GlassSearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GlassFormKit.kHintStyle,
        prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(GlassFormKit.kFieldFill),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.42)),
        ),
      ),
    );
  }
}
