# bloc/transaction_detail/: TransactionDetailBloc

| File | What it does |
|---|---|
| `transaction_detail_bloc.dart` | Starts `ready` when the transaction is already known (the user tapped a row), so no request is made. Otherwise, for example from a deep link, it fetches by id. `droppable()` prevents repeated fetches. |
| `transaction_detail_event.dart` | `TransactionDetailRequested`: load, or retry. |
| `transaction_detail_state.dart` | Status (loading, ready or failure), the transaction and the failure. |
