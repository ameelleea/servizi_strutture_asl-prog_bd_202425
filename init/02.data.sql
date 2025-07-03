-- Abilita l'importazione da CSV
SET GLOBAL local_infile=1;


-- Carica i dati da file CSV
-- Regione
LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE Regione
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @csv_codice_regione,     
    @csv_regione,
)
SET
    CodR = @csv_codice_regione, 
    CAP = @csv_regione;

-- Provincia
LOAD DATA INFILE '/docker-entrypoint-initdb.d/province_italiane.csv'
INTO TABLE Provincia
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @csv_Sigla,     
    @csv_Provincia,
)
SET
    siglaP = @csv_Sigla, 
    nome = @csv_Provincia;

LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE Provincia
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @csv_Sigla,     
    @csv_Provincia,
)
SET
    siglaP = @csv_Sigla, 
    nome = @csv_Provincia;

-- Comune
LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE Comune
FIELDS TERMINATED BY ';'      
ENCLOSED BY '"'               
LINES TERMINATED BY '\n'      
IGNORE 1 ROWS                 
(
    @csv_sigla_provincia_asl,     
    @csv_cap_asl,
    @csv_comune_asl
)
SET
    siglaP = @csv_sigla_provincia_asl, 
    CAP = @csv_cap_asl,
    nome = @csv_comune_asl;

-- ASL
LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE ASL
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @csv_codice_asl,     
    @csv_cap_asl,
    @csv_denominazione_asl
    @csv_indirizzo_asl
)
SET
   CodAsl = @csv_codice_asl,     
   CAP = @csv_cap_asl,
   NomeASL = @csv_denominazione_asl
   Indirizzo = @csv_indirizzo_asl;

-- Popolazione
LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE Popolazione
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @csv_anno_riferimento
    @csv_codice_asl
    @csv_cap_asl
    @csv_residenti_età_infantile
    @csv_residenti_età_adulta
    @csv_residenti_anziani
)
SET
    CodAsl = @csv_codice_asl,
    CAP = @csv_cap_asl,
    AnnoR = @csv_anno_riferimento,
    RAdulti = @csv_residenti_età_adulta,
    RInfanzia = @csv_residenti_età_infantile,
    RAnziani = @csv_residenti_anziani;

--Prescrizioni
LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE Prescrizioni
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @csv_anno_riferimento
    @csv_codice_asl
    @csv_cap_asl
    @csv_numero_ricette
    @csv_importo_ricette_euro
)
SET
    CodAsl = @csv_codice_asl,
    CAP = @csv_cap_asl,
    AnnoR = @csv_anno_riferimento,
    NumeroRicette = @csv_numero_ricette
    ImportoR = @csv_importo_ricette_euro;

--Tipi strutture
INSERT INTO TipoStruttura (id, nome) VALUES
(1, "Centro Unificato di Prenotazione Tipo 1"),
(2, "Centro Unificato di Prenotazione Tipo 2"),
(3, "Dipartimento di Prevenzione"),
(4, "Dipartimento Materno-Infantile"),
(5, "Dipartimento di Salute Mentale"),
(6, "Ambulatori e Laboratori"),
(7, "Ambulatori e Laboratori convenzionati");

-- Tipi Servizi
INSERT INTO TipoServizio (id, nome) VALUES
(1, "Servizio Trasporto per Centro Dialisi"),
(2, "Servizio di Assistenza Domiciliare Integrata"),
(3, "Unità Mobile di Rianimazione"),
(4, "Ambulanze Trasporto Emergenza Neonato"),
(5, "Assistenza Domiciliare Integrata Casi Trattati"),
(6, "Assistenza Domiciliare Integrata Casi Trattati Anziani"),
(7, "Assistenza Domiciliare Integrata Casi Trattati Pazienti Terminali");

-- Tipi medici
INSERT INTO TipoMedico (id, nome) VALUES
(1, "Medici"),
(2, "Medici con indennità per attività in forma associativa"),
(3, "Totale scelte per classe di scelte"),
(4, "Pediatri"),
(5, "Pediatri con indennità per attività in forma associativa"),
(6, "Totale scelte per classe di scelte dei pediatri");

-- Popolazione strutture
CREATE TEMPORARY TABLE TempRawStrutture (
    AnnoR INT NOT NULL,
    CodAsl INT NOT NULL, 
    CAP INT NOT NULL,           
    cup_tipo_1 INT,
    cup_tipo_2 INT,
    dipartimento_prevenzione INT,
    dipartimento_materno_infantile INT,
    dipartimento_salute_mentale INT,
    ambulatori_laboratori INT,
    ambulatori_laboratori_convenzionati INT
);

LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE TempRawStrutture
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    AnnoR,
    CodAsl,
    CAP,
    cup_tipo_1,
    cup_tipo_2,
    dipartimento_prevenzione,
    dipartimento_materno_infantile,
    dipartimento_salute_mentale,
    ambulatori_laboratori,
    ambulatori_laboratori_convenzionati
);

INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.cup_tipo_1
FROM
    TempRawStrutture AS TRS
JOIN
    TipoStruttura AS TS ON TS.Nome = 'cup_tipo_1'
WHERE
    TRS.cup_tipo_1 IS NOT NULL AND TRS.cup_tipo_1 >= 0 -- Inserisci solo se la quantità è valida
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.cup_tipo_2
FROM
    TempRawStrutture AS TRS
JOIN
    TipoStruttura AS TS ON TS.Nome = 'cup_tipo_2'
WHERE
    TRS.cup_tipo_2 IS NOT NULL AND TRS.cup_tipo_2 >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.dipartimento_prevenzione
FROM
    TempRawStrutture AS TRS
JOIN
    TipoStruttura AS TS ON TS.Nome = 'dipartimento_prevenzione'
WHERE
    TRS.dipartimento_prevenzione IS NOT NULL AND TRS.dipartimento_prevenzione >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.dipartimento_materno_infantile
FROM
    TempRawStrutture AS TRS
JOIN
    TipoStruttura AS TS ON TS.Nome = 'dipartimento_materno_infantile'
WHERE
    TRS.dipartimento_materno_infantile IS NOT NULL AND TRS.dipartimento_materno_infantile >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.dipartimento_salute_mentale
FROM
    TempRawStrutture AS TRS
JOIN
    TipoStruttura AS TS ON TS.Nome = 'dipartimento_salute_mentale'
WHERE
    TRS.dipartimento_salute_mentale IS NOT NULL AND TRS.dipartimento_salute_mentale >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.ambulatori_laboratori
FROM
    TempRawStrutture AS TRS
JOIN
    TipoStruttura AS TS ON TS.Nome = 'ambulatori_laboratori'
WHERE
    TRS.ambulatori_laboratori IS NOT NULL AND TRS.ambulatori_laboratori >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.ambulatori_laboratori_convenzionati
FROM
    TempRawStrutture AS TRS
JOIN
    TipoStruttura AS TS ON TS.Nome = 'ambulatori_laboratori_convenzionati'
WHERE
    TRS.ambulatori_laboratori_convenzionati IS NOT NULL AND TRS.ambulatori_laboratori_convenzionati >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

DROP TEMPORARY TABLE TempRawStrutture;

-- Popolazione personale
CREATE TEMPORARY TABLE TempRawPersonale (
    AnnoR INT NOT NULL,
    CodAsl INT NOT NULL, 
    CAP INT NOT NULL,           
    medici INT,
    pedici_indennità_associativa INT,
    totale_scelte INT,
    pediatri INT,
    pediatri_indennità_associativa INT,
    totale_scelte_dei pediatri INT
);

LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE TempRawPersonale
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    AnnoR,
    CodAsl,
    CAP,
    medici
    medici_indennità_associativa
    totale_scelte
    pediatri
    pediatri_indennità_associativa
    totale_scelte_dei pediatri
);

INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Numero)
SELECT
    TRP.CodAsl,
    TRP.CAP,
    TRP.AnnoR,
    TM.Id,
    TRP.medici
FROM
    TempRawPersonale AS TRP
JOIN
    TipoMedico AS TM ON TM.Nome = 'medici'
WHERE
    TRP.medici IS NOT NULL AND TRP.medici >= 0 -- Inserisci solo se la Numero è valida
ON DUPLICATE KEY UPDATE
    Numero = VALUES(Numero);

INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Numero)
SELECT
    TRP.CodAsl,
    TRP.CAP,
    TRP.AnnoR,
    TM.Id,
    TRP.medici_indennità_associativa
FROM
    TempRawPersonale AS TRP
JOIN
    TipoMedico AS TM ON TM.Nome = 'medici_indennità_associativa'
WHERE
    TRP.medici_indennità_associativa IS NOT NULL AND TRP.medici_indennità_associativa >= 0
ON DUPLICATE KEY UPDATE
    Numero = VALUES(Numero);

INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Numero)
SELECT
    TRP.CodAsl,
    TRP.CAP,
    TRP.AnnoR,
    TM.Id,
    TRP.totale_scelte
FROM
    TempRawPersonale AS TRP
JOIN
    TipoMedico AS TM ON TM.Nome = 'totale_scelte'
WHERE
    TRP.totale_scelte IS NOT NULL AND TRP.totale_scelte >= 0
ON DUPLICATE KEY UPDATE
    Numero = VALUES(Numero);

INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Numero)
SELECT
    TRP.CodAsl,
    TRP.CAP,
    TRP.AnnoR,
    TM.Id,
    TRP.pediatri
FROM
    TempRawPersonale AS TRP
JOIN
    TipoMedico AS TM ON TM.Nome = 'pediatri'
