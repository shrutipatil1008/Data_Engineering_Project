-- ============================================================
-- Bookstore Analytics — DWH (SQL Server / T-SQL version)
-- ============================================================

CREATE DATABASE BookstoreDWH;



-- SCD Typ 2: volle Historie der Kundenadresse
CREATE TABLE Dim_Kunde (
    KundeKey    INT IDENTITY(1,1) PRIMARY KEY,
    KundenID    INT NOT NULL,
    Vorname     NVARCHAR(100),
    Nachname    NVARCHAR(100),
    Adresse     NVARCHAR(200),
    Stadt       NVARCHAR(100),
    ValidFrom   DATE NOT NULL,
    ValidTo     DATE NULL,          -- NULL = aktuell
    IsCurrent   BIT NOT NULL
);

-- SCD Typ 2: volle Historie des Buchpreises
CREATE TABLE Dim_Buch (
    BuchKey     INT IDENTITY(1,1) PRIMARY KEY,
    BuchID      INT NOT NULL,
    Titel       NVARCHAR(200),
    ISBN        NVARCHAR(20),
    Kategorie   NVARCHAR(100),
    Preis       DECIMAL(10,2),
    ValidFrom   DATE NOT NULL,
    ValidTo     DATE NULL,
    IsCurrent   BIT NOT NULL
);

-- SCD Typ 1: aktueller Stand, wird ueberschrieben
CREATE TABLE Dim_Verlag (
    VerlagKey   INT IDENTITY(1,1) PRIMARY KEY,
    VerlagID    INT NOT NULL UNIQUE,
    Name        NVARCHAR(150),
    Land        NVARCHAR(100)
);

CREATE TABLE Dim_Datum (
    DatumKey    INT IDENTITY(1,1) PRIMARY KEY,
    Datum       DATE NOT NULL UNIQUE,
    Wochentag   NVARCHAR(20),
    Woche       INT,
    Monat       INT,
    Jahr        INT
);

CREATE TABLE Fact_Bestellposition (
    FactID      INT IDENTITY(1,1) PRIMARY KEY,
    PositionID  INT NOT NULL,
    KundeKey    INT NOT NULL,
    BuchKey     INT NOT NULL,
    VerlagKey   INT NOT NULL,
    DatumKey    INT NOT NULL,
    Menge       INT NOT NULL,
    Einzelpreis DECIMAL(10,2) NOT NULL,
    Rabatt      DECIMAL(10,2) NOT NULL,
    Gesamtpreis DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (KundeKey)  REFERENCES Dim_Kunde(KundeKey),
    FOREIGN KEY (BuchKey)   REFERENCES Dim_Buch(BuchKey),
    FOREIGN KEY (VerlagKey) REFERENCES Dim_Verlag(VerlagKey),
    FOREIGN KEY (DatumKey)  REFERENCES Dim_Datum(DatumKey)
);
