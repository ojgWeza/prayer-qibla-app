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
2. **No local Android SDK on the dev machine.** Builds happen entirely on
   **GitHub Actions** (`.github/workflows/build.yml`) — a deliberate choice to avoid
   multi-GB local installs. Only the Flutter SDK is local (`D:\dev\flutter`), for
   `flutter analyze` / `flutter test` / editing.
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
  screens/
    home_shell.dart           — owns all shared state, passes it down as props
    prayer_times_screen.dart  — includes the Hijri/Gregorian date header
    qibla_screen.dart
    settings_screen.dart      — includes the per-day/per-prayer notification grid
    city_search_screen.dart
  widgets/
    banner_ad_widget.dart
```

`home_shell.dart` is the single source of truth for state (location, prayer times,
settings, notification matrix). No external state management library (Provider/Riverpod/
Bloc) — the app isn't big enough to justify one yet.

**Design mockup:** there is a separate static HTML artifact used to iterate on visual
design before touching Flutter code. It is NOT wired to the real app and can drift out
of sync — see "Learnt lessons" below on how badly that drift can confuse feedback.

## 4. Learnt lessons

A living log. Add to this whenever something costs real time to figure out, so the next
session doesn't pay the same cost.

### Android build (Gradle)
- `permission_handler_android` needs `compileSdk = 37` — Flutter's default (36) isn't
  enough.
- `flutter_local_notifications` needs `isCoreLibraryDesugaringEnabled = true` in
  `compileOptions`, plus `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`
  in `dependencies`, both in `android/app/build.gradle.kts`.
- If Gradle fails complaining about compileSdk or desugaring, the fix is almost always
  in that same file.

### Third-party packages — non-obvious details
- `flutter_timezone` (v5) returns a `TimezoneInfo` object, not a `String` — use
  `.identifier`.
- The `hijri` package's locale keys are exactly `'ar'` and `'en'` (not `'Arabic'` or
  anything else).
- `adhan_dart`: `Qibla.qibla(coordinates)` returns the bearing directly; `PrayerTimes`
  takes `CalculationParameters` from `CalculationMethodParameters.<method>()`.

### GitHub / gh CLI
- If `git push` is rejected for touching `.github/workflows/*.yml` with "OAuth App...
  without `workflow` scope", fix with `gh auth refresh -h github.com -s workflow` (or
  request the full practical scope set up front: `repo,workflow,gist,read:org`).
- If `git push` 403s under the wrong account, run `gh auth setup-git` so git uses the
  gh-managed token instead of a stale credential in Windows Credential Manager.
- Downloading GitHub Actions artifacts requires being logged in. To hand someone a
  no-login direct download link, cut a **GitHub Release** and attach the APK as an
  asset (`gh release create ... path/to.apk`).

### External images / design assets
- **Look at any candidate image yourself (Read tool) before using it.** A text-based
  WebFetch description of an image is not reliable for judging framing/angle — we once
  used what turned out to be a full museum display-case photo instead of a clean face-on
  shot of the object, because the text description didn't say so.
- In the end, real photos were dropped entirely for the compass graphic in favor of a
  flat CSS treatment, to stay visually consistent with the rest of the (flat, Material)
  UI. An ornate/photographic element next to flat cards read as mismatched, not "richer."
- The eight-point star motif (`.star8`) is just two overlapping squares, one rotated
  45°, with a border instead of a fill. Cheapest way to get an authentic Islamic
  geometric mark without an image or hand-authored SVG path.
- **When feedback says "use X as the background", confirm background of *what*.** We
  once applied a requested background texture to the mockup *artifact's own page
  wrapper* when the user meant the real app's background — the artifact page chrome and
  the thing being designed are two different surfaces, and it is easy to conflate them.
  Ask, or default to applying visual changes to the artifact's simulated phone screens
  (the actual design surface), not the page around them.
- **Keep the mockup in sync with real app features, or say explicitly that it's
  behind.** We implemented the Hijri/Gregorian date header in the real Flutter code
  (`prayer_times_screen.dart`) but forgot to reflect it in the separate HTML mockup,
  which caused the user to think the feature had been dropped. The mockup and the real
  app are two independent files — a change to one does not propagate to the other.

### This session's tooling
- The in-session Browser tool was non-functional this session ("Browser pane is not
  displayed"). Don't rely on it for self-verification — inspect files directly instead
  (decode base64, count divs, etc.), and say plainly when you can't visually confirm
  something rather than implying you did.
- Python isn't available in this shell. Use PowerShell
  (`Add-Type -AssemblyName System.Drawing`) for any image crop/resize/compress work.

## 5. Open decisions

- Are we actually building iOS, or is this Android-only? (Original scope: Android only.)
- Will we ever need a backend (e.g. for cloud sync)? No, as of now.
