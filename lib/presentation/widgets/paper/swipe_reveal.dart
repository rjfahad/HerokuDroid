import 'package:flutter/material.dart';

import 'package:herokudroid/core/theme/paper_tokens.dart';

/// A single trailing action revealed by [SwipeReveal].
class RevealAction {
  const RevealAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;
}

/// Wraps a card so it can be dragged left to reveal trailing actions,
/// matching the mockup's "Swipe a card for Rename · Delete" affordance.
class SwipeReveal extends StatefulWidget {
  const SwipeReveal({
    super.key,
    required this.child,
    required this.actions,
    this.actionWidth = 78,
  });

  final Widget child;
  final List<RevealAction> actions;
  final double actionWidth;

  @override
  State<SwipeReveal> createState() => _SwipeRevealState();
}

class _SwipeRevealState extends State<SwipeReveal> {
  double _offset = 0;
  bool _dragging = false;

  double get _maxOffset => widget.actions.length * widget.actionWidth;

  void _settle() {
    final shouldOpen = _offset < -_maxOffset / 2;
    setState(() => _offset = shouldOpen ? -_maxOffset : 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isEmpty) return widget.child;

    return ClipRRect(
      borderRadius: BorderRadius.circular(PaperTokens.rCard),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final action in widget.actions)
                    _ActionButton(
                      action: action,
                      width: widget.actionWidth,
                      onTap: () {
                        setState(() => _offset = 0);
                        action.onTap();
                      },
                    ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onHorizontalDragStart: _maxOffset == 0
                ? null
                : (_) => _dragging = true,
            onHorizontalDragUpdate: _maxOffset == 0
                ? null
                : (details) {
                    setState(() {
                      _offset = (_offset + details.delta.dx).clamp(
                        -_maxOffset,
                        0.0,
                      );
                    });
                  },
            onHorizontalDragEnd: _maxOffset == 0
                ? null
                : (_) {
                    _dragging = false;
                    _settle();
                  },
            child: AnimatedContainer(
              duration: _dragging
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(_offset, 0, 0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.action,
    required this.width,
    required this.onTap,
  });

  final RevealAction action;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: action.background,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.color, size: 20),
              const SizedBox(height: 4),
              Text(
                action.label,
                style: TextStyle(
                  color: action.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
