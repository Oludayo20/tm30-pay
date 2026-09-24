import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tm30_pay/app/routes.dart';
import 'package:tm30_pay/core/widgets/responsive.dart';
import 'package:tm30_pay/core/widgets/state_views.dart';
import 'package:tm30_pay/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:tm30_pay/features/wallet/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/balance_card.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/home_header.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/list_footer.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/quick_actions.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/receive_money_sheet.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/transaction_groups.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/transaction_tile.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/wallet_skeleton.dart';
import 'package:tm30_pay/features/wallet/presentation/widgets/wallet_status_banner.dart';

/// The home screen: header, balance card, quick actions and the
/// transaction history grouped by day.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key, this.clock = DateTime.now});

  /// Can be replaced in tests so "Today" and the greeting are predictable.
  final DateTime Function() clock;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  /// Ask for the next page when the user is this close to the bottom, so it
  /// has usually loaded before they reach it.
  static const _loadMoreThreshold = 400.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      // This listener fires on every scroll frame. That's fine: the bloc
      // ignores the event while a page is already loading, or when there
      // are no more pages.
      context.read<WalletBloc>().add(const WalletNextPageRequested());
    }
  }

  Future<void> _refresh() async {
    final bloc = context.read<WalletBloc>()
      ..add(const WalletRefreshRequested());
    // RefreshIndicator keeps spinning until this future completes, which is
    // when the refresh has finished (whether it succeeded or failed).
    await bloc.stream.firstWhere((s) => s.status != WalletStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);
    final now = widget.clock();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            void retry() =>
                context.read<WalletBloc>().add(const WalletRefreshRequested());

            return LayoutBuilder(
              builder: (context, constraints) {
                final gutter = horizontalGutter(constraints.maxWidth);
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    controller: _scrollController,
                    // Lets pull-to-refresh work even when the list is too
                    // short to scroll, such as in the empty and error states.
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 0),
                        sliver: SliverList.list(
                          children: [
                            HomeHeader(
                              user: user,
                              now: now,
                              onOpenSettings: () =>
                                  context.push(AppRoutes.settings),
                            ),
                            const SizedBox(height: 20),
                            BalanceCard(
                              balance: state.balance,
                              accountNumber: user?.walletAccountNumber,
                              asOf: state.isFromCache ? null : state.asOf,
                            ),
                            const SizedBox(height: 16),
                            QuickActions(
                              onSend: () => context.push(AppRoutes.sendMoney),
                              onReceive: user == null
                                  ? () {}
                                  : () => showReceiveMoneySheet(context, user),
                            ),
                            const SizedBox(height: 16),
                            WalletStatusBanner(state: state, onRetry: retry),
                            const _SectionTitle('Transactions'),
                          ],
                        ),
                      ),
                      ..._buildList(context, state, gutter, now, retry),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildList(
    BuildContext context,
    WalletState state,
    double gutter,
    DateTime now,
    VoidCallback retry,
  ) {
    final padding = EdgeInsets.symmetric(horizontal: gutter);

    if (!state.hasData) {
      if (state.status == WalletStatus.failure) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: MessageView.error(
              key: const Key('wallet_error'),
              message: state.failure!.message,
              onRetry: retry,
            ),
          ),
        ];
      }
      return [
        SliverPadding(
          padding: padding,
          sliver: const SliverToBoxAdapter(
            child: _GroupCard(first: true, last: true, child: WalletSkeleton()),
          ),
        ),
      ];
    }

    if (state.transactions.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MessageView(
            key: Key('wallet_empty'),
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            message: 'Money you send or receive will show up here.',
          ),
        ),
      ];
    }

    final items = groupByDay(state.transactions, now: now);
    return [
      SliverPadding(
        padding: padding,
        sliver: SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => switch (items[index]) {
            DayHeaderItem(:final label) => _DayHeader(label),
            TransactionItem(
              :final transaction,
              :final isFirstInDay,
              :final isLastInDay,
            ) =>
              _GroupCard(
                key: ValueKey(transaction.id),
                first: isFirstInDay,
                last: isLastInDay,
                child: TransactionTile(
                  transaction: transaction,
                  onTap: () => context.push(
                    AppRoutes.transactionDetail(transaction.id),
                    extra: transaction,
                  ),
                ),
              ),
          },
        ),
      ),
      SliverToBoxAdapter(
        child: ListFooter(
          state: state,
          onRetry: () =>
              context.read<WalletBloc>().add(const WalletNextPageRequested()),
        ),
      ),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// One slice of a day's rounded card. Rows are separate list items (so the
/// list stays lazy), so each slice rounds only the corners it owns and draws
/// a divider under itself unless it is the last row of the day.
class _GroupCard extends StatelessWidget {
  const _GroupCard({
    super.key,
    required this.first,
    required this.last,
    required this.child,
  });

  final bool first;
  final bool last;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const radius = Radius.circular(20);
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: first ? radius : Radius.zero,
        bottom: last ? radius : Radius.zero,
      ),
      child: Material(
        color: scheme.surfaceContainerLow,
        child: Column(
          children: [
            child,
            if (!last)
              Divider(
                height: 1,
                indent: 74,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
