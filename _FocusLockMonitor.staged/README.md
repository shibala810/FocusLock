# FocusLockMonitor — DeviceActivityMonitor Extension

This folder contains the **pre-written source code** for the DeviceActivityMonitor extension.
The extension target itself **must be created in Xcode** (changing `project.pbxproj` to add a
new target is fragile and Xcode-version-specific). After you create the target, copy the
files here into the target's folder.

---

## Step-by-step (in Xcode)

### 1. Add the extension target

1. Open `FocusLock.xcodeproj`
2. **File → New → Target…**
3. Pick **iOS → Application Extension → DeviceActivityMonitor Extension** → Next
4. Product Name: **`FocusLockMonitor`**
   Team: your Apple ID
   Embed in Application: **FocusLock**
5. **Finish**
6. If Xcode asks "Activate FocusLockMonitor scheme?" → **Cancel** (we don't need to debug it directly)

Xcode now creates a new folder `FocusLockMonitor/` next to the main app, with a template
`.swift`, `Info.plist`, and `.entitlements`.

### 2. Replace template files with the staged ones

From a Terminal at the project root (`/Users/timwu/TWM/FocusLock/FocusLock/`):

```sh
# Overwrite Xcode's blank template with our actual implementation:
cp _FocusLockMonitor.staged/FocusLockMonitorExtension.swift  FocusLockMonitor/
cp _FocusLockMonitor.staged/Info.plist                       FocusLockMonitor/
cp _FocusLockMonitor.staged/FocusLockMonitor.entitlements    FocusLockMonitor/

# If Xcode named the template Swift file differently (e.g. FocusLockMonitor.swift),
# delete the old one from the Xcode group:
#   Right-click the file in the project navigator → Delete → "Move to Trash"

# Once everything builds, remove the staging folder:
rm -rf _FocusLockMonitor.staged
```

### 3. Wire capabilities on both targets

Both the **FocusLock** (main app) and **FocusLockMonitor** (extension) targets need:

- **Family Controls** capability (already on main; add to extension)
- **App Groups** capability with group `group.com.shibala810.FocusLock` (add to both)

For each target:
1. Select target → **Signing & Capabilities** tab
2. **+ Capability → App Groups** → check `group.com.shibala810.FocusLock` (create if needed)
3. **+ Capability → Family Controls** (extension only — main app already has it)

The entitlements files I provided already declare both keys; Xcode reads them on next build.

### 4. Verify the Info.plist extension point

Open `FocusLockMonitor/Info.plist` and confirm:

```xml
<key>EXAppExtensionAttributes</key>
<dict>
    <key>EXExtensionPointIdentifier</key>
    <string>com.apple.deviceactivity.monitor-extension</string>
    <key>EXPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).FocusLockMonitorExtension</string>
</dict>
```

The principal class name must match the Swift class name. If Xcode's template used a
different class name (e.g. `DeviceActivityMonitorExtension`), either rename the class in
the swift file or update the plist.

### 5. Build & run

`⌘B` should succeed. Run the app — when you toggle a schedule on, the main app calls
`ScreenTimeService.reconcileSchedules(…)` which registers a `DeviceActivitySchedule` per
(schedule, day). When the interval starts, the extension runs in a background process
and sets the shield; when it ends, the extension clears it.

---

## How the two processes share state

| What | Where |
|---|---|
| User-selected apps to block | `UserDefaults(suiteName: "group.com.shibala810.FocusLock")` under key `famSelection` (PropertyList-encoded `FamilyActivitySelection`) |
| The shield itself | `ManagedSettingsStore(named: .init("FocusLockShield"))` — same identifier in both processes |
| Is shield currently active? | Same shared UserDefaults under key `activeShield` (Bool; extension writes, main reads) |

This works because:
- App Group → both processes can read/write the same UserDefaults suite
- ManagedSettingsStore is keyed by a string `Name` — same name → same persisted store

## If the extension doesn't fire

1. Make sure the App Group ID is identical in both `.entitlements` files (typos kill it silently)
2. Make sure both targets have Family Controls enabled in the Apple Developer portal — the
   Development entitlement Xcode adds automatically should be enough for sim and your own
   device; distribution needs the manual Apple request
3. On Simulator, `DeviceActivityCenter.startMonitoring` registers but the system may not
   actually fire callbacks until iOS believes the apps are running. Real device gives the
   most accurate test
4. Check `Console.app` filtered for `FocusLockMonitor` to see if the process spawned
