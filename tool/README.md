# tool/: how the dummy data is created and stored

**Short answer:** the app has no database and no seeding step. The 60 dummy transactions are **generated in memory every time the app starts**, by `FakeWalletApi` ([lib/features/wallet/data/fake_wallet_api.dart](../lib/features/wallet/data/fake_wallet_api.dart)). The only wallet data written to the device is a **cache of the balance and the first 20 transactions**, saved in `shared_preferences` after each successful load.

The scripts in this folder let you see both halves:

| File | What it does |
|---|---|
| `generate_seed_data.dart` | Runs the app's own generator and writes all 60 transactions, plus the exact cache value the app would store, to JSON. |
| `inspect_local_storage.sh` | Reads what the running app has actually stored on an iOS simulator or Android emulator. |
| `output/` | Created by the generator. It is git-ignored because the files can be regenerated at any time. |

## 1. Generating the data

```bash
# from the project root
dart run tool/generate_seed_data.dart --now=2026-09-24T12:00:00
```

Output of that command:

```
Generated 60 transactions in 3 pages
  Starting balance : ₦250,000.00
  Credits / debits : 10 / 50
  Status           : 52 success, 4 pending, 4 failed
  Date range       : 2026-09-07 04:00:00.000 to 2026-09-24 12:00:00.000
  Ids              : txn_0060 (newest) to txn_0001 (oldest)

Wrote tool/output/seed_transactions.json  (all transactions)
Wrote tool/output/cached_snapshot.json  (what the app caches on device)
```

- `--now` fixes the "current time". Without it, dates are relative to the real current time, just like in the app.
- `--out=<dir>` changes the output folder.
- The script does not copy the generator. It creates a real `FakeWalletApi` (with no delay and no random failures) and pages through it 20 at a time using the same cursor pagination as the app's infinite scroll. Its output therefore cannot drift from what the app shows.
- It uses plain `dart run`, not `flutter run`, because nothing it imports depends on Flutter.

## 2. How each transaction is made

When the app starts, `main.dart` creates `FakeWalletApi()`. Its constructor calls `_seed(60)`, which builds the list with a **fixed random seed**, `Random(30)`. The same seed produces the same numbers in the same order, so every launch (and every run of the script) produces the same 60 transactions. This keeps screenshots, bug reports and tests reproducible.

For each index `i` from 0 (newest) to 59 (oldest), in this order:

| Field | Rule |
|---|---|
| `direction` | Credit with 25% probability, otherwise debit. |
| `status` | One draw: under 0.80 is `success`, under 0.92 is `pending`, otherwise `failed` (about 80% / 12% / 8%). |
| `title` | Picked from a fixed list: credits such as "Salary - Tm30 Global" or "Transfer from Chioma Eze"; debits such as "MTN Airtime", "Ikeja Electric" or "Uber Trip". |
| `amount` | A whole-naira amount from ₦500 to ₦150,000, stored as an **integer in kobo** (× 100), never as a `double`. |
| `createdAt` | `now − (7 × i + 0–5) hours`. That gives roughly one transaction every 7 hours, newest first, over about 17 days. |
| `counterpartyAccount` | 10 random digits. |
| `id` | Counts down from `txn_0060` (newest) to `txn_0001` (oldest), so new transfers continue at `txn_0061`. |

The percentages are probabilities, not quotas. With seed 30 they come out as 10 credits (17%) and 52/4/4 statuses. The starting balance is a separate constant, **₦250,000.00** (`25000000` kobo). It is not computed from the seeded transactions, which is how the assessment specifies it.

The generated list lives only in the `FakeWalletApi` object's memory:

- A transfer subtracts from the in-memory balance and adds a new transaction to the top of the list.
- A cold start rebuilds everything from the seed, so transfers from an earlier session are gone from the fake "server". This is documented in the root README as a known limitation.

## 3. What is stored on the device

| What | Where | Key | Written | Cleared |
|---|---|---|---|---|
| Wallet cache: balance + first 20 transactions + `nextCursor` + `asOf` | `shared_preferences` (plain JSON string) | `wallet_snapshot_v1` | After every successful overview fetch (launch, refresh, retry), and updated after every successful transfer | On sign-out, or automatically if it can't be parsed |
| Theme choice | `shared_preferences` | `theme_preference` | When you pick System / Light / Dark | Never; it belongs to the device, not the account |
| Session: tokens + profile | `flutter_secure_storage` (iOS Keychain / Android Keystore, encrypted) | `auth_session` | On sign-in | On sign-out |

How the cache is used:

1. On launch, `WalletBloc` sends `WalletStarted`, which **reads `wallet_snapshot_v1` first** and shows it instantly.
2. The app then calls `fetchOverview()`, which fetches the balance and page 1 from `FakeWalletApi` in parallel.
3. On success, `WalletRepositoryImpl` **overwrites** the cache with the fresh snapshot.
4. On a network failure (15% of list calls), the cached data stays on screen with the offline banner.
5. Pages 2 and later are never cached. Only the first page is, as the assessment specifies.

The JSON format is defined in [lib/features/wallet/data/wallet_json.dart](../lib/features/wallet/data/wallet_json.dart). `tool/output/cached_snapshot.json` shows the same structure.

### Where the files actually are

| Platform | Location |
|---|---|
| iOS | `NSUserDefaults` plist in the app container: `Library/Preferences/com.example.tm30Pay.plist`. The keys appear with no prefix. |
| Android | Jetpack DataStore, a binary protobuf file: `/data/data/com.example.tm30_pay/files/datastore/FlutterSharedPreferences.preferences_pb` |

To see it on a running simulator:

```bash
tool/inspect_local_storage.sh ios       # booted iOS simulator
tool/inspect_local_storage.sh android   # emulator with a debug build
```

Sample iOS output after signing in:

```
theme_preference: light

wallet_snapshot_v1:
  balance     : 25000000 kobo (NGN 250,000.00)
  asOf        : 2026-09-24T11:08:27.762145
  nextCursor  : txn_0041
  transactions: 20
    txn_0060  +  148,942.00  success  Transfer from Chioma Eze
    txn_0059  -  145,154.00  success  Transfer to Tunde Bakare
    ...
```

These are the same transactions as the first 20 in `seed_transactions.json`; only the timestamps differ, because they are relative to when the app launched. The session is deliberately not printed: it is encrypted in the Keychain or Keystore.

## Changing the dummy data

All of it is in `FakeWalletApi`:

- **Count:** the `seedCount` constructor argument (default 60).
- **Starting balance:** `startingBalance` (in kobo).
- **Titles, mix and amounts:** the lists and numbers in `_seed()`.
- **A different but still fixed dataset:** change the seed in `Random(30)`.

Then re-run the generator to see the result. Existing caches update on the next successful launch, because a fresh fetch overwrites them.
