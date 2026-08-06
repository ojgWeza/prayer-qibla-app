# TODO — Prayer Qibla App

Everything that needs doing, grouped by status. Update this file as soon as something
is done — move it into "Done" rather than leaving it ambiguous.

## Done ✅

- [x] Flutter SDK installed locally (no local Android SDK — builds run on GitHub Actions)
- [x] Flutter project (`prayer_qibla`) created and pushed to a public GitHub repo
- [x] GitHub Actions workflow builds debug + release APKs on every push
- [x] `impeccable_flutter_lints` + `custom_lint` wired into CI
- [x] Prayer time calculation (`adhan_dart`) + qibla bearing
- [x] Prayer times screen (next-prayer highlight, banner ad slot)
- [x] Qibla screen (real compass via `flutter_compass`)
- [x] Settings screen (language, calculation method, madhab)
- [x] Arabic/English support (`AppStrings`) + RTL
- [x] GPS location with permission handling and clear error states
- [x] Manual city search (Nominatim) as an alternative to GPS, for any city worldwide
- [x] Hijri + Gregorian date header on the prayer times screen (`date_service.dart`,
      wired into `prayer_times_screen.dart` — **this exists in the real app**, it is
      just not yet reflected in the separate HTML design mockup)
- [x] Android build fixed (compileSdk 37 + core library desugaring)
- [x] First real APK built successfully and published as a GitHub Release
- [x] Local adhan notifications (`flutter_local_notifications`) — baseline version
- [x] Per-day, per-prayer notification toggles (7×5 matrix) replacing the single
      global switch — code complete, analyze/lint/test all green
- [x] Switched from direct-to-master commits to a feature-branch workflow (per user
      request)
- [x] Static HTML design mockup for prayer times / qibla / settings screens + a home
      screen widget preview
- [x] Subtle eight-point-star watermark as a background texture, tiled small across
      the whole screen (`lib/widgets/star_watermark.dart`, wired into the `HomeShell`
      Scaffold body behind the tab content) — matches the mockup's page-background
      treatment. The mockup itself also had a bug where its per-screen watermark
      silently failed to render (a `z-index: -1` span escaping its ancestor's stacking
      context because `.screen` never established one); fixed by switching the mockup
      to the same tiled-background-image approach instead of the broken single-emblem
      trick.
- [x] `CONSTITUTION.md` and `TODO.md` created to carry context across sessions
- [x] **PR #1** (per-day/per-prayer notifications + Hijri date) merged to master
- [x] **PR #2** (seal watermark + launcher icon) merged to master
- [x] First-ever live run of the app, via appetize.io (no local Android SDK/emulator
      available, and no physical device connected) — uploading the CI-built debug APK
      to Appetize's web emulator. This surfaced two real, previously-unflagged gaps,
      both fixed in PR #3:
      - Qibla screen showed a bare `Icon(Icons.navigation)` instead of the ornate brass
        astrolabe from the design mockup — that visual was never actually built in
        Flutter, only ever existed as HTML/CSS. Replaced with a real `CustomPainter`
        (`lib/widgets/qibla_compass.dart`): brass ring, engraved ticks, cardinal
        letters, faint star medallion, two-tone needle.
      - Prayer times/qibla bearing don't update if location changes after the app's
        first GPS fix — location was only ever fetched once at startup, with no
        continuous watch and no refresh affordance. Added pull-to-refresh on the
        Prayer Times screen (reuses the existing `onRetryLocation` callback, now
        properly awaitable instead of a fire-and-forget `VoidCallback`). Changing
        location via the in-app manual city-search picker already worked correctly.
- [x] **Found and fixed the real "crashes on startup" bug**, root-caused via an actual
      crash log (not guessing) captured on a physical device (Xiaomi Mi 10, Android 13)
      connected over wireless `adb` — no local Android SDK/emulator, so `platform-tools`
      was fetched standalone to `D:\dev\platform-tools` for this. The release APK was
      hard-crashing before Flutter/Dart even started:
      `Failed to create an instance of androidx.work.impl.WorkDatabase` inside
      `androidx.startup.InitializationProvider`. The obfuscated frame names in the trace
      (`a2.n`, `c4.b`, tagged `r8-map-id-...`) showed R8 minification silently running on
      release builds (recent Flutter/AGP default, despite no explicit `isMinifyEnabled`
      in this project) and stripping/renaming something WorkManager needs via
      reflection. Fixed by explicitly setting `isMinifyEnabled = false` /
      `isShrinkResources = false` for the release build type
      (`android/app/build.gradle.kts`).
