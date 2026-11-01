# College Companion — Native Android Timetable, Attendance & Academic Calendar

**College Companion** is a complete, 100% offline-first, native Android application built with **Kotlin**, **Jetpack Compose (Material 3)**, **Jetpack Glance Home-Screen Widgets**, **Room Database**, **DataStore Preferences**, **AlarmManager**, and **WorkManager**.

---

## Key Features Implemented

### 1. Native Android Home-Screen Widgets (Jetpack Glance) & Direct Attendance Controls
- **Widget A (`TodayTimetableWidget`)**: Google Calendar-inspired schedule widget featuring a prominent Date/Weekday badge, a top **`COMPLETE ABSENT`** button, rounded blue/subject-accented lecture cards displaying subject, time, room/lab/building/floor, professor, and two genuine interactive buttons (**`✓ ATTENDED`** and **`✕ ABSENT`**) on every lecture card, plus a bottom current attendance bar.
- **Widget B (`AttendanceOverviewWidget`)**: Displays overall current attendance percentage, attended/absent/pending counts, safe absences, recovery lecture alerts, red alert styling when below threshold, and per-subject attendance rows.
- **Widget C (`CombinedCompanionWidget`)**: Combines today's interactive lecture schedule with a dual bottom footer clearly separating **Current (Actual) Attendance** and **Projected Attendance** alongside **Safe Absences**.
- **Complete-Day Absence Confirmation & Transactional Undo (`CompleteDayAbsentActivity`)**: Tapping **`COMPLETE ABSENT`** on the widget opens a native confirmation dialog listing all affected lectures for that date, warning explicitly if any previously `ATTENDED` lectures will be overwritten, executing the change in a single Room `@Transaction`, and providing one-tap **Undo** support.

### 2. Accurate Attendance Engine & Projected Attendance Simulator
- **Current Attendance**: Calculated strictly from `semesterStartDate` up to `currentLocalDate` using `Attended / (Attended + Absent) * 100`. Excludes future lectures, unmarked (`PENDING`) lectures, cancelled lectures, and holidays.
- **Overall Attendance**: Calculated as `Total Attended across all subjects / Total Finalized across all subjects * 100` (never a simple average of subject percentages).
- **Safe Absences**: `max(0, floor(A / r - T))` using `BigDecimal` precision.
- **Recovery Lectures**: Smallest non-negative integer `x` satisfying `(A + x) / (T + x) >= r`.
- **Attendance Warning Colours**:
  - **Green (`COMFORTABLE`)**: `>= 75%` (configurable)
  - **Yellow/Amber (`WARNING`)**: `70% .. <75%` (Attendance at exactly `70.0%` is Amber, never Red)
  - **Red (`CRITICAL`)**: Strictly below required threshold (`< 70%`)
- **Projected Attendance Simulator**: Separate from Current Attendance. Supports all 7 required scenarios:
  1. Attend all upcoming lectures
  2. Miss the next 1 lecture
  3. Miss the next 2 lectures
  4. Miss the next 3 lectures
  5. Miss a custom number of upcoming lectures
  6. Select specific future lectures to attend or miss
  7. Attend a selected number of future lectures and miss the remaining ones

