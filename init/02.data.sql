--Carica i dati

-- Abilita l'importazione da CSV
SET GLOBAL local_infile=1;

-- Carica i dati da file CSV
-- Regione
LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE Regione
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(codice_regione, regione);

-- ASL
LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE ASL
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(codice_asl, denominazione_asl, indirizzo_asl, comune_asl, cap_asl, sigla_provincia_asl);

-- Popolazione
LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE Popolazione
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(residenti_età_infantile, residenti_età_adulta, residenti_anziani, residenti_totale);

-- Popolazione
LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE Servizio
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(residenti_età_infantile, residenti_età_adulta, residenti_anziani, residenti_totale);

-- Servizio
INSERT INTO Servizio
VALUES (1, "Centro Unificato di Prenotazione Tipo 1")

INSERT INTO Servizio
VALUES (2, "Centro Unificato di Prenotazione Tipo 2")

INSERT INTO Servizio
VALUES (3, "Dipartimento di Prevenzione")

INSERT INTO Servizio
VALUES (4, "Dipartimento Materno-Infantile")

INSERT INTO Servizio
VALUES (5, "Dipartimento di Salute Mentale")

INSERT INTO Servizio
VALUES (6, "Servizio Trasporto per Centro Dialisi")

INSERT INTO Servizio
VALUES (7, "Servizio di Assistenza Domiciliare Integrata")

INSERT INTO Servizio
VALUES (8, "Unità Mobile di Rianimazione")

INSERT INTO Servizio
VALUES (9, "Ambulanze Trasporto Emergenza Neonato")

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


Anno di Riferimento
Totale medici
Medici con indennità per attività in forma associativa
Totale scelte per classe di scelte
Totale pediatri
Pediatri con indennità per attività in forma associativa
Totale scelte per classe di scelte dei pediatri
Ambulatori e Laboratori
Ambulatori e Laboratori convenzionati
Numero medio punti di guardia medica
Numero medio medici titolari
Ore totali guardia medica
Numero ricette di specialità medicinali e galenici
EURO Importo ricette di specialità medicinali e galenici
Assistenza Domiciliare Integrata Casi Trattati
Assistenza Domiciliare Integrata Casi Trattati Anziani
Assistenza Domiciliare Integrata Casi Trattati Pazienti Terminali
