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
- [x] `CONSTITUTION.md` and `TODO.md` created to carry context across sessions

## In progress / needs attention right now 🔄

- [ ] **PR #1** (`feature/per-day-prayer-notifications` → `master`) — CI build was
      running as of the last check; merge once it's green. This PR contains the Hijri
      date feature and the notification matrix.
- [ ] Confirm the 7-day rolling notification schedule actually fires correctly on a
      real device (so far only verified by static analysis/tests, not a live run)

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
- [ ] Subtle eight-point-star watermark as a background texture **in the real app**
      (Scaffold background), matching the treatment already applied to the mockup's
      page background — this was requested for the app itself, not just the preview
- [ ] Try the APK on an actual phone or emulator — everything so far has only been
      confirmed via `flutter analyze`/`test`, never a live run
- [ ] Background rescheduling so notifications stay current even if the user doesn't
      open the app for several days (currently the 7-day window is only refreshed when
      the app is opened)

### Before any real Play Store release
- [ ] Replace AdMob test IDs with real ones (`AndroidManifest.xml` and `ad_service.dart`)
- [ ] Create a real release **keystore/signing key** (currently signed with the debug
      key, which is not publishable)
- [ ] Decide on a final app name + real app icon (still using `flutter create`'s default)
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
