CREATE VIEW Autorzy_i_gatunki AS
SELECT ID_autora, Gatunek,  COUNT(Gatunek) as Iloœæ_ksi¹¿ek_danego_gatunku
FROM Ksi¹¿ki
GROUP BY ID_autora, Gatunek


CREATE VIEW Œrednie_oceny_ksi¹¿ek AS
SELECT Tytu³, AVG(Cast(Ocena as Float)) as Œrednia_ocena, Ksi¹¿ki.ID_ksi¹¿ki
FROM Ksi¹¿ki
JOIN Opinie ON Opinie.ID_ksi¹¿ki = Ksi¹¿ki.ID_ksi¹¿ki
GROUP BY Tytu³, Ksi¹¿ki.ID_ksi¹¿ki