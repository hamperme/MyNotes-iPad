# MyNotes native app — cross-agent rules

**Canonical app repo:** https://github.com/hamperme/MyNotes-iPad. The owner cancelled PWA on 2026-10-14. Separate website https://maplehub.study stays a StudyHub, not the delivery target for the native app.

READ FIRST: handoff.md → PROGRESS.md → docs/NATIVE_DEPLOYMENT_PLAN.md → ROADMAP.md → relevant code/Issues/PRs.

1. Build SwiftUI + PencilKit + PDFKit **native standalone iPad application**. Do not implement PWA/React/Cloudflare as a replacement.
2. Free Apple Personal Team is valid seven days, **not permanent**. SideStore is a third-party trial distribution target and requires local computer pairing with recipient's iPad first. The student **owns a Windows PC** (no Mac) and can perform USB/iloader setup locally; no actual pairing has been verified. Never claim fully remote, perpetual, zero-maintenance installation.
3. Real Xcode, IPA packaging, SideStore, Apple Pencil/PencilKit input, backup tests must be marked NOT RUN until actually verified; cite commands and device versions in PR.
4. Test third-party stylus under .pencilOnly and .anyInput on student's device. Goodnotes success alone does not prove PKCanvasView compatibility.
5. Preserve original PDFs, distinct editable per-page PKDrawing, stable page IDs, restore-capable backups, and backward compatibility. No destructive changes to app Bundle ID or file format.
6. Keep signing credentials, Apple Accounts, pairing files, private PDFs, school notes and certificates off GitHub and out of any distributed package.
7. One Issue per branch, small PRs with review. Every change updates both handoff.md and PROGRESS.md with tests and risks.
8. No paid Apple account/services or App Store release without owner's explicit approval.
