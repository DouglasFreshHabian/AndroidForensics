#!/usr/bin/env bash

set -euo pipefail

# ===============================
# Unlock Script (ADB Automation)
# ===============================

WIDTH=60

# ---------- Colors ----------
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
YELLOW="\e[33m"
BOLD="\e[1m"
RESET="\e[0m"

# ---------- UI Helpers ----------

line() {
    printf "%${WIDTH}s\n" | tr ' ' '='
}

section() {
    line
    printf "%*s\n" $(( (${#1} + WIDTH) / 2 )) "$1"
    line
}

success() { echo -e "${GREEN}[✓] $1${RESET}"; }
info()    { echo -e "${CYAN}[*] $1${RESET}"; }
warn()    { echo -e "${YELLOW}[!] $1${RESET}"; }
error()   { echo -e "${RED}[✗] $1${RESET}"; }

# ---------- Device State Check ----------

device_unlocked() {
    adb shell dumpsys trust 2>/dev/null |
        grep -q 'deviceLocked=0'
}

device_locked() {
    adb shell dumpsys trust 2>/dev/null |
        grep -q 'deviceLocked=1'
}

# ---------- Start ----------

clear
section "ADB Device Unlock Automation"

# ---------- Device Check ----------

info "Checking for connected ADB device..."

if ! adb get-state 1>/dev/null 2>&1; then
    error "No authorized ADB device detected."
    exit 1
fi

success "Device detected."

# ---------- Wake Device ----------

section "Waking Device"

info "Sending KEYCODE_WAKEUP..."

adb shell input keyevent KEYCODE_WAKEUP
sleep 1

success "Device wake signal sent."

# ---------- Swipe Up ----------

section "Opening Lock Screen"

info "Swiping to reveal PIN prompt..."

adb shell input swipe 540 1800 540 600 1000
sleep 1

success "PIN prompt should now be visible."

# ---------- Enter PIN ----------

section "Entering PIN"

info "Sending PIN through ADB keyevents..."

adb shell input keyevent KEYCODE_1
adb shell input keyevent KEYCODE_2
adb shell input keyevent KEYCODE_3
adb shell input keyevent KEYCODE_4

sleep 0.5

info "Submitting PIN..."

adb shell input keyevent KEYCODE_ENTER

sleep 2

success "PIN input sequence sent."

# ---------- Verify Unlock ----------

section "Verifying Device State"

info "Checking Android lock state..."

if device_unlocked; then
    success "Device unlocked successfully."
elif device_locked; then
    error "Device is still locked."
    exit 1
else
    error "Unable to determine device lock state."
    exit 1
fi

# ---------- Complete ----------

section "Process Complete"

success "Unlock routine completed successfully."

echo
