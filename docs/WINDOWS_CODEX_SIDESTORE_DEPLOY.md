# Windows Codex × SideStore — MyNotes iPad 部署及验收手册

Updated 2026-11-15 · Issue #10 · **Instructions only, not execution proof.**
For: developer's Mac + student's Windows PC and iPad. This is a standalone native SwiftUI/PencilKit app, **NOT a PWA**.

## 0. Roles and critical rules

- **Mac Codex / developer:** compile and package two separate unsigned IPA builds, run validator and tests, transfer those files and SHA-256 securely.
- **Windows Codex / student:** inspect Windows environment, install official drivers and iloader, USB-pair iPad, install SideStore, verify file hashes, test app signing and renewal.
- **Student personally handles Apple Account password, 2FA, device passcode, VPN consent and any certificate prompt.** Codex must NOT ask for, store, copy, upload or log secrets, pairing files, UDIDs, certificates or private notes.
- **No uninstall or replacement of the existing Xcode-installed MyNotes.** Trial app is separately identified as com.example.mynotes.sidestoretrial (display name MyNotes Trial). Initial tests use disposable notebooks only. Current backup/restore is NOT verified.
- Free Apple personal signing expires after about seven days. SideStore attempts on-device refresh but is neither perpetual nor guaranteed. Pairing can fail after iPadOS updates/resets or unexpectedly.

## 1. Developer/Mac Codex — build IPA and hand off

Source: https://github.com/hamperme/MyNotes-iPad

Mac terminal, with Xcode, XcodeGen (brew install xcodegen) and Python 3:

~~~bash
git clone https://github.com/hamperme/MyNotes-iPad.git
cd MyNotes-iPad
git pull --ff-only
xcodebuild -version
xcodegen --version
./scripts/bootstrap.sh
./scripts/check.sh

./scripts/package-ipa.sh --output-dir "$PWD/build/sidestore/trial-1" \
  --bundle-id com.example.mynotes.sidestoretrial \
  --display-name "MyNotes Trial" --build-number 1
./scripts/package-ipa.sh --output-dir "$PWD/build/sidestore/trial-2" \
  --bundle-id com.example.mynotes.sidestoretrial \
  --display-name "MyNotes Trial" --build-number 2

python3 -B -m unittest discover -s tests -p 'test_*.py' -v
shasum -a 256 build/sidestore/trial-{1,2}/MyNotes.ipa
~~~

Output per trial: MyNotes.ipa, manifest.json, MyNotes.ipa.sha256. Verify both IPA_PACKAGE_PASS outputs, exit status 0, iPad-only, arm64, correct ID/build number, unsigned. Output directories must be NEW/EMPTY; the script refuses overwriting an existing IPA. Rename a **copy** to MyNotes-Trial-1.ipa and MyNotes-Trial-2.ipa so the student can distinguish versions.

**Mac build is mandatory.** Windows cannot run Xcode or compile the SwiftUI/PencilKit app. Packaging proves ZIP structure, NOT SideStore install success. Do not claim otherwise. Use private file transfer (AirDrop/USB/private shared file), include expected SHA-256. Avoid publishing app with credentials or private user notes.

## 2. Student/Windows Codex — prerequisites, verified from SideStore official guide

Official: https://docs.sidestore.io/docs/installation/prerequisites

1. Win+R → control /name microsoft.system → System type. Confirm supported Windows 64-bit; **32-bit Windows and Windows 10 ARM are unsupported**. Note Windows version and architecture without disclosing identifying serial numbers.
2. Have a USB **data** cable, iPad passcode, Wi-Fi, iPadOS 15.0+, student-controlled Apple Account. iPad should be unlocked and able to trust a computer.
3. Install iTunes and drivers from Apple (direct Apple iTunes installer is recommended by SideStore; if not working, test Store version or Apple Devices as documented). Source: https://www.apple.com/itunes/
4. Download **iloader Windows MSI** using links from the official SideStore prerequisites: https://github.com/nab138/iloader/releases . Run verified installer, do not disable Windows security as a workaround.
5. On iPad install **LocalDevVPN** from App Store. The student must personally allow VPN configuration and connect; Wi-Fi and this VPN are needed whenever SideStore installs/refreshes apps.

## 3. Initial SideStore installation using Windows + USB

Official: https://docs.sidestore.io/docs/installation/install

