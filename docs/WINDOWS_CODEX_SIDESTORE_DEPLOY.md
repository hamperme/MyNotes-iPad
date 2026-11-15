# Windows Codex × SideStore — MyNotes iPad 部署及验收手册

Updated 2026-11-15 · Issue #10 · **Release files uploaded; SideStore execution still NOT RUN.**
For: developer's Mac + student's Windows PC and iPad. This is a standalone native SwiftUI/PencilKit app, **NOT a PWA**.

> **CURRENT DEPLOYMENT INPUT — 2026-11-15 (GitHub Pre-release available).** Two unsigned test IPAs, their manifests, and SHA256SUMS are already published in this repository. **Do not rebuild on the Mac just for the first SideStore installation.** Use the verified release first. SideStore sign/install/refresh is **NOT RUN**. The backup/restore release gate is still open.

## Start here — download the already built release

1. Open [sidestore-trial-pdf-2026-11-15](https://github.com/hamperme/MyNotes-iPad/releases/tag/sidestore-trial-pdf-2026-11-15) in a **browser signed into a GitHub account with READ access to this private repository**. Read permission is enough; the student does not need Git, Codex repository access or write/edit permission. The release is intentionally not public.
2. Under **Assets**, download `MyNotes-Trial-build-1.ipa`, `MyNotes-Trial-build-2.ipa` and `SHA256SUMS.txt`. The manifest JSONs are optional for installation but useful for investigation. If the student has no GitHub access, the owner downloads those assets using their own authorized account and transfers them by USB/AirDrop/private file sharing. **Do not share the owner's GitHub credentials or PAT.**
3. Windows PowerShell (run from the folder containing downloaded files):

~~~powershell
Get-FileHash -Algorithm SHA256 .\MyNotes-Trial-build-1.ipa
Get-FileHash -Algorithm SHA256 .\MyNotes-Trial-build-2.ipa
Get-Content .\SHA256SUMS.txt
~~~

GitHub Release asset SHA-256 values independently confirmed from its metadata:

| Asset | SHA-256 |
| --- | --- |
| `MyNotes-Trial-build-1.ipa` | `6ef0f2261f87ff83700ae5aed0de69edcd7ff0f2907b7f5c734a64469403933e` |
| `MyNotes-Trial-build-2.ipa` | `788274a6dd8bca0e9762700b4cff30fc1e3cd1c981724a16875e0f18069e42f9` |

Both expected values must match the Windows outputs and SHA256SUMS. On mismatch: STOP, redownload from the private release. The owner reports independent re-download/verification succeeded; this author independently checked GitHub release metadata, **not** the binary bytes.
4. Transfer **build 1** to the iPad **Files** app first; do not install build 2 yet. Follow the SideStore/iloader instructions below: set up SideStore and refresh itself, install build 1, create expendable test notes and verify refresh, then install build 2 as an **in-place upgrade without deleting build 1**.
5. If Windows Codex lacks access to this private repo, it can follow this text handed over by the owner; it cannot authenticate to GitHub on the student's behalf. No need to edit GitHub to complete the experiment. Send sanitized PASS/FAIL/NOT RUN back to the owner to update Issue #10.

**Release provenance:** GitHub prerelease source ref `7f73f7e4c14ff648852e30d422de541eafd467c3` (#12). Compared with merged main `c274de8f7fd82f81d9bcab4b0bfb3d058ace75aa`: all 11 `MyNotes/**` source files and `project.yml` paths matched by Git object SHA at review time. GitHub packages are unsigned, iPad-only, arm64, iOS 17+; the download cannot launch until SideStore signs and installs it. This is a **test**, not the stable school-notes release.

## 当前现场替代方案：由开发者 Mac 首次安装 SideStore（2026-11-15）

**设备现状：** 弟弟的 Windows 暂时检测不到 iPad，开发者 Mac 与弟弟 iPad 现在在同一地点。可用 **Mac + USB** 进行 SideStore 首次安装和配对；这**不会**使以后正常刷新必须回到这台 Mac。SideStore 的日常刷新是在 **iPad + Wi-Fi + LocalDevVPN** 完成。

官方依据：[安装](https://docs.sidestore.io/docs/installation/install)、[准备](https://docs.sidestore.io/docs/installation/prerequisites)、[配对失效恢复](https://docs.sidestore.io/docs/advanced/pairing-file)。

1. Mac 安装官方 [iloader](https://github.com/nab138/iloader/releases)（选择 macOS 版本）；可依官方 prerequisites 完成必要组件。不要下载未验证的第三方打包器。
2. 将**弟弟的 iPad** 用数据线接入 Mac，解锁，在 iPad 上确认「信任此电脑」。在 iloader 中确认选中的设备是他的 iPad。
3. **使用弟弟自己的 Apple Account 签名**：由弟弟本人在 iloader 输入密码/2FA，并点击 `Install SideStore (Stable)`；不必与 Mac 登录的 Apple ID 相同。Codex 不要读取凭据。
4. iPad：设置 → 通用 → VPN 与设备管理 → 信任开发者；按 iPadOS 提示开启开发者模式并重启；在 App Store 安装并连接 `LocalDevVPN`，同时连接 Wi-Fi。
5. iPad：打开 SideStore，用首次安装的**同一个签名 Apple Account** 登录；`My Apps` → 点 SideStore 的剩余天数完成**首次手动刷新**。
6. 使用现成的 [私有 Release 2026-11-15](https://github.com/hamperme/MyNotes-iPad/releases/tag/sidestore-trial-pdf-2026-11-15) 两份 unsigned IPA，先核对 SHA-256，再安装 Build 1 创建**可丢弃测试笔记**、手动刷新、最后通过 Build 2 原位升级验证测试笔记未丢失。IPA 可以由开发者通过 AirDrop 发送到弟弟的 iPad「文件」App；Windows 无需 GitHub 写权限和 Xcode。
7. **特别注意：** 配对文件与设备有关，当前安装所需的配对已由 Mac 写入 iPad/SideStore。正常每周刷新不用 Mac、也不用弟弟 Windows。但未来如果 iPadOS 更新/重置或者配对随机失效，官方要求连接一台能识别 iPad 的电脑重新置入配对文件；**若他的 Windows 仍然识别不到，就需要再次使用 Mac 或先修复 Windows 设备驱动问题**。尽量在分开前现场测试续签。
8. 不要卸载已有 Xcode 签名的 `MyNotes`、不要把 MyNotes Trial 安装成相同 Bundle ID，也不要擅自批准吊销其他 App 依赖的签名证书。真实笔记备份恢复目前没有验收通过。

**状态：Mac 首次替代路线可行，是否实际完成 USB 配对、SideStore 安装和刷新仍是 NOT RUN，需当事人验证后在 Issue #10 登记。**

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

**Mac build is only mandatory when producing a NEW IPA, not for this already published test release.** Windows cannot run Xcode or compile the SwiftUI/PencilKit app. Packaging proves ZIP structure, NOT SideStore install success. Do not claim otherwise. Use private file transfer (AirDrop/USB/private shared file), include expected SHA-256. Avoid publishing app with credentials or private user notes.

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
