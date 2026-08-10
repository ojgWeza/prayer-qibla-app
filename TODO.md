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

**Start here next session** (2026-08-10 session end — see CONSTITUTION.md's session log
for the full account; short version below):

1. **⚠️ STILL NOT RESOLVED — highest priority. Live-diagnosed on-device this session
   (2026-08-10) with a real, controlled protocol** (adb screenshots captured directly
   off the Mi 10 via wireless adb while the user physically rotated the phone —
   `adb exec-out screencap -p`, no manual photo needed). Two tests run:
   - **Clean 90°-turn test** (stayed in Salaty the whole time, no app-switching):
     baseline needle ~‑6° from up → after a stated 90° clockwise physical turn, needle
     at ~‑58° from up, i.e. the needle rotated **~52° counterclockwise** for a **90°
     clockwise** physical turn. That's the mathematically *correct* relative direction
     for a device-relative bearing needle (opposite the housing's own rotation, like a
     real compass card) — so the current sign
     (`angle = (heading - qiblaBearing) * pi / 180` in `qibla_screen.dart`, from last
     session's flip) is very likely NOT the bug. **Do not flip the sign again without
     new evidence** — this was checked properly this time, unlike prior sessions.
   - **Absolute-direction test against a second reference compass app**: contaminated
     the first attempt (switching apps physically disturbs the phone's orientation in
     hand) but a follow-up with the **phone lying flat on a table** (rotated to N=0° on
     the reference app, then switched to Salaty without touching it) showed the needle
     pointing at a fixed position that, per the user, corresponds to **true north**, not
     the 136° Qibla bearing — i.e. the qibla offset appeared not to be applied at all in
     that reading. However **the phone was lying flat on a table for this test**, and
     magnetometer tilt-compensation is known to be unreliable/unstable when a phone is
     horizontal rather than held upright — this is a very plausible confound, not
     necessarily a code bug. Live in-app rotation tracking was separately confirmed
     smooth/responsive (rules out a frozen/stale-sensor-stream theory).
   - **Session ended mid-diagnosis**: asked the user to repeat the absolute-direction
     test holding the phone upright (not flat on a table) — **answer not yet received**.
   - **Next session: get that answer first**, before touching `qibla_screen.dart` again.
     If upright-and-held gives a plausible southeast-ish "needle-up" direction, this
     was a sensor/table artifact and the current code is correct as-is (close this
     item). If it still points north/some other wrong fixed direction while held
     upright, that's a real, reproducible bug — worth checking whether
     `flutter_compass`'s `heading` on this device is actually magnetic vs. true north,
     whether it's frozen at a stale value from an earlier resume, or whether
     `qiblaBearing` itself is somehow reading as 0 inside `QiblaCompass` despite the
     "136°" label showing correctly (re-verify `widget.qiblaBearing` is the exact same
     value flowing into both the label `Text` and the `angle` calculation in
     `qibla_screen.dart:123` — they use the same variable currently, but re-confirm
     after any further edit).
   - **Needle shape — separate complaint, not yet addressed.** User's exact words:
     "the bug shape you added to the needle... looks very bad" — screenshots this
     session show the tapered-blade + chevron construction from `qibla_compass.dart`
     rendering as an odd asymmetric curved sliver rather than a clean arrow, and no
     chevrons were visibly distinguishable in the captured screenshots. This is a
     genuine visual-quality issue independent of the direction bug — consider
     simplifying the blade path (`_CompassPainter` in `qibla_compass.dart`, the
     `bladePath` `Path` starting at `qibla_compass.dart:160`) to something cleaner,
     but this changes `DESIGN_RULES.md`'s "locked" exact needle spec, so raise it with
     the user as a deliberate deviation before changing it, not a silent restyle.
2. [x] Rectangular home-screen widget rebuilt to match `DESIGN_RULES.md` literally
   (exact star motif, exact two-part needle, real Organic color tokens, bundled
   Caprasimo/Figtree fonts, Hijri date, dropped location) — CI-build-verified (real
   Gradle/AAPT compile passed) AND live-verified on a physical device (Mi 10, over
   wireless adb). See commit `95cc9a3`.
3. [x] Qibla compass needle rebuilt from a generic symmetric double-pointed diamond to
   the design's exact asymmetric tapered blade (sharp tip / blunt rounded tail) +
   trailing chevrons — live-verified the shape/gradient render correctly on-device;
   only the absolute rotation direction (item 1 above) still needs confirmation.
4. [x] Removed the Material `SegmentedButton` checkmark (`showSelectedIcon: false`)
   from both the time-format and language pills in Settings — was forcing a two-line
   wrap with Arabic labels. Live-verified fixed on-device.
5. [x] Fixed 7 pre-existing `custom_lint` const-decoration/cramped-padding issues
   (unrelated to this session's other work, but were blocking CI from ever reaching
   the APK build step) — see commit `b0f7aa3`.
6. [x] **Dark-mode "next prayer" card contrast bug — fixed (2026-08-09).** Root cause
   was the opposite of the earlier guess: `_PrayerRow`'s highlighted `Card` always used
   the light-ramp `AppTheme.accent100` background regardless of theme, while its title
   text already correctly used the theme-aware `text` color (which resolves to the
   near-white `_textDark` in dark mode) — light text on a light background, near-zero
   contrast. Fixed in `prayer_times_screen.dart` by branching the card background/
   border/subtitle color on `theme.brightness` (dark → `accent900`/`accent700`/
   `accent100`, light → the original `accent100`/`accent300`/`accent700`), same
   light/dark pairing pattern already used in `qibla_compass.dart`'s needle gradient.
   `flutter analyze` + `custom_lint` + `flutter test` all green. **Not yet
   live-verified on-device.**
6a. [x] **"Next prayer" countdown breaking after midnight — fixed (2026-08-09).**
   User-reported: "the time until the next prayer is not calculated properly."
   Root cause: `home_shell.dart`'s `_prayerTimes` (today's 6 times, computed via
   `_recomputeTimesAndQibla()`) was only ever recomputed on bootstrap, location
   change, or settings change — never on a plain day rollover. An app left open (or
   just not touched) past midnight kept holding yesterday's times, all already in the
   past, so `_nextPrayerKey()`/`_formatRemaining()` in `prayer_times_screen.dart` had
   nothing to highlight and no countdown to show at all (not merely "wrong number" —
   the next-prayer row and its countdown vanish entirely until something else happens
   to trigger a recompute). Fixed by tracking `_prayerTimesDate` (the calendar date
   the current `_prayerTimes` was computed for) and checking it against
   `DateTime.now()` on the same 1-minute `_appearanceTicker` that already exists for
   the afterMaghrib theme flip — `_recomputeIfDayChanged()` calls
   `_recomputeTimesAndQibla()` once the date has actually moved. `flutter analyze` +
   `custom_lint` + `flutter test` all green. **Not yet live-verified** (would need
   leaving the app open across an actual midnight, or manipulating device clock, on
   the Mi 10).
