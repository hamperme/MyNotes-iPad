# MyNotes-iPad progress

**Reviewed:** 2026-10-14  
**Direction:** native SwiftUI + PencilKit + PDFKit, **not PWA**.  
**State:** native code scaffold exists but **Mac build, IPA packaging, recipient install and all iPad real-device tests are NOT RUN**. SideStore distribution is an unproven plan, not a completed deployment.

| Stage | Issue | Verified status |
| --- | --- | --- |
| N0 Mac build & reproducible app export | [#1](https://github.com/hamperme/MyNotes-iPad/issues/1) | Not run; initial source scaffold only |
| N1 Third-party Pencil/eraser/lasso | [#2](https://github.com/hamperme/MyNotes-iPad/issues/2) | Tools wired in draft; not tested on student's iPad |
| N2 Pages & templates | [#3](https://github.com/hamperme/MyNotes-iPad/issues/3) | Basic add/switch/templates drafted; delete/reorder not done |
| N3 Folders/library | [#4](https://github.com/hamperme/MyNotes-iPad/issues/4) | Not done |
| N4 PDF import/overlay/export | [#5](https://github.com/hamperme/MyNotes-iPad/issues/5) | Not done |
| N5 Undo, durable saving, backup/restore | [#6](https://github.com/hamperme/MyNotes-iPad/issues/6) | Not done |
| D0 Fee-free remote install/refresh | [#10](https://github.com/hamperme/MyNotes-iPad/issues/10) | Not tested; initial physical computer pairing needed |

## Blocking risks

1. Apple free Personal Team provisioning expires every seven days. SideStore is an external tool, potentially subject to auto-refresh failure or pairing loss; it has not been installed or tested.
2. Student is remote and has **only an iPad**. First-time SideStore pairing needs a computer physically connected to his iPad; remote Mac alone cannot perform the pairing.
3. Need reproducible Mac Xcode build and re-signable IPA generation without paid program.
4. Third-party stylus works in Goodnotes/Notability per user report but PencilKit may classify it differently.
5. Must have actual backup/restore before student depends on notebooks for school.

## Recent history

- **2026-10-14** Owner cancelled PWA; restored original native repo as canonical app project and reopened native Issues #1–#6; created SideStore feasibility Issue #10. Documented limitations; **no app build/device test done**.
- **2026-10-14** Prior PWA plan (maplehub-study) was documentation only, no code shipped; now superseded.
- **2026-10-13** Original iPad SwiftUI draft and GitHub repo established; Swift static parsing reported, no Xcode builds.

See [deployment plan](docs/NATIVE_DEPLOYMENT_PLAN.md) and [handoff.md](handoff.md). Only record done after real validation.
