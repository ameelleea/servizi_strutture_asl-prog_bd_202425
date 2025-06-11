--Crea lo schema

-- REGIONE
CREATE TABLE IF NOT EXISTS Regione (
    codice_regione INT PRIMARY KEY,
    nome VARCHAR(100)
);

-- ASL
CREATE TABLE IF NOT EXISTS ASL (
    codice_asl INT PRIMARY KEY,
    denominazione VARCHAR(50),
    indirizzo VARCHAR(100),
    comune VARCHAR(50),
    cap VARCHAR(10),
    sigla_provincia VARCHAR(5),
    codice_regione INT,
    FOREIGN KEY (codice_regione) REFERENCES Regione(codice_regione)
);

-- POPOLAZIONE
CREATE TABLE IF NOT EXISTS Popolazione (
    codice_asl INT PRIMARY KEY,
    eta_infantile INT,
    eta_adulta INT,
    anziani INT,
    totale INT,
    FOREIGN KEY (codice_asl) REFERENCES ASL(codice_asl)
);

-- SERVIZI
CREATE TABLE IF NOT EXISTS Servizio (
    id_servizio INT PRIMARY KEY,
    nome VARCHAR(100)
);

-- ATTIVITÀ
CREATE TABLE IF NOT EXISTS Attivita (
    codice_asl INT,
    id_servizio INT,
    anno INT,
    quantita DECIMAL,
    PRIMARY KEY (codice_asl, id_servizio, anno),
    FOREIGN KEY (codice_asl) REFERENCES ASL(codice_asl),
    FOREIGN KEY (id_servizio) REFERENCES Servizio(id_servizio)
);
