-- 1 wyœwietl wydawnictwo z najwiêksza liczba sprzedanych ksi¹¿ek w ksiêgarni

SELECT   TOP 1 Nazwa, SUM(Iloœæ)
FROM Czêœci_zamówieñ
	JOIN Wydania ON Wydania.ISBN_ksi¹¿ki = Czêœci_zamówieñ.ISBN_ksi¹¿ki
	JOIN Wydawnictwa ON Wydawnictwa.Nazwa = Wydania.Nazwa_wydawnictwa
GROUP BY Wydawnictwa.Nazwa
ORDER BY  SUM(Iloœæ) DESC

--2 przypisz wydawnictw¹ œredni¹ z œrednich ocen ksi¹¿ek < 4

SELECT Nazwa_wydawnictwa, AVG(Cast(Œrednia_ocena as Float)) AS Œrednia_Ocena
FROM
(
	SELECT DISTINCT Nazwa_wydawnictwa, Œrednia_ocena,Wydania.ID_ksi¹¿ki
	FROM Wydania
	JOIN Œrednie_oceny_ksi¹¿ek ON Œrednie_oceny_ksi¹¿ek.ID_ksi¹¿ki= Wydania.ID_ksi¹¿ki
) wynik 
GROUP BY Nazwa_wydawnictwa
HAVING AVG(Cast(Œrednia_ocena as Float)) < 4

-- 3 wyswietl imiona i nazwiska autorow ktorzy maja wydane ksiazki w wiecej niz 1 wydawnictwie

SELECT TOP 3 Imiê, Nazwisko
FROM Osoby
WHERE ID_osoby IN (
	SELECT ID_autora 
	FROM 
	(
		SELECT Autorzy.ID_autora
		FROM Autorzy
			JOIN Ksi¹¿ki ON Ksi¹¿ki.ID_autora = Autorzy.ID_autora
			JOIN Wydania ON Wydania.ID_ksi¹¿ki = Ksi¹¿ki.ID_ksi¹¿ki
		GROUP BY Nazwa_wydawnictwa, Autorzy.ID_autora
	) Autorzy_i_ich_wydawnictwa
	GROUP BY ID_autora
	HAVING COUNT(*) > 1
);

-- 4 wyswietl firme kurierksa ktora dostarczyla najwiecej ksi¹¿ek, na ktore zostaly zlozone zamowienia od dnia 2022-12-12

SELECT TOP 1 Realizator, SUM(Il) AS Iloœæ_dostarczonych_ksi¹¿ek
FROM Zamówienia 
	JOIN (	
	SELECT ID_zamówienia, SUM(Iloœæ) AS Il
	FROM Czêœci_zamówieñ
	GROUP BY ID_zamówienia
	) Iloœæ_ksi¹¿ek_w_zamowieniu ON Iloœæ_ksi¹¿ek_w_zamowieniu.ID_zamówienia = Zamówienia.ID_zamówienia
WHERE Data_z³o¿enia > '2022-05-01' AND Status_zamówienia = 'Dostarczone'
GROUP BY Realizator
ORDER BY Iloœæ_dostarczonych_ksi¹¿ek DESC


-- 5 wyswietl imiona i nazwiska osob ktore zakupily kilka egzemplarzy jednej ksiazki i daly im najwyzsza ocene = 5, wypisz tez tytuly ksiazek

SELECT Imiê, Nazwisko, Tytu³
FROM Osoby
	JOIN (
		SELECT ID_ksi¹¿ki, ID_klienta
		FROM Zamówienia
			JOIN Czêœci_zamówieñ ON Czêœci_zamówieñ.ID_zamówienia = Zamówienia.ID_zamówienia
			JOIN Wydania ON Wydania.ISBN_ksi¹¿ki = Czêœci_zamówieñ.ISBN_ksi¹¿ki
		GROUP BY ID_klienta,ID_ksi¹¿ki
		HAVING SUM(Iloœæ) > 1
	) Sumy_ksiazek ON Sumy_ksiazek.ID_klienta = Osoby.ID_osoby
	JOIN Ksi¹¿ki ON Ksi¹¿ki.ID_ksi¹¿ki = Sumy_ksiazek.ID_ksi¹¿ki
