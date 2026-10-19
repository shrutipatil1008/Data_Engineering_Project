-- ============================================================
-- Bookstore Analytics — Business DB (SQL Server)
-- ============================================================
CREATE DATABASE BookstoreBusinessDB;


CREATE TABLE Kunden (
    KundenID    INT PRIMARY KEY,
    Vorname     NVARCHAR(100) NOT NULL,
    Nachname    NVARCHAR(100) NOT NULL,
    Adresse     NVARCHAR(200) NOT NULL,
    Stadt       NVARCHAR(100) NOT NULL,
    Email       NVARCHAR(150)
);

CREATE TABLE Verlage (
    VerlagID    INT PRIMARY KEY,
    Name        NVARCHAR(150) NOT NULL,
    Land        NVARCHAR(100) NOT NULL
);

CREATE TABLE Kategorien (
    KategorieID INT PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL
);

CREATE TABLE Buecher (
    BuchID      INT PRIMARY KEY,
    Titel       NVARCHAR(200) NOT NULL,
    ISBN        NVARCHAR(20) NOT NULL UNIQUE,
    Preis       DECIMAL(10,2) NOT NULL,
    VerlagID    INT NOT NULL,             -- Randbedingung: genau 1 Verlag pro Buch
    KategorieID INT NOT NULL,
    FOREIGN KEY (VerlagID) REFERENCES Verlage(VerlagID),
    FOREIGN KEY (KategorieID) REFERENCES Kategorien(KategorieID)
);

CREATE TABLE Bestellungen (
    BestellID    INT PRIMARY KEY,
    KundenID     INT NOT NULL,
    Bestelldatum DATE NOT NULL,
    FOREIGN KEY (KundenID) REFERENCES Kunden(KundenID)
);

CREATE TABLE Bestellpositionen (
    PositionID  INT PRIMARY KEY,
    BestellID   INT NOT NULL,
    BuchID      INT NOT NULL,
    Menge       INT NOT NULL,
    Einzelpreis DECIMAL(10,2) NOT NULL,
    Rabatt      DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (BestellID) REFERENCES Bestellungen(BestellID),
    FOREIGN KEY (BuchID) REFERENCES Buecher(BuchID)
);
