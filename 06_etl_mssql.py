import pyodbc
from datetime import datetime

# ---- adjust these for your local setup ----
SERVER = "localhost\\SQLEXPRESS"       
BUSINESS_DB = "BookstoreBusinessDB"
DWH_DB = "BookstoreDWH"
DRIVER = "{ODBC Driver 17 for SQL Server}"
# ---------------------------------------------

TODAY = datetime.now().strftime("%Y-%m-%d")
WEEKDAYS_DE = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]


def get_conn(database):
    conn_str = (
        f"DRIVER={DRIVER};"
        f"SERVER={SERVER};"
        f"DATABASE={database};"
        f"Trusted_Connection=yes;"   
    )
    conn = pyodbc.connect(conn_str, autocommit=False)
    return conn


def load_dim_kunde(src, dwh):
    """SCD Typ 2: keep full history of customer address."""
    rows = src.execute("SELECT KundenID, Vorname, Nachname, Adresse, Stadt FROM Kunden").fetchall()
    new_versions = 0
    for r in rows:
        current = dwh.execute(
            "SELECT KundeKey, Adresse, Stadt FROM Dim_Kunde WHERE KundenID=? AND IsCurrent=1", r.KundenID
        ).fetchone()
        if current is None:
            dwh.execute(
                """INSERT INTO Dim_Kunde (KundenID, Vorname, Nachname, Adresse, Stadt, ValidFrom, ValidTo, IsCurrent)
                   VALUES (?,?,?,?,?,?,NULL,1)""",
                r.KundenID, r.Vorname, r.Nachname, r.Adresse, r.Stadt, TODAY,
            )
            new_versions += 1
        elif current.Adresse != r.Adresse or current.Stadt != r.Stadt:
            dwh.execute("UPDATE Dim_Kunde SET ValidTo=?, IsCurrent=0 WHERE KundeKey=?", TODAY, current.KundeKey)
            dwh.execute(
                """INSERT INTO Dim_Kunde (KundenID, Vorname, Nachname, Adresse, Stadt, ValidFrom, ValidTo, IsCurrent)
                   VALUES (?,?,?,?,?,?,NULL,1)""",
                r.KundenID, r.Vorname, r.Nachname, r.Adresse, r.Stadt, TODAY,
            )
            new_versions += 1
    print(f"Dim_Kunde: {len(rows)} source rows processed, {new_versions} new version(s) inserted (SCD Typ 2)")


def load_dim_buch(src, dwh):
    """SCD Typ 2: keep full history of book price."""
    rows = src.execute("""
        SELECT b.BuchID, b.Titel, b.ISBN, b.Preis, k.Name AS Kategorie
        FROM Buecher b JOIN Kategorien k ON b.KategorieID = k.KategorieID
    """).fetchall()
    new_versions = 0
    for r in rows:
        current = dwh.execute(
            "SELECT BuchKey, Preis FROM Dim_Buch WHERE BuchID=? AND IsCurrent=1", r.BuchID
        ).fetchone()
        if current is None:
            dwh.execute(
                """INSERT INTO Dim_Buch (BuchID, Titel, ISBN, Kategorie, Preis, ValidFrom, ValidTo, IsCurrent)
                   VALUES (?,?,?,?,?,?,NULL,1)""",
                r.BuchID, r.Titel, r.ISBN, r.Kategorie, r.Preis, TODAY,
            )
            new_versions += 1
        elif float(current.Preis) != float(r.Preis):
            dwh.execute("UPDATE Dim_Buch SET ValidTo=?, IsCurrent=0 WHERE BuchKey=?", TODAY, current.BuchKey)
            dwh.execute(
                """INSERT INTO Dim_Buch (BuchID, Titel, ISBN, Kategorie, Preis, ValidFrom, ValidTo, IsCurrent)
                   VALUES (?,?,?,?,?,?,NULL,1)""",
                r.BuchID, r.Titel, r.ISBN, r.Kategorie, r.Preis, TODAY,
            )
            new_versions += 1
    print(f"Dim_Buch: {len(rows)} source rows processed, {new_versions} new version(s) inserted (SCD Typ 2)")


