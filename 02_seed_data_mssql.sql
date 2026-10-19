-- ============================================================
-- Sample data — small and hand-readable on purpose.
-- 6 customers, 5 publishers, 4 categories, 16 books,
-- 25 orders / ~35 order lines over 3 weeks.
-- All book titles/authors are fictional.
-- ============================================================

INSERT INTO Kunden (KundenID, Vorname, Nachname, Adresse, Stadt, Email) VALUES
(1, 'Anna',   'Krueger',  'Lindenstr. 12',   'Aachen',    'anna.krueger@mail.de'),
(2, 'Jonas',  'Vogel',    'Bahnhofstr. 5',   'Koeln',     'jonas.vogel@mail.de'),
(3, 'Mira',   'Sander',   'Gartenweg 3',     'Duesseldorf','mira.sander@mail.de'),
(4, 'Felix',  'Lorenz',   'Ringstr. 44',     'Aachen',    'felix.lorenz@mail.de'),
(5, 'Nora',   'Brandt',   'Schulstr. 8',     'Bonn',      'nora.brandt@mail.de'),
(6, 'Timo',   'Reuter',   'Marktplatz 2',    'Koeln',     'timo.reuter@mail.de');

INSERT INTO Verlage (VerlagID, Name, Land) VALUES
(1, 'Nordlicht Verlag',     'Deutschland'),
(2, 'Alpenblick Verlag',    'Schweiz'),
(3, 'Rheinwort Verlag',     'Deutschland'),
(4, 'Silbermond Verlag',    'Deutschland'),
(5, 'Blaufeder Verlag',     'Oesterreich');

INSERT INTO Kategorien (KategorieID, Name) VALUES
(1, 'Roman'),
(2, 'Krimi'),
(3, 'Sachbuch'),
(4, 'Kinderbuch');

INSERT INTO Buecher (BuchID, Titel, ISBN, Preis, VerlagID, KategorieID) VALUES
(1,  'Der Sommer am Fluss',        '978-3-1000-0001-1', 12.90, 1, 1),
(2,  'Nebel ueber Aachen',         '978-3-1000-0002-8', 14.50, 3, 2),
(3,  'Der letzte Zug',             '978-3-1000-0003-5', 11.90, 2, 2),
(4,  'Wege durch den Winter',      '978-3-1000-0004-2', 13.20, 1, 1),
(5,  'Die Zahlen der Zukunft',     '978-3-1000-0005-9', 19.90, 4, 3),
(6,  'Kleine Abenteuer im Park',   '978-3-1000-0006-6', 8.90,  5, 4),
(7,  'Stille Wasser',              '978-3-1000-0007-3', 12.50, 3, 2),
(8,  'Der Garten der Worte',       '978-3-1000-0008-0', 15.90, 2, 1),
(9,  'Kompass ohne Norden',        '978-3-1000-0009-7', 13.90, 1, 1),
(10, 'Fakten fuer Neugierige',     '978-3-1000-0010-3', 17.50, 4, 3),
(11, 'Die Katze und der Mond',     '978-3-1000-0011-0', 7.90,  5, 4),
(12, 'Spuren im Schnee',           '978-3-1000-0012-7', 12.90, 3, 2),
(13, 'Ein Haus am Meer',           '978-3-1000-0013-4', 14.90, 2, 1),
(14, 'Geschichte kurz erklaert',   '978-3-1000-0014-1', 21.90, 4, 3),
(15, 'Der Drache im Regal',        '978-3-1000-0015-8', 9.50,  5, 4),
(16, 'Schatten ueber der Stadt',   '978-3-1000-0016-5', 13.50, 3, 2);

INSERT INTO Bestellungen (BestellID, KundenID, Bestelldatum) VALUES
(1,  1, '2026-08-03'),
(2,  2, '2026-08-03'),
(3,  3, '2026-08-04'),
(4,  4, '2026-08-04'),
(5,  5, '2026-08-05'),
(6,  6, '2026-08-05'),
(7,  1, '2026-08-06'),
(8,  2, '2026-08-07'),
(9,  3, '2026-08-08'),
(10, 4, '2026-08-08'),
(11, 5, '2026-08-09'),
(12, 6, '2026-08-10'),
(13, 1, '2026-08-11'),
(14, 2, '2026-08-11'),
(15, 3, '2026-08-12'),
(16, 4, '2026-08-13'),
(17, 5, '2026-08-13'),
(18, 6, '2026-08-14'),
(19, 1, '2026-08-15'),
(20, 2, '2026-08-16'),
(21, 3, '2026-08-17'),
(22, 4, '2026-08-17'),
(23, 5, '2026-08-18'),
(24, 6, '2026-08-19'),
(25, 1, '2026-08-19');

INSERT INTO Bestellpositionen (PositionID, BestellID, BuchID, Menge, Einzelpreis, Rabatt) VALUES
(1,  1,  1, 1, 12.90, 0),
(2,  1,  6, 2, 8.90,  0),
(3,  2,  2, 1, 14.50, 0),
(4,  3,  3, 1, 11.90, 0),
(5,  3,  8, 1, 15.90, 1.00),
(6,  4,  4, 1, 13.20, 0),
(7,  5,  5, 1, 19.90, 0),
(8,  6,  6, 1, 8.90,  0),
(9,  7,  7, 1, 12.50, 0),
(10, 7,  9, 1, 13.90, 0),
(11, 8,  8, 1, 15.90, 0),
(12, 9,  9, 1, 13.90, 0),
(13, 10, 10,1, 17.50, 0),
(14, 11, 11,1, 7.90,  0),
(15, 12, 12,1, 12.90, 0),
(16, 13, 13,1, 14.90, 0),
(17, 13, 15,1, 9.50,  0),
(18, 14, 14,1, 21.90, 0),
(19, 15, 15,1, 9.50,  0),
(20, 16, 16,1, 13.50, 0),
(21, 17, 1, 1, 12.90, 0),
(22, 18, 2, 1, 14.50, 0),
(23, 19, 3, 1, 11.90, 0),
(24, 20, 4, 1, 13.20, 0),
(25, 21, 5, 1, 19.90, 1.50),
(26, 22, 6, 2, 8.90,  0),
(27, 23, 7, 1, 12.50, 0),
(28, 24, 8, 1, 15.90, 0),
(29, 25, 9, 1, 13.90, 0),
(30, 9,  11,1, 7.90,  0),
(31, 11, 12,1, 12.90, 0),
(32, 15, 13,1, 14.90, 0),
(33, 19, 14,1, 21.90, 2.00),
(34, 21, 16,1, 13.50, 0),
(35, 24, 10,1, 17.50, 0);

