# lib/core/utils/

Plain Dart helpers. They have no widgets, so they are easy to unit test.

| File | What it does |
|---|---|
| `money.dart` | `Money.format(kobo)` turns 25000000 into `₦250,000.00`. `Money.tryParse('1,500.50')` turns what the user typed into 150050 kobo, or returns null if it is not a valid amount. Money is always an `int` in kobo, never a `double`. |
| `fake_latency.dart` | `FakeLatency`: a random 600–1200 ms delay awaited by the fake APIs. `FakeLatency.none()` makes tests run instantly. |
| `id_generator.dart` | `randomId()` makes a random 128-bit hex id, used as a transfer idempotency key. `IdGenerator` is the matching function type, so tests can inject predictable ids. |
| `greeting.dart` | `greetingFor(time)` returns "Good morning", "Good afternoon" or "Good evening" for the home header. |
