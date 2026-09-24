# test/

65 tests, organised to mirror `lib/`. Run them with `flutter test`.

| Folder | Purpose |
|---|---|
| `helpers/` | Shared mocks and fixtures. |
| `core/` | Unit tests for `lib/core`. |
| `features/` | Unit, bloc (`bloc_test`) and widget tests for each feature. |

Conventions: repositories and blocs are mocked with `mocktail` (`MockBloc` from `bloc_test`). The fake APIs run with `FakeLatency.none()`. Async ordering (double taps, stale pages) is controlled with `Completer`s instead of timers.
