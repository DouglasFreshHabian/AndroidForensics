<h1 align="center">
🕵️‍♂️ AndroidForensics
</h1>

<p align="center">
  <img src="https://github.com/DouglasFreshHabian/AndroidForensics/blob/main/Assets/Droid-Detective.png" alt="Android Forensics Logo" width="400">
</p>

<h1 align="center">
Android Device Forensics: A Practical ADB Guide 🔍
</h1>

The **AndroidForensics** project is a practical guide and toolkit for extracting digital artifacts from Android devices using **ADB (Android Debug Bridge)** commands. Whether you’re an investigator, researcher, or security enthusiast, this repo walks you through the process of gathering system and app-level data safely, transparently, and reproducibly, using a non-rooted device running Android.

---

### ⚙️ Prerequisites

Before you begin, ensure you have:

* **ADB installed** on your system:
  ```bash
  sudo apt install adb -y
  ```
---
* **USB debugging enabled** on the target Android device.
* Proper authorization (legal and ethical) to access and analyze the device.

---

### 1. **Verify ADB Connection** 🔌

Ensure your device is connected and recognized:

```bash
adb devices
```

Example output:

```
List of devices attached
RZ8N1234XYZ	device
```

---

### 2. **Gather Basic System Info** 🧠

Pull general information about the device and system state:

```bash
adb shell getprop
```

Or, for specific properties:

```bash
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
adb shell getprop ro.serialno
```

This gives insight into the **model**, **OS version**, and **serial number** — essential for report documentation.

---

### 3. **Retrieve Installed Applications** 📱

List all installed apps and their installation paths:

```bash
adb shell pm list packages -f
```

To export this list for analysis:

```bash
adb shell pm list packages -f > installed_apps.txt
```

---

### 4. **Collect System Logs** 📋

Grab real-time logs from the device:

```bash
adb logcat -d > system_logs.txt
```

This file can contain crash traces, app activity, network events, and more — valuable for timeline reconstruction.

---

### 5. **Extract Battery & Power Data** 🔋

Gather device power metrics:

```bash
adb shell dumpsys battery
```

Example output:

```
AC powered: false
USB powered: true
level: 84
temperature: 290
```

---

### 6. **Dump Network Info** 🌐

Collect network configuration and connection details:

```bash
adb shell dumpsys connectivity
adb shell ifconfig
adb shell netstat
```

---

### 7. **Pull Specific Directories or Files** 🧾

Forensic acquisition of accessible directories:

```bash
adb pull /sdcard/DCIM ./Android_Images
adb pull /sdcard/Download ./Downloads
adb pull /data/system/packages.list ./Package_List
```

> ⚠️ Note: Access to `/data` directories may require root or forensic-mode images.

---

### 8. **Device Timeline and Activity Data** ⏰

Gather system usage and history:

```bash
adb shell dumpsys usagestats
adb shell dumpsys batterystats
adb shell settings list system
```

This helps reconstruct user behavior and system-level changes over time.

---

### 🧩 Included Scripts

This repo includes two Bash utilities to automate and standardize your data extraction workflow:

#### **`extract.sh`**

<details>
<summary>🖱 Click to Expand</summary>

Excellent — this is a **much more advanced version** of your earlier ADB script. It not only gathers system diagnostics but also extracts **user-level data** (contacts, call logs, SMS, accounts). Let’s go through what it does in detail and then pick a fitting name.

---

## 🧩 **What This Script Does**

This Bash script performs an **automated ADB-based forensic data and diagnostics extraction** from a connected Android device.
It’s designed for **system analysis, auditing, or incident response** — collecting both **system snapshots** and **select user-accessible data** in a single organized run.

---

### 🔧 **Step-by-Step Overview**

#### **1. Environment & Device Setup**

* Checks that `adb` (Android Debug Bridge) is installed.
* Starts the ADB server silently.
* Detects a connected Android device (`adb devices`).
* Exits if no authorized device is found.
* Displays the connected device ID.