6b. [x] **Inconsistent fonts — fixed (2026-08-09).** User-reported: "the font is not
   consistent." Root cause: `app_theme.dart` built Caprasimo/Figtree/Rakkas/Noto Sans
   Arabic via the `google_fonts` package, which downloads the actual font files over
   the network on first use and caches them — any text that renders before that
   download completes (or if it fails outright: no connectivity, a flaky network, a
   fresh install with no cache yet) silently falls back to the platform default font
   instead. That produces exactly this symptom: some text in the intended font, some
   not, inconsistently and non-deterministically depending on device/network/timing,
   not a fixed bug in specific text. Fixed by downloading the 4 exact font files
   (Caprasimo-Regular, Rakkas-Regular, Figtree variable, Noto Sans Arabic variable —
   same families as before, from the canonical `google/fonts` GitHub repo) as local
   assets under `assets/fonts/`, declaring them in `pubspec.yaml`'s `fonts:` section,
   and rebuilding `app_theme.dart`'s `headingFont`/`bodyFont` via
   `base.textTheme.apply(fontFamily: ..., fontFamilyFallback: ...)` referencing the
   bundled family names directly instead of `GoogleFonts.xTextTheme()`. Removed the
   now-unused `google_fonts` dependency from `pubspec.yaml`. This makes font
   rendering fully deterministic and offline-safe, which also fits the project's
   "no backend of our own" design principle better than a runtime font CDN fetch did.
   `flutter analyze` + `custom_lint` + `flutter test` all green. **Not yet
   live-verified** — the in-session Flutter-web preview used for earlier redesign
   passes hit the same "Browser pane is not displayed, screenshot times out" tooling
   limitation noted in the RTL fix session — could not visually confirm in-browser
   this time either. Next session/on-device: confirm both Caprasimo (headings) and
   Figtree (body) render correctly and consistently across all 3 screens, in both
   languages, on a cold install with no cached fonts.
