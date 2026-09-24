import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tm30_pay/features/transfer/presentation/validation_messages.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/button_progress.dart';
import '../../../../core/widgets/responsive.dart';
import '../../../wallet/domain/wallet_repository.dart';
import '../../../wallet/presentation/bloc/wallet/wallet_bloc.dart';
import '../../domain/transfer_validators.dart';
import '../bloc/transfer_bloc.dart';
import '../widgets/confirm_transfer_sheet.dart';
import '../widgets/transfer_success_view.dart';

class SendMoneyPage extends StatelessWidget {
  const SendMoneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TransferBloc(repository: context.read<WalletRepository>()),
      child: const SendMoneyView(),
    );
  }
}

class SendMoneyView extends StatelessWidget {
  const SendMoneyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransferBloc, TransferState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) async {
        if (state.status != TransferStatus.confirming) return;

        final bloc = context.read<TransferBloc>();

        final confirmed = await showConfirmTransferSheet(context, state);

        bloc.add(
          confirmed
              ? const TransferConfirmed()
              : const TransferReviewCancelled(),
        );
      },
      builder: (context, state) {
        return PopScope(
          canPop: state.status != TransferStatus.submitting,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Send money',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              automaticallyImplyLeading: state.status != TransferStatus.success,
            ),
            body: SafeArea(
              child: state.status == TransferStatus.success
                  ? TransferSuccessView(
                      receipt: state.receipt!,
                      recipientName: state.recipientName.trim(),
                      onDone: () => context.pop(),
                    )
                  : const _TransferForm(),
            ),
          ),
        );
      },
    );
  }
}

class _TransferForm extends StatelessWidget {
  const _TransferForm();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TransferBloc>();
    final theme = Theme.of(context);

    final balance = context.select((WalletBloc b) => b.state.balance);

    final state = context.select((TransferBloc bloc) => bloc.state);

    final enabled = !state.isLocked;

    void changed(TransferField field, String value) {
      bloc.add(TransferFieldChanged(field, value));
    }

    void blurred(TransferField field) {
      bloc.add(TransferFieldBlurred(field));
    }

    String? error(TransferField field, String? message) {
      return state.showsErrorFor(field) ? message : null;
    }

    void submit() {
      FocusScope.of(context).unfocus();
      bloc.add(const TransferReviewRequested());
    }

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: ResponsiveCenter(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BalanceCard(balance: balance),

            const SizedBox(height: 32),

            const _SectionHeader(
              title: 'Recipient',
              subtitle: 'Enter the account details of who you want to pay.',
            ),

            const SizedBox(height: 16),

            AppTextField(
              key: const Key('transfer_recipientName'),
              label: 'Recipient name',
              hintText: 'e.g. John Adebayo',
              enabled: enabled,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              errorText: error(
                TransferField.recipientName,
                state.recipientNameError?.message,
              ),
              onChanged: (value) => changed(TransferField.recipientName, value),
              onBlur: () => blurred(TransferField.recipientName),
            ),

            const SizedBox(height: 16),

            AppTextField(
              key: const Key('transfer_accountNumber'),
              label: 'Account number',
              hintText: '10-digit account number',
              enabled: enabled,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                  TransferValidators.accountNumberLength,
                ),
              ],
              errorText: error(
                TransferField.accountNumber,
                state.accountNumberError?.toString(),
              ),
              onChanged: (value) => changed(TransferField.accountNumber, value),
              onBlur: () => blurred(TransferField.accountNumber),
            ),

            const SizedBox(height: 32),

            const _SectionHeader(
              title: 'Payment details',
              subtitle: 'Choose how much you want to send.',
            ),

            const SizedBox(height: 16),

            _AmountField(
              enabled: enabled,
              errorText: error(
                TransferField.amount,
                state.amountError?.message,
              ),
              balance: balance,
              onChanged: (value) => changed(TransferField.amount, value),
              onBlur: () => blurred(TransferField.amount),
            ),

            const SizedBox(height: 16),

            AppTextField(
              key: const Key('transfer_note'),
              label: 'Note',
              hintText: 'What is this payment for?',
              enabled: enabled,
              maxLength: TransferValidators.maxNoteLength,
              textInputAction: TextInputAction.done,
              errorText: error(TransferField.note, state.noteError?.message),
              onChanged: (value) => changed(TransferField.note, value),
              onBlur: () => blurred(TransferField.note),
              onSubmitted: (_) => submit(),
            ),

            if (state.status == TransferStatus.failure) ...[
              const SizedBox(height: 16),
              _FailureCard(message: state.failure!.message),
            ],

            const SizedBox(height: 28),

            _SecurityNote(colorScheme: theme.colorScheme),

            const SizedBox(height: 20),

            SizedBox(
              height: 54,
              child: FilledButton(
                key: const Key('transfer_continue'),
                onPressed: enabled ? submit : null,
                child: state.status == TransferStatus.submitting
                    ? const ButtonProgress()
                    : Text(
                        state.status == TransferStatus.failure
                            ? 'Try again'
                            : 'Continue',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final int? balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: colors.onPrimary,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available balance',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  balance == null ? '—' : Money.format(balance!),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colors.onPrimaryContainer.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.enabled,
    required this.errorText,
    required this.balance,
    required this.onChanged,
    required this.onBlur,
  });

  final bool enabled;
  final String? errorText;
  final int? balance;
  final ValueChanged<String> onChanged;
  final VoidCallback onBlur;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      key: const Key('transfer_amount'),
      label: 'Amount',
      hintText: '0.00',
      prefixText: '₦ ',
      enabled: enabled,
      helperText: balance == null
          ? null
          : 'Available: ${Money.format(balance!)}',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
      errorText: errorText,
      onChanged: onChanged,
      onBlur: onBlur,
    );
  }
}

class _FailureCard extends StatelessWidget {
  const _FailureCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.error.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onErrorContainer, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            'Your transfer is protected and secure.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
  }
}