WHERE
    TRP.pediatri IS NOT NULL AND TRP.pediatri >= 0
ON DUPLICATE KEY UPDATE
    Numero = VALUES(Numero);

INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Numero)
SELECT
    TRP.CodAsl,
    TRP.CAP,
    TRP.AnnoR,
    TM.Id,
    TRP.pediatri_indennità_associativa
FROM
    TempRawPersonale AS TRP
JOIN
    TipoMedico AS TM ON TM.Nome = 'pediatri_indennità_associativa'
WHERE
    TRP.pediatri_indennità_associativa IS NOT NULL AND TRP.pediatri_indennità_associativa >= 0
ON DUPLICATE KEY UPDATE
    Numero = VALUES(Numero);

INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Numero)
SELECT
    TRP.CodAsl,
    TRP.CAP,
    TRP.AnnoR,
    TM.Id,
    TRP.totale_scelte_dei pediatri
FROM
    TempRawPersonale AS TRP
JOIN
    TipoMedico AS TM ON TM.Nome = 'totale_scelte_dei pediatri'
WHERE
    TRP.totale_scelte_dei pediatri IS NOT NULL AND TRP.totale_scelte_dei pediatri >= 0
ON DUPLICATE KEY UPDATE
    Numero = VALUES(Numero);

DROP TEMPORARY TABLE TempRawPersonale;

-- Popolazione servizi
CREATE TEMPORARY TABLE TempRawServizi (
    AnnoR INT NOT NULL,
    CodAsl INT NOT NULL, 
    CAP INT NOT NULL,           
    servizio_trasporto_dialisi INT,
    servizio_adi INT,
    unità_mobile_rianimazione INT,
    ambulanze_emergenza_neonato INT,
    ADI_casi_trattati INT,
    ADI_casi_trattati_Anziani INT,
    ADI_casi_trattati_Pazienti_Terminali INT
);

LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
INTO TABLE TempRawServizi
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    AnnoR,
    CodAsl,
    CAP,
    servizio_trasporto_dialisi
    servizio_adi
    unità_mobile_rianimazione
    ambulanze_emergenza_neonato
    ADI_casi_trattati
    ADI_casi_trattati_Anziani
    ADI_casi_trattati_Pazienti_Terminali
);

INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.servizio_trasporto_dialisi
FROM
    TempRawServizi AS TRS
JOIN
    TipoServizio AS TS ON TS.Nome = 'servizio_trasporto_dialisi'
WHERE
    TRS.servizio_trasporto_dialisi IS NOT NULL AND TRS.servizio_trasporto_dialisi >= 0 -- Inserisci solo se la Quantità è valida
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.servizio_adi
FROM
    TempRawServizi AS TRS
JOIN
    TipoServizio AS TS ON TS.Nome = 'servizio_adi'
WHERE
    TRS.servizio_adi IS NOT NULL AND TRS.servizio_adi >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.unità_mobile_rianimazione
FROM
    TempRawServizi AS TRS
JOIN
    TipoServizio AS TS ON TS.Nome = 'unità_mobile_rianimazione'
WHERE
    TRS.unità_mobile_rianimazione IS NOT NULL AND TRS.unità_mobile_rianimazione >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.ambulanze_emergenza_neonato
FROM
    TempRawServizi AS TRS
JOIN
    TipoServizio AS TS ON TS.Nome = 'ambulanze_emergenza_neonato'
WHERE
    TRS.ambulanze_emergenza_neonato IS NOT NULL AND TRS.ambulanze_emergenza_neonato >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.ADI_casi_trattati
FROM
    TempRawServizi AS TRS
JOIN
    TipoServizio AS TS ON TS.Nome = 'ADI_casi_trattati'
WHERE
    TRS.ADI_casi_trattati IS NOT NULL AND TRS.ADI_casi_trattati >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.ADI_casi_trattati_Anziani
FROM
    TempRawServizi AS TRS
JOIN
    TipoServizio AS TS ON TS.Nome = 'ADI_casi_trattati_Anziani'
WHERE
    TRS.ADI_casi_trattati_Anziani IS NOT NULL AND TRS.ADI_casi_trattati_Anziani >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantità)
SELECT
    TRS.CodAsl,
    TRS.CAP,
    TRS.AnnoR,
    TS.Id,
    TRS.ADI_casi_trattati_Pazienti_Terminali
FROM
    TempRawServizi AS TRS
JOIN
    TipoServizio AS TS ON TS.Nome = 'ADI_casi_trattati_Pazienti_Terminali'
WHERE
    TRS.ADI_casi_trattati_Pazienti_Terminali IS NOT NULL AND TRS.ADI_casi_trattati_Pazienti_Terminali >= 0
ON DUPLICATE KEY UPDATE
    Quantità = VALUES(Quantità);

DROP TEMPORARY TABLE TempRawServizi;