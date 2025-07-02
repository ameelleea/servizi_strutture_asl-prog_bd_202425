CREATE TABLE IF NOT EXISTS Regione (
    CodR INT PRIMARY KEY,
    Nome VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS Provincia (
    siglaP CHAR(2) PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,
    codR INT NOT NULL,
    FOREIGN KEY (codR) REFERENCES Regione(CodR)
);

CREATE TABLE IF NOT EXISTS Comune (
    siglaP VARCHAR(2) NOT NULL,
    CAP INT PRIMARY KEY,
    nome VARCHAR(20) NOT NULL,
    FOREIGN KEY (siglaP) REFERENCES Provincia(siglaP)
);

CREATE TABLE IF NOT EXISTS ASL (
    CodAsl INT,
    CAP INT,
    NomeASL VARCHAR(100) NOT NULL,
    Indirizzo VARCHAR(100) NOT NULL,
    PRIMARY KEY (CodAsl, CAP)
);

CREATE TABLE IF NOT EXISTS Popolazione (
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

CREATE TABLE IF NOT EXISTS Prescrizioni (
    CodAsl INT,
    CAP INT,
    AnnoR INT,
    NumeroRicette INT,
    ImportoR INT,
    PRIMARY KEY (CodAsl, CAP, AnnoR),
    FOREIGN KEY (CodAsl, CAP) REFERENCES ASL(CodAsl, CAP)
);

CREATE TABLE IF NOT EXISTS Personale(
    CodAsl INT,
    CAP INT,
    AnnoR INT NOT NULL,
    TipoMedico VARCHAR(50) NOT NULL,
    Numero INT,
    PRIMARY KEY (CodAsl, CAP, AnnoR),
    FOREIGN KEY (CodAsl, CAP) REFERENCES ASL(CodAsl, CAP),
    FOREIGN KEY (TipoMedico) REFERENCES TipoMedico(Id)
);

CREATE TABLE IF NOT EXISTS Strutture(
    CodAsl INT,
    CAP INT,
    AnnoR INT NOT NULL,
    TipoStruttura VARCHAR(50) NOT NULL,
    Quantità INT,
    PRIMARY KEY (CodAsl, CAP, AnnoR),
    FOREIGN KEY (CodAsl, CAP) REFERENCES ASL(CodAsl, CAP),
    FOREIGN KEY (TipoStruttura) REFERENCES TipoStruttura(Id)
);

CREATE TABLE IF NOT EXISTS Servizi(
    CodAsl INT,
    CAP INT,
    AnnoR INT NOT NULL,
    TipoServizio VARCHAR(50) NOT NULL, 
    Quantità INT,
    PRIMARY KEY (CodAsl, CAP, AnnoR),
    FOREIGN KEY (CodAsl, CAP) REFERENCES ASL(CodAsl, CAP),
    FOREIGN KEY (TipoServizio) REFERENCES TipoServizio(Id)
);

CREATE TABLE IF NOT EXISTS TipoStruttura(
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS TipoMedico(
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS TipoServizio(
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);
