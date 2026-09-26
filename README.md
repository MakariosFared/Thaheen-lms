# Thaheen LMS — Mini Offline Learning App

A lightweight, offline-first mobile learning application tailored for health-sciences and medical students in Arabic. Built as part of the Thaheen Flutter screening task.

---

## 🛠️ Getting Started & How to Run

### Prerequisites
- **Flutter SDK**: `^3.13.0` or newer (Tested on Flutter 3.27+ / Dart 3.6+)
- **Target Platforms**: Android, iOS, Windows, macOS, or Web

### Run Instructions
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit & widget tests
flutter test

# 3. Launch the app on your connected device / emulator
flutter run
```

> **Note on Assets**: All courses data (`assets/data/courses.json`) and sample lesson videos (`assets/videos/*.mp4`) are bundled directly into the app. No network connection, emulator setup, or backend APIs are required.

---

## 🏛️ Architecture & State Management Choices

### 1. Architectural Pattern (Layered Clean Architecture)
I organized the codebase into four clean, decoupled layers to keep business logic isolated, testable, and maintainable:

- **`domain/`**: Contains pure Dart business entities (`LessonProgress`, `LessonStatus`) and calculation rules (`ProgressCalculator`). This layer has zero Flutter or framework dependencies, making unit testing straightforward and fast.
- **`data/`**: Implements JSON loading (`CourseRepository`) and offline persistence (`ProgressRepository`).
- **`application/`**: Houses Cubits and UI state models (`CoursesCubit`, `CourseDetailsCubit`, `LessonPlayerCubit`, `ThemeCubit`).
- **`presentation/`**: Screens, custom video player widgets, theme tokens, and `go_router` navigation.

### 2. Why Cubit (`flutter_bloc`)?
- **Predictability & Less Boilerplate**: For this scope, `Cubit` provided the ideal balance between clean state separation and avoiding event boilerplate.
- **Per-Lesson State Strategy**: Rather than having a monolithic app state that triggers unnecessary rebuilds whenever a video position updates, I decoupled the states:
  - `CourseDetailsCubit` pre-computes the sequential unlock status and progress for all lessons once per screen view.
  - `LessonPlayerCubit` manages isolated playback, speed, and real-time position updates for the active lesson only.
  - `ProgressRepository` acts as the single source of truth across all screens.

### 3. Why Hive for Local Storage?
- **Speed & Simplicity**: Hive is a lightweight, pure Dart NoSQL key-value store. It stores structured JSON objects (`LessonProgress` with timestamp, position, duration, and completion status) without the heavy native binding overhead of SQLite or the type-limitation of `SharedPreferences`.
- **Reliable Persistence**: User progress, completed lessons, last playback speed, and theme preferences seamlessly survive app restarts.

---

## 📐 Business Rules & Logic

1. **90% Completion Rule**: A lesson is automatically marked as completed in storage as soon as the playback position reaches `90%` of its total duration (`positionSec / durationSec >= 0.9`).
2. **Sequential Lesson Unlock**: The first lesson of any course is always unlocked. Any subsequent lesson remains locked until the immediately preceding lesson is completed.
3. **Course Progress Calculation**: Dynamically computed as `(completedLessons / totalLessons) * 100`, handling empty courses safely (returning `0.0%`).
4. **Per-Lesson Notes (Bonus Feature)**: A local study notes editor saved in Hive per `lessonId`, with one-tap video timestamp insertion (`[01:15]`) and auto-saving.
5. **Continue Watching**: When returning to the home screen, the app detects the most recent unfinished lesson and displays a quick-resume banner.

---

## 🧪 Testing

The repository includes **16 automated tests** covering both business rules and UI smoke tests:
- **`test/progress_logic_test.dart`**: Tests the 90% completion rule, sequential unlock edge cases, progress % math, and status evaluation.
- **`test/cubits_test.dart`**: Tests state transitions for `CoursesCubit` and `CourseDetailsCubit` using `bloc_test` and `mocktail`.
- **`test/widget_test.dart`**: Tests app startup and widget rendering.

Run all tests:
```bash
flutter test
```

---

## ⚖️ Trade-offs & Known Issues

1. **Custom Video Player UI vs Default Controls**:
   Instead of default player styling, I built custom controls on top of `video_player` to ensure seamless RTL slider interaction, custom 10-second forward/backward skips, integrated speed control, and Arabic-first tooltips.
2. **Local Assets vs Real Streaming**:
   To strictly fulfill the offline requirement without external network dependencies, 3 small royalty-free MP4 files (< 6MB each) are bundled in `assets/videos/`. In a production setup, this would connect to an HLS/DASH streaming server (e.g., Mux / Cloudflare Stream) with offline caching.
3. **Fullscreen Orientation**:
   Landscape orientation is triggered via `SystemChrome.setPreferredOrientations`. On some desktop/web window resizes, the player retains aspect ratio within its frame.

---

## ⏳ What I'd Build With More Time

If I had more time to expand this project further:
- 🌐 **Language Toggle (EN / AR)**: Adding an explicit dynamic language switcher using `intl` / `.arb` localization files.
- 📊 **Study Analytics**: Visual charts showing total hours studied, completion rate trends, and weekly streaks.
- 🔖 **Interactive Quizzes**: Short self-assessment quizzes at the end of each section before unlocking the next milestone.
- 📥 **Offline Download Manager**: Background downloading and storage management for high-res medical videos.

---

## ⏱️ Time Spent

Total time spent: **~5 hours**
- **Architecture, Models & Data Layer**: ~45 mins
- **Domain Logic & Unit Tests**: ~45 mins
- **State Management (Cubits & Hive Integration)**: ~45 mins
- **UI, RTL Layout & Custom Video Player**: ~1.5 hours
- **Theme (Dark Mode), Search & Refinements**: ~45 mins
- **Review, Testing & Documentation**: ~30 mins

---

## 📹 Demo & Screen Recording

> A 2–3 minute video demonstration showing:
> 1. Course browsing & real-time search.
> 2. Light / Dark mode switching.
> 3. Locked lesson dialog interaction.
> 4. Video playback with speed changing (1x to 2x) and 10s seeking.
> 5. 90% auto-completion triggering the green badge and unlocking the "Next Lesson" button.
> 6. App restart demonstrating progress persistence and the "Continue Watching" banner.
