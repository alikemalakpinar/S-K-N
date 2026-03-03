# Sukun

An offline-first Islamic companion app built with SwiftUI, SwiftData, and GRDB.

## Architecture

```
SÜKÛN/
├── App/                          # App entry point + DI container
│   ├── SU_KU_NApp.swift
│   ├── RootView.swift
│   └── DependencyContainer.swift
├── Core/
│   ├── Protocols/
│   └── Extensions/
├── Data/
│   ├── StaticDB/                 # Pre-populated SQLite (GRDB + FTS5)
│   │   ├── StaticDBClient.swift
│   │   └── DTOs/                 # SurahDTO, VerseDTO, DuaDTO
│   ├── UserDB/
│   │   └── Models/               # SwiftData @Model classes
│   └── Repositories/
│       ├── Protocols/            # Repository interfaces
│       └── Implementations/      # Default implementations
├── Services/
│   ├── LocationService.swift
│   ├── PrayerTimeService.swift   # Adhan-swift wrapper + cache
│   ├── NotificationScheduler.swift
│   └── WidgetDataService.swift
├── Features/
│   ├── Dashboard/                # Next prayer countdown + today checklist
│   ├── PrayerTimes/              # Today + 30-day prayer schedule
│   ├── Quran/                    # FTS search + surah browser
│   ├── Duas/                     # FTS search for duas
│   ├── Dhikr/                    # Tap counter with presets
│   ├── Tracker/                  # Reading & dhikr activity log
│   └── Settings/                 # Method, offsets, notifications, theme
└── Resources/
    └── Data/                     # Place sukun_static.sqlite here
```

## Offline-First Design

- **User data**: Stored in SwiftData (Core Data backed). All user preferences, prayer logs, reading progress, and dhikr sessions persist locally with zero network dependency.
- **Static content**: Quran text, duas, and metadata live in a pre-populated SQLite database (`sukun_static.sqlite`) accessed via GRDB in read-only mode with FTS5 full-text search.
- **Prayer times**: Computed locally using [Adhan-swift](https://github.com/batoulapps/adhan-swift) from device coordinates. Results are cached to `PrayerTimesCache.json` in Application Support.
- **Notifications**: Scheduled locally for a rolling 10-day window (50 notifications max, within iOS 64 limit). Rescheduled when settings change.

## Adding the Static SQLite Database

The app expects a pre-populated SQLite database at bundle path `Resources/Data/sukun_static.sqlite` (or simply `sukun_static.sqlite` in the bundle root).

### Required Schema

```sql
CREATE TABLE surahs (
    id INTEGER PRIMARY KEY,
    name_arabic TEXT NOT NULL,
    name_english TEXT NOT NULL,
    name_transliteration TEXT NOT NULL,
    verse_count INTEGER NOT NULL,
    revelation_type TEXT NOT NULL  -- 'Meccan' or 'Medinan'
);

CREATE TABLE verses (
    surah_id INTEGER NOT NULL,
    verse_number INTEGER NOT NULL,
    text_arabic TEXT NOT NULL,
    text_translation TEXT NOT NULL,
    text_transliteration TEXT NOT NULL,
    PRIMARY KEY (surah_id, verse_number)
);

CREATE TABLE duas (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    text_arabic TEXT NOT NULL,
    text_translation TEXT NOT NULL,
    text_transliteration TEXT NOT NULL,
    category TEXT NOT NULL,
    source TEXT NOT NULL
);

-- FTS5 virtual tables for search
CREATE VIRTUAL TABLE verses_fts USING fts5(
    text_translation, text_transliteration,
    content='verses', content_rowid='rowid'
);

CREATE VIRTUAL TABLE duas_fts USING fts5(
    title, text_translation, text_transliteration,
    content='duas', content_rowid='rowid'
);
```

### Steps

1. Create and populate the SQLite database using the schema above
2. Place the file at `SÜKÛN/Resources/Data/sukun_static.sqlite`
3. Xcode will automatically include it in the bundle (PBXFileSystemSynchronizedRootGroup)

If the database is missing at runtime, the app will show a clear error state in the Quran and Duas tabs instead of crashing.

## Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| [GRDB.swift](https://github.com/groue/GRDB.swift) | Read-only access to static SQLite + FTS5 search | 7.0+ |
| [Adhan-swift](https://github.com/batoulapps/adhan-swift) | Local prayer time calculation | 1.0+ |

Both are added via Swift Package Manager in the Xcode project.

## SwiftData Models

| Model | Purpose |
|-------|---------|
| `UserSetting` | Calculation method, Asr juristic, offsets, theme, notification prefs |
| `PrayerLog` | Daily prayer completion status |
| `ReadingLog` | Quran reading sessions (surah, verse range, duration) |
| `CounterPreset` | Dhikr counter presets (title, target, haptic) |
| `CounterSession` | Completed dhikr sessions |
| `FavoriteItem` | Favorited verses, surahs, or duas |
| `Bookmark` | Bookmarks with optional notes |

## Requirements

- iOS 17+ / macOS 14+
- Swift 5.9+
- Xcode 15+
