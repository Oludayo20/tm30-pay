# wallet/presentation/widgets/

The pieces the home and detail screens are built from.

| File | What it does |
|---|---|
| `home_header.dart` | Avatar (opens settings), time-based greeting, first name, and a settings button. |
| `balance_card.dart` | Branded gradient card: balance with a hide/show toggle, tappable account number chip (copies it), and "Updated h:mm". |
| `quick_actions.dart` | Send (solid brand blue) and Receive (tonal). Only actions that work are shown. |
| `receive_money_sheet.dart` | Bottom sheet with the details someone needs to pay this wallet (name, bank, account number), plus a copy button. |
| `transaction_groups.dart` | `groupByDay()` turns a newest-first list into day headers and rows, noting which rows start and end each day. `dayLabel()` returns "Today", "Yesterday", "Tue, 22 Sep" or "31 Dec 2025". |
| `transaction_tile.dart` | One row: category icon, title, time, status (shown only when pending or failed), and the signed amount. The amount of a failed transaction is crossed out. |
| `transaction_formatting.dart` | Display extensions: signed amount, time and date formats, category icon, and status label and colour. |
| `status_chip.dart` | The coloured "Successful / Pending / Failed" pill used on the detail screen. |
| `wallet_status_banner.dart` | Offline or "couldn't refresh" banner with Retry, or "Updating…" while cached data is being refreshed. |
| `list_footer.dart` | End of the list: spinner while the next page loads, "tap to retry" if it failed, or "You're all caught up". |
| `wallet_skeleton.dart` | Pulsing placeholder rows shown during the first load, shaped like real rows. |
