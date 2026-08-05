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

## In progress / needs attention right now 🔄

- [ ] Confirm the 7-day rolling notification schedule actually fires correctly on a
      real device (so far only verified by static analysis/tests, not a live run)
- [ ] **PR #3** (`feature/qibla-compass-and-location-refresh` → `master`) — fixes below,
      merge once CI is green.

## Known gaps in the design mockup (not the real app)

The mockup (`prayer_qibla_mockup.html`, a separate Artifact) is a fast way to iterate on
visual direction, but it is a hand-maintained file that does **not** automatically track
the real Flutter code. As of now it is missing:

- [ ] The Hijri/Gregorian date header (implemented in the real app, not in the mockup)
- [ ] The per-day/per-prayer notification grid in the settings screen preview

If the mockup is picked up again, sync these first so it doesn't misrepresent what the
app actually does.

## Not started yet 📋

### Core features
- [ ] **Android home screen widget** — shows the next prayer without opening the app
      (needs the `home_widget` package + a Kotlin `AppWidgetProvider` + XML layout)
- [ ] Try the APK on an actual physical phone (still only verified via `flutter
      analyze`/`test` plus one appetize.io web-emulator run so far — no real device yet)
- [ ] Consider continuous/background location watching instead of the current
      fetch-once-at-startup + manual-refresh-only model, if one-shot GPS + pull-to-
      refresh + the manual city picker turns out not to be enough in practice
- [ ] Background rescheduling so notifications stay current even if the user doesn't
      open the app for several days (currently the 7-day window is only refreshed when
      the app is opened)

### Before any real Play Store release
- [ ] Replace AdMob test IDs with real ones (`AndroidManifest.xml` and `ad_service.dart`)
- [ ] Create a real release **keystore/signing key** (currently signed with the debug
      key, which is not publishable)
- [x] Real app icon — the seal motif (ring + eight-point star), generated via
      `flutter_launcher_icons` for legacy + adaptive icon across all densities
- [ ] Decide on a final app name (still just "prayer_qibla" / `com.hgdroid.prayer_qibla`)
- [ ] Write a Privacy Policy (required by Google for any app using AdMob + location)
- [ ] Real screenshots + Play Store listing copy
- [ ] Finalize `applicationId` (currently `com.hgdroid.prayer_qibla`)
- [ ] Build with `--split-per-abi` to shrink the APK (currently ~53MB, large for a
      "lightweight" app)

### Open decisions
- [ ] Keep iOS in scope, or officially drop it and go Android-only? (original scope was
      Android-only)
- [ ] When to pay the one-time $25 Google Play Console fee — now or closer to launch?

## Notes

- Every item here must pass `flutter analyze` + `dart run custom_lint` +
  `flutter test` before being considered done.
- Read `CONSTITUTION.md` before starting any new work — it has the project rules and
  the learnt-lessons log.
