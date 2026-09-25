#!/usr/bin/env bash

set -euo pipefail

# ==========================================================
# androidShark.sh
#
# Android Network Capture & Wireshark Automation
#
# Requirements:
#   adb
#   wireshark
#
# Place a compatible tcpdump binary in the same directory
# as this script before running it.
#
# ==========================================================

WIDTH=65

# ---------- Configuration ----------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TCPDUMP_LOCAL="$SCRIPT_DIR/tcpdump"
TCPDUMP_REMOTE="tcpdump"

CAPTURE_REMOTE="/sdcard/capture.pcap"
CAPTURE_LOCAL="$SCRIPT_DIR/capture.pcap"

# ---------- Colors ----------

RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
YELLOW="\e[33m"
WHITE="\e[37m"
BOLD="\e[1m"
RESET="\e[0m"

# ---------- UI Helpers ----------

line() {
    printf "%${WIDTH}s\n" | tr ' ' '='
}

section() {
    echo
    line
    printf "%*s\n" $(( (${#1} + WIDTH) / 2 )) "$1"
    line
}

success() {
    echo -e "${GREEN}[✓] $1${RESET}"
}

info() {
    echo -e "${CYAN}[*] $1${RESET}"
}

warn() {
    echo -e "${YELLOW}[!] $1${RESET}"
}

error() {
    echo -e "${RED}[✗] $1${RESET}"
}

# ---------- Banner ----------

banner() {

    clear

    echo -e "${CYAN}"

    cat <<'EOF'
    _              _           _     _ ____  _                _    
   / \   _ __   __| |_ __ ___ (_) __| / ___|| |__   __ _ _ __| | __
  / _ \ | '_ \ / _` | '__/ _ \| |/ _` \___ \| '_ \ / _` | '__| |/ /
 / ___ \| | | | (_| | | | (_) | | (_| |___) | | | | (_| | |  |   < 
/_/   \_\_| |_|\__,_|_|  \___/|_|\__,_|____/|_| |_|\__,_|_|  |_|\_\

                 Android Network Capture

EOF

    echo -e "${RESET}"

    line
}

# ---------- Dependency Check ----------

check_dependencies() {

    section "Dependency Check"

    local missing=()

    if ! command -v adb >/dev/null 2>&1; then
        missing+=("adb")
    fi

    if ! command -v wireshark >/dev/null 2>&1; then
        missing+=("wireshark")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then

        error "Missing dependencies:"

        for dependency in "${missing[@]}"; do
            echo "    $dependency"
        done

        echo
        error "Install the missing dependencies and try again."

        exit 1
    fi

    success "ADB found."
    success "Wireshark found."
}

# ---------- ADB Device Check ----------

check_device() {

    section "ADB Device Check"

    info "Checking for authorized Android device..."

    if ! adb get-state >/dev/null 2>&1; then

        error "No authorized ADB device detected."

        echo
        echo "Run:"
        echo
        echo "    adb devices"
        echo

        exit 1
    fi

    success "Android device detected."

    local device
    local android
    local abi
    local kernel

    device=$(adb shell getprop ro.product.model 2>/dev/null |
        tr -d '\r')

    android=$(adb shell getprop ro.build.version.release 2>/dev/null |
        tr -d '\r')

    abi=$(adb shell getprop ro.product.cpu.abilist 2>/dev/null |
        tr -d '\r')

    kernel=$(adb shell uname -m 2>/dev/null |
        tr -d '\r')

    echo
    echo -e "${BOLD}Device:${RESET}          $device"
    echo -e "${BOLD}Android:${RESET}         $android"
    echo -e "${BOLD}CPU ABI:${RESET}         $abi"
    echo -e "${BOLD}Kernel:${RESET}          $kernel"
}

# ---------- Root Check ----------

check_root() {

    section "Root Check"

    info "Checking Android root access..."

    if adb shell su -c id 2>/dev/null | grep -q 'uid=0'; then

        success "Root access confirmed."

    else

        warn "su root access was not detected."

        info "Trying adb root..."

        if adb root >/dev/null 2>&1; then

            sleep 2

            if adb shell id 2>/dev/null | grep -q 'uid=0'; then
                success "ADB root confirmed."
                return 0
            fi
        fi

        error "Root access is required for packet capture."

        exit 1
    fi
}

# ---------- Check Local tcpdump ----------

check_local_tcpdump() {

    section "Local tcpdump"

    if [[ ! -f "$TCPDUMP_LOCAL" ]]; then

        error "tcpdump binary not found."

        echo
        echo "Expected:"
        echo
        echo "    $TCPDUMP_LOCAL"
        echo

        echo "Place the correct tcpdump binary next to"
        echo "androidShark.sh and try again."

        exit 1
    fi

    success "tcpdump binary found."

    chmod +x "$TCPDUMP_LOCAL"

    echo
    echo "    $TCPDUMP_LOCAL"
}

# ---------- Install tcpdump ----------

install_tcpdump() {

    section "Checking Android tcpdump"

    info "Locating tcpdump on Android..."

    local tcpdump_path

    tcpdump_path=$(adb shell command -v tcpdump 2>/dev/null | tr -d '\r')

    if [[ -z "$tcpdump_path" ]]; then
        error "tcpdump was not found on the Android device."
        exit 1
    fi

    success "tcpdump found:"
    echo
    echo "    $tcpdump_path"

    echo
    info "Testing tcpdump..."

    if adb shell tcpdump -D >/dev/null; then
        success "tcpdump is installed and working."
    else
        error "tcpdump was found but could not be executed."
        exit 1
    fi
}

# ---------- Verify tcpdump ----------

verify_tcpdump() {

    section "Verifying tcpdump"

    info "Executing tcpdump -D..."
    echo

    if adb shell tcpdump --version; then
        echo
        success "tcpdump is working."
    else
        echo
        error "tcpdump failed to execute."
        exit 1
    fi
}

# ---------- List Interfaces ----------

list_interfaces() {

    section "Android Network Interfaces"

    info "Running tcpdump -D..."

    echo

    adb shell "$TCPDUMP_REMOTE" -D
}

# ---------- Capture to Android ----------

capture_to_android() {

    section "Capture Traffic to Android"

    echo
    echo "Capture file:"
    echo "    $CAPTURE_REMOTE"

    echo
    warn "Press CTRL+C to stop the capture."
    echo

    adb shell "$TCPDUMP_REMOTE" \
        -i any \
        -nn \
        -w "$CAPTURE_REMOTE"
}

# ---------- Pull Capture ----------

pull_capture() {

    section "Pull PCAP from Android"

    if ! adb shell "test -f $CAPTURE_REMOTE"; then

        error "Capture file does not exist."

        echo
        echo "Expected:"
        echo "    $CAPTURE_REMOTE"

        return
    fi

    info "Pulling capture..."

    adb pull "$CAPTURE_REMOTE" "$CAPTURE_LOCAL"

    echo
    success "Capture pulled successfully."

    echo
    echo "    $CAPTURE_LOCAL"
}

# ---------- Open Wireshark ----------

open_wireshark() {

    section "Open Capture in Wireshark"

    if [[ ! -f "$CAPTURE_LOCAL" ]]; then

        error "PCAP file not found."

        echo
        echo "Expected:"
        echo "    $CAPTURE_LOCAL"

        return
    fi

    info "Opening capture in Wireshark..."

    wireshark "$CAPTURE_LOCAL" >/dev/null 2>&1 &

    success "Wireshark launched."
}

# ---------- Live Capture ----------

live_capture() {

    section "Live Android Capture"

    info "Starting tcpdump on Android..."
    info "Streaming packets directly to Wireshark."

    echo
    warn "Press CTRL+C to stop."
    echo

    adb exec-out \
        su -c "$TCPDUMP_REMOTE -i any -s 0 -U -w -" |
        wireshark -k -i -
}

# ---------- Live Capture + Save ----------

live_capture_save() {

    section "Live Capture + Save"

    local output

    read -rp "PCAP filename [android.pcap]: " output

    output="${output:-android.pcap}"

    local output_path="$SCRIPT_DIR/$output"

    info "Starting live capture..."
    info "Saving PCAP to:"
    echo
    echo "    $output_path"

    echo
    warn "Press CTRL+C to stop."
    echo

    adb exec-out \
        su -c "$TCPDUMP_REMOTE -i any -s 0 -U -w -" |
        tee "$output_path" |
        wireshark -k -i -

    echo
    success "Capture saved."

    echo
    echo "    $output_path"
}

# ---------- Full Setup ----------

full_setup() {

    check_device
    check_root
    check_local_tcpdump
    install_tcpdump
    verify_tcpdump

    echo
    success "AndroidShark setup complete."
}

# ---------- Menu ----------

menu() {

    while true; do

        echo
        line

        echo -e "${BOLD}${WHITE} AndroidShark Menu${RESET}"
        echo

        echo "  1) Check Android device"
        echo "  2) Check root access"
        echo "  3) Check local tcpdump"
        echo "  4) Install tcpdump"
        echo "  5) Verify tcpdump"
        echo "  6) List network interfaces"
        echo "  7) Capture PCAP on Android"
        echo "  8) Pull PCAP from Android"
        echo "  9) Open PCAP in Wireshark"
        echo " 10) Live capture → Wireshark"
        echo " 11) Live capture + save PCAP"
        echo " 12) Run full setup"
        echo "  0) Exit"

        echo
        line

        read -rp "Select an option: " choice

        case "$choice" in

            1)
                check_device
                ;;

            2)
                check_root
                ;;

            3)
                check_local_tcpdump
                ;;

            4)
                check_local_tcpdump
                install_tcpdump
                ;;

            5)
                verify_tcpdump
                ;;

            6)
                list_interfaces
                ;;

            7)
                capture_to_android
                ;;

            8)
                pull_capture
                ;;

            9)
                open_wireshark
                ;;

            10)
                live_capture
                ;;

            11)
                live_capture_save
                ;;

            12)
                full_setup
                ;;

            0)
                echo
                success "Exiting AndroidShark."
                exit 0
                ;;

            *)
                error "Invalid option."
                ;;

        esac

        echo
        read -rp "Press ENTER to continue..."
        clear

    done
}

# ---------- Main ----------

banner
check_dependencies
menu
