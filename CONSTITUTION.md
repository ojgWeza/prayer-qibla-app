# Project Constitution — Prayer Qibla App

Read this file first before doing any work on this project. Its purpose is to stop us
from re-learning the same lessons or re-litigating decisions that are already settled.

## 1. What this app is

A lightweight Android app (original scope: Android only — iOS is unconfirmed/unconfigured)
that does two things:

- **Prayer times**: from GPS, or from any city the user picks manually.
- **Qibla direction**: a compass using the device's real sensor.

Monetization is **AdMob ads only** (no subscriptions, no in-app purchases for now).
Audience: Egypt/Arab world first, global (Arabic/English) second.

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

## 3. Architecture, briefly

```
lib/
  main.dart                 — entry point, MaterialApp, locale handling
  l10n/app_strings.dart      — every user-facing string (AR/EN)
  services/
    prayer_times_service.dart — prayer time + qibla math (adhan_dart)
    location_service.dart     — GPS via geolocator
    geocoding_service.dart    — manual city search via Nominatim
    notification_service.dart — schedules adhan reminders (flutter_local_notifications)
    date_service.dart         — Hijri/Gregorian date formatting (hijri package,
                                 hand-rolled Gregorian names to avoid intl locale init)
    prefs_service.dart        — all local persistence (SharedPreferences)
    ad_service.dart           — AdMob init
    widget_service.dart       — pushes the rolling prayer schedule to the Android
                                 home screen widget (see below)
  screens/
    home_shell.dart           — owns all shared state, passes it down as props
    prayer_times_screen.dart  — includes the Hijri/Gregorian date header
    qibla_screen.dart
    settings_screen.dart
    city_search_screen.dart
  widgets/
    banner_ad_widget.dart
    star_watermark.dart      — tiled seal (ring + eight-point star) background
                                texture, a CustomPainter, applied behind every tab
    qibla_compass.dart       — the real brass astrolabe compass (CustomPainter):
                                ring, engraved ticks, cardinal letters, medallion,
                                two-tone needle — replaces a bare Icons.navigation
```

**Android home screen widget** (added 2026-08-06): a native `NextPrayerWidgetProvider`
(`android/app/src/main/kotlin/.../NextPrayerWidgetProvider.kt`, extends the `home_widget`
plugin's `HomeWidgetProvider`) plus `next_prayer_widget.xml` / `next_prayer_widget_info.xml`
/ `widget_background.xml` under `android/app/src/main/res/`. It is intentionally
Flutter-engine-independent: `widget_service.dart` pushes the whole rolling schedule
(today + several days ahead, mirroring the notification window) as JSON whenever
`home_shell.dart` recomputes prayer times; the native provider's job is only to find
the first entry whose timestamp hasn't passed yet and render it, so Android's own
periodic `updatePeriodMillis` refresh keeps the widget honest even when the app isn't
opened. The widget reuses `@drawable/ic_launcher_foreground` (the generated seal motif)
at low opacity as a background watermark rather than any new art asset.

`home_shell.dart` is the single source of truth for state (location, prayer times,
settings). No external state management library (Provider/Riverpod/Bloc) — the app isn't
big enough to justify one yet.

**App icon**: generated by `flutter_launcher_icons` (config in
`flutter_launcher_icons.yaml`) from `assets/icon/icon_square.png` (legacy) and
`assets/icon/icon_foreground.png` (adaptive-icon foreground, transparent padding) — both
are the same seal motif (ring + eight-point star) drawn as flat vector shapes, gold on
the app's primary teal. Re-run `dart run flutter_launcher_icons` after changing either
source image; don't hand-edit the generated `android/app/src/main/res/mipmap-*` files.

**Design mockup:** there is a separate static HTML artifact used to iterate on visual
design before touching Flutter code. It is NOT wired to the real app and can drift out
of sync — see "Learnt lessons" below on how badly that drift can confuse feedback.

**Design reference assets (`design/`) are gitignored, not committed.** The Organic
design handoff (`design/Prayer times app design.zip` + its extracted
`design_handoff_prayer_qibla_app/`) and the approved Claude-Design screenshots
(`design/ScreenShots/*.png`) that this session's redesign (2026-08-07) was built
against live under `design/`, which `.gitignore` excludes (line ~46, pre-existing rule,
not added this session). **These files will NOT be present on a fresh clone** — if a
future session needs to re-check something against the original design source, ask the
user to re-supply `design/` rather than assuming it's still there.

## 4. Learnt lessons — index (full detail in `LESSONS.md`)

The detailed, dated debugging/decision narratives that used to live in this section now
live in **`LESSONS.md`**, unchanged, in full — moved out to keep this file's mandatory
every-session read light. **Grep `LESSONS.md` for the relevant keyword before debugging
something in one of these areas from scratch** — most of these were expensive to figure
out the first time, and the fix/root-cause is already written down.

Topics covered (grep `LESSONS.md` for these keywords):

- **Android build (Gradle)** — `compileSdk`/desugaring requirements, R8-minification-off
  (WorkManager crash), ephemeral CI debug keystore → signature mismatches on reinstall.
- **Third-party packages** — `flutter_compass` web-stream quirk, `DropdownButton` width
  bug, `flutter_timezone` API shape, `hijri` locale keys, `adhan_dart`'s
  UTC-labeled-but-correct timestamps + the two-stage timezone-rendering fix,
  `flutter_local_notifications`' Android 14+ exact-alarm permission gotcha (silently
  cancels all scheduling if ungranted).
