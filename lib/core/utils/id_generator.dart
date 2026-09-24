import 'dart:math';

typedef IdGenerator = String Function();

final Random _random = Random.secure();

/// A random 128-bit id in hex, used as an idempotency key. Tests pass in
/// their own generator so the key is predictable.
String randomId() => List.generate(
  16,
  (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();
