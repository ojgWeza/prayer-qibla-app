## 2. Non-negotiable principles

1. **Everything runs with no backend of our own.** Prayer times and qibla are computed
   on-device (`adhan_dart`). The one exception is manual city search, which calls the
   free Nominatim (OpenStreetMap) API — once per search, not a recurring dependency.
2. **Building the app locally still doesn't work — but running a pre-built APK locally
   now does.** Builds (compiling) happen entirely on **GitHub Actions**
   (`.github/workflows/build.yml`) — Gradle/NDK/Kotlin on this machine are a confirmed
   dead end (see "Local device testing" below). The Flutter SDK is local at
   `D:\dev\flutter\bin` (also `D:\dev\platform-tools\adb.exe`) — **neither is on PATH**,
   but both exist and work when invoked by full path
   (`"D:\dev\flutter\bin\flutter.bat" analyze`, etc.). **Don't report "flutter isn't
   available"/"can't verify the build" from a bare `flutter` PATH lookup failing** —
   check `grep -i flutter CONSTITUTION.md` or just try the full path first; a real APK
   can still be produced by pushing + dispatching the CI workflow
   (`gh workflow run build.yml --ref <branch>`, `gh run watch <id> --exit-status`) and
   pulling the artifact down (`gh run download <id> -n app-debug`) to install via
   `adb install`. As of 2026-08-15 there is also a **local Android SDK + emulator**
   (separate from the build toolchain, see "Local Android emulator" below) at
   `D:\dev\android-sdk` for running that already-built APK without a physical device —
   still blocked on one one-time Windows setting as of this writing.
3. **Every change must pass, before it's pushed:**
   - `flutter analyze` (must say "No issues found")
   - `dart run custom_lint` (the `impeccable_flutter_lints` check for "AI-slop" UI
     patterns — must come back clean)
   - `flutter test`
   CI runs these too, but catching problems locally first is cheaper.
4. **Git workflow: one branch per feature**, merged into `master` once verified
   (analyze/lint/test green, ideally a passing CI build on the PR). Direct commits to
   `master` are no longer the default — this was a deliberate change the user asked for
   partway through the project; don't revert to direct-to-master without asking again.
5. **Translations live in `lib/l10n/app_strings.dart`** — a plain Map, no code-gen, no
   ARB files. Keeps footprint and complexity small.
6. **All settings live in `SharedPreferences` via `PrefsService`** — no database, no
   server-side storage of any kind.
7. **Current AdMob IDs are Google's official test IDs**
   (`ca-app-pub-3940256099942544/...`). **Must be swapped for real IDs before any real
   Play Store release.**
8. **No default "AI-generated" look.** No `Colors.deepPurple` seed, no literal
   `Colors.black`/`Colors.white`, no low-contrast text. This is what
   `impeccable_flutter_lints` actually checks for — trust it.
9. **Repo docs (this file, TODO.md, commit messages, code comments) are in English**,
   even though the working conversation with the user happens in Egyptian Arabic. Don't
   mix languages into project files.
10. **Don't run the full CI build/merge cycle after every small change.** Each CI build
    takes ~7-10 minutes; the user explicitly said this is too slow to repeat per tiny
    fix. Batch several changes together on a branch and only push/merge to trigger a
    real build when a meaningful batch is ready, or when the user explicitly asks for a
    build/release. Verify locally first (`flutter analyze`/`custom_lint`/`flutter test`,
    plus a real connected device when one is available — see "Local device testing"
    below) instead of defaulting to a CI round-trip for every fix.

