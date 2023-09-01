CREATE TABLE Dane_kontaktowe ( 
	ID_danych varchar (5) NOT NULL,
	Miasto varchar (30) NOT NULL,
	Ulica varchar (50) NOT NULL,
	Numer_budynku varchar(5) NOT NULL,
	Numer_telefonu varchar (9) NOT NULL,
	Email varchar (255) NOT NULL,
	PRIMARY KEY (ID_danych)
);

CREATE TABLE Osoby ( 
	ID_osoby varchar (5) NOT NULL ,
	Imi� varchar (20) NOT NULL,
	Nazwisko varchar (30) NOT NULL,
	Data_urodzenia date NOT NULL,
	P�e� varchar (10) NOT NULL,
	ID_danych varchar (5),
	PRIMARY KEY (ID_osoby),
	FOREIGN KEY (ID_danych) REFERENCES Dane_kontaktowe(ID_danych) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK (P�e� IN ('M�czyzna', 'Kobieta')) 
);

CREATE TABLE Autorzy ( 
	ID_autora varchar (5) NOT NULL,
	Opis varchar (1000),
	PRIMARY KEY (ID_autora),
	FOREIGN KEY (ID_autora) REFERENCES Osoby(ID_osoby) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Klienci ( 
	ID_klienta varchar (5) NOT NULL,
	Data_utworzenia_konta date NOT NULL,
	PRIMARY KEY (ID_klienta),
	FOREIGN KEY (ID_klienta) REFERENCES Osoby(ID_osoby) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK (Data_utworzenia_konta > '2020-01-01')
);

CREATE TABLE Wydawnictwa ( 
	Nazwa varchar (40) NOT NULL,
	PRIMARY KEY (Nazwa)
);

CREATE TABLE Firmy_kurierskie ( 
	Nazwa_firmy_kurierskiej varchar (40) NOT NULL ,
	ID_danych varchar (5) NOT NULL,
	PRIMARY KEY (Nazwa_firmy_kurierskiej),
	FOREIGN KEY (ID_danych) REFERENCES Dane_kontaktowe(ID_danych) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Zam�wienia ( 
	ID_zam�wienia varchar (5) NOT NULL,
	Data_z�o�enia date NOT NULL,
	Status_zam�wienia varchar (15) NOT NULL,
	Realizator varchar (40),
	ID_klienta varchar (5) NOT NULL,
	PRIMARY KEY (ID_zam�wienia),
	FOREIGN KEY (Realizator) REFERENCES Firmy_kurierskie(Nazwa_firmy_kurierskiej) ON DELETE SET NULL,
	FOREIGN KEY (ID_klienta) REFERENCES Klienci (ID_klienta) ON DELETE CASCADE
);

CREATE TABLE Ksi��ki ( 
	ID_ksi��ki varchar (5) NOT NULL,
	Tytu� varchar (50) NOT NULL,
	Opis varchar (5000) NOT NULL,
	Gatunek varchar (50) NOT NULL,
	ID_autora varchar (5) NOT NULL,
	PRIMARY KEY (ID_ksi��ki),
	FOREIGN KEY (ID_autora) REFERENCES Autorzy(ID_autora) ON DELETE NO ACTION,
	CHECK (Gatunek IN ('Horror', 'Krymina�','Romans','Thriller','Fantastyka','Science Fiction','Przygodowa'))
);

CREATE TABLE Wydania ( 
	ISBN_ksi��ki varchar (13) NOT NULL,
	Numer_wydania int NOT NULL,
	Data_wydania date NOT NULL,
	Liczba_stron int NOT NULL,
	ID_ksi��ki varchar (5) NOT NULL,
	Nazwa_wydawnictwa varchar (40) NOT NULL,
	FOREIGN KEY (ID_ksi��ki) REFERENCES Ksi��ki(ID_ksi��ki) ON DELETE CASCADE,
	FOREIGN KEY (Nazwa_wydawnictwa) REFERENCES Wydawnictwa(Nazwa) ON DELETE NO ACTION ON UPDATE CASCADE,
	PRIMARY KEY (ISBN_ksi��ki),
	CONSTRAINT SprawdzanieNaturalnych CHECK (Liczba_stron > 0 AND Numer_wydania > 0)
);

CREATE TABLE Opinie ( 
	ID_opini varchar (5) NOT NULL,
	Ocena int NOT NULL,
	Komentarz varchar(500),
	Data_opini date NOT NULL,
	ID_ksi��ki varchar (5) NOT NULL,
	ID_klienta varchar (5) NOT NULL,
	PRIMARY KEY (ID_opini),
	FOREIGN KEY (ID_ksi��ki) REFERENCES Ksi��ki(ID_ksi��ki) ON DELETE CASCADE,
	FOREIGN KEY (ID_klienta) REFERENCES Klienci(ID_klienta) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK (Ocena BETWEEN 0 and 6)
);

CREATE TABLE Cz�ci_zam�wie� ( 
	ID_zam�wienia varchar (5) NOT NULL,
	ISBN_ksi��ki varchar (13) NOT NULL,
	Ilo�� int NOT NULL,
	PRIMARY KEY (ID_zam�wienia, ISBN_ksi��ki),
	FOREIGN KEY (ID_zam�wienia) REFERENCES Zam�wienia(ID_zam�wienia) ON DELETE CASCADE,
	FOREIGN KEY (ISBN_ksi��ki) REFERENCES Wydania(ISBN_ksi��ki)  ON DELETE CASCADE,
	CHECK (Ilo�� > 0)
);

CREATE TABLE Tabela ( 
	ID_tabeli varchar (5) NOT NULL,
	ID_zam�wienia varchar (5) NOT NULL,
	ISBN_ksi��ki varchar (13) NOT NULL,
	PRIMARY KEY (ID_tabeli),
	FOREIGN KEY (ID_zam�wienia, ISBN_ksi��ki) REFERENCES Cz�ci_zam�wie�(ID_zam�wienia, ISBN_ksi��ki) ON DELETE CASCADE
);
