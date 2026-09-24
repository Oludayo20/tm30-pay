# lib/core/

Code shared by every feature. Nothing here imports from `features/`.

| Folder | Purpose |
|---|---|
| `error/` | Typed failures, the `Result` type, data-layer exceptions and the `guard()` helper that converts one into the other. |
| `theme/` | Material 3 theme seeded from Tm30 blue, plus the status colours. |
| `utils/` | Small helpers with no Flutter UI: money handling, fake latency, ids, greeting. |
| `widgets/` | Reusable, feature-agnostic widgets. |
