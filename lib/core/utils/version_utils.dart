/// Helpers for comparing semantic-ish version strings like `1.2.3`,
/// `v1.2`, `1.2.3+4` or `1.2.3-beta.1`.
library;

/// Compares [a] and [b], returning a negative number if [a] is older, zero if
/// they are equal, and a positive number if [a] is newer.
///
/// A leading `v` and any `-prerelease` / `+build` suffix are ignored, and
/// missing trailing components are treated as zero (`1.2` == `1.2.0`).
int compareVersions(String a, String b) {
  final partsA = _parse(a);
  final partsB = _parse(b);
  final length = partsA.length > partsB.length ? partsA.length : partsB.length;

  for (var i = 0; i < length; i++) {
    final valueA = i < partsA.length ? partsA[i] : 0;
    final valueB = i < partsB.length ? partsB[i] : 0;
    if (valueA != valueB) return valueA.compareTo(valueB);
  }
  return 0;
}

/// Whether [candidate] is a strictly newer version than [current].
bool isNewerVersion(String candidate, String current) =>
    compareVersions(candidate, current) > 0;

List<int> _parse(String version) {
  var cleaned = version.trim();
  if (cleaned.startsWith('v') || cleaned.startsWith('V')) {
    cleaned = cleaned.substring(1);
  }

  // Drop pre-release (-beta) and build metadata (+4) suffixes.
  final cut = cleaned.indexOf(RegExp(r'[+\-]'));
  if (cut >= 0) cleaned = cleaned.substring(0, cut);

  return cleaned
      .split('.')
      .map((part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList();
}
