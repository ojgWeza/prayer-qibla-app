## 4. Learnt lessons — index (full detail in `LESSONS.md`)

The detailed, dated debugging/decision narratives that used to live in this section now
live in **`LESSONS.md`**, unchanged, in full — moved out to keep this file's mandatory
every-session read light. **Grep `LESSONS.md` for the relevant keyword before debugging
something in one of these areas from scratch** — most of these were expensive to figure
out the first time, and the fix/root-cause is already written down.

Topics covered (grep `LESSONS.md` for these keywords):

- **Android build (Gradle)** — `compileSdk`/desugaring requirements, R8-minification-off
  (WorkManager crash), ephemeral CI debug keystore → signature mismatches on reinstall.
- **Third-party packages** — `flutter_compass` web-stream quirk, `DropdownButton` width
  bug, `flutter_timezone` API shape, `hijri` locale keys, `adhan_dart`'s
  UTC-labeled-but-correct timestamps + the two-stage timezone-rendering fix,
  `flutter_local_notifications`' Android 14+ exact-alarm permission gotcha (silently
  cancels all scheduling if ungranted).
- **Android home screen widgets (RemoteViews)** — RTL text/layout-direction quirks,
  mockup-before-XML, icon reuse, `RemoteViews` view support, grid-cell sizing floor, XML
  comment `--` parse bug, `google_fonts` doesn't reach `RemoteViews`, `setRotation`,
  static-needle decision.
- **Local device testing** — adb/JDK setup, NDK license dead end, wireless adb pairing,
  Location-Services-off vs. permission-denied, Appetize.io dead end, ephemeral-keystore
  issue also applies to debug builds, screenshot-focus privacy check, MSYS path-mangling
  fix, local-build abandonment (full failure chain).
- **Local Android emulator** — SDK/JDK setup, `avdmanager -d` bug + fix, hypervisor
  driver requirement, `ANDROID_AVD_HOME` gotcha, working boot recipe.
- **MCP servers** — `mobile` (ADB/emulator driver), `dart` (Flutter MCP, web-verification
  limits).
- **GitHub / gh CLI** — workflow-scope auth fix, gh path/auth-persistence gotchas,
  `workflow_dispatch` vs. push-trigger, HTTP 500-but-dispatched, GitHub Actions outages,
  CI Flutter-version pin drift bug.
- **External images / design assets** — verify images visually before use,
  mockup-vs-real-app drift risk, icon design lessons.
- **Tooling notes** — browser automation (Claude-in-Chrome vs. sandboxed browser)
  history, the `flutter run -d web-server` fast verification loop (and its
  cross-context-clear pitfall), Python unavailable locally.

Add new lessons to `LESSONS.md` (not here) whenever something costs real time to figure
out, so the next session doesn't pay the same cost.

