#!/usr/bin/env python3
"""
build_static_db.py — Builds sukun_static.sqlite from Tanzil XML sources.

Reads XMLs from tools/input/ and produces the SQLite database at
Resources/Data/sukun_static.sqlite with the schema expected by the Swift app.
"""
import os
import sqlite3
import sys
import xml.etree.ElementTree as ET

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_DIR = os.path.join(SCRIPT_DIR, "input")
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
OUTPUT_PATH = os.path.join(PROJECT_ROOT, "SÜKÛN", "Resources", "Data", "sukun_static.sqlite")

# Expected input files
QURAN_UTHMANI = os.path.join(INPUT_DIR, "quran-uthmani.xml")
QURAN_DATA = os.path.join(INPUT_DIR, "quran-data.xml")
TR_ELMALILI = os.path.join(INPUT_DIR, "tr.elmalili.xml")
TR_TRANSLIT = os.path.join(INPUT_DIR, "tr.transliteration.xml")


def check_inputs():
    """Verify all required input files exist."""
    missing = []
    for path in [QURAN_UTHMANI, QURAN_DATA, TR_ELMALILI, TR_TRANSLIT]:
        if not os.path.isfile(path):
            missing.append(path)
    if missing:
        print("ERROR: Missing input files:", file=sys.stderr)
        for m in missing:
            print(f"  {m}", file=sys.stderr)
        print("\nRun tools/download_sources.sh first.", file=sys.stderr)
        sys.exit(1)


def parse_surahs(quran_data_path):
    """Parse surah metadata from quran-data.xml."""
    tree = ET.parse(quran_data_path)
    root = tree.getroot()
    surahs = []

    # quran-data.xml has <suras> with <sura> children
    for suras_elem in root.iter("suras"):
        for sura in suras_elem.findall("sura"):
            idx = int(sura.get("index"))
            surahs.append({
                "id": idx,
                "name_arabic": sura.get("name", ""),
                "name_english": sura.get("ename", ""),
                "name_transliteration": sura.get("tname", ""),
                "verse_count": int(sura.get("ayas", "0")),
                "revelation_type": sura.get("type", ""),
            })

    if not surahs:
        print("ERROR: No surahs parsed from quran-data.xml", file=sys.stderr)
        sys.exit(1)

    return sorted(surahs, key=lambda s: s["id"])


def parse_quran_text(xml_path):
    """Parse a Tanzil quran text XML (uthmani, translation, transliteration).

    Returns dict: (surah_id, aya_number) -> text
    """
    tree = ET.parse(xml_path)
    root = tree.getroot()
    texts = {}

    for sura in root.iter("sura"):
        surah_id = int(sura.get("index"))
        for aya in sura.findall("aya"):
            aya_num = int(aya.get("index"))
            text = aya.get("text", "")
            texts[(surah_id, aya_num)] = text

    return texts