WHERE EXISTS (
	SELECT *
	FROM Opinie
	WHERE Ocena = 5 AND Osoby.ID_osoby = ID_klienta AND Ksi¹¿ki.ID_ksi¹¿ki = ID_ksi¹¿ki
);

-- 6 wypisz autorow i ich ksiazki ktore zostaly ocenione przez przynajmniej 2 osoby na 5

SELECT Imiê, Nazwisko, Tytu³
FROM Osoby
	JOIN Ksi¹¿ki ON Osoby.ID_osoby = Ksi¹¿ki.ID_autora
WHERE EXISTS (
	SELECT ID_ksi¹¿ki, COUNT (*)
	FROM Opinie
	WHERE Ocena = 5 AND Ksi¹¿ki.ID_ksi¹¿ki = Opinie.ID_ksi¹¿ki
	GROUP BY ID_ksi¹¿ki
	HAVING COUNT (*) > 1
);

-- 7 podaj ilœæ sprzedanych mezczyzna ksiazek w roku 2022 w miesiacach parzystych

SELECT SUM (Iloœæ) AS Iloœæ_sprzedanych_ksia¿ek
FROM Zamówienia
	JOIN Czêœci_zamówieñ ON Zamówienia.ID_zamówienia = Czêœci_zamówieñ.ID_zamówienia
WHERE YEAR(Data_z³o¿enia) = 2022 AND (MONTH(Data_z³o¿enia) % 2) = 0 AND EXISTS (
	SELECT *
	FROM Osoby
	WHERE P³eæ = 'Mê¿czyzna' AND ID_klienta = ID_osoby
)

-- 8 Dla ka¿dego autora znajdŸ najczêstszy gatunek jego ksi¹¿ek.
SELECT DISTINCT ID_autora, Gatunek
FROM Autorzy_i_gatunki AS t1
WHERE EXISTS (
	SELECT ID_autora, MAX(Iloœæ_ksi¹¿ek_danego_gatunku) AS Najpopularniejszy_gatunek
	FROM Autorzy_i_gatunki AS t2
	WHERE t1.ID_autora = t2.ID_autora
	GROUP BY ID_autora
	HAVING t1.Iloœæ_ksi¹¿ek_danego_gatunku = MAX(Iloœæ_ksi¹¿ek_danego_gatunku)
)
ORDER BY ID_autora


--  9 znalezc klientow ktorzy w 2022 kupili conajmniej 8 ksiazek i napisali chociaz 1 opinie, na tej podstawie
-- obliczyc im znizke ktora dostana w prezencie
-- (znizka =  1% * liczba kupionych ksiazek + liczba opini * 2%)

SELECT Iloœæ_kupionych_ksi¹¿ek.ID_klienta, Iloœæ_kupionych_ksi¹¿ek + 2 * Iloœæ_Opini AS Zni¿ka_w_procentach
FROM (
	SELECT ID_klienta, SUM(Iloœæ) AS Iloœæ_kupionych_ksi¹¿ek
	FROM Zamówienia
		JOIN Czêœci_zamówieñ ON Czêœci_zamówieñ.ID_zamówienia = Zamówienia.ID_zamówienia
	WHERE YEAR(Data_z³o¿enia) = 2022
	GROUP BY ID_klienta
) Iloœæ_kupionych_ksi¹¿ek
JOIN (
	SELECT ID_klienta, COUNT(*) AS Iloœæ_Opini
	FROM Opinie
	WHERE YEAR(Data_opini) = 2022
	GROUP BY ID_klienta
) Iloœæ_napisanych_opinii ON Iloœæ_napisanych_opinii.ID_klienta = Iloœæ_kupionych_ksi¹¿ek.ID_klienta
WHERE Iloœæ_kupionych_ksi¹¿ek >= 8 

-- 10 Podaj nazwe firmy kurierskiej ktora byla realizatorem anjwiekszej ilosci paczek i jest przy ulicy na litere M

SELECT TOP 1 Nazwa_firmy_kurierskiej
FROM Firmy_kurierskie
	JOIN Dane_kontaktowe ON Dane_kontaktowe.ID_danych = Firmy_kurierskie.ID_danych
	JOIN Zamówienia ON Zamówienia.Realizator = Firmy_kurierskie.Nazwa_firmy_kurierskiej
WHERE Ulica LIKE 'M%'
GROUP BY Nazwa_firmy_kurierskiej
ORDER BY COUNT(*) DESC





