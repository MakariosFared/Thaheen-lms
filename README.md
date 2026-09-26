# 🩺 Thaheen LMS (ذهين - منصة التعليم الطبي)

> **Mini Offline Learning Management System (LMS) with Video Player for Medical Students**  
> Built with Flutter (Dart, Clean Architecture, BLoC/Cubit, Hive Offline Persistence & RTL Arabic-First UX).

---

## 📱 نظرة عامة على المشروع (Project Overview)

**ذهين (Thaheen)** هو تطبيق تعليمي مُوجّه لطلاب العلوم الطبية والتمريض في العالم العربي، يعمل **بالكامل بدون إنترنت (100% Offline)** عبر حزم البيانات والفيديوهات المدمجة داخل التطبيق (`assets/data/courses.json` و `assets/videos/`).

---

## ✨ المميزات الرئيسية (Core Features)

### 1. 📚 شاشة المقررات التعليمية (Courses Screen)
* **بطاقة استكمال المشاهدة (Continue Watching)**: تظهر تلقائياً في أعلى الشاشة عند وجود درس قيد المشاهدة لم يكتمل، مع شريط تقدم ونسبة مئوية دقيقة للانتقال المباشر للمشاهدة.
* **قائمة المقررات**: عرض غلاف كل دورة، اسم المحاضر، عدد الدروس، إجمالي المدة، وشريط التقدم المئوي الإجمالي المحسوب من الدروس المكتملة.
* **البحث الفوري (Bonus)**: فلترة سريعة للمقررات والمحاضرين بالاسم.
* **الوضع الليلي والنهاري (Dark / Light Mode)**: دعم كامل للتبديل بين الوضعين مع حفظ التفضيل في التخزين المحلي.

### 2. 📋 شاشة تفاصيل المقرر (Course Details Screen)
* **عرض تفاعلي للأقسام (Collapsible Sections)**: أقسام المقرر قابلة للطي والفتح (`ExpansionTile`).
* **حالات الدروس المتعددة**:
  * ✅ **مكتمل (Completed)**: تم مشاهدة 90% أو أكثر من مدة الدرس.
  * ⏳ **قيد المشاهدة (In Progress)**: بدأ الطالب مشاهدة الدرس ولم يكمل 90% بعد، مع عرض الدقائق/الثواني المشاهدة.
  * ⚪ **لم يبدأ (Not Started)**: الدرس مفتوح ولكن لم يبدأ تشغيله.
  * 🔒 **مقفول (Locked)**: الدرس مغلق وفقاً لقاعدة الفتح المتسلسل.
* **الفتح المتسلسل (Sequential Unlock Rule)**: يتم قفل الدرس حتى يتم إكمال الدرس السابق له. النقر على درس مقفول يعرض نافذة توجيهية لطيفة تشرح الشرط بدون حدوث أي خطأ.

### 3. 🎬 شاشة مشغل الفيديو (Lesson Player Screen)
* **تشغيل محلي (Offline Asset Player)** بدون إنترنت وبأداء عالي.
* **استئناف المشاهدة (Resume Playback)**: البدء تلقائياً من آخر موضع توقف عنده الطالب.
* **قاعدة الإكمال التلقائي عند 90%**: بمجرد وصول المشاهدة إلى 90%، يتم اعتبار الدرس مكتملاً تلقائياً وحفظه في `Hive`، مع فتح الدرس التالي مباشرة وإظهار شارة إنجاز تفاعلية.
* **التحكم في سرعة التشغيل (Playback Speed)**: خيارات `0.75x`, `1.0x`, `1.25x`, `1.5x`, `2.0x` مع حفظ السرعة المفضلة واسترجاعها تلقائياً للدروس التالية.
* **زر الانتقال للدرس التالي (Next Lesson)**: يراعي قاعدة القفل المتسلسل ويتفعل بمجرد إكمال الدرس الحالي.
* **أدوات تحكم متكاملة**: شريط تقديم وسحب (Seek bar) متوافق مع RTL، أزرار تقديم/ترجيع 10 ثوانٍ، ودعم وضع ملء الشاشة (Landscape / Fullscreen).
* **معالجة الأخطاء (Error Handling)**: معالجة آمنة لملفات الفيديو التالفة أو غير الموجودة بدون أي شاشات حمراء.

### 4. 🧪 اختبارات الجودة (Unit & Widget Tests)
* **16 اختباراً شاملاً** تغطي:
  1. قاعدة الإكمال التلقائي عند 90% وحالات الحافة (0 مدة، أرقام سالبة، نسب تقريبية).
  2. قاعدة الفتح المتسلسل للدروس.
  3. حساب النسبة المئوية لتقدم المقرر.
  4. منطق إدارة الحالة (`CoursesCubit` و `CourseDetailsCubit`).
  5. اختبار بناء الشاشات ودخان الواجهة (`Widget smoke test`).

---

## 🏗️ الهيكلية والمعمارية (Architecture & Tech Stack)

تم بناء المشروع باتباع **معمارية الطبقات المفصولة (Clean-Layered Architecture)** لضمان وضوح الكود وسهولة صيانته واختباره:

