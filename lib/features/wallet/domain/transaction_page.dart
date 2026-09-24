import 'package:equatable/equatable.dart';

import 'transaction.dart';

/// One page of transactions from cursor-based pagination.
///
/// This uses a cursor ("give me the items after this id") rather than an
/// offset ("skip 40"). When a new transfer is added to the top of the list,
/// an offset would shift every page by one and repeat an item, but a cursor
/// stays correct.
class TransactionPage extends Equatable {
  const TransactionPage({required this.items, required this.nextCursor});

  final List<Transaction> items;

  /// Pass this to get the next page. It is null on the last page.
  final String? nextCursor;

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [items, nextCursor];
}