- [x] **Verified the fix end-to-end on the real Mi 10**: installed the new release APK
      (had to `adb uninstall` first — every CI run signs with a fresh ephemeral debug
      keystore, so signatures don't match between builds until a real release keystore
      exists), launched it, no crash. Confirmed live on-device: the seal watermark tiles
      correctly in the background, the real qibla compass renders and points correctly,
      prayer times populate with the Hijri header, and the AdMob test banner loads.
      Also discovered along the way: the device's Location Services toggle was off
      system-wide, which is why no permission dialog ever appeared — not an app bug.
- [x] **PR #5**: fixed prayer times displaying in UTC instead of local time. Found live
      on the same Mi 10 (Cairo): Fajr showed 01:37 instead of the correct ~03:37, every
      one of the 6 times off by exactly the local UTC offset. `adhan_dart` returns
      UTC-flagged `DateTime`s; `computePrayerTimes()` now calls `.toLocal()` before
      returning them. See `CONSTITUTION.md` § Learnt lessons for the full root cause.
- [x] Added a **12-hour/24-hour time format toggle** to Settings (persisted via
      `PrefsService`, defaults to 24-hour — no behavior change for existing installs).
- [x] **Removed the per-day/per-prayer notification-muting UI** (the 7-day-chips-per-
      prayer grid in Settings, plus its `PrefsService` persistence) — grouped by
      *prayer* with days underneath, which the user now wants inverted (grouped by
      *day*, prayers underneath). Rather than leave the soon-to-be-replaced UI in place,
      it was deleted outright; see the redesign task below and
      `CONSTITUTION.md` § 6 for the full decision record. Notifications currently fire
      for all 5 notifiable prayers unconditionally in the meantime (no muting at all
      until the redesign lands).
- [x] **Android home screen widget** (`feature/home-screen-widget` branch) — shows the
      next upcoming prayer without opening the app. Uses the `home_widget` package +
      a native `NextPrayerWidgetProvider` (`AppWidgetProvider`, not tied to the Flutter
      engine); `widget_service.dart` pushes the full rolling schedule (label, epoch
      millis, pre-formatted display time, all in the current language/time-format) as
      JSON whenever `home_shell.dart` recomputes prayer times. The native side just
      picks the first entry not yet in the past, so Android's own periodic widget
      refresh (`updatePeriodMillis`) keeps it correct across a stretch of days without
      the app being reopened. Verified live on the Mi 10:
      - Went through two real design bugs found by actually looking at it on-device
        (not just reading the XML) — see `CONSTITUTION.md` § 4 for both root causes.
      - Carries a faded version of the app's existing seal motif (ring + eight-point
        star, reused from the generated launcher icon asset) as a background watermark,
        mocked up first as an HTML preview and approved before touching the real
        Android layout, to avoid burning more CI/device round-trips on a design that
        might still be wrong.
- [x] **Added `--split-per-abi` to the release build** (`.github/workflows/build.yml`)
      to shrink the APK from one ~53MB universal build into 3 smaller per-ABI APKs
      (armeabi-v7a / arm64-v8a / x86_64). Updated the "Upload release APK" artifact
      step's path from the single `app-release.apk` to the glob `app-*-release.apk`
      since that exact filename no longer exists after the split. Not yet run through
      CI to confirm the upload glob actually matches — verify on the next push to
      master.
- [x] **Added a live countdown line** under the next-prayer row: "4 hours & 46 minutes
      remaining" style text (falls back to "12 minutes remaining" once under an
      hour), shown as the highlighted `_PrayerRow`'s subtitle in
      `prayer_times_screen.dart`, computed from the existing 30-second `Timer`
      rebuild ticker. New `remainingHoursMinutes`/`remainingMinutes` string keys in
      `app_strings.dart` (ar/en, `{h}`/`{m}` placeholders). `flutter analyze` +
      `dart run custom_lint` + `flutter test` all green. **Not yet verified live on
      a device** — only static-checked so far.
- [x] **Synced the HTML design mockup** (the "معاينة تطبيق مواقيت الصلاة والقبلة"
      Artifact) with the real app: it was missing the Hijri/Gregorian date header that
      `prayer_times_screen.dart`'s `_DateHeader` already renders. Added a matching
      `.date-header` block (Gregorian on top, Hijri muted below) to the Prayer Times
      screen mock, republished to the same Artifact URL.

## In progress / needs attention right now 🔄

- [ ] Confirm the 7-day rolling notification schedule actually fires correctly on a
      real device (so far only verified by static analysis/tests, not a live run)
