import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:herokudroid/core/constants/theme_constants.dart';

/// Skeleton loading widget for app cards
class AppCardSkeleton extends StatelessWidget {
  const AppCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Bone.text(words: 2)),
                const SizedBox(width: 12),
                Bone.button(width: 72, height: 22),
              ],
            ),
            const SizedBox(height: 10),
            Bone.text(words: 3, fontSize: 12),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 6 ? 0 : 3),
                    child: Bone(height: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading widget for config var items
class ConfigVarSkeleton extends StatelessWidget {
  const ConfigVarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingXs,
      ),
      child: ListTile(
        title: Bone.text(words: 2),
        subtitle: Bone.text(words: 3),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Bone.iconButton(),
            const SizedBox(width: ThemeConstants.spacingXs),
            Bone.iconButton(),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading widget for addon cards
class AddonSkeleton extends StatelessWidget {
  const AddonSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Bone.square(size: 40),
                const SizedBox(width: ThemeConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.text(words: 2),
                      const SizedBox(height: ThemeConstants.spacingXs),
                      Bone.text(words: 1, fontSize: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            Bone.text(words: 4),
            const SizedBox(height: ThemeConstants.spacingXs),
            Bone.text(words: 2, fontSize: 12),
            const SizedBox(height: ThemeConstants.spacingM),
            Row(
              children: [
                Bone.button(width: 120),
                const SizedBox(width: ThemeConstants.spacingS),
                Bone.button(width: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading widget for dyno items
class DynoSkeleton extends StatelessWidget {
  const DynoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingM,
        vertical: ThemeConstants.spacingS,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Bone.icon(),
                const SizedBox(width: ThemeConstants.spacingS),
                Expanded(child: Bone.text(words: 1)),
                Bone.button(width: 80),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingS),
            Bone.text(words: 4, fontSize: 12),
            const SizedBox(height: ThemeConstants.spacingXs),
            Bone.text(words: 3, fontSize: 12),
          ],
        ),
      ),
    );
  }
}
