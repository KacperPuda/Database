ALTER TABLE Zam�wienia
ADD CHECK (Status_zam�wienia IN ('Dostarczone', 'Wys�ane','Przygotowywana','Potwierdzone'));

ALTER TABLE Dane_kontaktowe
ADD Kod_pocztowy varchar (6) NOT NULL;

ALTER TABLE Wydawnictwa
ADD ID_danych varchar (5) NOT NULL FOREIGN KEY REFERENCES Dane_kontaktowe(ID_danych) ON DELETE NO ACTION ON UPDATE CASCADE;