def load_dim_verlag(src, dwh):
    """SCD Typ 1: overwrite in place, no history kept."""
    rows = src.execute("SELECT VerlagID, Name, Land FROM Verlage").fetchall()
    changed = 0
    for r in rows:
        existing = dwh.execute("SELECT Land FROM Dim_Verlag WHERE VerlagID=?", r.VerlagID).fetchone()
        if existing:
            if existing.Land != r.Land:
                changed += 1
            dwh.execute("UPDATE Dim_Verlag SET Name=?, Land=? WHERE VerlagID=?", r.Name, r.Land, r.VerlagID)
        else:
            dwh.execute("INSERT INTO Dim_Verlag (VerlagID, Name, Land) VALUES (?,?,?)", r.VerlagID, r.Name, r.Land)
    print(f"Dim_Verlag: {len(rows)} source rows processed, {changed} overwritten in place (SCD Typ 1)")


def load_dim_datum(src, dwh):
    dates = [r.Bestelldatum for r in src.execute("SELECT DISTINCT Bestelldatum FROM Bestellungen").fetchall()]
    added = 0
    for d in dates:
        existing = dwh.execute("SELECT DatumKey FROM Dim_Datum WHERE Datum=?", d).fetchone()
        if existing:
            continue
        dt = d if isinstance(d, datetime) else datetime.strptime(str(d), "%Y-%m-%d")
        dwh.execute(
            "INSERT INTO Dim_Datum (Datum, Wochentag, Woche, Monat, Jahr) VALUES (?,?,?,?,?)",
            dt.date(), WEEKDAYS_DE[dt.weekday()], dt.isocalendar()[1], dt.month, dt.year,
        )
        added += 1
    print(f"Dim_Datum: {len(dates)} distinct dates in source, {added} new")


def load_fact(src, dwh):
    rows = src.execute("""
        SELECT bp.PositionID, bp.BuchID, bp.Menge, bp.Einzelpreis, bp.Rabatt,
               b.KundenID, b.Bestelldatum, bu.VerlagID
        FROM Bestellpositionen bp
        JOIN Bestellungen b ON bp.BestellID = b.BestellID
        JOIN Buecher bu ON bp.BuchID = bu.BuchID
    """).fetchall()
    loaded = 0
    for r in rows:
        exists = dwh.execute("SELECT FactID FROM Fact_Bestellposition WHERE PositionID=?", r.PositionID).fetchone()
        if exists:
            continue

        kunde_key = dwh.execute(
            "SELECT KundeKey FROM Dim_Kunde WHERE KundenID=? AND IsCurrent=1", r.KundenID
        ).fetchone().KundeKey
        buch_key = dwh.execute(
            "SELECT BuchKey FROM Dim_Buch WHERE BuchID=? AND IsCurrent=1", r.BuchID
        ).fetchone().BuchKey
        verlag_key = dwh.execute(
            "SELECT VerlagKey FROM Dim_Verlag WHERE VerlagID=?", r.VerlagID
        ).fetchone().VerlagKey
        datum_key = dwh.execute(
            "SELECT DatumKey FROM Dim_Datum WHERE Datum=?", r.Bestelldatum
        ).fetchone().DatumKey

        gesamtpreis = round((float(r.Einzelpreis) - float(r.Rabatt)) * r.Menge, 2)

        dwh.execute(
            """INSERT INTO Fact_Bestellposition
               (PositionID, KundeKey, BuchKey, VerlagKey, DatumKey, Menge, Einzelpreis, Rabatt, Gesamtpreis)
               VALUES (?,?,?,?,?,?,?,?,?)""",
            r.PositionID, kunde_key, buch_key, verlag_key, datum_key, r.Menge, r.Einzelpreis, r.Rabatt, gesamtpreis,
        )
        loaded += 1
    print(f"Fact_Bestellposition: {len(rows)} source rows, {loaded} newly loaded")


def main():
    src = get_conn(BUSINESS_DB)
    dwh = get_conn(DWH_DB)
    src_cur = src.cursor()
    dwh_cur = dwh.cursor()

    load_dim_kunde(src_cur, dwh_cur)
    load_dim_buch(src_cur, dwh_cur)
    load_dim_verlag(src_cur, dwh_cur)
    load_dim_datum(src_cur, dwh_cur)
    load_fact(src_cur, dwh_cur)

    dwh.commit()
    src.close()
    dwh.close()
    print("ETL run complete.")


if __name__ == "__main__":
    main()
