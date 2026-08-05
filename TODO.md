# TODO — Prayer Qibla App

قائمة بكل اللي المفروض يتعمل، مقسّمة حسب الحالة. حدّثي الملف ده أول ما تخلصي أي بند
(انقليه لقسم "تم" مع تاريخ تقريبي لو حابة).

## تم ✅

- [x] تثبيت Flutter SDK محلياً (بدون Android SDK محلي — الاعتماد على GitHub Actions)
- [x] عمل مشروع Flutter (`prayer_qibla`) + رفعه على GitHub (public repo)
- [x] GitHub Actions workflow لبناء الـ APK تلقائياً (debug + release) عند كل push
- [x] `impeccable_flutter_lints` + `custom_lint` مربوطين في الـ CI
- [x] حساب مواقيت الصلاة (`adhan_dart`) + اتجاه القبلة
- [x] شاشة المواقيت (مع الصلاة القادمة متلونة، بانر إعلان)
- [x] شاشة القبلة (بوصلة حقيقية عن طريق `flutter_compass`)
- [x] شاشة الإعدادات (لغة، طريقة حساب، مذهب)
- [x] دعم عربي/إنجليزي (`AppStrings`) + RTL
- [x] موقع GPS + طلب صلاحية + رسائل خطأ واضحة
- [x] اختيار مدينة يدوي من أي مكان في العالم (بحث Nominatim) بدل GPS
- [x] التاريخ الهجري + الميلادي في شاشة المواقيت
- [x] إصلاح بناء Android (compileSdk 37 + core library desugaring)
- [x] أول APK حقيقي اتبنى بنجاح ونزل كـ GitHub Release
- [x] تنبيهات أذان محلية (`flutter_local_notifications`) — أساسية
- [x] تنبيهات مخصصة **لكل يوم ولكل صلاة على حدة** (مصفوفة 7×5) بدل زرار واحد عام
- [x] معاينة تصميم (Mockup) لشاشات المواقيت/القبلة/الإعدادات + ويدجت الشاشة الرئيسية

## شغالين عليه دلوقتي 🔄

- [ ] **branch:** `feature/per-day-prayer-notifications` — الكود خلص وعدّى
      analyze/lint/test، لسه محتاج commit + push + دمج على master
- [ ] التأكد إن جدولة الإشعارات لـ 7 أيام قدام شغالة صح على جهاز حقيقي (مش مجرد تحليل ثابت)

## قدام (لسه ماتعملناش) 📋

### فيتشرز أساسية
- [ ] **Android Home Screen Widget** — ويدجت بيوضح الصلاة القادمة من غير فتح التطبيق
      (هيحتاج `home_widget` package + Kotlin `AppWidgetProvider` + XML layout)
- [ ] تجربة الـ APK فعلياً على موبايل حقيقي أو محاكي (لسه معملناش ده، كل التأكيد لغاية
      دلوقتي كان عن طريق `flutter analyze`/`test` بس مش تشغيل فعلي)
- [ ] إعادة جدولة الإشعارات تلقائياً في الخلفية (لو المستخدم مفتحش التطبيق كذا يوم،
      حالياً بنجدول 7 أيام قدام بس ده بيحصل بس وقت فتح التطبيق)

### قبل أي نشر فعلي (Play Store)
- [ ] استبدال AdMob test IDs بـ IDs حقيقية (`android/app/src/main/AndroidManifest.xml`
      و `lib/services/ad_service.dart`)
- [ ] عمل **keystore/signing key** حقيقي للـ release build (حالياً بيوقع بمفتاح debug —
      مش صالح للنشر)
- [ ] تحديد اسم التطبيق النهائي + الأيقونة (لسه بنستخدم الأيقونة الافتراضية من `flutter create`)
- [ ] كتابة Privacy Policy (مطلوب من جوجل لأي تطبيق بيستخدم AdMob + الموقع)
- [ ] لقطات شاشة حقيقية + وصف التطبيق لصفحة Play Store
- [ ] تحديد `applicationId` النهائي (حالياً `com.hgdroid.prayer_qibla`)
- [ ] بناء `--split-per-abi` لتصغير حجم الـ APK (النسخة الحالية ~53 ميجا، كبيرة لتطبيق "خفيف")

### قرارات لسه معلقة
- [ ] هل هنكمل دعم iOS ولا نقفل عليه أندرويد بس؟ (الأصل كان أندرويد بس)
- [ ] هل محتاجين اشتراك Play Console (25$ مرة واحدة) دلوقتي ولا لسه بدري؟

## ملاحظات

- كل بند هنا لازم يعدي `flutter analyze` + `dart run custom_lint` + `flutter test`
  قبل ما نعتبره "تم".
- راجعي `CONSTITUTION.md` قبل أي شغل جديد — فيه قواعد المشروع والدروس المستفادة.
