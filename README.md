# MyNotes-iPad — Native handwritten notes for iPad

> **Active project (2026-10-14).** The user explicitly cancelled the PWA pivot and chose a **real standalone iPad App**. This repository is the single source of truth for the SwiftUI/PencilKit/PDFKit product. Start with [docs/NATIVE_DEPLOYMENT_PLAN.md](docs/NATIVE_DEPLOYMENT_PLAN.md), [PROGRESS.md](PROGRESS.md) and [handoff.md](handoff.md). The other [maplehub-study](https://github.com/hamperme/maplehub-study) repository stays a separate existing teaching website; no PWA work should continue there.

## Product goal

The brother in Mississauga has a **Windows PC + iPad** and a third-party stylus, but no Mac. The developer has a Mac. Need an **independently installed app** with handwriting, eraser, colours/widths, four templates, pages/folders, PDF annotations and lasso moving/scaling. It must be offline-first and preserve notes across app upgrades.

**No Apple Developer Program ($99/year), no App Store release.** Apple's free provisioning expires in seven days. [SideStore](https://docs.sidestore.io/docs/installation/install) is the first candidate for re-signing on-device, but **can be set up locally by the student on his own supported Windows PC** (via USB + iloader); Windows may also be needed later if device pairing expires. Permanent fee-free, signing-free deployment is **not promised**.

## State

- SwiftUI project skeleton, XcodeGen spec, editable PKDrawing per-page storage and paper backgrounds **drafted**.
- No verified Xcode build or device test, no working IPA, no tested SideStore setup, no tested PDF overlay/export, folders, backup or restore.
- Do not use real school notes until note export/restore is verified.
- Site https://maplehub.study remains a separate StudyHub; may optionally distribute instructions and an IPA later, but the domain **does not solve iOS signing**.

## First development steps

1. Clone: `git clone https://github.com/hamperme/MyNotes-iPad.git`
2. Install compatible Xcode and XcodeGen (`brew install xcodegen`).
3. `./scripts/bootstrap.sh` and `./scripts/check.sh` on your Mac; fix any compile issues.
4. The student can prepare his own Windows installation: [SideStore Windows prerequisites](https://docs.sidestore.io/docs/installation/prerequisites), [installation guide](https://docs.sidestore.io/docs/installation/install). He needs a USB data cable, compatible 64-bit Windows PC, iTunes/Apple Devices, iloader, LocalDevVPN and his own Apple Account. **None of this has been tested on his device yet.**
5. Work on [#1 Native build](https://github.com/hamperme/MyNotes-iPad/issues/1) and [#10 SideStore delivery feasibility](https://github.com/hamperme/MyNotes-iPad/issues/10) **before** overbuilding.
6. Test third-party stylus with `PKCanvasView.drawingPolicy` = `.pencilOnly` / `.anyInput` in the actual recipient iPad. Goodnotes compatibility is not proof it works as native PencilKit input.
7. Add and test full backup/restore to Files/iCloud Drive before a real class notebook.

## Code

- `project.yml`: XcodeGen configuration (iPadOS 17+ target in current draft).
- `MyNotes/App/`: SwiftUI entry.
- `MyNotes/Views/`, `MyNotes/Components/`: editor, library, PencilKit canvas and paper background.
- `MyNotes/Models/`, `MyNotes/Services/`: local note records and editable PKDrawing persistence.
- `docs/ARCHITECTURE.md`, `docs/DECISIONS.md`, `docs/TEST_PLAN.md`: engineering details.
- `ROADMAP.md`: phases and acceptance criteria.

## AI collaboration

- `handoff.md`: single canonical cross-agent handoff record.
- `PROGRESS.md`: verified milestone state.
- `AGENTS.md` and `CLAUDE.md`: agent instructions.
- Issues/PRs: tasks/reviews. One Issue per branch; report actual tests, skipped tests and data-migration impact.
- Never commit sign-in credentials, provisioning profiles, device pairing files, certificates, personal notes or private PDFs.
