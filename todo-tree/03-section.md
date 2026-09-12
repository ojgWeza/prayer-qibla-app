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
- [x] **Bug: "next prayer" highlight on the Prayer Times screen is sometimes
      wrong — investigated and fixed (2026-08-15).** Original report (2026-08-06,
      "Fajr hadn't been called yet, but Dhuhr was highlighted as next") predated
      several since-landed fixes (UTC/local conversion, GPS caching, the Cairo
      default-location fallback, the midnight-rollover recompute) and could not be
      reproduced as originally described. Investigation via `/investigate` found a
      real, concretely-reproducible bug in the same area instead: `_nextPrayerKey()`
      in `lib/screens/prayer_times_screen.dart` only ever looks inside the single
      day's `times.ordered` list (today's 6 entries) — `home_shell.dart`'s
      `_recomputeTimesAndQibla()` already computes a full 7-day `upcomingDays` list
      for notification scheduling, but only ever passed `upcomingDays.first` (today)
      down to the screen, discarding the rest. So **after Isha and before midnight**,
      every one of today's entries is in the past, `_nextPrayerKey()` returns `null`,
      and the screen shows **no highlight and no countdown at all** — even though
      there plainly is a next prayer (tomorrow's Fajr). Confirmed live via the
      Flutter-web loop at the actual real-world reproduction instant (23:12 Cairo
      time, after Isha): no row was highlighted before the fix.
      Fixed by threading a `nextDayFajr` value through: `home_shell.dart` now stores
      `_nextDayFajr = upcomingDays[1].fajr` alongside `_prayerTimes` in the same
      `setState()`, and passes it to `PrayerTimesScreen` as a new required
      `nextDayFajr` param. In `prayer_times_screen.dart`'s `build()`, when
      `_nextPrayerKey()` finds nothing left today, it rolls over to `nextKey='fajr'`
      / `nextTime=widget.nextDayFajr` instead of leaving both null; the Fajr row's
      displayed clock time is also overridden to `nextDayFajr` in that specific case
      (not today's already-passed value) so the digits shown match the actual next
      occurrence. Matching by `entry.key == nextKey` still can't double-highlight
      today's own (already-past) Fajr row, since the two cases are mutually
      exclusive (`rolledOverToTomorrow` is only true when nothing today qualifies).
      New `test/prayer_times_screen_test.dart` (2 cases: rollover, and a normal
      same-day highlight unaffected by the change) — confirmed the rollover test
      fails to even compile against the pre-fix widget (proves the widget genuinely
      lacked this capability, not just a logic tweak) and passes with the fix.
      `flutter analyze` + `dart run custom_lint` + `flutter test` (10/10) all green.
      **Live-verified via the free `flutter run -d web-server` loop** (no CI/device
      build) at the real after-Isha instant: Fajr row now shows "Next prayer — 5
      hours & 29 minutes remaining" with the correct tomorrow's clock time (04:49),
      instead of nothing.
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