#### **2. Creates a Timestamped Output Folder**

Example:

```
ADB_Report_20251025_163200/
```

All collected data is stored here, one file per command.

---

### 📋 **3. Core Function — `run_adb_command`**

A helper that:

* Displays a colorized header describing the task.
* Runs the given ADB command.
* Saves output to a specified filename.
* Optionally runs “silent” tasks (no console output, for noisy commands).

---

### 🧠 **4. Data Collected**

#### 📱 **Device & System Information**

| Category     | Description                                  | Command                                             |
| ------------ | -------------------------------------------- | --------------------------------------------------- |
| Basic Info   | Model, manufacturer, Android version, serial | `getprop ...`                                       |
| Device State | Uptime, battery, and connectivity            | `uptime`, `dumpsys battery`, `dumpsys connectivity` |
| Network Info | Interface config                             | `ifconfig` or `ip addr show`                        |

---

#### 👤 **User & App Data Extraction**

| Data                   | Description                      | Command                                          |
| ---------------------- | -------------------------------- | ------------------------------------------------ |
| **Accounts**           | Extracts account package names   | `dumpsys account`                                |
| **Email addresses**    | Extracts email strings via regex | `dumpsys account`                                |
| **Reboot count**       | Reads global boot counter        | `settings list global`                           |
| **Contacts**           | Lists contacts and phone numbers | `content query --uri content://contacts/phones/` |
| **Call logs**          | Queries system call history      | `content query --uri content://call_log/calls`   |
| **SMS messages**       | Dumps all SMS database entries   | `content query --uri content://sms/`             |
| **Installed packages** | Lists all and third-party apps   | `pm list packages`                               |
| **Running services**   | Dumps currently active services  | `dumpsys -l`                                     |

> ⚠️ These use Android’s public **content providers**, meaning some data may not be available on modern devices (Android 11+ restricts SMS, contacts, etc. access via ADB unless rooted or with specific permissions).

---

#### ⚙️ **5. System Diagnostics**

* **`logcat` snapshot:** Captures last ~1000 lines of logs.
* **`bugreport`:** Generates a full system report in the background (`.zip` or `.txt`), allowing the user to continue using the script while it completes.

---

### 📊 **6. Final Summary**

* Prints a color-coded summary table showing all collected files and their sizes.
* Displays total runtime (excluding background bugreport).
* Reminds the user that the bugreport will appear when finished.

Example:

```
[✓] All ADB data extraction commands executed successfully!
Summary of extracted files:
device_info.txt         4.2K
emails.txt              1.1K
contacts.txt            32K
sms.txt                 80K
-------------------------------------------
Results saved in: ADB_Report_20251025_163200
Total runtime: 42s
[i] Bugreport is running in the background...
```

---

## ⚙️ **Use Cases**

This script is suitable for:

* **Incident response or forensic triage**
* **Device auditing before handoff**
* **Support or QA data collection**
* **Security analysis / compliance snapshots**

It collects:

* **System state**
* **Network and battery info**
* **App lists**
* **User-level communications data (where permitted)**
* **Logs and bugreport**

---

## ⚠️ **Cautions / Limitations**

* Access to **SMS, call logs, and contacts** may be blocked on newer Android versions (especially Android 11+).
* Should only be used on devices you **own or have explicit consent** to examine.
* Data collected may contain **personally identifiable information** — handle securely.

---

</details>

#### **`dumpsys.sh`**

<details>
<summary>🖱 Click to Expand</summary>

## 🧩 **What the `dumpsys.sh` Script Does**

This Bash script is an **automated Android diagnostics collector**.
It connects to an Android device over **ADB (Android Debug Bridge)** and runs a series of **`dumpsys` commands** — each targeting a key Android system service — then saves their outputs into organized text files.

Here’s what happens step by step:

---

### 🧱 **1. Setup & Environment Checks**

