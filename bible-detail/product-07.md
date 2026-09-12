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

