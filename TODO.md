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
- [x] **Stopped blocking app startup on a live GPS fix, in two layers.**
      **Live-confirmed as bad UX on the Mi 10 (2026-08-06)**: a fresh install showed
      nothing but a blank "location permission needed" screen until GPS resolved — no
      cached prayer times, no prior screen state, just an empty blocking wait.
      1. **Caching layer**: `_bootstrap()` in `lib/screens/home_shell.dart` now checks
         `PrefsService.getCachedGpsLocation()` (new) before ever calling
         `LocationService.getCurrentLocation()`. If a previous GPS fix is cached, it
         shows times from it instantly and refreshes GPS in the background
         (`_backgroundLocationRefresh()` — a failed background refresh no longer
         clobbers an already-showing cached location, only a successful one updates
         and re-caches). `_refreshLocation()` (pull-to-refresh, explicit "use GPS"
         picker action) now also writes to the cache on every successful fix.
      2. **Default-location layer (per user, 2026-08-06, refining the above)**: even
         the *very first* launch ever — before any GPS fix or manual pick exists —
         should not prompt for GPS automatically at all. `_bootstrap()` now falls back
         to a hardcoded default (Cairo, Egypt — `_defaultLatitude`/`_defaultLongitude`
         in `home_shell.dart`) when there's no manual location and no cached GPS fix,
         showing that city's times immediately with no permission prompt. The user
         opts into GPS or a specific city explicitly via the existing location picker
         (`CitySearchScreen`, tap the app bar location chip — "Use my current location
         (GPS)" list tile already exists there). New `defaultLocationName` string key
         in `app_strings.dart` (ar/en) for the chip label while on the default.
      `flutter analyze` + `dart run custom_lint` + `flutter test` all green.
      **Verified live on the Mi 10** (2026-08-06, clean uninstall + fresh install):
      first-ever launch showed real Cairo prayer times and qibla bearing (136°)
      immediately, no permission prompt, no blank screen.
      3. **Follow-up fix, same session**: user caught a real flash-of-wrong-screen —
         on that same live run, the "location permission needed" error screen briefly
         showed before the Cairo default kicked in, timed around when the notification
         permission dialog was up. Cause: `_locationState` defaulted to
         `LocationState.denied` at field-init time, and `PrayerTimesScreen`/
         `QiblaScreen` treat `denied` as "show the permission-denied error," even
         though bootstrap hadn't actually checked location yet at that point — it was
         still awaiting the unrelated notification-permission request. Fixed by adding
         a new `LocationState.unknown` (in `location_service.dart`) as the initial
         value instead of reusing `denied`; since neither screen's error check matches
         `unknown`, they correctly fall through to the existing loading-spinner branch
         until bootstrap actually resolves a location. `flutter analyze`/
         `custom_lint`/`flutter test` green; **not yet re-verified live**.
- [x] **Added a live countdown line** under the next-prayer row: "4 hours & 46 minutes
      remaining" style text (falls back to "12 minutes remaining" once under an
      hour), shown as the highlighted `_PrayerRow`'s subtitle in
      `prayer_times_screen.dart`, computed from the existing 30-second `Timer`
      rebuild ticker. New `remainingHoursMinutes`/`remainingMinutes` string keys in
      `app_strings.dart` (ar/en, `{h}`/`{m}` placeholders). `flutter analyze` +
      `dart run custom_lint` + `flutter test` all green. **Verified live on the Mi
      10** (2026-08-06, via wireless adb + a CI-built debug APK): Maghrib row showed
      "الصلاة القادمة — متبقي 2 ساعة و25 دقيقة" correctly against the device's actual
      clock/next-prayer time.
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
- [x] **Widget visual redesign — rebuilt to actually match the mockup, not just
      tweaked** (2026-08-06). User's live verdict on the previous version: "its look
      has zero relation to what we agreed on or what's in the artifact." Confirmed by
      comparing directly against the mockup's `.widget-card` (the "معاينة تطبيق
      مواقيت الصلاة والقبلة" Artifact, home-widget-preview section): the widget had
      drifted to a solid teal box with a giant faded 88dp watermark icon and no
      countdown text, none of which matches the mockup's light card + small gold seal
      + countdown line. Rebuilt from scratch to mirror the mockup layout exactly:
      - `widget_background.xml`: solid teal box → white card, thin `#E3D9C2` border,
        18dp corners (was `#0D6E63` solid).
      - `next_prayer_widget.xml`: full rewrite — gold accent stripe on the leading
        edge (`.widget-card::before`), small 26dp gold seal icon (reusing
        `ic_launcher_foreground`, already gold-on-transparent, no tint needed) instead
        of the old 88dp alpha-0.18 background watermark, a label+prayer-name column,
        and a time+**new countdown line** column at the trailing edge.
      - **Countdown line added**: previously the widget showed no remaining-time text
        at all. `NextPrayerWidgetProvider.kt` now computes it natively
        (`formatRemaining()`) from the existing pushed `millis`, using new
        `remaining_hours_minutes_template`/`remaining_minutes_template` keys pushed
        from `widget_service.dart` — reusing the exact same `remainingHoursMinutes`/
        `remainingMinutes` `AppStrings` entries the in-app countdown uses, so wording
        matches and ar/en translation logic isn't duplicated in Kotlin.
      - Added `android:supportsRtl="true"` to `AndroidManifest.xml` (was missing
        entirely). **This did not actually fix RTL mirroring for the widget** as
        assumed here — see the dedicated RTL bug item below, found live.
      `flutter analyze` + `custom_lint` + `flutter test` all green (Kotlin side can
      only be checked by a real Gradle build, not these). **Live-verified on the Mi
      10 (2026-08-06)**: card style, accent stripe, and countdown line all render
      correctly, matching the mockup. The RTL icon-placement bug (separate item
      below) was found on this same live check.
