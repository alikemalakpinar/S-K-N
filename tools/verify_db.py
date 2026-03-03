#!/usr/bin/env python3
"""
verify_db.py — Verifies the integrity of sukun_static.sqlite.

Runs sanity checks on table counts, sample queries, and FTS search.
Exits non-zero if any check fails.
"""
import os
import sqlite3
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
DB_PATH = os.path.join(PROJECT_ROOT, "SÜKÛN", "Resources", "Data", "sukun_static.sqlite")

EXPECTED_SURAHS = 114
EXPECTED_VERSES = 6236


def fail(msg):
    print(f"FAIL: {msg}", file=sys.stderr)
    sys.exit(1)


def main():
    print("=== SÜKÛN: Database Verification ===\n")

    if not os.path.isfile(DB_PATH):
        fail(f"Database not found at {DB_PATH}")

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    # Check surah count
    cur.execute("SELECT COUNT(*) FROM surahs")
    surah_count = cur.fetchone()[0]
    print(f"Surahs: {surah_count} (expected {EXPECTED_SURAHS})")
    if surah_count != EXPECTED_SURAHS:
        fail(f"Expected {EXPECTED_SURAHS} surahs, got {surah_count}")

    # Check verse count
    cur.execute("SELECT COUNT(*) FROM verses")
    verse_count = cur.fetchone()[0]
    print(f"Verses: {verse_count} (expected {EXPECTED_VERSES})")
    if verse_count != EXPECTED_VERSES:
        fail(f"Expected {EXPECTED_VERSES} verses, got {verse_count}")

    # Sample query: surah 1, verse 1 (Al-Fatiha)
    cur.execute(
        "SELECT surah_id, verse_number, text_arabic, text_translation, text_transliteration "
        "FROM verses WHERE surah_id = 1 AND verse_number = 1"
    )
    row = cur.fetchone()
    if not row:
        fail("Could not find verse 1:1")
    print(f"\nSample verse 1:1:")
    print(f"  Arabic:          {row[2][:80]}")
    print(f"  Translation:     {row[3][:80]}")
    print(f"  Transliteration: {row[4][:80]}")

    # Verify fields are non-empty
    if not row[2].strip():
        fail("Verse 1:1 has empty Arabic text")
    if not row[3].strip():
        fail("Verse 1:1 has empty translation text")
    if not row[4].strip():
        fail("Verse 1:1 has empty transliteration text")

    # FTS search test: "rahman"
    print(f"\nFTS search for 'rahman':")
    cur.execute(
        "SELECT COUNT(*) FROM verses_fts WHERE verses_fts MATCH 'rahman*'"
    )
    fts_count = cur.fetchone()[0]
    print(f"  Matches: {fts_count}")

    # Also try translation search
    cur.execute(
        "SELECT v.surah_id, v.verse_number, v.text_transliteration "
        "FROM verses_fts fts "
        "JOIN verses v ON v.id = fts.rowid "
        "WHERE verses_fts MATCH 'rahman*' "
        "ORDER BY bm25(verses_fts) "
        "LIMIT 3"
    )
    rows = cur.fetchall()
    if rows:
        for r in rows:
            print(f"  {r[0]}:{r[1]} — {r[2][:60]}")
    else:
        # Not a hard failure — translation may not contain 'rahman'
        print("  (No matches found — this is OK if the translation doesn't use 'rahman')")

    # Check duas table exists (empty for v1 is OK)
    cur.execute("SELECT COUNT(*) FROM duas")
    duas_count = cur.fetchone()[0]
    print(f"\nDuas table: {duas_count} rows (empty is OK for v1)")

    # Check duas_fts table exists
    cur.execute("SELECT COUNT(*) FROM duas_fts")
    duas_fts_count = cur.fetchone()[0]
    print(f"Duas FTS:   {duas_fts_count} rows")

    # FTS search test with Turkish word from Elmalılı
    print(f"\nFTS search for 'Allah':")
    cur.execute(
        "SELECT COUNT(*) FROM verses_fts WHERE verses_fts MATCH 'Allah*'"
    )
    allah_count = cur.fetchone()[0]
    print(f"  Matches: {allah_count}")
    if allah_count == 0:
        fail("FTS search for 'Allah' returned 0 results — FTS index may be broken")

    conn.close()

    print(f"\n=== All checks passed ===")


if __name__ == "__main__":
    main()
