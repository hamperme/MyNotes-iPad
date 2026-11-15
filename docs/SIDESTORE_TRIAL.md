> **UPDATE 2026-11-15:** The recipient now has a Windows PC and iPad with access for local setup, and the release includes a separate [complete Windows Codex guide](WINDOWS_CODEX_SIDESTORE_DEPLOY.md). The trial installation/refresh remains **NOT RUN**; earlier references below to recipient being elsewhere describe a historical 2026-10-14 session, not current logistics.

# SideStore local trial — Issue #10

## Scope and observed state (2026-10-14)

The owner selected the iPad physically connected to this Mac for experiments. The final recipient's iPad is elsewhere; this trial cannot establish recipient-device compatibility. Native app/editor progress from PRs #7–#9 is retained. This procedure does not migrate the current Xcode-installed app.

| Gate | Observed result |
| --- | --- |
| Release arm64 iOS IPA, iPad-only, build 1 and 2 | PASS, Xcode 26.6 / XcodeGen 2.45.4 |
| ZIP/Mach-O/identity/version/no-signature validator | PASS; 8 offline tests, including negative fixtures |
| Fresh existing-app note backup to private Mac directory | PASS (copy/hash only; restoration NOT RUN) |
| iloader 2.3.7 provenance/signature | Official-guide link; GitHub asset digest matched; codesign and Gatekeeper notarization PASS |
| iloader USB device detection | PASS; owner handles Apple login, no credentials saved by the agent |
| SideStore install / first refresh / trial IPA import | NOT RUN |
| Trial build 1 → 2 data preservation / relaunch | NOT RUN |
| Seven-day renewal, missed refresh, pairing recovery | NOT RUN |
| Third-party pen on final recipient device | NOT RUN |

The initial device build succeeded but packaging validation rejected a missing version. Supplying `CURRENT_PROJECT_VERSION` (not only the generated Info.plist key) corrected it. Never publish a stale IPA after a failed validation.

## Reproduce packages without touching signing

Run from the repository on macOS with Xcode, XcodeGen and Python 3 available:

```bash
./scripts/package-ipa.sh --output-dir "$PWD/build/sidestore/trial-1" \
  --bundle-id com.example.mynotes.sidestoretrial \
  --display-name 'MyNotes Trial' --build-number 1
./scripts/package-ipa.sh --output-dir "$PWD/build/sidestore/trial-2" \
  --bundle-id com.example.mynotes.sidestoretrial \
  --display-name 'MyNotes Trial' --build-number 2
python3 -B -m unittest discover -s tests -p test_ipa_validation.py -v
```

Outputs: `MyNotes.ipa`, `manifest.json`, `MyNotes.ipa.sha256`. Each build copies only tracked-style app sources and the public project specification into a fresh temporary directory. It does not regenerate/read the user's signed `.xcodeproj`, access Apple accounts, or embed a provisioning profile. Release builds use `CODE_SIGNING_ALLOWED=NO`, an empty team/identity and explicit iPad targeting. The validator rejects signatures, simulator binaries, wrong identity/version and private pairing/signing metadata. Source hashes are recorded; byte-identical builds are not promised.

These are **unsigned input packages for a signing tool**, not directly installable/approved apps. No successful SideStore re-signing is claimed. The trial ID and display name deliberately differ from the user's app. Keep this same trial ID and Apple account for both test versions; SideStore may transform identifiers during signing, so record the installed identity privately and compare it before updating.

## Owner-mediated setup

Official instructions checked 2026-10-14:
- [Prerequisites](https://docs.sidestore.io/docs/installation/prerequisites)
- [Install](https://docs.sidestore.io/docs/installation/install)
- [FAQ and app limits](https://docs.sidestore.io/docs/faq)
- [Pairing recovery](https://docs.sidestore.io/docs/advanced/pairing-file)
- [Apple Personal Team limits](https://developer.apple.com/help/account/basics/about-your-developer-account/)

1. Back up existing notes and preserve the original signed app/project. Never delete the user's app to make room or troubleshoot.
2. Connect the experimental iPad over USB to the trusted Mac. The owner personally handles passcode, trust and Apple login/2FA. Do not send passwords, verification codes or pairing files through chat/GitHub.
3. Use the stable iloader installer linked by the official guide. Select the USB iPad, not another discovered device. Keep **Save Credentials** unchecked and keep secure keyring storage enabled. Do not change custom Anisette servers, disable Gatekeeper, or remove quarantine as a workaround.
4. Owner installs LocalDevVPN from the App Store and reviews/approves its VPN configuration. Wi-Fi and LocalDevVPN are required for SideStore install/update/refresh per its guide; this is not a remote VPN subscription.
5. Install SideStore Stable. If a certificate-revocation/replacement prompt appears, stop and review with the owner. It may invalidate the existing Xcode signature even when bundle IDs differ. Do not auto-approve, revoke certificates, or switch accounts to bypass this decision.
6. Owner completes trust/developer-mode prompts if actually needed. Existing developer mode was already enabled on the local iPad; do not repeat or reset it blindly. Sign into SideStore with the same trial signing account, then refresh **SideStore itself first**.
7. Verify available free provisioning slots before importing MyNotes Trial. SideStore counts toward the three-app limit. Existing free-provisioned apps may consume slots; do not delete any app without owner review and data recovery.

## Trial acceptance — do not mark complete from packaging

1. Transfer build 1 locally to iPad Files (for example owner AirDrop), import it **from SideStore**, and record success/error. Do not publish an untested binary to GitHub Releases or a public website.
2. Confirm separate **MyNotes Trial** icon, launching, writing and normal original MyNotes still present. Create only disposable notes: distinct ink on three pages, two colors and both eraser modes. Exit/reopen and compare.
3. Capture private baseline note hashes or an independent backup. Refresh SideStore and MyNotes Trial on-device; reopen and compare notes.
4. Import build 2 through SideStore as an **in-place update**, same actual installed identifier/account. No uninstall. Confirm build 2 and unchanged notebook/page identities and drawing data.
5. Record signing expiry and refresh outcome. A manual refresh today does not prove seven-day survival or unattended automatic refresh. Later missed-refresh/recovery tests use only the trial app and require an independent backup first.
6. Do not deliberately invalidate global pairing or revoke certificates while other apps depend on them. A safe pairing-recovery test needs separate owner approval and a documented restore path. If pairing naturally fails, preserve data and follow the official recovery guide.

Stop and preserve logs on failure; distinguish NOT RUN from FAIL. If a future recipient never has access to a locally paired computer, first-time SideStore installation remains blocked despite this Mac-side success. No permanent free signature or guaranteed unattended refresh is promised.
