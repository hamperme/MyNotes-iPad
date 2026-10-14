# Agent instructions (Codex / ChatGPT / other coding agents)

The project is a private, native iPad handwriting app using SwiftUI, PencilKit and (future) PDFKit. **Read `handoff.md` first**; it is the canonical cross-agent transfer record. See `PROGRESS.md` for verified milestone state and `ROADMAP.md` for scope.

## Non-negotiable rules

1. Do not claim builds or tests passed without actual execution and exact evidence. If not on macOS, mark `not run (Xcode unavailable)`.
2. Keep pen strokes editable: preserve original PDF files, and store per-page `PKDrawing` data separately from background/template/PDF.
3. Preserve user data and backward compatibility. Storage schema updates require migration + recovery consideration. Never overwrite damaged indexes silently.
4. No secrets, signing keys, personal PDFs, account identifiers, or user notes in Git.
5. No external backend/analytics, dependencies, or broad refactors without a documented decision in `docs/DECISIONS.md`.
6. Keep PRs small and single-purpose. For each PR, link an Issue, provide reproduction/verification steps, and update `handoff.md` + `PROGRESS.md`.
7. Never mark incomplete work complete based only on file existence or AI-generated code. Focus on running on the user's actual iPad.

## Standard workflow

- **Start:** `git status`, pull latest, read `handoff.md` → `PROGRESS.md` → `ROADMAP.md` → relevant code, Issues, PRs.
- **Implement:** create `feat/issue-N-short-description` or `fix/issue-N-short-description`, add acceptance checks, avoid overlapping agent work.
- **Verify:** `./scripts/check.sh` on Mac, plus `docs/TEST_PLAN.md` physical-device checks as applicable.
- **Review:** document specific risks, tests performed and tests not performed. Request human/second-agent review before merging significant storage/PDF changes.
- **Handoff:** update `handoff.md` Snapshot and log + `PROGRESS.md`; write the next agent's first concrete command/task.

In case of conflicting instructions, preserve user data and stop for review rather than automatically resolving conflicts destructively.