7. **Open idea, not yet implemented**: user suggested showing a Kaaba icon just
   outside the compass ring, in the direction it's pointing, as an extra disambiguation
   cue beyond the asymmetric needle shape. Deferred — ask whether it's still wanted now
   that the needle shape itself disambiguates tip vs. tail.
8. **Open idea, not yet implemented**: the rectangular widget's Qibla needle is a
   static north-relative bearing indicator, not a live device-heading-relative one —
   this is intentional (a home-screen widget has no continuous compass sensor feed
   without a battery-draining foreground service), not a bug, but the user's initial
   reaction was that it "shouldn't be" static. Revisit if they still want something
   different here after reading the explanation.
9. [x] **Branch-splitting decision made (2026-08-09).** Traced the actual commit
   history (21 commits, 47 files) before deciding: the bodies of work are NOT cleanly
   separable — the Organic design-system commit (`f936513`) touches nearly every
   screen file, and later commits (compass fixes, custom_lint fixes, this session's
   font/countdown fixes) all assume that redesign already landed, so cherry-picking
   them onto a pre-redesign branch would conflict. Retroactively splitting = rewriting
   already-pushed history for mostly-cosmetic benefit. **Decision (user-confirmed):
   merge as one PR, enforce one-branch-per-feature strictly from the next task
   onward.** Opened **[PR #7](https://github.com/ojgWeza/prayer-qibla-app/pull/7)** —
   not yet merged (waiting on the open qibla-direction diagnosis above, plus general
   on-device confirmation of this session's other fixes). CI passing on the PR's head
   commit (`05f389e`, run `31309642868`).
10. [x] **App display name + icon done (2026-08-09/10), pushed as commit `05f389e`,
    CI green.** User: the launcher was showing the raw `prayer_qibla` placeholder as
    its caption — set `android:label="Salaty"` in `AndroidManifest.xml` (plus
    `web/index.html`/`web/manifest.json` for the verification-only web build).
    `applicationId` unchanged (`com.hgdroid.prayer_qibla`, separately locked). Also
    regenerated `assets/icon/icon_foreground.png`/`icon_square.png` — the previous
    ones predated the Organic redesign (still had the old teal adaptive-icon
    background) and the khatam-star shape correction applied elsewhere in the app.
    Rendered fresh via a one-off `flutter test`-based generator (deleted after use)
    reusing the exact same star construction as `star_watermark.dart`, then
    regenerated all launcher densities via `flutter_launcher_icons`. Live-installed
    and confirmed on the Mi 10 this session.
11. **Local Android builds don't work on this Windows dev machine — use CI, not
    `flutter build apk` locally.** Tried this session and burned real time on it before
    remembering `CONSTITUTION.md` already says "no local Android SDK — builds run on
    GitHub Actions." Local build hit a chain of environment issues (JDK 11 default too
    old for Gradle, needed `D:\Program Files\Android\openjdk\jdk-21.0.8`; NDK/SDK
    licenses never accepted, needed manual `D:\dev\licenses\android-sdk-license`
    files; an installed "Android SDK Platform 37.0" directory whose
    `AndroidVersion.ApiLevel=37.0` didn't match Gradle's expected `android-37` target
    hash, needed a manually-patched duplicate `android-37` platform dir; and finally a
    reproducible Windows-only Kotlin "Build Tools API" incremental-cache concurrency
    bug — `Could not close incremental caches`/`storage already registered` — across
    4-5 plugin modules' `compileDebugKotlin` tasks that persisted through daemon
    restarts and `org.gradle.parallel=false`). **Abandoned rather than fully solved**
    — reverted the `android/gradle.properties` workaround attempts, switched to
    downloading the already-green CI artifact (`gh run download`) and installing that
    via `adb install` instead. **Next session: don't attempt local
    `flutter build apk` again** — go straight to `gh run list`/`gh run download`
    against the pushed branch's latest CI run.
12. **Wireless adb to the Mi 10 needs re-pairing most sessions** — the pairing code
    and port shown in Settings → Developer options → Wireless debugging change each
    time that screen is opened fresh. `adb pair <ip:pairing-port> <code>` then
    `adb connect <ip:connect-port>` (two different ports — pairing port is one-time,
    the connect port is what's used afterward). Confirmed working flow this session.
---

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

### From the "Organic" design handoff (`design/Prayer times app design.zip`, 2026-08-07)

Compared the bundled design handoff (`design/extracted/design_handoff_prayer_qibla_app/`)
against the real Flutter app, then implemented the gaps found (2026-08-07). All items
below are now **done** except the home-widget visual-variant one, which stays open (see
Not started yet).

- [x] **Adopted the "Organic" design system tokens (colors/fonts/radii).** New
      `lib/theme/app_theme.dart`: `ColorScheme`s built from the exact handoff hex values
      (`--color-bg` `#f5ead8`/`#2e2b25`, `--color-surface` `#ebddc5`/`#474238`,
      `--color-text` `#201e1d`/`#f5ead8`, terracotta/sage accent ramps), `google_fonts`
      package added for Caprasimo (headings) + Figtree (body), pill (`StadiumBorder`)
      shapes for `FilledButton`/`SegmentedButton`. Wired into `main.dart` as
      `theme`/`darkTheme`. Next-prayer card in `prayer_times_screen.dart` now uses the
      actual `accent-100`/`accent-300` tokens instead of the generic Material
      `primaryContainer`.
- [x] **4-mode appearance setting** (`appearanceMode`: `afterMaghrib`/`light`/`dark`/
      `system`, default `afterMaghrib`). New `PrefsService.getAppearanceMode`/
      `setAppearanceMode`; `home_shell.dart`'s `_applyAppearance()` computes `isDark`
      from `_prayerTimes.maghrib`/`.fajr` each time prayer times recompute plus a 1-minute
      `Timer.periodic` (so the mode flips even with no other state change), and pushes
      the resolved `ThemeMode` up to `MaterialApp` via a new `onThemeModeChanged`
      callback on `HomeShell`. Settings → Language & appearance has a `RadioGroup` of
      the 4 options.
- [x] **Week-start setting.** `PrefsService.getWeekStart`/`setWeekStart` (0=Monday..
      6=Sunday, default 5/Saturday), new `fullDay1..7` string keys, dropdown added to
      Settings → Time & calculation; the notification grid (below) reorders its day rows
      from this same value.
- [x] **Notifications: master toggle + dedicated "Customize by day" grid screen.**
      `PrefsService.getNotificationsEnabled`/`setNotificationsEnabled` (master switch)
      plus `getNotifDayEnabled`/`setNotifDayEnabled` (the `notif_day_${weekday}_$prayer`
      per-cell grid). Settings has the master `SwitchListTile` + a "Customize by day" row
      that opens the new full-screen `lib/screens/notification_grid_screen.dart`
      (prayers as columns, days as rows in week-start order, checkbox chips with a
      checkmark icon). `home_shell.dart`'s `_rescheduleNotifications()` now reads the
      grid + master toggle before calling `NotificationService.scheduleUpcoming`,
      replacing the old unconditional "everything fires" stand-in.
- [x] **Qibla compass cardinal letters now follow the app language.** `QiblaCompass`
      takes a `language` param (`qibla_compass.dart`), draws N/S/E/W in English mode and
      ش/ج/ق/غ in Arabic mode instead of always-Arabic; wired through
      `qibla_screen.dart` from `home_shell.dart`'s `_language`.
      `flutter analyze` + `dart run custom_lint` + `flutter test` all green after every
      change above. **Not yet live-verified on a device** — this pass was Flutter-side
      only (no APK build/device run this session).
- [ ] **Home-screen widget: only one visual variant exists** (still open — native
      Android work, out of scope for this Flutter-side pass). Design specifies 3 widget
      mockups (circular dark, circular light, rectangular light-with-sage-star); current
      `home_widget`/`NextPrayerWidgetProvider` implementation only ships the one
      rectangular card style. Overlaps with the existing "add a horizontal
      5-prayer-row style" and "add a progress-bar style" widget TODO items below — worth
      deciding as one combined "widget style picker" piece of work.
- [x] **Corrected against the actual approved screenshots (2026-08-07, same day).** The
      first redesign pass above was based only on the handoff's `README.md` prose, not
      the real rendered design — user pointed out the result looked "so much different"
      and pointed at `design/ScreenShots/*.png` (4 screenshots from the Claude Design
      tool: prayer list, qibla gauge, widgets/icons, and the qibla screen in English).
      Comparing against those directly surfaced real gaps the prose missed, fixed in the
      same session:
      - **Qibla compass fully repainted** (`qibla_compass.dart`): the screenshot shows a
        sage↔terracotta gradient ring with tick marks, a fixed true-north dot, a cream
        dial with a faint diamond medallion, and a wide chevron/arrowhead needle — not
        the old brass ring + thin two-tone pointer. Rewrote the `CustomPainter`
        accordingly.
      - **Star watermark was tiled, should be one large corner emblem.**
        `star_watermark.dart` had been (mis-)changed in an earlier session to a small
        tiled repeat "to fix a mockup bug" — the actual approved design shows one big
        low-opacity star anchored top-corner behind the app bar, exactly like the
        original handoff prose said. Rewrote to a single `Align`ed emblem.
      - **App bar didn't match**: screenshot shows a bold serif title with a terracotta
        highlighter-style bar behind part of the text, plus a small moon/sun mode
        indicator icon at the trailing edge. Added both to `home_shell.dart`'s `AppBar`.
      - **Found and fixed a real bug while doing this**: the location pill was styled
        with `colorScheme.onPrimary`, which in the new Organic theme resolves to cream —
        against the app bar's now-also-cream background this made the location text
        invisible. Restyled the pill as its own bordered card using `surface`/`outline`/
        `accent-700` tokens directly instead of assuming a colored app bar.
      - `flutter analyze` + `dart run custom_lint` + `flutter test` all still green after
        these changes (INFO-level "missing const decoration" hints remain, same
        dynamic-color false-positive class as before).
      - **Artifact rebuilt a second time** to match the screenshots pixel-by-pixel where
        feasible in HTML/CSS/SVG: bold serif type, the same qibla gauge redesign, a
        tessellating eight-point-star SVG pattern (two overlapping squares, matching the
        handoff's own construction) reused across the home-widget and app-icon
        references instead of flat color chips, and the app-bar highlight/moon-icon
        treatment. Republished to the same Artifact URL.
      - **Not yet done**: the tessellating star-tile texture and the native
        Android widget/icon assets themselves were only built in the Artifact/HTML
        reference, not regenerated as real Flutter/Android assets (existing app icon and
        home-widget background are still the older simple seal, not this tile pattern) —
        call this out explicitly rather than assume it's covered by the earlier "only one
        widget visual variant" TODO item below, since the actual texture design changed
        too, not just the count of variants.
      - **Second correction, same day**: user caught that the rectangular "PRAYERS"
        widget's sage tile in the screenshot isn't just the star texture -- it also has
        the qibla gauge's needle + true-north dot drawn on top of it (same motif as the
        standalone Qibla widget, just smaller/embedded). Missed this on the first
        artifact rebuild; added the mini needle overlay to the Artifact's rectangular
        widget mockup. **Flag for whoever eventually builds the real native widget**:
        the rectangular Android widget layout needs this needle+dot drawn onto its sage
        tile too, not just the star pattern -- easy to miss again since it's a small
        detail inside a busy reference image.
      - **Third correction, same day**: user asked directly whether the *motif itself*
        had drifted, prompting a closer zoom on the app-icon/widget screenshots. It had
        -- the app icons and widget backgrounds in the screenshots are a checkerboard of
        the actual filled {8/3} khatam star polygon (the exact shape given in the
        handoff's own reference coordinates), not the "two outlined squares" stand-in
        used in both the first and second artifact rebuilds. Rebuilt the Artifact's SVG
        pattern defs to tile the real polygon (corner + center placement per tile so
        adjacent copies interlock edge-to-edge, matching how these girih patterns are
        actually constructed) across all 6 colorways. Also caught the same crude
        two-square shape being used for the **qibla compass's center medallion** in the
        real Flutter code (`qibla_compass.dart`) -- fixed there too, via a new
        `_drawKhatamStar()` helper using the same polygon construction as
        `star_watermark.dart`'s corner emblem, so all three motif usages (corner
        watermark, qibla medallion, widget/icon tessellation) now agree.
        `flutter analyze`/`custom_lint`/`flutter test` all green after this fix too.
      - **Fourth correction, same day — stopped trusting eyeballed comparisons and
        actually ran the real app.** User pushed back a third time: "I know you will
        already drift from the artifact when applying to the real app (as you always
        do)". Fair -- every fix up to this point was verified by re-reading source, not
        by looking at the actual rendered app. Added Flutter **web** platform support
        (`flutter create . --platforms=web`, new `web/` dir + `.claude/launch.json`) so
        the real app could be run and screenshotted in a browser and compared directly
        against `design/ScreenShots/*.png`, instead of maintaining a separate hand-built
        HTML approximation that can silently drift from the Dart code. This is
        verification-only -- the app still ships Android-only; web is not a target
        platform.
        - Guarded every mobile-only plugin call (`google_mobile_ads`, `home_widget`,
          `flutter_local_notifications`/`flutter_timezone`) behind `kIsWeb` in
          `ad_service.dart`, `banner_ad_widget.dart`, `widget_service.dart`,
          `notification_service.dart`, and `main.dart` -- none of these have a web
          implementation and were throwing `MissingPluginException` before `runApp()`
          ever got a chance to render, leaving a blank white page.
        - **Two real bugs found by actually looking at the rendered app** (not visible
          from reading the code, and not things the earlier "eyeball the screenshot"
          passes caught):
          1. `star_watermark.dart`'s corner emblem was **340x340 at 10% opacity**,
             rendering as an oversized, blurry, half-transparent disc that bled down
             over multiple prayer rows instead of a compact corner accent. Shrunk to
             220x220 at 7% opacity, pushed further into the corner.
          2. **Caprasimo/Figtree have no Arabic glyphs** — Arabic text (the app's
             default language) was silently falling back to the platform's plain
             default font the entire time, meaning the "bold serif heading" look from
             the design was never actually showing for Arabic users, only for any
             stray Latin text. Fixed properly via `TextTheme.apply(fontFamilyFallback:
             ...)` in `app_theme.dart` -- Rakkas for headings, Noto Sans Arabic for
             body -- so Flutter automatically falls through per-glyph instead of
             switching the whole font by locale.
        - **Verified live in the browser** (Prayer Times screen, Arabic/RTL): date
          header, all 6 prayer rows, the peach/terracotta-bordered next-prayer card
          with the live countdown, the location pill, and the corner star watermark all
          now render correctly and match the reference screenshot much more closely
          than any prior artifact-only comparison could confirm.
        - **Not verified this session**: Qibla and Settings screens, and English/LTR —
          browser click automation against the Flutter web canvas consistently timed
          out when switching bottom-nav tabs (a tooling limitation hit repeatedly, not
          an app bug), so only the default first tab was confirmed live. Flag for next
          session: re-attempt tab switching, or fall back to a real Android
          emulator/device run instead of web.
        - `flutter analyze` + `dart run custom_lint` + `flutter test` all green after
          this round too (same handful of INFO-level "missing const decoration"
          false positives as before, nothing new).
- [x] **Design-mockup Artifact republished to match** — the "معاينة تطبيق مواقيت الصلاة
      والقبلة" Artifact (same URL as before) was rebuilt from scratch on the Organic
      tokens: interactive phone-frame mock with a live language (AR/RTL ⇄ EN/LTR) and
      light/dark toggle, switchable Prayer Times / Qibla / Settings / notification-grid
      screens, plus the 3 home-widget mockups and 3 app-icon color variants from the
      handoff's README. The previous Artifact was still on the old teal/gold palette
      from before this redesign — fully replaced, not merged.
- [x] **Fixed a real infinite-spinner bug on the Qibla screen, found live by the user
      manually clicking the tab themselves** (2026-08-07, after the browser-automation
      click issue above blocked me from finding it via the same route). `QiblaScreen`'s
      `StreamBuilder` on `FlutterCompass.events` only ever handled two cases: the stream
      connected and sent a heading (show the compass), or connected and sent a null
      heading (`compassUnavailable` message) — there was no handling at all for **the
      stream never emitting anything in the first place**, which just leaves
      `ConnectionState.waiting` forever with no way out. Confirmed root cause:
      `flutter_compass`'s own `pubspec.yaml` only declares `android`/`ios` platform
      implementations, nothing else — on the web verification build this session added,
      `FlutterCompass.events` connects but never sends a single event. The same failure
      mode is also possible on a **real Android device with no magnetometer**, not just
      on web, so this was worth fixing properly rather than dismissing as web-only.
      Fix: `qibla_screen.dart` now chains `.timeout(Duration(seconds: 4))` onto the
      stream and treats `snapshot.hasError` (what a stream timeout produces) the same
      as the existing null-heading case. Converted `QiblaScreen` to a `StatefulWidget`
      to hold the stream instance stably across rebuilds (recreating a `.timeout()`
      stream every `build()` would keep resubscribing and never actually time out), and
      added a `debugCompassStreamOverride` constructor param purely so this is testable
      without a real sensor. New regression test:
      `test/qibla_screen_test.dart`, using a `StreamController` that's deliberately
      never fed data — asserts the spinner shows immediately, then the
      `compassUnavailable` message replaces it once the timeout fires.
      `flutter analyze` + `dart run custom_lint` + `flutter test` all green (custom_lint
      also flagged the new test's bare `MaterialApp()` with no theme —
      `impeccable_material_baseline` — fixed by giving it one).
      **Not yet re-verified live** on a real Android device (only via the new widget
      test) — next session, confirm this doesn't regress the normal working-compass
      path on-device, not just the timeout path.

### Easy
- [x] ~~Dark vs. light theme support~~ — **superseded, done differently.** This item
      predates the Organic redesign and referenced a `ColorScheme.fromSeed(seedColor:
      Colors.teal)` that no longer exists. Delivered instead (2026-08-07) as part of the
      4-mode appearance setting above: `AppTheme.light()`/`AppTheme.dark()` in
      `lib/theme/app_theme.dart`, `main.dart`'s `darkTheme`, and `ThemeMode` driven by
      `PrefsService.appearanceMode`. The brass-gradient contrast-check caveat mentioned
      here no longer applies either — `qibla_compass.dart` was fully repainted (see
      above) and its colors now come from `AppTheme` tokens, not a hardcoded brass
      gradient.
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
- [x] **App display name decided (2026-08-09): "Salaty."** User pointed out the
      launcher was showing the literal Flutter project placeholder name
      (`android:label="prayer_qibla"`) as the icon caption, which is ugly/technical.
      Changed `AndroidManifest.xml`'s `android:label` to `"Salaty"`, plus the
      web-preview-only `web/index.html`/`web/manifest.json` title/name for
      consistency. **`applicationId` stays `com.hgdroid.prayer_qibla`** — unrelated
      and already locked (can't change post-upload, see the decision entry below).
      The in-app `AppBar` still shows the existing localized tagline
      (`appName` in `app_strings.dart`: "مواقيت الصلاة والقبلة" / "Prayer Times &
      Qibla") — not touched, since that's separate branded copy, not the
      ugly-placeholder issue that was reported. Revisit if "Salaty" should replace
      that too.
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
