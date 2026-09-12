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

