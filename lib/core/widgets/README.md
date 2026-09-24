# lib/core/widgets/

Reusable widgets with no knowledge of any feature.

| File | What it does |
|---|---|
| `app_text_field.dart` | `AppTextField`: a `TextField` that also reports when it loses focus (`onBlur`). Form blocs use this to start showing a field's errors only after the user has left it. |
| `state_views.dart` | `MessageView`: a centred icon, title, message and optional action, used for empty states. `MessageView.error(...)` is the standard error view with a Retry button. |
| `responsive.dart` | `kMaxContentWidth` (640), `horizontalGutter()` and `ResponsiveCenter`: they keep content centred and readable on tablets and in landscape. |
| `button_progress.dart` | The small spinner shown inside a disabled button while its action runs. |
| `copy_to_clipboard.dart` | `copyToClipboard(context, text:, label:)` copies the text and confirms with a snackbar, e.g. "Account number copied". |
