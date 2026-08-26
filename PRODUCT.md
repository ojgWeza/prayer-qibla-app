# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Practicing Muslims who need accurate daily prayer times and Qibla direction. Primary
audience is Egypt/the Arab world; global Arabic- and English-speaking Muslims are a
confirmed secondary audience. The core job: check today's prayer times and find the
Qibla direction, either from GPS or a manually picked city, quickly and without
needing an active data connection at the moment of prayer.

## Product Purpose

Salaty gives users accurate daily prayer times and a real-sensor Qibla compass,
computed fully on-device with no backend, so it keeps working once installed even
without connectivity. Success is the right prayer times/qibla for the user's actual
location, visible at a glance (including from the home screen widget without opening
the app), with reminders that don't require the user to remember to check manually.

## Positioning

Fully on-device computation (`adhan_dart`) with no backend dependency of the product's
own — the only network call is a single Nominatim (OpenStreetMap) lookup per manual
city search, not a standing dependency — making the app offline-safe and
privacy-respecting where competitors may phone home. Distinguishes further with a real
magnetometer-driven Qibla compass (not a static arrow) with live "facing Qibla"
alignment feedback, a home-screen widget that stays current without opening the app,
and a culturally authentic Islamic geometric design language (the eight-point
khatam/girih star motif) rather than generic app UI.

## Operating Context

Used daily, typically multiple times a day around each of the 5 prayers. Users often
check the home-screen widget without opening the app at all, or open the app
specifically for the Qibla compass while physically turning to orient themselves for
prayer (phone held upright — tilt/flat-on-table readings are known to be unreliable).
Manual city search serves travelers or anyone who doesn't want to grant GPS. Language
is a per-app setting independent of the device's system locale, so the UI, in-app
strings, and even the home-screen widget's text direction must follow the app's own
language choice, not just the OS's. Settings drive: calculation method, madhab, 12/24h
time format, a 4-mode appearance setting (including an "after Maghrib" auto-dark
mode), and per-day/per-prayer notification muting (mid-redesign, see below).

## Capabilities and Constraints

- On-device prayer time and Qibla bearing calculation (`adhan_dart`); the only network
  dependency is Nominatim geocoding for manual city search, called once per search.
- No backend of our own and no database — all settings persist via `SharedPreferences`
  through `PrefsService`.
- Monetization is AdMob banner ads only, no subscriptions or IAP. Currently wired to
  Google's official test ad unit IDs — must be swapped for real IDs before any real
  Play Store release (not yet done).
- Android home screen widget (`NextPrayerWidgetProvider`) shows the next prayer without
  opening the app, refreshed via Android's own periodic widget update, independent of
  the Flutter engine. Its Qibla needle is intentionally static (true-bearing only, not
  live-heading) since a widget has no continuous compass-sensor feed without a
  battery-costly foreground service — the user's first reaction was that this
  "shouldn't be" static, so this is a live, unresolved discussion, not a settled
  decision.
- Builds run exclusively via GitHub Actions CI — there is no local Android SDK/NDK on
  the dev machine, only the Flutter SDK itself.
- **iOS platform scope is explicitly undecided.** Original scope was Android-only; an
  unconfigured `ios/` folder exists only because `flutter create` scaffolds it by
  default, and no iOS-specific work (icons, entitlements, real device testing, App
  Store setup) has been done. Do not start iOS-specific work, and do not assume
  Android-only either, without asking again — this is a live open decision, not a
  default.
- Localization is Arabic and English via a plain `Map` (`lib/l10n/app_strings.dart`,
  no code-gen/ARB), with full in-app RTL support. No other languages are planned.
- `applicationId` is locked at `com.hgdroid.prayer_qibla` — cannot change after the
  first Play Store upload, already confirmed with the user.

## Brand Commitments

- App display name is **"Salaty"** (`android:label`, decided 2026-08-09/10). The
  in-app app-bar tagline still shows the older localized name ("مواقيت الصلاة والقبلة"
  / "Prayer Times & Qibla") — that has not yet been reconciled with the Salaty rebrand;
  treat as a known gap, not an intentional two-name system.
- Visual identity follows the "Organic" design system: a warm cream/terracotta/sage
  palette, Caprasimo (Latin headings) + Rakkas (Arabic headings) + Figtree (Latin body)
  + Noto Sans Arabic (Arabic body), all bundled locally as assets (no runtime font
  fetching). The eight-point khatam/girih star motif is used consistently as the single
  signature mark (corner watermark, Qibla compass medallion, widget/icon
  tessellation) — deliberately not scattered as decoration elsewhere. Full detail lives
  in `design/extracted/design_handoff_prayer_qibla_app/DESIGN_RULES.md` (gitignored,
  not guaranteed present on a fresh clone).
- A real device-sensor Qibla compass (`flutter_compass`), not a static icon, is a
  stated product commitment, not just an implementation detail.

## Evidence on Hand

- `design/` (gitignored, not committed — will be absent on a fresh clone) holds the
  original "Organic" design handoff (`design/Prayer times app design.zip` and its
  extracted `design_handoff_prayer_qibla_app/`) and approved reference screenshots
  (`design/ScreenShots/*.png`) that the current visual system was built and verified
  against. If a future session needs to re-check something against the original design
  source, ask the user to re-supply `design/` rather than assuming it still exists.
- No customer testimonials, case studies, press mentions, or usage benchmarks exist —
  do not fabricate any for marketing or store-listing copy.
- A Google Play Console account exists and the $25 registration fee is paid
  (2026-08-06); identity verification was still pending as of that session. No live
  Play Store listing exists yet.

## Product Principles

1. Zero backend, zero database — everything computes on-device or reads
   `SharedPreferences`; the one narrow exception (Nominatim city search) is a single
   per-search call, not a standing dependency.
2. Never block the user on network or sensors — cached/default location on first
   launch, no forced GPS prompt, graceful fallback when the compass or a fresh GPS fix
   isn't available yet.
3. Verify on a real device before calling anything done — mockups and even the
   Flutter-web verification build have repeatedly drifted from real on-device
   rendering in ways only a physical-device check caught.
4. Culturally authentic over generic — real khatam/girih geometry and a real magnetic
   compass sensor, not decorative or placeholder stand-ins.
5. Egypt/the Arab world first — Arabic is the default language and gets first-class
   treatment (fonts, RTL, a culturally appropriate default location), English is a
   fully supported second audience, not an afterthought.

## Accessibility & Inclusion

No formally adopted accessibility standard is in place yet. Full RTL support and
bilingual (Arabic/English) parity are treated as confirmed, first-class product
requirements, not optional polish.