```
lib/
├── application/           # إدارة الحالة (BLoC / Cubit)
│   ├── course_details/    # CourseDetailsCubit + CourseDetailsState
│   ├── courses/           # CoursesCubit + CoursesState
│   ├── lesson_player/     # LessonPlayerCubit + LessonPlayerState
│   └── theme/             # ThemeCubit (Light / Dark mode persistence)
├── data/                  # طبقة البيانات ومصادر التخزين
│   ├── models/            # CourseModel, SectionModel, LessonModel (JSON Parsing)
│   └── repositories/      # CourseRepository (JSON Loading) + ProgressRepository (Hive)
├── domain/                # منطق الأعمال النقي (Pure Dart)
│   ├── entities/          # LessonProgress, LessonStatus
│   └── utils/             # ProgressCalculator (90% rule, unlock rule, percentage math)
├── presentation/          # واجهات المستخدم (UI & Widgets)
│   ├── router/            # GoRouter Navigation (/ -> /course/:id -> /lesson/:id)
│   ├── screens/           # CoursesScreen, CourseDetailsScreen, LessonPlayerScreen
│   ├── theme/             # AppTheme (Light & Dark Themes, RTL Color Tokens)
│   └── widgets/           # ContinueWatchingCard, CourseCard, LessonListItem
└── main.dart              # تهيئة التطبيق ومزودي الخدمات (RepositoryProviders & BlocProviders)
```

### 💡 أسباب اختيار التقنيات (Design Decisions & Justification)

1. **إدارة الحالة (State Management - Cubit)**:
   * تم استخدام `Cubit` من حزمة `flutter_bloc` لسهولة قراءة تدفق البيانات، وإمكانية فصل الحسابات المعقدة كلياً عن شجرة الـ Widgets.
   * **حل معضلة الـ Per-lesson state**: تم تقسيم الـ Cubits بحسب نطاق كل شاشة (`CourseDetailsCubit` لحساب قائمة وحالة دروس المقرر مرة واحدة وقت الـ emit، و `LessonPlayerCubit` للتحكم في موضع وتشغيل الدرس الفردي)، مع اعتماد `ProgressRepository` كمصدر وحيد للحقيقة (Single Source of Truth).

2. **التخزين المحلي (Local Persistence - Hive)**:
   * تم اختيار `Hive` بدلاً من `SharedPreferences` أو `sqflite` لكونه NoSQL Key-Value Store سريع جداً (Pure Dart)، ولا يحتاج Native bindings معقدة، ومناسب تماماً لتخزين كائنات `LessonProgress` المهيكلة JSON لكل `lessonId` بدون Overhead.

3. **التوجيه والتنقل (Routing - GoRouter)**:
   * تم استخدام `go_router` لإدارة المسارات عبر مسارات واضحة وقابلة للتمرير بالمعرفات: `/`, `/course/:id`, `/lesson/:id`.

4. **تصميم عربي أصيل (Arabic-First & RTL)**:
   * استخدام `Locale('ar')` افتراضياً، وتطبيق `EdgeInsetsDirectional`، ومحاذاة أشرطة التقدم والأيقونات لتناسب القراءة الطبيعية من اليمين لليسار.

---

## 🚀 كيفية تشغيل التطبيق (How to Run)

### المتطلبات:
* Flutter SDK (3.13+ أو أحدث).
* أي محاكي (Android / iOS) أو جهاز متصل أو Windows Desktop.

### الخطوات:
```bash
# 1. تثبيت الحزم والمكتبات
flutter pub get

# 2. تشغيل الاختبارات للتأكد من سلامة منطق التقدم
flutter test

# 3. تشغيل التطبيق
flutter run
```

---

## ⏱️ الوقت المستغرق (Time Spent)
* **الوقت الإجمالي**: حوالي **4 ساعات و 30 دقيقة** توزعت بين:
  * إعداد البيانات والـ Models و الـ Assets: ~45 دقيقة.
  * الـ Domain Logic واختبارات الـ Unit Tests: ~45 دقيقة.
  * الـ Cubits وتكامل الـ Hive: ~45 دقيقة.
  * تصميم الشاشات وتجربة المشاهدة و الـ RTL: ~1.5 ساعة.
  * التلميع والوضع الليلي والـ README: ~45 دقيقة.

---

## ⚖️ المفاضلات والتطويرات المستقبلية (Trade-offs & Future Work)

### المفاضلات (Trade-offs):
* **Custom Video Controls**: تم بناء واجهة تحكم مخصصة كاملة للمشغل تضمن اتجاهات RTL مثالية للـ Slider بدلاً من الاعتماد الكلي على القوالب الجاهزة.
* **Mocked JSON Data**: تم الاكتفاء بملف JSON داخلي يحتوي على فيديوهات حقيقية خفيفة (<10MB) لضمان العمل Offline بنسبة 100% دون الحاجة لأي Backend.

### ما يمكن إضافته مع مزيد من الوقت (With More Time):
* 📝 **ملاحظات الدروس (Lesson Notes)**: إتاحة كتابة ملاحظات دراسية خاصة بكل درس وحفظها محلياً في Hive.
* 🌐 **التبديل بين العربية والإنجليزية**: دعم تبديل لغة الواجهة ديناميكياً مع ملفات ARB.
* 📊 **لوحة إحصائيات الطالب (Learning Analytics)**: رسوم بيانية لإجمالي الساعات المنجزة والشهادات الطبية بعد إكمال المقرر بنسبة 100%.
* 🔔 **التذكير بالدراسة (Local Notifications)**: إرسال تنبيهات لتشجيع الطالب على استكمال الدروس غير المكتملة.

---
**فريق التطوير**: تم التنفيذ بعناية فائقة وفق معايير الكود النظيف وجودة تجربة المستخدم. 🌟