### 3. Date-Based Timetable Mapping, Academic Calendar & External AI Schedule Generator
- Maps recurring weekday slots onto concrete dates across the semester (`[semesterStartDate, semesterEndDate]`), automatically excluding holidays, vacations, and examination periods, while honoring **Special Working Saturdays** and **Timetable Override Days** (e.g., Saturday following Monday's schedule) and **Rotating Schedules** (`EVERY_WEEK`, `ODD_WEEKS`, `EVEN_WEEKS`, `ROTATION_SET_A`, `ROTATION_SET_B`).
- Detects overlapping slots and concrete lecture conflicts.
- **Independent Import Options**: Import Timetable Only, Import Academic Calendar Only, Import Combined Schedule, or Full Backup/Restore using JSON or CSV via Android Storage Access Framework (SAF).
- **"Generate My Academic Schedule" (`COPY AI PROMPT`)**: Copies a complete, schema-documented AI prompt to the clipboard so any external AI assistant can convert a syllabus/calendar into a validated JSON file.

### 4. Multi-Interval Lecture Notifications (`AlarmManager`)
- Supports simultaneous selection of multiple reminder intervals (`5, 10, 15, 20, 30, 45, 60` minutes before each lecture).
- Handles Android 13+ `POST_NOTIFICATIONS` and Android 12+ `SCHEDULE_EXACT_ALARM` permissions gracefully (with automatic fallback to `setAndAllowWhileIdle` if exact alarms are denied).
- Automatically reschedules after device reboot (`BOOT_COMPLETED`), timezone/time changes, and midnight date rollovers.

---

## Repository Structure

```text
CollegeCompanion/
├── .github/workflows/android-ci.yml         # GitHub Actions CI workflow (Unit tests + Debug/Release APK artifacts)
├── app/
│   ├── build.gradle.kts                     # App module Gradle Kotlin DSL configuration
│   ├── proguard-rules.pro                   # R8 / ProGuard rules for Serialization, Room & Glance
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml          # App, Glance Widget Receivers, Alarm/Boot Receivers (No Internet permission)
│       │   ├── java/com/collegecompanion/
│       │   │   ├── CollegeCompanionApplication.kt
│       │   │   ├── MainActivity.kt          # 5-tab Material 3 Navigation host
│       │   │   ├── data/
│       │   │   │   ├── SampleInitialDataSeeder.kt
│       │   │   │   ├── local/
│       │   │   │   │   ├── CollegeCompanionDatabase.kt  # Room DB + MIGRATION_1_2
│       │   │   │   │   ├── RoomConverters.kt
│       │   │   │   │   ├── dao/CollegeDaos.kt
│       │   │   │   │   └── entity/Entities.kt
│       │   │   │   ├── preferences/PreferencesDataStore.kt
│       │   │   │   └── repository/CollegeRepository.kt
│       │   │   ├── domain/
│       │   │   │   ├── engine/
│       │   │   │   │   ├── AiPromptBuilder.kt
│       │   │   │   │   ├── AttendanceEngine.kt
│       │   │   │   │   ├── ProjectedAttendanceEngine.kt
│       │   │   │   │   ├── ScheduleImportExportEngine.kt
│       │   │   │   │   └── TimetableGenerator.kt
│       │   │   │   └── model/DomainModels.kt
│       │   │   ├── notification/
│       │   │   │   ├── BootAndTimeChangeReceiver.kt
│       │   │   │   ├── LectureReminderReceiver.kt
│       │   │   │   └── LectureReminderScheduler.kt
│       │   │   ├── ui/
│       │   │   │   ├── screens/
│       │   │   │   │   ├── AttendanceScreen.kt
│       │   │   │   │   ├── CalendarScreen.kt
│       │   │   │   │   ├── GenerateAiScheduleScreen.kt
│       │   │   │   │   ├── HomeScreen.kt
│       │   │   │   │   ├── ImportScheduleScreen.kt
│       │   │   │   │   ├── SettingsScreen.kt
│       │   │   │   │   └── TimetableScreen.kt
│       │   │   │   ├── theme/{Color.kt, Theme.kt, Type.kt}
│       │   │   │   └── viewmodel/MainViewModel.kt
│       │   │   ├── widget/
│       │   │   │   ├── AttendanceOverviewWidget.kt      # Widget B
│       │   │   │   ├── CombinedCompanionWidget.kt       # Widget C
│       │   │   │   ├── CompleteDayAbsentActivity.kt     # Bulk absent confirmation dialog + Undo
│       │   │   │   ├── MarkLectureAttendanceActionCallback.kt
│       │   │   │   ├── TodayTimetableWidget.kt          # Widget A
│       │   │   │   ├── WidgetDataSnapshot.kt
│       │   │   │   └── WidgetRefreshManager.kt
│       │   │   └── worker/DailyWidgetRefreshWorker.kt
│       │   └── res/
│       │       ├── drawable/ic_launcher_foreground.xml
│       │       ├── layout/glance_default_loading_layout.xml
│       │       ├── values/{strings.xml, themes.xml}
│       │       └── xml/{widget_today_timetable.xml, widget_attendance_overview.xml, widget_combined.xml}
│       ├── test/java/com/collegecompanion/              # JUnit 4 Unit Tests
│       └── androidTest/java/com/collegecompanion/       # Instrumented Room & Bulk Action Tests
├── docs/JSON_IMPORT_SCHEMA.md
├── examples/
│   ├── sample_academic_schedule.json
│   └── sample_timetable.csv
├── gradle/libs.versions.toml
├── build.gradle.kts
├── settings.gradle.kts
└── gradle.properties
```

---

## Building APKs via GitHub Actions or Local Android Studio

### Option A: Automated Build via GitHub Actions (Recommended)
1. Push this repository to your private GitHub repository:
   ```bash
   git remote add origin https://github.com/<your-username>/<your-private-repo>.git
   git branch -M main
   git push -u origin main
   ```
2. Open your GitHub repository -> **Actions** tab -> **Android CI & APK Build**.
3. Once the workflow completes, download:
   - **`CollegeCompanion-Debug-APK`** (`app-debug.apk`)
   - **`CollegeCompanion-Release-APK`** (`app-release.apk`)

### Option B: Configuring Your Own Release Signing Key (Optional)
By default, if no custom release keystore is supplied, `app/build.gradle.kts` signs the release build with the standard debug key so `app-release.apk` is immediately installable on your phone. To sign with your own personal release key without ever committing secrets to Git:
1. Generate a keystore locally:
   ```bash
   keytool -genkey -v -keystore release.keystore -alias college_companion -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Base64-encode the keystore and add the following **GitHub Repository Secrets** (`Settings -> Secrets and variables -> Actions`):
   - `RELEASE_KEYSTORE_BASE64`: Output of `base64 -w 0 release.keystore`
   - `KEYSTORE_PASSWORD`: Your keystore password
   - `KEY_ALIAS`: `college_companion`
   - `KEY_PASSWORD`: Your key password

---

## Installing the APK on Your Android Phone

1. Transfer the downloaded `app-debug.apk` or `app-release.apk` to your Android phone.
2. Tap the APK file in your phone's **Files** app.
3. If prompted, enable **Install unknown apps** for your file manager or browser.
4. Tap **Install** and then **Open**.
5. In **Settings -> Lecture Reminders**, tap **Grant Notification Permission** and **Allow Exact Alarms** so multi-interval reminders trigger at the exact minute.

---

## Adding the Native Home-Screen Widgets

1. Long-press an empty space on your Android home screen and select **Widgets**.
2. Scroll to **College Companion** to see all three native Glance widgets:
   - **College Companion: Today's Timetable** (Widget A)
   - **College Companion: Attendance Overview** (Widget B)
   - **College Companion: Timetable & Attendance** (Widget C)
3. Drag your preferred widget(s) onto your home screen and resize them freely using the drag handles.
4. Tap **`✓ ATTENDED`** or **`✕ ABSENT`** directly on any lecture card in the widget to record attendance immediately, or tap **`COMPLETE ABSENT`** next to the date to open the confirmation dialog for marking the entire day absent.