* Checks that the `adb` tool is installed and accessible in your system `PATH`.
* Starts the ADB server if it’s not already running.
* Waits up to **30 seconds (10 retries × 3s)** for an Android device to be connected and authorized.
* Accepts an optional **device serial** as an argument (useful if multiple devices are connected).

---

### 📂 **2. Creates a Timestamped Report Directory**

Creates an output folder such as:

```
DumpSysReport_20251025_153000/
```

All command outputs are saved in this directory, each to its own `.txt` file.

---

### ⚙️ **3. Runs a Series of System Commands via ADB**

It loops through a predefined list of **21 `dumpsys` services**, including:

| Command                       | Purpose                          |
| ----------------------------- | -------------------------------- |
| `dumpsys meminfo`             | Memory usage                     |
| `dumpsys media.audio_flinger` | Audio playback internals         |
| `dumpsys sensorservice`       | Sensor (motion/environment) data |
| `dumpsys adb`                 | ADB subsystem info               |
| `dumpsys account`             | Accounts and sync services       |
| `dumpsys fingerprint`         | Fingerprint authentication info  |
| `dumpsys netstats`            | Network usage statistics         |
| `dumpsys power`               | Power manager and wake locks     |
| `dumpsys location`            | GPS and location services        |
| `dumpsys notification`        | Notification history             |
| `dumpsys telecom`             | Telephony/call data              |
| `dumpsys wifi`                | Wi-Fi state/history              |
| ...and more                   |                                  |

Each command’s output is:

* Displayed live in the terminal (`tee`)
* Saved to a corresponding file (e.g., `wifi.txt`, `meminfo.txt`)

If a command fails, it’s logged as failed — otherwise marked as succeeded.

---

### 📊 **4. Generates a Summary**

At the end, it prints a color-coded summary:

```
Succeeded Commands: 20
 ✔ dumpsys meminfo
 ✔ dumpsys wifi
 ...

Failed Commands: 1
 ✖ dumpsys clipboard

All outputs saved in DumpSysReport_20251025_153000
```

---

## 🧠 **Purpose / Use Case**

This script is ideal for:

* **Developers** gathering system state for debugging.
* **QA engineers** doing regression tests or bug triage.
* **Forensic analysts** collecting non-user diagnostic data.
* **Tech support** capturing structured device reports.

It’s non-invasive — it **does not pull user files (photos, downloads, etc.)** — only system service states available via ADB.

---

</details>

---

### 🔧 How to Use

1. Clone the repo:

   ```bash
   git clone https://github.com/DouglasFreshHabian/AndroidForensics.git
   cd AndroidForensics
   ```

2. Make the scripts executable:

   ```bash
   chmod +x extract.sh dumpsys.sh
   ```

3. Run the `extract.sh` script:

   ```bash
   ./extract.sh
   ```

4. Run the `dumpsys.sh` script:

   ```bash
   ./dumpsys.sh
   ```

---

### 🧱 Directory Structure

```
AndroidForensics/
├── extract.sh
├── dumpsys.sh
├── Assets/
│   └── Droid-Detective.png
├── outputs/
│   ├── ADB_Report_20251025_005650/
│   └── DumpSysReport_20251024_171220/
└── README.md
```

---

### ⚖️ Legal & Ethical Notice

This toolkit is for **authorized forensic analysis only**.
Ensure compliance with local laws and privacy regulations. Unauthorized data extraction may violate legal boundaries.

---

### 💬 Feedback & Contributions

If you have ideas, want to add new ADB command modules, or improve automation — open an issue or submit a pull request!
Let’s build an open, transparent, and responsible forensic community.

---

### ☕ Support This Project

If **AndroidForensics™** helps your investigations, consider supporting continued development:

<p align="center">
  <a href="https://www.buymeacoffee.com/dfreshZ" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
</p>

---

<!-- 
    Fresh Forensics, LLC | Douglas Fresh Habian | 2025
    github.com/DouglasFreshHabian
    freshforensicsllc@tuta.com
-->

