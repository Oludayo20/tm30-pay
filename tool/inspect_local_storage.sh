#!/usr/bin/env bash
# Shows what Tm30 Pay has stored on a simulator or emulator: the cached wallet
# snapshot and the theme preference. Run the app and sign in at least once
# first.
#
#   tool/inspect_local_storage.sh ios        # booted iOS simulator
#   tool/inspect_local_storage.sh android    # connected emulator (debug build)
#
# The session (tokens and profile) is deliberately not shown: it is encrypted
# in the iOS Keychain / Android Keystore by flutter_secure_storage.
set -euo pipefail

IOS_BUNDLE_ID="com.example.tm30Pay"
ANDROID_APP_ID="com.example.tm30_pay"

case "${1:-ios}" in
  ios)
    container=$(xcrun simctl get_app_container booted "$IOS_BUNDLE_ID" data)
    plist="$container/Library/Preferences/$IOS_BUNDLE_ID.plist"
    if [[ ! -f "$plist" ]]; then
      echo "No preferences yet at $plist. Launch the app and sign in first." >&2
      exit 1
    fi
    echo "File: $plist"
    echo
    echo "theme_preference: $(plutil -extract theme_preference raw "$plist" 2>/dev/null || echo '(not set, so system)')"
    echo
    echo "wallet_snapshot_v1:"
    if snapshot=$(plutil -extract wallet_snapshot_v1 raw "$plist" 2>/dev/null); then
      # The value is a JSON string; summarise it.
      python3 - "$snapshot" <<'PY'
import json, sys
s = json.loads(sys.argv[1])
txs = s['transactions']
print(f"  balance     : {s['balance']} kobo (NGN {s['balance'] / 100:,.2f})")
print(f"  asOf        : {s['asOf']}")
print(f"  nextCursor  : {s['nextCursor']}")
print(f"  transactions: {len(txs)}")
for t in txs[:5]:
    sign = '+' if t['direction'] == 'credit' else '-'
    print(f"    {t['id']}  {sign}{t['amount'] / 100:>12,.2f}  {t['status']:<8} {t['title']}")
if len(txs) > 5:
    print('    ...')
PY
    else
      echo "  (not cached yet, or cleared by sign-out)"
    fi
    ;;
  android)
    # shared_preferences' async API stores data with Jetpack DataStore, in a
    # binary protobuf file. `strings` pulls out the readable keys and values.
    file="files/datastore/FlutterSharedPreferences.preferences_pb"
    echo "File: /data/data/$ANDROID_APP_ID/$file"
    echo
    adb shell run-as "$ANDROID_APP_ID" cat "$file" | strings | cut -c1-300
    ;;
  *)
    echo "Usage: $0 [ios|android]" >&2
    exit 64
    ;;
esac
