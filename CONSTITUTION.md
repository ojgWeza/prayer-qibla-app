# دستور المشروع — Prayer Qibla App

هذا الملف أول حاجة المفروض تتقرأ قبل أي شغل على المشروع ده. الهدف منه إننا مانعيدش اختراع
العجلة ولا نكرر نفس الأخطاء تاني.

## 1. الهدف من التطبيق

تطبيق أندرويد خفيف (هدف أصلي: أندرويد بس، iOS مش متأكد منه ولا متظبط) بيعمل حاجتين أساسيتين:

- **مواقيت الصلاة**: بالموقع الحالي (GPS) أو بمدينة يختارها المستخدم يدوياً من أي مكان في العالم.
- **اتجاه القبلة**: بوصلة بتستخدم حساس الجهاز الحقيقي.

الربح عن طريق **إعلانات AdMob** فقط (مفيش اشتراكات ولا مشتريات داخل التطبيق حالياً).
الجمهور: مصر/الوطن العربي بالدرجة الأولى + عالمي (عربي/إنجليزي).

## 2. مبادئ أساسية (اتفقنا عليها ومتتغيرش من غير نقاش)

1. **كل حاجة تشتغل من غير سيرفر/باك إند من عندنا.** المواقيت والقبلة بيتحسبوا محلياً على
   الجهاز (`adhan_dart`). الاستثناء الوحيد هو البحث عن مدينة (Nominatim API خارجي مجاني،
   مرة واحدة وقت البحث بس، مش استخدام دوري).
2. **مفيش تحميل Android SDK محلي على جهاز المطور.** البناء (build) بيحصل بالكامل على
   **GitHub Actions** (`.github/workflows/build.yml`) — ده قرار متعمد عشان نوفر مساحة
   وتعقيد على الجهاز المحلي. Flutter SDK بس محلي (`D:\dev\flutter`) لأغراض
   `flutter analyze` / `flutter test` / تحرير الكود.
3. **كل تعديل لازم يعدي على:**
   - `flutter analyze` (لازم "No issues found")
   - `dart run custom_lint` (فحص `impeccable_flutter_lints` ضد "روائح تصميم الـ AI" — لازم يطلع نضيف)
   - `flutter test`
   قبل ما يتعمله push. الـ CI بيشغلهم برضو، بس أرخص نكتشف المشكلة محلياً الأول.
4. **الترجمة (AR/EN) عن طريق `lib/l10n/app_strings.dart`** — Map بسيط بدون code-gen،
   مش `flutter gen-l10n` / ARB files. الهدف إبقاء الحجم والتعقيد صغير.
5. **الإعدادات كلها في `SharedPreferences` عن طريق `PrefsService`** — مفيش قاعدة بيانات،
   مفيش حاجة تتخزن على أي سيرفر.
6. **AdMob IDs الحالية هي test IDs الرسمية من جوجل** (`ca-app-pub-3940256099942544/...`).
   **لازم تتغير لـ IDs حقيقية قبل أي نشر فعلي على Play Store.**
7. **Git workflow: branch منفصل لكل فيتشر جديدة** ثم merge على `master` بعد التأكد إنها
   شغالة (قرار المستخدم بتاريخ بداية المشروع — راجعي أول ما تبدئي فيتشر جديدة).
8. **مفيش تصميم "شكله AI" افتراضي** — ممنوع `Colors.deepPurple` seed، `Colors.black`/`white`
   الحرفيين، تباين ضعيف، إلخ. ده اللي بيتفحصه `impeccable_flutter_lints` فعلياً.

## 3. البنية (Architecture) باختصار

```
lib/
  main.dart                 — نقطة الدخول + MaterialApp + إدارة اللغة
  l10n/app_strings.dart      — كل النصوص (AR/EN)
  services/
    prayer_times_service.dart — حساب المواقيت والقبلة (adhan_dart)
    location_service.dart     — GPS عن طريق geolocator
    geocoding_service.dart    — بحث مدينة عن طريق Nominatim (OpenStreetMap)
    notification_service.dart — جدولة تنبيهات الأذان (flutter_local_notifications)
    date_service.dart         — تحويل هجري/ميلادي (حزمة hijri، بدون intl locale init)
    prefs_service.dart        — كل التخزين المحلي (SharedPreferences)
    ad_service.dart           — تهيئة AdMob
  screens/
    home_shell.dart           — الحاوية الرئيسية، فيها كل الـ state المشترك
    prayer_times_screen.dart
    qibla_screen.dart
    settings_screen.dart
    city_search_screen.dart
  widgets/
    banner_ad_widget.dart
```

