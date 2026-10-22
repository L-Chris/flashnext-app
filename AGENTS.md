# Repository Instructions

## Android Verification

- The active app is the native Kotlin project in `android/`. Do not reintroduce Flutter/Dart code or dependencies.
- Preserve the established interface when changing implementation: icon controls, rating labels and colors, theme, layout, accessibility, and interaction. The UI reference and screenshots are in `docs/implementation/android-ui-parity-2026-10-22.md`.
- Before preparing a release tag, run the same checks as CI: `android/gradlew -p android testDebugUnitTest lintDebug`, then build the production path with `android/gradlew -p android assembleRelease`. On Windows use `android/gradlew.bat`.
- Run relevant existing emulator/device tests for changed behavior. Keep real-server and APK-fixture checks separate from the default test suite, use local fixtures for writes, and state any skipped checks or device limitations accurately.
- Follow [the release procedure](docs/RELEASING.md). Versions come only from `android/version.properties`; increase both `versionName` and `versionCode` for a release.

## GitHub Release Notes

- The GitHub Release title must exactly match its tag, including the lowercase `v` prefix, for example `v0.3.2`. Do not add a product name, date, subtitle, or suffix. This rule concerns the release title, not headings in its body.
- With the GitHub CLI, explicitly use the tag as the title and a UTF-8 notes file: `gh release create <tag> --verify-tag --title <tag> --notes-file docs/releases/<tag>.md`. Tag CI normally handles this; do not create a competing release while CI is running. Verify the published title matches the tag.
- Write release notes in English first, followed by the Simplified Chinese translation inside an HTML `<details>` block. The marker must be exactly `<summary>中文更新说明</summary>`, with no attributes or altered wording.
- Write for ordinary users. Lead with the change in their experience and its benefit. Avoid library names, code symbols, implementation details, and technical terms unless users need them for compatibility or action.
- Keep notes concise: one short sentence per entry, combine closely related work, and omit internal maintenance with no meaningful user-facing effect.
- Classify changes under these headings, in this order, in both languages: `## Feature` for new capabilities, `## Improvement` for intentional enhancements to working behavior, and `## Fix` for defects or regressions. Omit empty categories; use the same English headings in the Chinese section.
- Assign each change to one primary category and mention it once per language. Describe a new feature and the compatibility work or refinements needed to deliver it together under `Feature`; do not duplicate them as improvements or fixes.
- Split categories only for independently meaningful changes. When uncertain, prefer one concise entry describing the primary user-facing outcome.
- English and Chinese entries must be one-to-one translations with identical category and item order, without additions or duplication in either language.
- Keep all English-only content before `<details>` and all Chinese-only content inside it. If a Full Changelog link is included in both languages, put it in both sections, never after `</details>`.
- Use this structure, omitting categories without entries:

  ```markdown
  ## Feature

  - English description of a new capability.

  ## Improvement

  - English description of an enhancement.

  ## Fix

  - English description of a correction.

  <details>
  <summary>中文更新说明</summary>

  ## Feature

  - 新功能的中文说明。

  ## Improvement

  - 现有功能改进的中文说明。

  ## Fix

  - 问题修复的中文说明。

  </details>
  ```

### Encoding and Publication Verification

- Write notes explicitly as UTF-8 and publish with `--notes-file`. Prefer `apply_patch` for Chinese text. Do not pipe Unicode-containing PowerShell here-strings into native programs without explicitly controlling the pipe encoding; UTF-8 file output cannot repair text already damaged by the pipe.
- Before publishing or editing a release, read the actual notes file as UTF-8 and inspect Chinese text and punctuation. Verify the exact summary marker; reject replacement characters (`U+FFFD`), unexpected question marks replacing text, and other garbled content.
- After publishing or editing, fetch the GitHub release body, repeat the encoding and content checks, verify the title, and compare the remote body with the local file. Equality alone is insufficient because both may contain the same damaged text. Display and inspect the fetched Chinese section as UTF-8.
- If encoding damage is found, regenerate the intended UTF-8 text, update the release, and fetch it again for verification; never reuse the damaged body as the source.

### Contributor Attribution

- Before publishing, inspect commits and associated PRs between the previous release tag and the new tag. Credit only work shipped in this release; query GitHub's commit-to-PR associations to cover squash/rebase merges.
- Credit external contributions in their own `Feature`, `Improvement`, or `Fix` entry with absolute links to the author's GitHub profile and contributing PR. The maintainer is `L-Chris`; omit attribution for the maintainer's own changes.
- Use the PR author and verified co-authors, not the person who merged the PR or the merge commit's committer. Confirm contributions against the included code.
- Preserve identical contributors and PR links in both languages. If multiple authors contributed to an entry, identify their respective work or split independently meaningful changes; do not attribute the maintainer's additions to an external PR author.
- For a verified external contribution without a PR, link its commit. Do not guess authorship from a display name or unverified email address.
- Attribution example: `Keep the selected card visible. — by [@contributor](https://github.com/contributor), [#3](https://github.com/L-Chris/flashnext-app/pull/3)`; use the same author and PR links in the corresponding Chinese entry.

These release rules are adapted from `F:/projects/ebook/torto/AGENTS.md`; the repository-specific commands above apply to FlashNext.
