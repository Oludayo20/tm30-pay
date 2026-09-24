import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tm30_pay/core/error/failure.dart';
import 'package:tm30_pay/core/widgets/responsive.dart';
import 'package:tm30_pay/core/widgets/state_views.dart';
import 'package:tm30_pay/features/wallet/domain/transaction.dart';
import 'package:tm30_pay/features/wallet/domain/wallet_repository.dart';
import 'package:tm30_pay/features/wallet/presentation/bloc/transaction_detail/transaction_detail_bloc.dart';
import 'package:tm30_pay/features/wallet/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/status_chip.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/transaction_formatting.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({
    super.key,
    required this.transactionId,
    this.initial,
  });

  final String transactionId;

  /// Set when the user tapped a row in the list. Null when the app was
  /// opened from a deep link.
  final Transaction? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionDetailBloc(
        repository: context.read<WalletRepository>(),
        transactionId: transactionId,
        initial:
            initial ??
            context.read<WalletBloc>().state.findTransaction(transactionId),
      )..add(const TransactionDetailRequested()),
      child: const TransactionDetailView(),
    );
  }
}

class TransactionDetailView extends StatelessWidget {
  const TransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction details')),
      body: BlocBuilder<TransactionDetailBloc, TransactionDetailState>(
        builder: (context, state) {
          return switch (state.status) {
            TransactionDetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            TransactionDetailStatus.failure => switch (state.failure!) {
              NotFoundFailure() => const MessageView(
                icon: Icons.search_off_rounded,
                title: 'Transaction not found',
                message: 'It may have been removed, or the link is wrong.',
              ),
              final failure => MessageView.error(
                message: failure.message,
                onRetry: () => context.read<TransactionDetailBloc>().add(
                  const TransactionDetailRequested(),
                ),
              ),
            },
            TransactionDetailStatus.ready => _Details(state.transaction!),
          };
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = transaction;

    return SingleChildScrollView(
      child: ResponsiveCenter(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              t.formattedAmount,
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Center(child: StatusChip(t.status)),
            const SizedBox(height: 32),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _Row('Description', t.title),
                    _Row('Type', t.isCredit ? 'Money in' : 'Money out'),
                    _Row('Date', t.longDate),
                    if (t.counterpartyAccount != null)
                      _Row('Account number', t.counterpartyAccount!),
                    if (t.note != null) _Row('Note', t.note!),
                    _Row('Reference', t.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