`home_shell.dart` هو مركز الـ state (موقع، مواقيت، إعدادات، تنبيهات) وبيمرر كل حاجة
كـ props للشاشات التانية. مفيش state management library خارجية (Provider/Riverpod/Bloc) —
الحجم الحالي للتطبيق مايستحملش التعقيد ده.

## 4. الدروس المستفادة (Learnt Lessons)

قسم بيتحدث كل ما نتعلم حاجة جديدة أو نقع في مشكلة وناخد وقت نحلها. الهدف: منكررش نفس الغلطة.

### بناء Android (Gradle)
- `permission_handler_android` محتاج `compileSdk = 37` — الافتراضي من Flutter (36) مش كفاية.
- `flutter_local_notifications` محتاج `isCoreLibraryDesugaringEnabled = true` في
  `compileOptions` + `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`
  في `dependencies` جوه `android/app/build.gradle.kts`.
- لو ظهر خطأ Gradle عن compileSdk/desugaring، الحل غالباً في نفس الملف ده.

### حزم خارجية (Packages) — تفاصيل غير بديهية
- `flutter_timezone` (v5) بيرجع `TimezoneInfo` object، مش `String` — استخدمي `.identifier`.
- حزمة `hijri`: الـ locale keys هي `'ar'` و `'en'` بالظبط (مش `'Arabic'` ولا أي حاجة تانية).
- `adhan_dart`: الكلاس `Qibla.qibla(coordinates)` بيرجع الزاوية مباشرة، والـ `PrayerTimes`
  بياخد `CalculationParameters` من `CalculationMethodParameters.<method>()`.

### GitHub / gh CLI
- لو `git push` رفض تعديل على `.github/workflows/*.yml` بسبب "OAuth App... without
  `workflow` scope"، الحل: `gh auth refresh -h github.com -s workflow` (أو اطلبي كل
  الصلاحيات العملية دفعة واحدة من الأول: `repo,workflow,gist,read:org`).
- لو `git push` طلع 403 لحساب غلط، شغلي `gh auth setup-git` عشان git يستخدم توكن gh
  بدل أي credential قديم متخزن في Windows Credential Manager.
- تحميل GitHub Actions artifacts محتاج تسجيل دخول. لو عايزة تدي حد رابط تحميل مباشر
  بدون تسجيل دخول، اعملي **GitHub Release** وارفعي الـ APK كـ asset عليه
  (`gh release create ... path/to.apk`).

### صور خارجية / تصميم
- **افحصي أي صورة بعينك (أداة Read) قبل ما تستخدميها** — وصف WebFetch النصي للصورة
  مش موثوق لتقييم الزاوية/الإطار (اتغلطنا في صورة بوصلة كانت لقطة جانبية لفاترينة متحف
  كاملة بدل ما تكون وش البوصلة لوحدها).
- لو مفيش أداة موثوقة لمعاينة CSS/HTML بصرياً في الجلسة، **متدّعيش إنك شفتي النتيجة** —
  قولي بوضوح إنك مش قادرة تتأكد بعينك واعتمدي على فيدباك المستخدم المباشر.
- زخرفة النجمة الثمانية (`.star8`) بتتعمل بمربعين متراكبين (واحد مدوّر 45 درجة) — أسهل
  طريقة تعمل بيها شكل إسلامي هندسي بـ CSS خالص بدون صور أو SVG معقد.

### أدوات الجلسة (Claude Code environment)
- أداة الـ Browser الداخلية كانت متعطلة في الجلسة دي ("Browser pane is not displayed") —
  متعتمديش عليها للتحقق الذاتي، اعتمدي على فحص الملفات مباشرة (فك base64، عد الـ divs، إلخ).
- بايثون مش متاح في الـ shell — استخدمي PowerShell (`Add-Type -AssemblyName System.Drawing`)
  لأي تعديل صور (قص/تصغير/ضغط).

## 5. حاجات لسه ماتقررناش فيها نهائياً

- هل هنعمل iOS فعلاً ولا نركز أندرويد بس؟ (الأصل كان أندرويد بس)
- هل هنحتاج backend في المستقبل (زي لو ضفنا مزامنة سحابية)؟ — لغاية دلوقتي الإجابة لأ.
