CREATE TABLE Regione (
    CodR INT PRIMARY KEY,
    Nome VARCHAR(20) NOT NULL
);

CREATE TABLE Provincia (
    siglaP CHAR(2) PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,
    codR INT NOT NULL,
    FOREIGN KEY (codR) REFERENCES Regione(CodR)
);

CREATE TABLE Comune (
    siglaP VARCHAR(2) NOT NULL,
    CAP INT PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,
    FOREIGN KEY (siglaP) REFERENCES Provincia(siglaP)
);

CREATE TABLE ASL (
    CodAsl INT,
    CAP INT,
    NomeASL VARCHAR(100) NOT NULL,
    Indirizzo VARCHAR(100) NOT NULL,
    PRIMARY KEY (CodAsl, CAP)
);

CREATE TABLE Popolazione (
    CodAsl INT,
    CAP INT,
    AnnoR INT,
    RTotali INT,
    RAdulti INT,
    RInfanzia INT,
    RAnziani INT,
    PRIMARY KEY (CodAsl, CAP, AnnoR)
    FOREIGN KEY (CodAsl, CAP) REFERENCES ASL(CodAsl, CAP)
);

CREATE TABLE Prescrizioni (
    CodAsl INT,
    CAP INT,
    AnnoR INT,
    NumeroRicette INT,
    ImportoR INT,
    PRIMARY KEY (CodAsl, CAP, AnnoR),
    FOREIGN KEY (CodAsl, CAP) REFERENCES ASL(CodAsl, CAP)
);

CREATE TABLE Personale(
    CodAsl INT,
    CAP INT,
    AnnoR INT NOT NULL,
    TipoMedico VARCHAR(50) NOT NULL,
    Numero INT,
    PRIMARY KEY (CodAsl, CAP, AnnoR),
    FOREIGN KEY (CodAsl, CAP) REFERENCES ASL(CodAsl, CAP)
);

CREATE TABLE Strutture(
    CodAsl INT,
    CAP INT,
    AnnoR INT NOT NULL,
    TipoStruttura VARCHAR(50) NOT NULL,
    Quantità INT,
    PRIMARY KEY (CodAsl, CAP, AnnoR),
    FOREIGN KEY (CodAsl, CAP) REFERENCES ASL(CodAsl, CAP)
);

CREATE TABLE Servizi(
    CodAsl INT,
    CAP INT,
    AnnoR INT NOT NULL,
    TipoServizio VARCHAR(50) NOT NULL, 
    Quantità INT,
    PRIMARY KEY (CodAsl, CAP, AnnoR),
    FOREIGN KEY (CodAsl, CAP) REFERENCES ASL(CodAsl, CAP)
);

CREATE TABLE TipoStruttura(
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE TipoMedico(
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE TipoServizio(
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);


