ALTER TABLE Zamówienia
ADD CHECK (Status_zamówienia IN ('Dostarczone', 'Wys³ane','Przygotowywana','Potwierdzone'));

ALTER TABLE Dane_kontaktowe
ADD Kod_pocztowy varchar (6) NOT NULL;

ALTER TABLE Wydawnictwa
ADD ID_danych varchar (5) NOT NULL FOREIGN KEY REFERENCES Dane_kontaktowe(ID_danych) ON DELETE NO ACTION ON UPDATE CASCADE;

