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

