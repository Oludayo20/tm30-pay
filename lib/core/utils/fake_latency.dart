import 'dart:math';

/// Adds a random delay to calls to the fake backend. Tests pass in
/// [FakeLatency.none] so they run instantly.
class FakeLatency {
  const FakeLatency({this.min = 600, this.max = 1200, this.random});

  const FakeLatency.none() : min = 0, max = 0, random = null;

  final int min;
  final int max;
  final Random? random;

  Future<void> call() {
    if (max <= 0) return Future.value();
    final spread = max - min;
    final ms =
        min + (spread > 0 ? (random ?? Random()).nextInt(spread + 1) : 0);
    return Future.delayed(Duration(milliseconds: ms));
  }
}