- [ ] Re-test pull-to-refresh on the Prayer Times screen actually recomputes times after
      a real location change on-device (added in PR #3, not yet exercised live)
- [ ] **Widget still looks visually broken despite yesterday's fixes** — the box
      renders much bigger than the text it contains, even after multiple passes. Read
      the actual layout/provider code to find the real cause instead of tweaking
      values again: `next_prayer_widget.xml`'s outer `FrameLayout` is
      `match_parent`×`match_parent` and paints the full
      `@drawable/widget_background` over whatever area the launcher grants the widget,
      while the actual content (icon + two `TextView`s) sits in an inner
      `wrap_content`, centered `LinearLayout` with **fixed** text sizes (13sp/22sp).
      `NextPrayerWidgetProvider.kt` never overrides `onAppWidgetOptionsChanged`, so
      those sizes never adapt to how much space was actually granted. Home-screen
      launchers size widgets to whole grid cells, which are typically much larger than
      the declared `minWidth="180dp"`/`minHeight="90dp"`/`targetCellWidth="3"` hints —
      those are only a floor, not what gets rendered. Net effect: a big painted
      background with a small fixed-size text blob centered in the middle, which
      matches exactly what's being seen live.
      **Chosen fix (per user, 2026-08-06): don't fight this with runtime responsive
      scaling — ship two separate, pickable widgets instead.** A "compact" variant
      (today's small text, tuned for its own fixed target size) and a "large text"
      variant (bigger fonts/icon, tuned for a bigger fixed target size), each its own
      `AppWidgetProvider` + `appwidget-provider` XML + layout, so both show up as
      distinct entries in the Android widget picker and the user picks whichever fits
      how they actually resize it — this is the standard pattern most Android apps use
      instead of dynamic `onAppWidgetOptionsChanged` scaling, and is far more reliable.
      Concretely: duplicate `NextPrayerWidgetProvider.kt` →
      `NextPrayerWidgetProviderLarge.kt` (or parameterize one class registered twice),
      duplicate `next_prayer_widget.xml` → `next_prayer_widget_large.xml` with bigger
      text sizes/padding/icon and a larger `minWidth`/`minHeight`/`targetCellWidth`/
      `targetCellHeight` in its own `next_prayer_widget_info.xml`, and register the
      second provider in `AndroidManifest.xml`. **Do not claim this fixed without
      re-verifying live on the Mi 10** — this exact pattern (claiming a widget fix
      without a live check) is why it's still broken after multiple attempts; see
      `CONSTITUTION.md` § 4 for the two prior root causes that were only found by
      actually looking at the device.

## Not started yet — ordered easiest → hardest 📋

Ranked by implementation effort/risk, not by importance — pick from the top unless a
specific item is more urgent. Pure business/content/decision items (not code) are
listed separately at the bottom since "effort" doesn't mean the same thing for them.

### Easy
- [ ] **Dark vs. light theme support.** Checked how much work this needs: almost none.
      `star_watermark.dart`, `prayer_times_screen.dart`, and `home_shell.dart` all pull
      colors from the theme's `ColorScheme` rather than hardcoding them, so today's
      cream background / dark-teal text is simply what
      `ColorScheme.fromSeed(seedColor: Colors.teal)` produces in light mode — passing
      the same seed with `Brightness.dark` naturally inverts that relationship without
      hand-picking replacement colors. Add `darkTheme: ThemeData(colorScheme:
      ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
      useMaterial3: true)` to `main.dart:46-49`, default `themeMode:
      ThemeMode.system` (optional manual override persisted in `PrefsService`, like
      the language/time-format toggles). One exception needing a manual check:
      `qibla_compass.dart:36-37`'s brass gradient (`_brassLo`/`_brassHi`) is hardcoded
      outside the theme and needs a contrast check against a dark background rather
      than relying on automatic inversion. (Competitor-analysis finding, 2026-08-06.)
- [ ] **Hijri ⟷ Gregorian date-conversion tool.** A small dialog: pick a date from
      either calendar (radio toggle "From Gregorian" / "From Hijri"), shows the
      converted result in the other calendar, with a disclaimer that the conversion
      may be off by a day or two. We already depend on a Hijri calc for the date
      header (`date_service.dart`), so this is mostly UI — expose it as a standalone
      utility (e.g. from Settings or an app-bar action). (Competitor-analysis finding,
      2026-08-06.)

### Medium
- [ ] **Bug: "next prayer" highlight on the Prayer Times screen is sometimes wrong**
      (reported live: Fajr hadn't been called yet, but Dhuhr was highlighted as next).
      `_nextPrayerKey()` in `lib/screens/prayer_times_screen.dart` itself looks correct
      (walks `fajr → sunrise(skipped) → dhuhr → …`, returns the first one still in the
      future) — the likely real cause is upstream, in `_recomputeTimesAndQibla()`
      (`lib/screens/home_shell.dart`): `_prayerTimes` is only ever recomputed when
      location/settings change or on app bootstrap, **not** on a day rollover. Needs:
      (1) confirm this reproduces (note the exact device time + location when it
      happens next), and (2) recompute `_prayerTimes` when the calendar date changes
      while the app is running/resumed. Also worth double-checking the resolved
      location wasn't stale/wrong at the time (see the GPS-caching item below).
- [ ] **Widget: fix oversized box vs. small text, by shipping a compact + a
      large-text variant as two separate pickable widgets** — see the full write-up
      under "In progress" above; listed here too since it's a real implementation
      task (a second `AppWidgetProvider` + layout + manifest entry), not a one-line
      tweak, and needs live device verification before it can be marked done.
- [ ] **Add swipe navigation between the 3 main tabs** (Prayer Times / Qibla /
      Settings), not just the bottom `NavigationBar`. `HomeShell`
      (`lib/screens/home_shell.dart`) currently renders the 3 screens in an
      `IndexedStack` with no swipe gesture. Swap it for a `PageView` (or
      `TabBarView`) driven by the same `_tabIndex` state so swiping left/right and
      tapping the bottom nav both work and stay in sync. Watch for: RTL (Arabic swipe
      direction should feel natural, not mirrored wrong), and the Qibla screen's
      compass/gesture handling shouldn't fight with horizontal swipe.
- [ ] **Don't require a live GPS fix at every app startup.** Right now
      `_bootstrap()` in `lib/screens/home_shell.dart` only skips the GPS call when a
      *manual* (city-search) location was saved; otherwise it always calls
      `LocationService.getCurrentLocation()`, which blocks on a fresh
      `Geolocator.getCurrentPosition()` fix. `LocationService.getLastKnownLocation()`
      already exists but is **dead code, never called**. Fix: persist the last
      resolved coordinates (GPS *or* manual) in `PrefsService`, show times instantly
      from that cache on startup, and only kick off a fresh GPS fix in the background
      (or on explicit pull-to-refresh / "use GPS" picker action). Also surface the
      location picker more prominently (`CitySearchScreen` already exists, tap the app
      bar location chip) so switching location doesn't feel GPS-only. This is also the
      agreed no-regrets first step on the open "lower-power location strategy"
      question — see Open decisions.
- [ ] **Settings backup/restore.** Export/import all `PrefsService` settings (location,
      calc method, madhab, notification toggles, language, time format) as a single
      file — useful before reinstalling or switching devices. (Competitor-analysis
      finding, 2026-08-06.)
- [ ] **Qibla arrow redesign — make it read as directional even when static.** Our
      current `qibla_compass.dart` needle is a simple two-tone pointer. The
      competitor's arrow has a layered/receding chevron trail behind the arrowhead
      (like a comet tail), which reads as implied motion purely from the static shape,
      plus "قبلة/Qibla" text embedded inside the arrow body itself so the label moves
      with the needle, plus two small reference dots on the compass ring (true north +
      current heading). Explicitly called out as the competitor's standout feature —
      worth prioritizing within this tier. (Competitor-analysis finding, 2026-08-06.)
- [ ] **Home screen widget: add a horizontal 5-prayer-row style** (Fajr / Zuhr / Asr /
      Magrib / Isha inline, current prayer highlighted) as an alternate widget alongside
      the existing single-next-prayer one. (Competitor-analysis finding, 2026-08-06.)
- [ ] **Home screen widget: add a progress-bar style** — a horizontal bar showing
      elapsed time between the previous and next prayer (e.g. "Zuhr ──●───── Asr" with
      both times at the ends) plus a small Hijri-date chip. The single most impressive
      widget in the competitor's set. (Competitor-analysis finding, 2026-08-06.)
- [ ] **Redesign per-day/per-prayer notification muting, day-categorized.** The removed
      UI (see Done ✅) grouped by *prayer*, with 7 day-toggles underneath each one.
      Rebuild it inverted: each **day** as the top-level group, with the (5) prayers
      listed underneath that day to toggle individually. Needs: new Settings UI shape,
      and `PrefsService` persistence to match (the old `notif_${weekday}_$prayer` key
      scheme still works fine, just the UI grouping changes). Wire back into
      `home_shell.dart`'s `scheduleUpcoming(isEnabled: ...)`, which currently just
      returns `true` unconditionally.
- [ ] Re-enable R8 minification with proper keep rules for WorkManager/Room (and
      anything else reflection-based) rather than leaving it off forever — currently
      disabled as the fix for the startup crash (see Done ✅), which is safe but leaves
      the release APK larger than it needs to be. Needs careful on-device retesting
      before landing — this is exactly the class of bug that only showed up as a
      release-build crash last time.

### Hard
- [ ] Background rescheduling so notifications stay current even if the user doesn't
      open the app for several days (currently the 7-day window is only refreshed when
      the app is opened) — needs a periodic background task (WorkManager), not just
      app-side logic.
- [ ] **Fajr/Sahoor wake-up alarm, with Snooze.** A dedicated full-screen alarm (big
      clock, Snooze/Stop buttons, "Wake Up! Fajr prayer is near") distinct from the
      regular notification — aimed at waking up in time for Suhoor before Fajr,
      especially relevant in Ramadan. Needs a full-screen intent/alarm activity, not
      just a notification. **Snooze** is its own sub-piece worth calling out: our
      current `flutter_local_notifications` setup only ever fires a single scheduled
      notification per prayer with no snooze concept — adding it means the alarm
      activity has to re-schedule itself N minutes later (with a cap on repeat
      snoozes), which needs the full-screen alarm activity to exist first.
      (Competitor-analysis finding, 2026-08-06.)
- [ ] **Auto-silent-phone-during-prayer option.** Settings toggle (per-prayer) to
      automatically switch the phone to silent/DND for the duration of each prayer
      window, then restore the previous mode. Requires `ACCESS_NOTIFICATION_POLICY` /
      DND permission on Android — needs a permission-rationale screen.
      (Competitor-analysis finding, 2026-08-06.)
- [ ] Consider continuous/background location watching instead of the current
      fetch-once-at-startup + manual-refresh-only model, if the cached-location fix
      above turns out not to be enough in practice.
- [ ] **(Long-term, low priority) Wear OS smartwatch support.** Competitor ships
      several actual watch faces (analog clock with two prayer sub-dials, a circular
      arc countdown gauge, a 6-circle prayer grid). Much bigger investment (separate
      Wear OS module) — a possible future direction, not a near-term task.
      (Competitor-analysis finding, 2026-08-06.)

### Deferred / recommend skipping unless requested
- [ ] **Widget-specific theming.** Competitor's "Display Options" lets language/colors
      be set independently for the app vs. the widgets. Currently our widget always
      mirrors the app's language/time-format via `widget_service.dart`'s JSON payload
      with no separate override — real complexity for a marginal win; skip unless a
      user actually asks. (Competitor-analysis finding, 2026-08-06.)

### Business / content / decisions (not code — not effort-ranked the same way)
- [ ] Replace AdMob test IDs with real ones (`AndroidManifest.xml` and `ad_service.dart`)
- [ ] Create a real release **keystore/signing key** (currently signed with the debug
      key, which is not publishable)
- [ ] Decide on a final app name (still just "prayer_qibla" / `com.hgdroid.prayer_qibla`)
- [ ] Write a Privacy Policy (required by Google for any app using AdMob + location)
- [ ] Real screenshots + Play Store listing copy
- [ ] AdMob real IDs, release keystore, and R8 re-enablement are all still **open** —
      asked the user about each individually (2026-08-06); none were confirmed yet
      (dismissed / not answered). Re-ask before assuming a default for any of them.
- [ ] Keep iOS in scope, or officially drop it and go Android-only? (original scope was
      Android-only)
- [ ] Which lower-power location strategy to adopt? Options: (a) just cache+reuse the
      last GPS/manual fix and stop blocking startup on a fresh one — smallest change,
      no new deps, **this is the plan, see the Medium-tier item above**; (b) switch to
      Android's network/passive location provider instead of high-accuracy GPS for the
      periodic refresh; (c) add IP-based or timezone-based coarse geolocation as a
      zero-permission first-run guess. (a) is decided as the first step; (b)/(c) remain
      open for later.
- [x] Real app icon — the seal motif (ring + eight-point star), generated via
      `flutter_launcher_icons` for legacy + adaptive icon across all densities
- [x] Finalize `applicationId` — **decided (2026-08-06): keep `com.hgdroid.prayer_qibla`**,
      no change. This can never be changed after the first Play Store upload.
- [x] Google Play Console account: **created and the $25 fee paid (2026-08-06)**, using
      an account the user believes predates the November 2023 cutoff for the
      20-tester/14-day closed-testing requirement — identity verification was still
      pending as of this session. Confirm in Console whether the testing-requirement
      banner actually applies before assuming production publishing is unlocked.

## Notes

- Every item here must pass `flutter analyze` + `dart run custom_lint` +
  `flutter test` before being considered done.
- Read `CONSTITUTION.md` before starting any new work — it has the project rules and
  the learnt-lessons log.
