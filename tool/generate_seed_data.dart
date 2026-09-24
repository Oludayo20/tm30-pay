// Generates the dummy wallet data exactly as the app creates it, and writes
// it to JSON files so it can be read, diffed or reused (for example as a
// mock API response).
//
// Run from the project root:
//
//   dart run tool/generate_seed_data.dart
//   dart run tool/generate_seed_data.dart --now=2026-09-24T12:00:00
//   dart run tool/generate_seed_data.dart --out=build/seed
//
// The app never runs this script. The app builds the same data in memory, at
// startup, inside FakeWalletApi. This script calls that same class through
// its public API, so its output cannot drift from what the app shows.

import 'dart:convert';
import 'dart:io';

import 'package:tm30_pay/core/utils/fake_latency.dart';
import 'package:tm30_pay/core/utils/money.dart';
import 'package:tm30_pay/features/wallet/data/fake_wallet_api.dart';
import 'package:tm30_pay/features/wallet/data/wallet_json.dart';
import 'package:tm30_pay/features/wallet/domain/transaction.dart';
import 'package:tm30_pay/features/wallet/domain/wallet_repository.dart';
import 'package:tm30_pay/features/wallet/domain/wallet_snapshot.dart';

Future<void> main(List<String> args) async {
  final options = _parse(args);
  if (options.containsKey('help')) {
    stdout.writeln(_usage);
    return;
  }

  // Dates are relative to "now", as in the app. Pass --now to get the same
  // output on every run.
  final now = options['now'] == null
      ? DateTime.now()
      : DateTime.parse(options['now']!);
  final outDir = Directory(options['out'] ?? 'tool/output');

  // The same class the app uses, with no delay and no random failures, so
  // the script is fast and always succeeds.
  final api = FakeWalletApi(
    latency: const FakeLatency.none(),
    listFailureRate: 0,
    clock: () => now,
  );

  // Page through with the real cursor pagination, 20 at a time, exactly as
  // the app's infinite scroll does.
  final transactions = <Transaction>[];
  String? cursor;
  var pages = 0;
  do {
    final page = await api.getTransactions(
      cursor: cursor,
      limit: WalletRepository.pageSize,
    );
    transactions.addAll(page.items);
    cursor = page.nextCursor;
    pages++;
  } while (cursor != null);
  final balance = await api.getBalance();

  // What the app saves in shared_preferences after a successful first load:
  // the balance plus the first page only.
  final firstPage = transactions.take(WalletRepository.pageSize).toList();
  final snapshot = WalletSnapshot(
    balance: balance,
    transactions: firstPage,
    nextCursor: firstPage.length < transactions.length
        ? firstPage.last.id
        : null,
    asOf: now,
  );

  const encoder = JsonEncoder.withIndent('  ');
  await outDir.create(recursive: true);

  final seedFile = File('${outDir.path}/seed_transactions.json');
  await seedFile.writeAsString(
    encoder.convert({
      'generatedAt': now.toIso8601String(),
      'startingBalance': balance,
      'startingBalanceFormatted': Money.format(balance),
      'count': transactions.length,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    }),
  );

  final snapshotFile = File('${outDir.path}/cached_snapshot.json');
  await snapshotFile.writeAsString(encoder.convert(snapshot.toJson()));

  _printSummary(transactions, balance, pages, seedFile, snapshotFile);
}

void _printSummary(
  List<Transaction> transactions,
  int balance,
  int pages,
  File seedFile,
  File snapshotFile,
) {
  int count(bool Function(Transaction) test) => transactions.where(test).length;
  final credits = count((t) => t.isCredit);
  final dates = transactions.map((t) => t.createdAt).toList()..sort();

  stdout
    ..writeln('Generated ${transactions.length} transactions in $pages pages')
    ..writeln('  Starting balance : ${Money.format(balance)}')
    ..writeln(
      '  Credits / debits : $credits / ${transactions.length - credits}',
    )
    ..writeln(
      '  Status           : '
      '${count((t) => t.status == TransactionStatus.success)} success, '
      '${count((t) => t.status == TransactionStatus.pending)} pending, '
      '${count((t) => t.status == TransactionStatus.failed)} failed',
    )
    ..writeln('  Date range       : ${dates.first} to ${dates.last}')
    ..writeln(
      '  Ids              : ${transactions.first.id} (newest) to '
      '${transactions.last.id} (oldest)',
    )
    ..writeln()
    ..writeln('Wrote ${seedFile.path}  (all transactions)')
    ..writeln('Wrote ${snapshotFile.path}  (what the app caches on device)');
}

Map<String, String?> _parse(List<String> args) {
  final options = <String, String?>{};
  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      options['help'] = null;
    } else if (arg.startsWith('--') && arg.contains('=')) {
      final i = arg.indexOf('=');
      options[arg.substring(2, i)] = arg.substring(i + 1);
    } else {
      stderr.writeln('Unknown argument: $arg\n\n$_usage');
      exit(64);
    }
  }
  return options;
}

const _usage = '''
Usage: dart run tool/generate_seed_data.dart [--now=<ISO date>] [--out=<dir>]

  --now   The "current time" the dates are generated relative to.
          Default: the real current time.
  --out   Output folder. Default: tool/output''';