1. USB-connect iPad to student Windows machine, unlock, tap Trust This Computer, enter iPad passcode.
2. Launch iloader, confirm the correct iPad appears.
3. **Student**, not Codex, enters their Apple Account and 2FA, selects iPad, clicks **Install SideStore (Stable)**.
4. If replacing/revoking signing certificate may disable another existing app, stop and ask the student to evaluate the consequence. Codex must not silently approve signing-account or certificate changes.
5. iPad Settings → General → VPN & Device Management → trust Developer App for the signing account. For iPadOS 16+ follow Settings → Privacy & Security → Developer Mode and restart if required.
6. Connect LocalDevVPN and Wi-Fi, launch SideStore and sign in with the **same Apple Account used in iloader**.
7. SideStore → My Apps → tap the SideStore remaining-days badge, such as **7 DAYS**, to refresh **SideStore itself first**. After success the app may temporarily return to Home Screen.
8. Report status (PASS/FAIL/NOT RUN), errors sanitized; do not send credentials or device identifiers.

### Windows SHA-256 validation

After receiving MyNotes-Trial-1.ipa and MyNotes-Trial-2.ipa, open PowerShell in the download folder:

~~~powershell
Get-FileHash -Algorithm SHA256 -Path .\MyNotes-Trial-1.ipa
Get-FileHash -Algorithm SHA256 -Path .\MyNotes-Trial-2.ipa
~~~

Compare hashes to developer's Mac output. **Mismatch = STOP**; do not install unverified transfer.

## 4. MyNotes Trial-1 install and in-place upgrade to Trial-2

1. Save **MyNotes-Trial-1.ipa** to iPad Files. Turn on Wi-Fi and LocalDevVPN.
2. SideStore → My Apps → + → select MyNotes-Trial-1.ipa. Check separate **MyNotes Trial** Home Screen icon exists, launches independently, and the original signed MyNotes was not replaced.
3. Create disposable test note: 3 pages, two colors, whole-stroke and partial erasing, pinch zoom, palette drag. Exit/reopen, confirm pages and strokes persisted. Test third-party stylus. **Important:** the current canvas policy is PencilKit .pencilOnly; a clone pen may be reported as touch and appear to do nothing. Report that condition instead of guessing.
4. Manually refresh **SideStore** then **MyNotes Trial** using each app's days badge in My Apps, keeping Wi-Fi and LocalDevVPN connected. Verify relaunch.
5. **Do not uninstall Trial-1.** Using the **same signing account and identical actual installed Bundle ID**, import **MyNotes-Trial-2.ipa** through SideStore as an **in-place update**. Verify original test notebook, page identities and ink remain, and the newer build is running. If a duplicate App icon appears, or SideStore proposes uninstall to update, STOP for data safety review.
6. A successful same-day refresh does not prove seven-day automated renewal. Advise manually checking about every five days, record expiration days and actual refresh results.
7. No real school notes until app full backup/restore, version migration and missed-expiry recovery have actually passed.

## 5. Pairing repair without deleting notes

Official recovery: https://docs.sidestore.io/docs/advanced/pairing-file

1. Connect iPad to Windows over USB; update iloader if prompted.
2. iloader → **Delete Stored Pairing** (this deletes the pairing cache, not iPad notes).
3. Select iPad, accept Trust prompt on iPad.
4. iloader → **Manage Pairing File** → **Place** for SideStore; expect green success message.
5. On iPad enable Wi-Fi + LocalDevVPN, retry refresh. If still failing restart iPad and Windows then repeat. Do NOT uninstall MyNotes, revoke unrelated certificates or wipe data.

## 6. Required report format (Windows Codex)

~~~text
OS/architecture (no machine ID):
iPad model/iPadOS (no UDID):
iloader source/version:
USB detected/trusted: PASS/FAIL/NOT RUN
SideStore installed: PASS/FAIL/NOT RUN
SideStore first refresh: PASS/FAIL/NOT RUN
LocalDevVPN + Wi-Fi: PASS/FAIL/NOT RUN
Trial-1 SHA-256 matches Mac: PASS/FAIL/NOT RUN
Trial-2 SHA-256 matches Mac: PASS/FAIL/NOT RUN
Trial-1 install/launch: PASS/FAIL/NOT RUN
Third-party pen/palm rejection: PASS/FAIL/NOT RUN
3-page note relaunch persistence: PASS/FAIL/NOT RUN
Manual refresh SideStore and Trial: PASS/FAIL/NOT RUN
Trial-1 → Trial-2 in-place update: PASS/FAIL/NOT RUN
Notebook after update intact: PASS/FAIL/NOT RUN
Pairing repair (if necessary): PASS/FAIL/NOT RUN
7-day later/automatic renewal: NOT RUN until observed
Sanitized error and exact next action:
~~~

Forward sanitized results to developer for Issue #10, docs/TEST_PLAN.md, PROGRESS.md and handoff.md. Windows Codex may lack private repo permissions; it can prepare a local report and send it without exposing secrets.

## Official resources

- https://docs.sidestore.io/docs/installation/prerequisites
- https://docs.sidestore.io/docs/installation/install
- https://docs.sidestore.io/docs/advanced/pairing-file
- https://docs.sidestore.io/docs/faq
- https://developer.apple.com/help/account/basics/about-your-developer-account/