def build_database():
    """Main pipeline: parse sources and build the SQLite database."""
    print("=== SÜKÛN: Building static database ===\n")

    check_inputs()

    # Parse sources
    print("Parsing quran-data.xml ...")
    surahs = parse_surahs(QURAN_DATA)
    print(f"  {len(surahs)} surahs parsed")

    print("Parsing quran-uthmani.xml ...")
    arabic_texts = parse_quran_text(QURAN_UTHMANI)
    print(f"  {len(arabic_texts)} verses parsed")

    print("Parsing tr.elmalili.xml ...")
    translation_texts = parse_quran_text(TR_ELMALILI)
    print(f"  {len(translation_texts)} translations parsed")

    print("Parsing tr.transliteration.xml ...")
    translit_texts = parse_quran_text(TR_TRANSLIT)
    print(f"  {len(translit_texts)} transliterations parsed")

    # Ensure output directory exists
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

    # Remove existing DB if present
    if os.path.exists(OUTPUT_PATH):
        os.remove(OUTPUT_PATH)

    print(f"\nCreating database at {OUTPUT_PATH} ...")
    conn = sqlite3.connect(OUTPUT_PATH)
    cur = conn.cursor()

    # Create tables
    cur.executescript("""
        CREATE TABLE surahs (
            id INTEGER PRIMARY KEY,
            name_arabic TEXT NOT NULL,
            name_english TEXT NOT NULL,
            name_transliteration TEXT NOT NULL,
            verse_count INTEGER NOT NULL,
            revelation_type TEXT NOT NULL
        );

        CREATE TABLE verses (
            id INTEGER PRIMARY KEY,
            surah_id INTEGER NOT NULL,
            verse_number INTEGER NOT NULL,
            text_arabic TEXT NOT NULL DEFAULT '',
            text_translation TEXT NOT NULL DEFAULT '',
            text_transliteration TEXT NOT NULL DEFAULT '',
            FOREIGN KEY (surah_id) REFERENCES surahs(id)
        );

        CREATE INDEX idx_verses_surah ON verses(surah_id, verse_number);

        CREATE VIRTUAL TABLE verses_fts USING fts5(
            text_translation,
            text_transliteration,
            content='verses',
            content_rowid='id',
            tokenize='unicode61'
        );

        CREATE TABLE duas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL DEFAULT '',
            text_arabic TEXT NOT NULL DEFAULT '',
            text_translation TEXT NOT NULL DEFAULT '',
            text_transliteration TEXT NOT NULL DEFAULT '',
            category TEXT NOT NULL DEFAULT '',
            source TEXT NOT NULL DEFAULT ''
        );

        CREATE VIRTUAL TABLE duas_fts USING fts5(
            title,
            text_translation,
            text_transliteration,
            content='duas',
            content_rowid='id',
            tokenize='unicode61'
        );
    """)

    # Insert surahs
    print("Inserting surahs ...")
    for s in surahs:
        cur.execute(
            "INSERT INTO surahs (id, name_arabic, name_english, name_transliteration, verse_count, revelation_type) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (s["id"], s["name_arabic"], s["name_english"],
             s["name_transliteration"], s["verse_count"], s["revelation_type"]),
        )

    # Insert verses
    print("Inserting verses ...")
    verse_count = 0
    for s in surahs:
        surah_id = s["id"]
        for aya_num in range(1, s["verse_count"] + 1):
            verse_id = surah_id * 1000 + aya_num  # stable id
            text_ar = arabic_texts.get((surah_id, aya_num), "")
            text_tr = translation_texts.get((surah_id, aya_num), "")
            text_tl = translit_texts.get((surah_id, aya_num), "")
            cur.execute(
                "INSERT INTO verses (id, surah_id, verse_number, text_arabic, text_translation, text_transliteration) "
                "VALUES (?, ?, ?, ?, ?, ?)",
                (verse_id, surah_id, aya_num, text_ar, text_tr, text_tl),
            )
            verse_count += 1

    # Populate FTS
    print("Populating FTS index ...")
    cur.execute("""
        INSERT INTO verses_fts(rowid, text_translation, text_transliteration)
        SELECT id, text_translation, text_transliteration FROM verses
    """)

    # Optimize
    print("Running ANALYZE + VACUUM ...")
    cur.execute("ANALYZE")
    conn.commit()
    conn.execute("VACUUM")
    conn.close()

    # Verification summary
    print(f"\n=== Build complete ===")
    print(f"  Surahs: {len(surahs)}")
    print(f"  Verses: {verse_count}")

    # Show sample
    conn = sqlite3.connect(OUTPUT_PATH)
    cur = conn.cursor()
    cur.execute(
        "SELECT surah_id, verse_number, text_arabic, text_translation, text_transliteration "
        "FROM verses WHERE surah_id = 1 AND verse_number = 1"
    )
    row = cur.fetchone()
    if row:
        print(f"\n  Sample (1:1):")
        print(f"    Arabic:          {row[2][:80]}...")
        print(f"    Translation:     {row[3][:80]}...")
        print(f"    Transliteration: {row[4][:80]}...")

    db_size = os.path.getsize(OUTPUT_PATH)
    print(f"\n  Database size: {db_size / 1024 / 1024:.1f} MB")
    conn.close()


if __name__ == "__main__":
    build_database()
