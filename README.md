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

#### **`androidQuickDump.sh`**

<details>
<summary>🖱 Click to Expand</summary>

* Quickly gathers key forensic artifacts:

  * Device info (model, build, serial)
  * Installed apps
  * Battery stats
  * Logs
  * Network configuration
* Saves all outputs into a timestamped directory for organization.
* Color-coded console output for clarity.

</details>

#### **`androidDeepDive.sh`**

<details>
<summary>🖱 Click to Expand</summary>

* Performs an extended forensic capture:

  * Dumpsys output for key system services
  * Pulls accessible data directories (DCIM, Downloads, etc.)
  * Extracts additional diagnostic info (storage, activity, processes)
* Organizes results in structured folders per run.

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
   chmod +x androidQuickDump.sh androidDeepDive.sh
   ```

3. Run the quick scan:

   ```bash
   ./androidQuickDump.sh
   ```

4. Run the deep forensic capture:

   ```bash
   ./androidDeepDive.sh
   ```

---

### 🧱 Directory Structure

```
AndroidForensics/
├── androidQuickDump.sh
├── androidDeepDive.sh
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

