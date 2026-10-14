# Native iPad App — Roadmap

**Active 2026-10-14:** SwiftUI + PencilKit + PDFKit. Owner cancelled PWA; keep learning website separate. See [native deployment plan](docs/NATIVE_DEPLOYMENT_PLAN.md).

**Core requirement:** Independently installed native iPad app, no Apple Developer Program membership, student's only device iPad, own Mac remote, third-party stylus. SideStore is a **conditional** delivery option, not a no-expiry certificate; initial local computer pairing and weekly signing refresh still matter.

## Early go/no-go gates

- [ ] [#1](https://github.com/hamperme/MyNotes-iPad/issues/1): run XcodeGen bootstrap/check and build native project on developer's Mac.
- [ ] [#10](https://github.com/hamperme/MyNotes-iPad/issues/10): verify a re-signable IPA, physically initialize SideStore on student iPad, launch and refresh in place from the iPad.
- [ ] [#2](https://github.com/hamperme/MyNotes-iPad/issues/2): the student's actual third-party stylus works in PencilKit with acceptable palm rejection; test .pencilOnly vs .anyInput.

If recipient cannot temporarily pair iPad with any computer, **pause SideStore delivery** and report the blocker rather than promising OTA installation.

## Functional milestones

- [ ] [#2 PencilKit](https://github.com/hamperme/MyNotes-iPad/issues/2): pen colour/width, eraser, lasso selection/move/scale (device proof), undo and restart persistence.
- [ ] [#3 Pages and templates](https://github.com/hamperme/MyNotes-iPad/issues/3): ruled/grid/dotted/blank; add, delete, reorder, stable page IDs; 20-page smoke.
- [ ] [#4 Library and folders](https://github.com/hamperme/MyNotes-iPad/issues/4): rename, delete safely, notebooks and subject folders, versioned storage migration.
- [ ] [#5 PDF import and markup](https://github.com/hamperme/MyNotes-iPad/issues/5): original preserved, editable page overlays, coordinate-aware zoom and 50-page test.
- [ ] [#6 Durability and backup](https://github.com/hamperme/MyNotes-iPad/issues/6): explicit failure UI, undo/redo, Files/iCloud Drive export + restore, version upgrade regression.

## Release acceptance

- Actual build & install proved, not just source parse.
- Student installs a dedicated Home Screen icon and uses their third-party pen on their own iPad.
- SideStore refreshed in-device; missed refresh and pairing loss documented. Free signature **never assumed permanent**.
- Note export and restore tested, and data survives at least one in-place app update.
- No private data uploaded to GitHub, learning website, or release assets.
- Each PR updates handoff.md / PROGRESS.md with real test logs and next steps.
