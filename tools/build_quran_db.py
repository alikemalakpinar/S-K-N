#!/usr/bin/env python3
"""
Build SÜKÛN static Quran database from Al Quran Cloud API.
Downloads Uthmani Arabic text + Turkish Diyanet translation + page mapping,
and builds SQLite + FTS5.

Usage: python3 tools/build_quran_db.py
Output: SÜKÛN/Resources/Data/sukun_static.sqlite
"""

import sqlite3
import urllib.request
import os
import json

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
DB_PATH = os.path.join(PROJECT_ROOT, "SÜKÛN", "Resources", "Data", "sukun_static.sqlite")
CACHE_DIR = os.path.join(SCRIPT_DIR, ".cache")

# Al Quran Cloud API endpoints
UTHMANI_API_URL = "https://api.alquran.cloud/v1/quran/quran-uthmani"
DIYANET_API_URL = "https://api.alquran.cloud/v1/quran/tr.diyanet"

# Surah metadata: (id, arabic, english, transliteration, turkish, verse_count, revelation_type)
SURAH_META = [
    (1, "الفاتحة", "Al-Fatiha", "El-Fâtiha", "Fâtiha", 7, "Meccan"),
    (2, "البقرة", "Al-Baqarah", "El-Bakara", "Bakara", 286, "Medinan"),
    (3, "آل عمران", "Ali 'Imran", "Âl-i İmrân", "Âl-i İmrân", 200, "Medinan"),
    (4, "النساء", "An-Nisa", "En-Nisâ", "Nisâ", 176, "Medinan"),
    (5, "المائدة", "Al-Ma'idah", "El-Mâide", "Mâide", 120, "Medinan"),
    (6, "الأنعام", "Al-An'am", "El-En'âm", "En'âm", 165, "Meccan"),
    (7, "الأعراف", "Al-A'raf", "El-A'râf", "A'râf", 206, "Meccan"),
    (8, "الأنفال", "Al-Anfal", "El-Enfâl", "Enfâl", 75, "Medinan"),
    (9, "التوبة", "At-Tawbah", "Et-Tevbe", "Tevbe", 129, "Medinan"),
    (10, "يونس", "Yunus", "Yûnus", "Yûnus", 109, "Meccan"),
    (11, "هود", "Hud", "Hûd", "Hûd", 123, "Meccan"),
    (12, "يوسف", "Yusuf", "Yûsuf", "Yûsuf", 111, "Meccan"),
    (13, "الرعد", "Ar-Ra'd", "Er-Ra'd", "Ra'd", 43, "Medinan"),
    (14, "إبراهيم", "Ibrahim", "İbrâhîm", "İbrâhîm", 52, "Meccan"),
    (15, "الحجر", "Al-Hijr", "El-Hicr", "Hicr", 99, "Meccan"),
    (16, "النحل", "An-Nahl", "En-Nahl", "Nahl", 128, "Meccan"),
    (17, "الإسراء", "Al-Isra", "El-İsrâ", "İsrâ", 111, "Meccan"),
    (18, "الكهف", "Al-Kahf", "El-Kehf", "Kehf", 110, "Meccan"),
    (19, "مريم", "Maryam", "Meryem", "Meryem", 98, "Meccan"),
    (20, "طه", "Ta-Ha", "Tâ-Hâ", "Tâ-Hâ", 135, "Meccan"),
    (21, "الأنبياء", "Al-Anbiya", "El-Enbiyâ", "Enbiyâ", 112, "Meccan"),
    (22, "الحج", "Al-Hajj", "El-Hac", "Hac", 78, "Medinan"),
    (23, "المؤمنون", "Al-Mu'minun", "El-Mü'minûn", "Mü'minûn", 118, "Meccan"),
    (24, "النور", "An-Nur", "En-Nûr", "Nûr", 64, "Medinan"),
    (25, "الفرقان", "Al-Furqan", "El-Furkân", "Furkân", 77, "Meccan"),
    (26, "الشعراء", "Ash-Shu'ara", "Eş-Şuarâ", "Şuarâ", 227, "Meccan"),
    (27, "النمل", "An-Naml", "En-Neml", "Neml", 93, "Meccan"),
    (28, "القصص", "Al-Qasas", "El-Kasas", "Kasas", 88, "Meccan"),
    (29, "العنكبوت", "Al-Ankabut", "El-Ankebût", "Ankebût", 69, "Meccan"),
    (30, "الروم", "Ar-Rum", "Er-Rûm", "Rûm", 60, "Meccan"),
    (31, "لقمان", "Luqman", "Lokmân", "Lokmân", 34, "Meccan"),
    (32, "السجدة", "As-Sajdah", "Es-Secde", "Secde", 30, "Meccan"),
    (33, "الأحزاب", "Al-Ahzab", "El-Ahzâb", "Ahzâb", 73, "Medinan"),
    (34, "سبأ", "Saba", "Sebe'", "Sebe'", 54, "Meccan"),
    (35, "فاطر", "Fatir", "Fâtır", "Fâtır", 45, "Meccan"),
    (36, "يس", "Ya-Sin", "Yâsîn", "Yâsîn", 83, "Meccan"),
    (37, "الصافات", "As-Saffat", "Es-Sâffât", "Sâffât", 182, "Meccan"),
    (38, "ص", "Sad", "Sâd", "Sâd", 88, "Meccan"),
    (39, "الزمر", "Az-Zumar", "Ez-Zümer", "Zümer", 75, "Meccan"),
    (40, "غافر", "Ghafir", "Mü'min (Gâfir)", "Mü'min", 85, "Meccan"),
    (41, "فصلت", "Fussilat", "Fussilet", "Fussilet", 54, "Meccan"),
    (42, "الشورى", "Ash-Shura", "Eş-Şûrâ", "Şûrâ", 53, "Meccan"),
    (43, "الزخرف", "Az-Zukhruf", "Ez-Zuhruf", "Zuhruf", 89, "Meccan"),
    (44, "الدخان", "Ad-Dukhan", "Ed-Duhân", "Duhân", 59, "Meccan"),
    (45, "الجاثية", "Al-Jathiyah", "El-Câsiye", "Câsiye", 37, "Meccan"),
    (46, "الأحقاف", "Al-Ahqaf", "El-Ahkâf", "Ahkâf", 35, "Meccan"),
    (47, "محمد", "Muhammad", "Muhammed", "Muhammed", 38, "Medinan"),
    (48, "الفتح", "Al-Fath", "El-Fetih", "Fetih", 29, "Medinan"),
    (49, "الحجرات", "Al-Hujurat", "El-Hucurât", "Hucurât", 18, "Medinan"),
    (50, "ق", "Qaf", "Kâf", "Kâf", 45, "Meccan"),
    (51, "الذاريات", "Adh-Dhariyat", "Ez-Zâriyât", "Zâriyât", 60, "Meccan"),
    (52, "الطور", "At-Tur", "Et-Tûr", "Tûr", 49, "Meccan"),
    (53, "النجم", "An-Najm", "En-Necm", "Necm", 62, "Meccan"),
    (54, "القمر", "Al-Qamar", "El-Kamer", "Kamer", 55, "Meccan"),
    (55, "الرحمن", "Ar-Rahman", "Er-Rahmân", "Rahmân", 78, "Medinan"),
    (56, "الواقعة", "Al-Waqi'ah", "El-Vâkıa", "Vâkıa", 96, "Meccan"),
    (57, "الحديد", "Al-Hadid", "El-Hadîd", "Hadîd", 29, "Medinan"),
    (58, "المجادلة", "Al-Mujadilah", "El-Mücâdele", "Mücâdele", 22, "Medinan"),
    (59, "الحشر", "Al-Hashr", "El-Haşr", "Haşr", 24, "Medinan"),
    (60, "الممتحنة", "Al-Mumtahanah", "El-Mümtehine", "Mümtehine", 13, "Medinan"),
    (61, "الصف", "As-Saff", "Es-Saf", "Saf", 14, "Medinan"),
    (62, "الجمعة", "Al-Jumu'ah", "El-Cum'a", "Cum'a", 11, "Medinan"),
    (63, "المنافقون", "Al-Munafiqun", "El-Münâfikûn", "Münâfikûn", 11, "Medinan"),
    (64, "التغابن", "At-Taghabun", "Et-Teğâbün", "Teğâbün", 18, "Medinan"),
    (65, "الطلاق", "At-Talaq", "Et-Talâk", "Talâk", 12, "Medinan"),
    (66, "التحريم", "At-Tahrim", "Et-Tahrîm", "Tahrîm", 12, "Medinan"),
    (67, "الملك", "Al-Mulk", "El-Mülk", "Mülk", 30, "Meccan"),
    (68, "القلم", "Al-Qalam", "El-Kalem", "Kalem", 52, "Meccan"),
    (69, "الحاقة", "Al-Haqqah", "El-Hâkka", "Hâkka", 52, "Meccan"),
    (70, "المعارج", "Al-Ma'arij", "El-Meâric", "Meâric", 44, "Meccan"),
    (71, "نوح", "Nuh", "Nûh", "Nûh", 28, "Meccan"),
    (72, "الجن", "Al-Jinn", "El-Cin", "Cin", 28, "Meccan"),
    (73, "المزمل", "Al-Muzzammil", "El-Müzzemmil", "Müzzemmil", 20, "Meccan"),
    (74, "المدثر", "Al-Muddaththir", "El-Müddessir", "Müddessir", 56, "Meccan"),
    (75, "القيامة", "Al-Qiyamah", "El-Kıyâme", "Kıyâme", 40, "Meccan"),
    (76, "الإنسان", "Al-Insan", "El-İnsân", "İnsân", 31, "Medinan"),
    (77, "المرسلات", "Al-Mursalat", "El-Mürselât", "Mürselât", 50, "Meccan"),
    (78, "النبأ", "An-Naba", "En-Nebe'", "Nebe'", 40, "Meccan"),
    (79, "النازعات", "An-Nazi'at", "En-Nâziât", "Nâziât", 46, "Meccan"),
    (80, "عبس", "Abasa", "Abese", "Abese", 42, "Meccan"),
    (81, "التكوير", "At-Takwir", "Et-Tekvîr", "Tekvîr", 29, "Meccan"),
    (82, "الانفطار", "Al-Infitar", "El-İnfitâr", "İnfitâr", 19, "Meccan"),
    (83, "المطففين", "Al-Mutaffifin", "El-Mutaffifîn", "Mutaffifîn", 36, "Meccan"),
    (84, "الانشقاق", "Al-Inshiqaq", "El-İnşikâk", "İnşikâk", 25, "Meccan"),
    (85, "البروج", "Al-Buruj", "El-Burûc", "Burûc", 22, "Meccan"),
    (86, "الطارق", "At-Tariq", "Et-Târık", "Târık", 17, "Meccan"),
    (87, "الأعلى", "Al-A'la", "El-A'lâ", "A'lâ", 19, "Meccan"),
    (88, "الغاشية", "Al-Ghashiyah", "El-Gâşiye", "Gâşiye", 26, "Meccan"),
    (89, "الفجر", "Al-Fajr", "El-Fecr", "Fecr", 30, "Meccan"),
    (90, "البلد", "Al-Balad", "El-Beled", "Beled", 20, "Meccan"),
    (91, "الشمس", "Ash-Shams", "Eş-Şems", "Şems", 15, "Meccan"),
    (92, "الليل", "Al-Layl", "El-Leyl", "Leyl", 21, "Meccan"),
    (93, "الضحى", "Ad-Duha", "Ed-Duhâ", "Duhâ", 11, "Meccan"),
    (94, "الشرح", "Ash-Sharh", "Eş-Şerh (İnşirâh)", "İnşirâh", 8, "Meccan"),
    (95, "التين", "At-Tin", "Et-Tîn", "Tîn", 8, "Meccan"),
    (96, "العلق", "Al-Alaq", "El-Alak", "Alak", 19, "Meccan"),
    (97, "القدر", "Al-Qadr", "El-Kadr", "Kadr", 5, "Meccan"),
    (98, "البينة", "Al-Bayyinah", "El-Beyyine", "Beyyine", 8, "Medinan"),
    (99, "الزلزلة", "Az-Zalzalah", "Ez-Zilzâl", "Zilzâl", 8, "Medinan"),
    (100, "العاديات", "Al-Adiyat", "El-Âdiyât", "Âdiyât", 11, "Meccan"),
    (101, "القارعة", "Al-Qari'ah", "El-Kâria", "Kâria", 11, "Meccan"),
    (102, "التكاثر", "At-Takathur", "Et-Tekâsür", "Tekâsür", 8, "Meccan"),
    (103, "العصر", "Al-Asr", "El-Asr", "Asr", 3, "Meccan"),
    (104, "الهمزة", "Al-Humazah", "El-Hümeze", "Hümeze", 9, "Meccan"),
    (105, "الفيل", "Al-Fil", "El-Fîl", "Fîl", 5, "Meccan"),
    (106, "قريش", "Quraysh", "Kureyş", "Kureyş", 4, "Meccan"),
    (107, "الماعون", "Al-Ma'un", "El-Mâûn", "Mâûn", 7, "Meccan"),
    (108, "الكوثر", "Al-Kawthar", "El-Kevser", "Kevser", 3, "Meccan"),
    (109, "الكافرون", "Al-Kafirun", "El-Kâfirûn", "Kâfirûn", 6, "Meccan"),
    (110, "النصر", "An-Nasr", "En-Nasr", "Nasr", 3, "Medinan"),
    (111, "المسد", "Al-Masad", "El-Mesed (Tebbet)", "Tebbet", 5, "Meccan"),
    (112, "الإخلاص", "Al-Ikhlas", "El-İhlâs", "İhlâs", 4, "Meccan"),
    (113, "الفلق", "Al-Falaq", "El-Felak", "Felak", 5, "Meccan"),
    (114, "الناس", "An-Nas", "En-Nâs", "Nâs", 6, "Meccan"),
]


