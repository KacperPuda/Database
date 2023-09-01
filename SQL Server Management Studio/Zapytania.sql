-- 1 wy�wietl wydawnictwo z najwi�ksza liczba sprzedanych ksi��ek w ksi�garni

SELECT   TOP 1 Nazwa, SUM(Ilo��)
FROM Cz�ci_zam�wie�
	JOIN Wydania ON Wydania.ISBN_ksi��ki = Cz�ci_zam�wie�.ISBN_ksi��ki
	JOIN Wydawnictwa ON Wydawnictwa.Nazwa = Wydania.Nazwa_wydawnictwa
GROUP BY Wydawnictwa.Nazwa
ORDER BY  SUM(Ilo��) DESC

--2 przypisz wydawnictw� �redni� z �rednich ocen ksi��ek < 4

SELECT Nazwa_wydawnictwa, AVG(Cast(�rednia_ocena as Float)) AS �rednia_Ocena
FROM
(
	SELECT DISTINCT Nazwa_wydawnictwa, �rednia_ocena,Wydania.ID_ksi��ki
	FROM Wydania
	JOIN �rednie_oceny_ksi��ek ON �rednie_oceny_ksi��ek.ID_ksi��ki= Wydania.ID_ksi��ki
) wynik 
GROUP BY Nazwa_wydawnictwa
HAVING AVG(Cast(�rednia_ocena as Float)) < 4

-- 3 wyswietl imiona i nazwiska autorow ktorzy maja wydane ksiazki w wiecej niz 1 wydawnictwie

SELECT TOP 3 Imi�, Nazwisko
FROM Osoby
WHERE ID_osoby IN (
	SELECT ID_autora 
	FROM 
	(
		SELECT Autorzy.ID_autora
		FROM Autorzy
			JOIN Ksi��ki ON Ksi��ki.ID_autora = Autorzy.ID_autora
			JOIN Wydania ON Wydania.ID_ksi��ki = Ksi��ki.ID_ksi��ki
		GROUP BY Nazwa_wydawnictwa, Autorzy.ID_autora
	) Autorzy_i_ich_wydawnictwa
	GROUP BY ID_autora
	HAVING COUNT(*) > 1
);

-- 4 wyswietl firme kurierksa ktora dostarczyla najwiecej ksi��ek, na ktore zostaly zlozone zamowienia od dnia 2022-12-12

SELECT TOP 1 Realizator, SUM(Il) AS Ilo��_dostarczonych_ksi��ek
FROM Zam�wienia 
	JOIN (	
	SELECT ID_zam�wienia, SUM(Ilo��) AS Il
	FROM Cz�ci_zam�wie�
	GROUP BY ID_zam�wienia
	) Ilo��_ksi��ek_w_zamowieniu ON Ilo��_ksi��ek_w_zamowieniu.ID_zam�wienia = Zam�wienia.ID_zam�wienia
WHERE Data_z�o�enia > '2022-05-01' AND Status_zam�wienia = 'Dostarczone'
GROUP BY Realizator
ORDER BY Ilo��_dostarczonych_ksi��ek DESC


-- 5 wyswietl imiona i nazwiska osob ktore zakupily kilka egzemplarzy jednej ksiazki i daly im najwyzsza ocene = 5, wypisz tez tytuly ksiazek

SELECT Imi�, Nazwisko, Tytu�
FROM Osoby
	JOIN (
		SELECT ID_ksi��ki, ID_klienta
		FROM Zam�wienia
			JOIN Cz�ci_zam�wie� ON Cz�ci_zam�wie�.ID_zam�wienia = Zam�wienia.ID_zam�wienia
			JOIN Wydania ON Wydania.ISBN_ksi��ki = Cz�ci_zam�wie�.ISBN_ksi��ki
		GROUP BY ID_klienta,ID_ksi��ki
		HAVING SUM(Ilo��) > 1
	) Sumy_ksiazek ON Sumy_ksiazek.ID_klienta = Osoby.ID_osoby
	JOIN Ksi��ki ON Ksi��ki.ID_ksi��ki = Sumy_ksiazek.ID_ksi��ki
