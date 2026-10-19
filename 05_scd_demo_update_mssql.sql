
-- SCD Typ 2 trigger: book price change
UPDATE Buecher SET Preis = 22.90 WHERE BuchID = 5;   -- was 19.90

-- SCD Typ 2 trigger: customer moves
UPDATE Kunden SET Adresse = 'Poststr. 21', Stadt = 'Aachen' WHERE KundenID = 3; -- was Duesseldorf

-- SCD Typ 1 trigger: publisher record correction
UPDATE Verlage SET Land = 'Liechtenstein' WHERE VerlagID = 2;  -- was Schweiz