def download_file(url, filename):
    """Download file with caching."""
    os.makedirs(CACHE_DIR, exist_ok=True)
    path = os.path.join(CACHE_DIR, filename)
    if os.path.exists(path):
        print(f"  Using cached: {filename}")
        return path
    print(f"  Downloading: {filename}...")
    req = urllib.request.Request(url, headers={"User-Agent": "SUKUN-Builder/1.0"})
    with urllib.request.urlopen(req) as response:
        data = response.read()
    with open(path, "wb") as f:
        f.write(data)
    print(f"  Downloaded: {len(data)} bytes")
    return path


def parse_alquran_json(path):
    """Parse Al Quran Cloud API JSON.
    Returns: dict (surah, ayah) -> text, dict (surah, ayah) -> page (if available)"""
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    verses = {}
    pages = {}
    for surah in data["data"]["surahs"]:
        surah_id = surah["number"]
        for ayah in surah["ayahs"]:
            ayah_num = ayah["numberInSurah"]
            verses[(surah_id, ayah_num)] = ayah["text"]
            if "page" in ayah:
                pages[(surah_id, ayah_num)] = ayah["page"]
    return verses, pages


def build_database():
    print("=== SÜKÛN Static DB Builder ===\n")

    # 1. Download sources
    print("Step 1: Downloading sources...")
    arabic_path = download_file(UTHMANI_API_URL, "quran-uthmani.json")
    turkish_path = download_file(DIYANET_API_URL, "tr.diyanet.json")

    # 2. Parse data
    print("\nStep 2: Parsing data...")
    arabic_verses, verse_pages = parse_alquran_json(arabic_path)
    turkish_verses, _ = parse_alquran_json(turkish_path)
    print(f"  Arabic verses: {len(arabic_verses)}")
    print(f"  Turkish verses: {len(turkish_verses)}")
    print(f"  Page mapping entries: {len(verse_pages)}")
    if verse_pages:
        print(f"  Page range: {min(verse_pages.values())} - {max(verse_pages.values())}")

    # 3. Build database
    print(f"\nStep 3: Building SQLite database...")
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    # Create tables
    cur.executescript("""
        CREATE TABLE surahs (
            id INTEGER PRIMARY KEY,
            name_arabic TEXT NOT NULL,
            name_english TEXT NOT NULL,
            name_transliteration TEXT NOT NULL,
            name_turkish TEXT NOT NULL DEFAULT '',
            verse_count INTEGER NOT NULL,
            revelation_type TEXT NOT NULL
        );

        CREATE TABLE verses (
            rowid INTEGER PRIMARY KEY AUTOINCREMENT,
            surah_id INTEGER NOT NULL,
            verse_number INTEGER NOT NULL,
            text_arabic TEXT NOT NULL,
            text_translation TEXT NOT NULL DEFAULT '',
            text_transliteration TEXT NOT NULL DEFAULT '',
            text_tefsir TEXT NOT NULL DEFAULT '',
            page_number INTEGER NOT NULL DEFAULT 0,
            UNIQUE(surah_id, verse_number)
        );

        CREATE TABLE duas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            text_arabic TEXT NOT NULL,
            text_translation TEXT NOT NULL DEFAULT '',
            text_transliteration TEXT NOT NULL DEFAULT '',
            category TEXT NOT NULL DEFAULT '',
            source TEXT NOT NULL DEFAULT ''
        );
    """)

    # Insert surahs
    print("  Inserting 114 surahs...")
    for meta in SURAH_META:
        cur.execute(
            "INSERT INTO surahs VALUES (?,?,?,?,?,?,?)",
            (meta[0], meta[1], meta[2], meta[3], meta[4], meta[5], meta[6])
        )

    # Insert verses
    print("  Inserting verses...")
    verse_count = 0
    for meta in SURAH_META:
        surah_id = meta[0]
        count = meta[5]
        for ayah in range(1, count + 1):
            arabic = arabic_verses.get((surah_id, ayah), "")
            turkish = turkish_verses.get((surah_id, ayah), "")
            page = verse_pages.get((surah_id, ayah), 0)
            cur.execute(
                "INSERT INTO verses (surah_id, verse_number, text_arabic, text_translation, text_transliteration, text_tefsir, page_number) VALUES (?,?,?,?,?,?,?)",
                (surah_id, ayah, arabic, turkish, "", "", page)
            )
            verse_count += 1

    print(f"  Inserted {verse_count} verses")

    # Insert sample duas
    print("  Inserting duas...")
    duas_data = [
        ("Sabah Duası", "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ", "Sabaha erdik, mülk de Allah'ın olarak sabaha erdi.", "Asbahnâ ve asbahal-mülkü lillâh.", "Sabah-Akşam", "Müslim"),
        ("Akşam Duası", "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ", "Akşama erdik, mülk de Allah'ın olarak akşama erdi.", "Emseynâ ve emsel-mülkü lillâh.", "Sabah-Akşam", "Müslim"),
        ("Yemek Duası", "بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ", "Allah'ın adıyla ve Allah'ın bereketiyle.", "Bismillâhi ve alâ bereketillâh.", "Yemek", "Ebu Davud"),
        ("Yolculuk Duası", "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ", "Bunu bizim hizmetimize veren Allah'ı tenzih ederiz.", "Sübhânellezî sahhara lenâ hâzâ ve mâ künnâ lehû mukrinîn.", "Yolculuk", "Müslim"),
        ("İstiğfar", "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ", "Yüce Allah'tan mağfiret dilerim.", "Estağfirullâhel-azîm.", "Tövbe", "Tirmizî"),
    ]
    for d in duas_data:
        cur.execute("INSERT INTO duas (title, text_arabic, text_translation, text_transliteration, category, source) VALUES (?,?,?,?,?,?)", d)

    # Build FTS5 indexes
    print("  Building FTS5 indexes...")
    cur.executescript("""
        CREATE VIRTUAL TABLE verses_fts USING fts5(
            text_arabic,
            text_translation,
            text_transliteration,
            content=verses,
            content_rowid=rowid
        );

        INSERT INTO verses_fts (rowid, text_arabic, text_translation, text_transliteration)
            SELECT rowid, text_arabic, text_translation, text_transliteration FROM verses;

        CREATE VIRTUAL TABLE duas_fts USING fts5(
            title,
            text_arabic,
            text_translation,
            text_transliteration,
            content=duas,
            content_rowid=id
        );

        INSERT INTO duas_fts (rowid, title, text_arabic, text_translation, text_transliteration)
            SELECT id, title, text_arabic, text_translation, text_transliteration FROM duas;
    """)

    conn.commit()

    # Verify
    cur.execute("SELECT count(*) FROM surahs")
    s = cur.fetchone()[0]
    cur.execute("SELECT count(*) FROM verses")
    v = cur.fetchone()[0]
    cur.execute("SELECT count(*) FROM verses WHERE page_number > 0")
    vp = cur.fetchone()[0]
    cur.execute("SELECT max(page_number) FROM verses")
    mp = cur.fetchone()[0]

    conn.close()

    size_mb = os.path.getsize(DB_PATH) / (1024 * 1024)
    print(f"\n=== Database built successfully ===")
    print(f"  Surahs: {s}")
    print(f"  Verses: {v}")
    print(f"  Verses with page mapping: {vp}")
    print(f"  Max page number: {mp}")
    print(f"  File size: {size_mb:.1f} MB")
    print(f"  Path: {DB_PATH}")


if __name__ == "__main__":
    build_database()
