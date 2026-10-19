import 'package:flutter/material.dart';

import 'package:herokudroid/core/theme/paper_colors.dart';
import 'package:herokudroid/core/theme/paper_tokens.dart';

/// Rounded paper surface with a hairline border. Used everywhere a card is
/// drawn in Design B.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PaperTokens.l),
    this.onTap,
    this.borderColor,
    this.radius = PaperTokens.rCard,
    this.width,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double radius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final shaped = Container(
      width: width,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? c.line),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    return shaped;
  }
}

enum PaperTagVariant { success, error, warning, accent, neutral }

/// Small pill status/level badge.
class PaperTag extends StatelessWidget {
  const PaperTag({
    super.key,
    required this.label,
    this.variant = PaperTagVariant.neutral,
    this.dot = false,
  });

  final String label;
  final PaperTagVariant variant;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final (bg, fg) = switch (variant) {
      PaperTagVariant.success => (c.successSoft, c.success),
      PaperTagVariant.error => (c.errorSoft, c.error),
      PaperTagVariant.warning => (c.warningSoft, c.warning),
      PaperTagVariant.accent => (c.accentSoft, c.accent),
      PaperTagVariant.neutral => (c.line, c.muted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PaperTokens.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

enum PaperButtonVariant { ink, accent, outline, destructive }

enum PaperButtonSize { regular, small }

/// Pill button. The `ink` variant is the default primary action; `accent`
/// is used for the single hero call-to-action on a screen.
class PaperButton extends StatelessWidget {
  const PaperButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PaperButtonVariant.ink,
    this.size = PaperButtonSize.regular,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PaperButtonVariant variant;
  final PaperButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final (bg, fg, border) = switch (variant) {
      PaperButtonVariant.ink => (c.ink, c.background, null),
      PaperButtonVariant.accent => (c.accent, Colors.white, null),
      PaperButtonVariant.outline => (
        Colors.transparent,
        c.ink,
        c.line,
      ),
      PaperButtonVariant.destructive => (c.errorSoft, c.error, null),
    };

    final isSmall = size == PaperButtonSize.small;
    final enabled = onPressed != null && !loading;

    final button = ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg.withValues(alpha: 0.45),
        disabledForegroundColor: fg.withValues(alpha: 0.6),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: isSmall ? const Size(0, 34) : const Size(0, 48),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 13 : PaperTokens.l + 2,
          vertical: isSmall ? 0 : PaperTokens.m + 1,
        ),
        side: border == null ? BorderSide.none : BorderSide(color: border),
        textStyle: TextStyle(
          fontSize: isSmall ? 12 : 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PaperTokens.rPill),
        ),
      ),
      child: loading
          ? SizedBox(
              width: isSmall ? 14 : 18,
              height: isSmall ? 14 : 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fg),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: isSmall ? 14 : 18),
                  const SizedBox(width: 6),
                ],
                Text(label),
              ],
            ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// Circular, hairline-bordered icon button (the mockup's `.ib`).
class PaperIconButton extends StatelessWidget {
  const PaperIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 38,
    this.tooltip,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    final button = Material(
      color: filled ? c.ink : c.card,
      shape: CircleBorder(side: BorderSide(color: filled ? c.ink : c.line)),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.47,
            color: filled ? c.background : c.ink,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Selectable filter chip.
class PaperChip extends StatelessWidget {
  const PaperChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.accentSoft : c.card,
          borderRadius: BorderRadius.circular(PaperTokens.rPill),
          border: Border.all(color: selected ? c.accent : c.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? c.accent : c.muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Uppercase section label (the mockup's `.cap`).
class PaperCaption extends StatelessWidget {
  const PaperCaption(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: PaperText.caption.copyWith(color: color ?? context.paper.muted),
    );
  }
}

/// Small status dot with an optional glow.
class PaperStatusDot extends StatelessWidget {
  const PaperStatusDot({
    super.key,
    required this.color,
    this.size = 8,
    this.glow = false,
  });

  final Color color;
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: glow
            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4)]
            : null,
      ),
    );
  }
}

/// A themed text field with a leading/suffix affordance slot.
class PaperTextField extends StatelessWidget {
  const PaperTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.autofocus = false,
    this.uppercase = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffix;
  final bool autofocus;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final c = context.paper;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      autofocus: autofocus,
      textCapitalization:
          uppercase ? TextCapitalization.characters : TextCapitalization.none,
      style: PaperText.body.copyWith(color: c.ink),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffix,
        prefixIconColor: c.muted,
        suffixIconColor: c.muted,
      ),
    );
  }
}