- [x] **Widget: oversized box vs. small text — root cause refined, content scaled
      up.** Live-tested the redesigned card on the Mi 10 (2026-08-06) and the box was
      still much bigger than the 2-line content needed — user pushed back hard on
      this being unresolved. Re-examined the actual constraint: launcher hosts (MIUI
      here) grant widget space in **whole grid cells**, and even a small declared
      `minHeight` (90dp) still rounds up to at least one full grid row — there is no
      way to get a box smaller than one row, so the earlier "ship a compact variant"
      half of the two-widget plan doesn't actually help (a compact variant would
      still occupy the same minimum one-row box). The real lever is making the
      **content** fill that inherently tall-ish row properly instead of leaving two
      small lines centered in mostly empty space. Scaled everything up in
      `next_prayer_widget.xml`: icon 26dp→44dp, prayer name 15sp→22sp, time
      18sp→28sp, header 11sp→14sp, countdown 10sp→13sp, padding 14dp→22dp. The
      "large text" variant idea from the earlier plan is kept as a *further* opt-in
      option on top of this (for a 2-row placement), not as the fix for the base
      case. **Live-verified on the Mi 10 (2026-08-06)**: text/icon are visibly bigger
      and the countdown line renders — this part genuinely landed. User's overall
      verdict on that same screenshot was still unhappy, but for a *different* reason
      than box size — see the new RTL item directly below, found from that same
      screenshot.
- [ ] **Widget: icon renders on the wrong side for Arabic — RTL mirroring isn't
      applying to the widget despite `supportsRtl="true"`.** Found live (2026-08-06).
      **Root cause confirmed (2026-08-06)**: `RemoteViews` are inflated by the
      **launcher process**, which resolves RTL from the device's *system* locale —
      not from Flutter's in-app language override (`PrefsService`, independent of
      system locale). So `supportsRtl="true"` alone can never mirror this widget for
      the app's own Arabic setting unless the phone's system language also happens to
      be Arabic. **Fix implemented and pushed** (commit `a200aa5` on
      `feature/home-screen-widget`), not a manifest tweak: `widget_service.dart` now
      also pushes the raw `language` string; `NextPrayerWidgetProvider.kt` reads it
      and calls `views.setInt(R.id.widget_root, "setLayoutDirection",
      LAYOUT_DIRECTION_RTL/LTR)` explicitly on the new `@+id/widget_root` FrameLayout,
      driven by the app's actual language choice rather than system config or a
      hardcoded order — works correctly if the user ever switches language too.
      `flutter analyze`/`custom_lint`/`flutter test` all green (Kotlin side can only
      be checked by a real Gradle build). **NOT yet live-verified** — GitHub Actions
      was hit by a **platform-wide outage** this session (confirmed via
      githubstatus.com, "Minor Service Outage"): two dispatch attempts (`31119000914`,
      `31119004460`) both failed on infra grounds, not our code — one on
      `Service Unavailable` resolving action downloads, the other on
      `The job was not acquired by Runner of type hosted even after multiple
      attempts`. A third build was re-dispatched as run **`31119995664`** right as
      this session ended, outcome unknown (outage was still showing "minor" on
      githubstatus.com at dispatch time). **Next session: check
      `gh run list --branch feature/home-screen-widget --limit 5` first. If
      `31119995664` (or a later one) succeeded, download the APK and verify live on
      the Mi 10 — icon should now render on the right, time/countdown on the left, in
      Arabic — before touching anything else on this branch. If it also failed on
      infra grounds, just re-dispatch (check githubstatus.com first).**

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
- [ ] **Add swipe navigation between the 3 main tabs** (Prayer Times / Qibla /
      Settings), not just the bottom `NavigationBar`. `HomeShell`
      (`lib/screens/home_shell.dart`) currently renders the 3 screens in an
      `IndexedStack` with no swipe gesture. Swap it for a `PageView` (or
      `TabBarView`) driven by the same `_tabIndex` state so swiping left/right and
      tapping the bottom nav both work and stay in sync. Watch for: RTL (Arabic swipe
      direction should feel natural, not mirrored wrong), and the Qibla screen's
      compass/gesture handling shouldn't fight with horizontal swipe.
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
