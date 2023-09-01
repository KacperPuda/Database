CREATE VIEW Autorzy_i_gatunki AS
SELECT ID_autora, Gatunek,  COUNT(Gatunek) as Ilo��_ksi��ek_danego_gatunku
FROM Ksi��ki
GROUP BY ID_autora, Gatunek


CREATE VIEW �rednie_oceny_ksi��ek AS
SELECT Tytu�, AVG(Cast(Ocena as Float)) as �rednia_ocena, Ksi��ki.ID_ksi��ki
FROM Ksi��ki
JOIN Opinie ON Opinie.ID_ksi��ki = Ksi��ki.ID_ksi��ki
GROUP BY Tytu�, Ksi��ki.ID_ksi��ki