WHERE EXISTS (
	SELECT *
	FROM Opinie
	WHERE Ocena = 5 AND Osoby.ID_osoby = ID_klienta AND Ksi��ki.ID_ksi��ki = ID_ksi��ki
);

-- 6 wypisz autorow i ich ksiazki ktore zostaly ocenione przez przynajmniej 2 osoby na 5

SELECT Imi�, Nazwisko, Tytu�
FROM Osoby
	JOIN Ksi��ki ON Osoby.ID_osoby = Ksi��ki.ID_autora
WHERE EXISTS (
	SELECT ID_ksi��ki, COUNT (*)
	FROM Opinie
	WHERE Ocena = 5 AND Ksi��ki.ID_ksi��ki = Opinie.ID_ksi��ki
	GROUP BY ID_ksi��ki
	HAVING COUNT (*) > 1
);

-- 7 podaj il�� sprzedanych mezczyzna ksiazek w roku 2022 w miesiacach parzystych

SELECT SUM (Ilo��) AS Ilo��_sprzedanych_ksia�ek
FROM Zam�wienia
	JOIN Cz�ci_zam�wie� ON Zam�wienia.ID_zam�wienia = Cz�ci_zam�wie�.ID_zam�wienia
WHERE YEAR(Data_z�o�enia) = 2022 AND (MONTH(Data_z�o�enia) % 2) = 0 AND EXISTS (
	SELECT *
	FROM Osoby
	WHERE P�e� = 'M�czyzna' AND ID_klienta = ID_osoby
)

-- 8 Dla ka�dego autora znajd� najcz�stszy gatunek jego ksi��ek.
SELECT DISTINCT ID_autora, Gatunek
FROM Autorzy_i_gatunki AS t1
WHERE EXISTS (
	SELECT ID_autora, MAX(Ilo��_ksi��ek_danego_gatunku) AS Najpopularniejszy_gatunek
	FROM Autorzy_i_gatunki AS t2
	WHERE t1.ID_autora = t2.ID_autora
	GROUP BY ID_autora
	HAVING t1.Ilo��_ksi��ek_danego_gatunku = MAX(Ilo��_ksi��ek_danego_gatunku)
)
ORDER BY ID_autora


--  9 znalezc klientow ktorzy w 2022 kupili conajmniej 8 ksiazek i napisali chociaz 1 opinie, na tej podstawie
-- obliczyc im znizke ktora dostana w prezencie
-- (znizka =  1% * liczba kupionych ksiazek + liczba opini * 2%)

SELECT Ilo��_kupionych_ksi��ek.ID_klienta, Ilo��_kupionych_ksi��ek + 2 * Ilo��_Opini AS Zni�ka_w_procentach
FROM (
	SELECT ID_klienta, SUM(Ilo��) AS Ilo��_kupionych_ksi��ek
	FROM Zam�wienia
		JOIN Cz�ci_zam�wie� ON Cz�ci_zam�wie�.ID_zam�wienia = Zam�wienia.ID_zam�wienia
	WHERE YEAR(Data_z�o�enia) = 2022
	GROUP BY ID_klienta
) Ilo��_kupionych_ksi��ek
JOIN (
	SELECT ID_klienta, COUNT(*) AS Ilo��_Opini
	FROM Opinie
	WHERE YEAR(Data_opini) = 2022
	GROUP BY ID_klienta
) Ilo��_napisanych_opinii ON Ilo��_napisanych_opinii.ID_klienta = Ilo��_kupionych_ksi��ek.ID_klienta
WHERE Ilo��_kupionych_ksi��ek >= 8 

-- 10 Podaj nazwe firmy kurierskiej ktora byla realizatorem anjwiekszej ilosci paczek i jest przy ulicy na litere M

SELECT TOP 1 Nazwa_firmy_kurierskiej
FROM Firmy_kurierskie
	JOIN Dane_kontaktowe ON Dane_kontaktowe.ID_danych = Firmy_kurierskie.ID_danych
	JOIN Zam�wienia ON Zam�wienia.Realizator = Firmy_kurierskie.Nazwa_firmy_kurierskiej
WHERE Ulica LIKE 'M%'
GROUP BY Nazwa_firmy_kurierskiej
ORDER BY COUNT(*) DESC





