## 6. Settled feature decisions (don't re-litigate without new input)

- **Per-day/per-prayer notification muting was removed (2026-08-05), not just
  deferred.** The old UI (`_PrayerDayToggleRow`/`_DayChip` in `settings_screen.dart`,
  plus `PrefsService.getNotificationMatrix`/`setNotificationEnabled`) grouped by
  **prayer** with 7 day-toggles underneath each one. The user wants the *opposite*
  shape next: grouped by **day**, with the prayers listed underneath each day. Rather
  than leave the old, soon-to-be-replaced UI in place, it was deleted outright — see
  TODO.md for the redesign task. In the meantime, `scheduleUpcoming(...)` in
  `home_shell.dart` fires all 5 notifiable prayers unconditionally
  (`isEnabled: (weekday, prayer) => true`); there is currently no per-prayer/per-day
  muting at all until the redesign lands.
- **`applicationId` is finalized (2026-08-06): staying on `com.hgdroid.prayer_qibla`,
  no rename.** Explicitly confirmed with the user, since this can never change again
  after the first Play Store upload. Don't revisit this without a strong new reason —
  a change now would mean starting over as a brand-new Play Store listing.
- **First-ever app launch defaults to Cairo, Egypt (2026-08-06), not a live GPS
  prompt.** Confirmed bad UX live on the Mi 10: a fresh install blocked on a full GPS
  permission flow with nothing but a blank screen until it resolved. Decided
  approach, in order of precedence in `home_shell.dart`'s `_bootstrap()`: (1) a saved
  manual location always wins, (2) otherwise a cached GPS fix (`PrefsService`) is
  used instantly while a fresh fix refreshes in the background, (3) otherwise —
  meaning no location has ever been resolved or picked at all — default to Cairo
  (`_defaultLatitude`/`_defaultLongitude` constants) with **no automatic GPS
  prompt**. The user opts into GPS or a specific city explicitly via the existing
  location picker (`CitySearchScreen`, tap the app bar location chip). Don't revert
  to auto-requesting GPS on first launch without asking again.
- **AdMob real IDs, the release signing keystore, and re-enabling R8 minification are
  all deliberately still open/undecided** as of 2026-08-06 — each was asked about
  individually and none were confirmed (the AskUserQuestion prompts were dismissed or
  the user redirected to something else first). Don't assume a default for any of
  these three; ask again before acting on them.
