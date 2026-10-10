#!/usr/bin/env bash
# Validate the running OP64D3L1 integration recovery.
set -Eeuo pipefail
export LC_ALL=C

[[ $(adb get-state 2>/dev/null || true) == recovery ]] || {
    echo "ERROR: device is not in recovery/ADB mode" >&2
    exit 2
}

failures=0
note() { printf '%s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; failures=$((failures + 1)); }

prop_value() { adb shell "getprop '$1'" 2>/dev/null | tr -d '\r'; }

require_prop() {
    local name=$1 expected=$2 actual
    actual=$(prop_value "$name")
    if [[ $actual == "$expected" ]]; then
        note "PASS $name=$actual"
    else
        fail "$name expected '$expected', got '$actual'"
    fi
}

require_service_running() {
    require_prop "init.svc.$1" running
}

note '=== core properties ==='
require_prop crypto.ready 1
require_prop twrp.wifi.driver.ready true

note '=== core services ==='
for service in adbd vendor.qseecomd vendor.keymint-qti vendor.gatekeeper_default vendor.boot-qti vendor.oplus.vibrator vendor.health-default wpa_supplicant; do
    require_service_running "$service"
done

note '=== user decryption ==='
user_decrypt=$(prop_value twrp.user.0.decrypt)
if [[ $user_decrypt == 1 ]]; then
    note 'PASS twrp.user.0.decrypt=1'
else
    note 'WARN twrp.user.0.decrypt is not 1; enter the lock-screen PIN if this is a fresh boot'
fi

note '=== storage ==='
if adb shell 'mount | grep -q " /data "' >/dev/null 2>&1; then
    note 'PASS /data is mounted'
    adb shell 'mount | grep " /data "'
else
    fail '/data is not mounted'
fi
if adb shell 'test -d /data/media/0' >/dev/null 2>&1; then
    note 'PASS /data/media/0 exists'
    adb shell 'ls -la /data/media/0 | head -20'
else
    fail '/data/media/0 does not exist'
fi

note '=== local enhancements ==='
for file in /system/bin/7za /system/bin/zstd; do
    if adb shell "test -x '$file'" >/dev/null 2>&1; then
        note "PASS $file executable"
    else
        fail "$file missing or not executable"
    fi
done

note '=== WiFi modules ==='
for module in qca_cld3_qca6750 mac80211 cfg80211 icnss2; do
    if adb shell cat /proc/modules | grep -q "^$module "; then
        note "PASS module $module loaded"
    else
        fail "module $module not loaded"
    fi
done

note '=== recovery log evidence ==='
if adb shell "grep -q 'Successfully decrypted metadata encrypted data partition' /tmp/recovery.log" >/dev/null 2>&1; then
    note 'PASS metadata decryption marker found'
else
    fail 'metadata decryption marker missing'
fi
if adb shell "grep -q 'User 0 Decrypted Successfully' /tmp/recovery.log" >/dev/null 2>&1; then
    note 'PASS user 0 decryption marker found'
elif [[ $user_decrypt == 1 ]]; then
    note 'PASS user decryption property is set; log may have rotated'
else
    note 'WARN user 0 marker absent; PIN may not have been entered yet'
fi

touch_state=$(prop_value init.svc.touch-aidl)
note "INFO init.svc.touch-aidl=$touch_state (restart is a known non-blocking issue)"

if (( failures )); then
    echo "VALIDATION FAILED: $failures failure(s)" >&2
    exit 1
fi
echo 'VALIDATION PASSED'
