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
- [x] **Design-taste audit + 4 fixes (2026-08-15)**, via a design-skill pass (Emil
      Kowalski's `emil-design-eng` + Leonxlnx's `design-taste-frontend`/
      `redesign-existing-projects`, both written for web/CSS and adapted for Flutter —
      most of their checklist didn't apply, see `CONSTITUTION.md` if that adaptation
      needs redoing later). Audit findings and rationale are in the session transcript,
      not duplicated here — just the outcome:
      - `_PrayerRow`'s next-prayer highlight (`prayer_times_screen.dart`) now
        crossfades background/border/text color (`AnimatedContainer` +
        `AnimatedDefaultTextStyle`, 200ms `Curves.easeOut`) instead of snapping when
        the highlighted row changes (settings edit, or a prayer time passing while the
        app is open). Card's `margin` moved to a wrapping `Padding` after
        `custom_lint`'s `impeccable_layout_transition` correctly flagged it as a
        layout property sitting directly on the `AnimatedContainer`.
      - `qibla_compass.dart`'s `_alignController` (the resting↔"locked on Qibla" color
        crossfade) now reads through a `CurvedAnimation(Curves.easeOut)` instead of
        its raw linear value, matching the curve already used elsewhere in the same
        widget.
      - `main.dart`'s `MaterialApp` gained `themeAnimationCurve: Curves.easeInOut` —
        the built-in 200ms theme-flip animation (the `afterMaghrib` auto dark-mode
        transition) was already there via Flutter's default, just linear.
      - 8 call sites across `home_shell.dart`, `settings_screen.dart`,
        `notification_grid_screen.dart`, `prayer_times_screen.dart`, `qibla_screen.dart`,
        `city_search_screen.dart` switched from mixed default/outlined Material icons
        to a single `_rounded` family, matching the pill-shaped buttons/cards already
        in the Organic system.
      `flutter analyze` + `dart run custom_lint` + `flutter test` all green.
      **Not yet live-verified** — needs either the new local emulator (blocked, see
      below) or the Mi 10.
- [x] **Fixed prayer notifications not firing at all, on any prayer (2026-08-23)** —
      user report: "nothing happened on any prayer time." Root-caused by reading
      `flutter_local_notifications`' Java source directly, not guessing: the app never
      requested `SCHEDULE_EXACT_ALARM` (only `POST_NOTIFICATIONS`), and Android 14+
      doesn't grant that permission by default on a fresh install. Every
      `zonedSchedule(..., androidScheduleMode: exactAllowWhileIdle)` call threw
      `exact_alarms_not_permitted`, uncaught, aborting the whole scheduling loop on the
      very first prayer of the very first day — silently, since the call site
      (`home_shell.dart`'s `_rescheduleNotifications`) is fire-and-forget. Fixed in
      `notification_service.dart`: `requestPermission()` now also calls
      `requestExactAlarmsPermission()`, and each `zonedSchedule()` call is wrapped in
      try/catch so one denial can't silently cancel every other prayer/day. Full
      write-up in `LESSONS.md` under "Third-party packages". `flutter analyze` +
      `flutter test` green (`custom_lint` currently broken locally for an unrelated,
      pre-existing reason — see the CI Flutter-version-drift lesson, which now also
      reproduces locally since the local Flutter SDK moved to 3.47.0). **Not yet
      live-verified on a device** — this directly informs the still-open item below
      about confirming notifications fire on a real device.