- **Android home screen widgets (RemoteViews)** — RTL text/layout-direction quirks,
  mockup-before-XML, icon reuse, `RemoteViews` view support, grid-cell sizing floor, XML
  comment `--` parse bug, `google_fonts` doesn't reach `RemoteViews`, `setRotation`,
  static-needle decision.
- **Local device testing** — adb/JDK setup, NDK license dead end, wireless adb pairing,
  Location-Services-off vs. permission-denied, Appetize.io dead end, ephemeral-keystore
  issue also applies to debug builds, screenshot-focus privacy check, MSYS path-mangling
  fix, local-build abandonment (full failure chain).
- **Local Android emulator** — SDK/JDK setup, `avdmanager -d` bug + fix, hypervisor
  driver requirement, `ANDROID_AVD_HOME` gotcha, working boot recipe.
- **MCP servers** — `mobile` (ADB/emulator driver), `dart` (Flutter MCP, web-verification
  limits).
- **GitHub / gh CLI** — workflow-scope auth fix, gh path/auth-persistence gotchas,
  `workflow_dispatch` vs. push-trigger, HTTP 500-but-dispatched, GitHub Actions outages,
  CI Flutter-version pin drift bug.
- **External images / design assets** — verify images visually before use,
  mockup-vs-real-app drift risk, icon design lessons.
- **Tooling notes** — browser automation (Claude-in-Chrome vs. sandboxed browser)
  history, the `flutter run -d web-server` fast verification loop (and its
  cross-context-clear pitfall), Python unavailable locally.

Add new lessons to `LESSONS.md` (not here) whenever something costs real time to figure
out, so the next session doesn't pay the same cost.

## 5. Open decisions

- Are we actually building iOS, or is this Android-only? (Original scope: Android only.)
- Will we ever need a backend (e.g. for cloud sync)? No, as of now.

## 6. Settled feature decisions (don't re-litigate without new input)

- **Per-day/per-prayer notification muting was removed (2026-08-05), not just
  deferred.** The old UI (`_PrayerDayToggleRow`/`_DayChip` in `settings_screen.dart`,
  plus `PrefsService.getNotificationMatrix`/`setNotificationEnabled`) grouped by
  **prayer** with 7 day-toggles underneath each one. The user wants the *opposite*
  shape next: grouped by **day**, with the prayers listed underneath each day. Rather
  than leave the old, soon-to-be-replaced UI in place, it was deleted outright — see
  TODO.md for the redesign task. In the meantime, `scheduleUpcoming(...)` in
  `home_shell.dart` fires all 5 notifiable prayers unconditionally
  (`isEnabled: (weekday, prayer) => true`); there is currently no per-prayer/per-day
  muting at all until the redesign lands.
- **`applicationId` is finalized (2026-08-06): staying on `com.hgdroid.prayer_qibla`,
  no rename.** Explicitly confirmed with the user, since this can never change again
  after the first Play Store upload. Don't revisit this without a strong new reason —
  a change now would mean starting over as a brand-new Play Store listing.
- **First-ever app launch defaults to Cairo, Egypt (2026-08-06), not a live GPS
  prompt.** Confirmed bad UX live on the Mi 10: a fresh install blocked on a full GPS
  permission flow with nothing but a blank screen until it resolved. Decided
  approach, in order of precedence in `home_shell.dart`'s `_bootstrap()`: (1) a saved
  manual location always wins, (2) otherwise a cached GPS fix (`PrefsService`) is
  used instantly while a fresh fix refreshes in the background, (3) otherwise —
  meaning no location has ever been resolved or picked at all — default to Cairo
  (`_defaultLatitude`/`_defaultLongitude` constants) with **no automatic GPS
  prompt**. The user opts into GPS or a specific city explicitly via the existing
  location picker (`CitySearchScreen`, tap the app bar location chip). Don't revert
  to auto-requesting GPS on first launch without asking again.
- **AdMob real IDs, the release signing keystore, and re-enabling R8 minification are
  all deliberately still open/undecided** as of 2026-08-06 — each was asked about
  individually and none were confirmed (the AskUserQuestion prompts were dismissed or
  the user redirected to something else first). Don't assume a default for any of
  these three; ask again before acting on them.
