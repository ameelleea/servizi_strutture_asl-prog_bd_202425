-- Abilita l'importazione da CSV
SET GLOBAL local_infile=1;

-- Preprocessamento CSV
CREATE TABLE RawCSVData (
    anno_riferimento VARCHAR(255),
    codice_regione VARCHAR(255),
    codice_asl VARCHAR(255),
    regione VARCHAR(255),
    denominazione_asl VARCHAR(255),
    indirizzo_asl VARCHAR(255),
    cap_asl VARCHAR(255),
    comune_asl VARCHAR(255),
    sigla_provincia_asl VARCHAR(255),
    `residenti_età_infantile` VARCHAR(255), 
    `residenti_età_adulta` VARCHAR(255),    
    `residenti_anziani` VARCHAR(255),       
    `residenti_totale` VARCHAR(255),        
    cup_tipo_1 VARCHAR(255),
    cup_tipo_2 VARCHAR(255),
    dipartimento_prevenzione VARCHAR(255),
    dipartimento_materno_infantile VARCHAR(255),
    dipartimento_salute_mentale VARCHAR(255),
    servizio_trasporto_dialisi VARCHAR(255),
    servizio_adi VARCHAR(255),
    `unità_mobile_rianimazione` VARCHAR(255), 
    `ambulanze_emergenza_neonato` VARCHAR(255), 
    medici VARCHAR(255),
    `pedici_indennità_associativa` VARCHAR(255), 
    `totale_scelte` VARCHAR(255),             
    pediatri VARCHAR(255),
    `pediatri_indennità_associativa` VARCHAR(255), 
    `totale_scelte_dei pediatri` VARCHAR(255),
    ambulatori_laboratori VARCHAR(255),
    ambulatori_laboratori_convenzionati VARCHAR(255),
    numero_ricette VARCHAR(255),
    `importo_ricette_euro` VARCHAR(255),      
    `ADI_casi_trattati` VARCHAR(255),         
    `ADI_casi_trattati_Anziani` VARCHAR(255), 
    `ADI_casi_trattati_Pazienti_Terminali` VARCHAR(255) 
);

LOAD DATA INFILE '/docker-entrypoint-initdb.d/Strutture_e_attività_ASL.csv'
IGNORE
INTO TABLE RawCSVData
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Regione
INSERT INTO Regione (CodR, Nome)
SELECT
    CAST(NULLIF(TRIM(codice_regione), '') AS UNSIGNED) AS CodR_Converted,
    regione
FROM
    RawCSVData
WHERE
    TRIM(codice_regione) IS NOT NULL           
    AND TRIM(codice_regione) != ''             
    AND TRIM(codice_regione) REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE
    Nome = VALUES(Nome);

-- Provincia
CREATE TEMPORARY TABLE TempProvinceNomi (
    siglaP CHAR(2) PRIMARY KEY,
    nome VARCHAR(20) NOT NULL
);

LOAD DATA INFILE '/docker-entrypoint-initdb.d/province_italiane.csv'
IGNORE
INTO TABLE TempProvinceNomi
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @csv_Provincia, 
    @csv_Sigla   
)
SET
    siglaP = @csv_Sigla,
    nome = @csv_Provincia;

INSERT INTO Provincia (siglaP, nome, codR)
SELECT DISTINCT T1.sigla_provincia_asl, T2.nome, T1.codice_regione
FROM RawCSVData AS T1
JOIN TempProvinceNomi AS T2 ON T1.sigla_provincia_asl = T2.SiglaP
ON DUPLICATE KEY UPDATE nome = VALUES(nome), codR = VALUES(codR);

DROP TEMPORARY TABLE TempProvinceNomi;

-- Comune
INSERT INTO Comune (siglaP, CAP, nome)
SELECT DISTINCT T1.sigla_provincia_asl, T1.cap_asl, T1.comune_asl
FROM RawCSVData AS T1
WHERE
    TRIM(cap_asl) IS NOT NULL           
    AND TRIM(cap_asl) != ''             
    AND TRIM(cap_asl) REGEXP '^[0-9]+$';

-- ASL
INSERT INTO ASL (CodAsl, CAP, NomeAsl, Indirizzo)
SELECT DISTINCT T1.codice_asl, T1.cap_asl, T1.denominazione_asl, T1.indirizzo_asl
FROM RawCSVData AS T1
WHERE
    TRIM(cap_asl) IS NOT NULL           
    AND TRIM(cap_asl) != ''             
    AND TRIM(cap_asl) REGEXP '^[0-9]+$'
    AND TRIM(codice_asl) IS NOT NULL           
    AND TRIM(codice_asl) != ''             
    AND TRIM(codice_asl) REGEXP '^[0-9]+$';

-- Popolazione
INSERT INTO Popolazione (CodAsl, CAP, AnnoR, RAdulti, RInfanzia, RAnziani)
SELECT DISTINCT  R.codice_asl, R.cap_asl, R.anno_riferimento, R.`residenti_età_adulta`, R.`residenti_età_infantile`, R.`residenti_anziani` 
FROM RawCSVData AS R
WHERE
    TRIM(cap_asl) IS NOT NULL           
    AND TRIM(cap_asl) != ''             
    AND TRIM(cap_asl) REGEXP '^[0-9]+$'
    AND TRIM(codice_asl) IS NOT NULL           
    AND TRIM(codice_asl) != ''             
    AND TRIM(codice_asl) REGEXP '^[0-9]+$';

-- Prescrizioni
INSERT INTO Prescrizioni (CodAsl, CAP, AnnoR, NumeroRicette, ImportoR)
SELECT DISTINCT R.codice_asl, R.cap_asl, R.anno_riferimento, R.numero_ricette, R.importo_ricette_euro
FROM RawCSVData AS R
WHERE
    TRIM(cap_asl) IS NOT NULL           
    AND TRIM(cap_asl) != ''             
    AND TRIM(cap_asl) REGEXP '^[0-9]+$'
    AND TRIM(codice_asl) IS NOT NULL           
    AND TRIM(codice_asl) != ''             
    AND TRIM(codice_asl) REGEXP '^[0-9]+$';

-- Tipi strutture
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
-- Inserimento per cup_tipo_1
INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.cup_tipo_1
FROM RawCSVData AS R
JOIN TipoStruttura AS TS ON TS.nome = 'Centro Unificato di Prenotazione Tipo 1'
WHERE R.cup_tipo_1 IS NOT NULL AND R.cup_tipo_1 != '' AND R.cup_tipo_1 REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per cup_tipo_2
INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.cup_tipo_2
FROM RawCSVData AS R
JOIN TipoStruttura AS TS ON TS.nome = 'Centro Unificato di Prenotazione Tipo 2'
WHERE R.cup_tipo_2 IS NOT NULL AND R.cup_tipo_2 != '' AND R.cup_tipo_2 REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per dipartimento_prevenzione
INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.dipartimento_prevenzione
FROM RawCSVData AS R
JOIN TipoStruttura AS TS ON TS.nome = 'Dipartimento di Prevenzione'
WHERE R.dipartimento_prevenzione IS NOT NULL AND R.dipartimento_prevenzione != '' AND R.dipartimento_prevenzione REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per dipartimento_materno_infantile
INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.dipartimento_materno_infantile
FROM RawCSVData AS R
JOIN TipoStruttura AS TS ON TS.nome = 'Dipartimento Materno-Infantile'
WHERE R.dipartimento_materno_infantile IS NOT NULL AND R.dipartimento_materno_infantile != '' AND R.dipartimento_materno_infantile REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per dipartimento_salute_mentale
INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.dipartimento_salute_mentale
FROM RawCSVData AS R
JOIN TipoStruttura AS TS ON TS.nome = 'Dipartimento di Salute Mentale'
WHERE R.dipartimento_salute_mentale IS NOT NULL AND R.dipartimento_salute_mentale != '' AND R.dipartimento_salute_mentale REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per ambulatori_laboratori
INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.ambulatori_laboratori
FROM RawCSVData AS R
JOIN TipoStruttura AS TS ON TS.nome = 'Ambulatori e Laboratori'
WHERE R.ambulatori_laboratori IS NOT NULL AND R.ambulatori_laboratori != '' AND R.ambulatori_laboratori REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per ambulatori_laboratori_convenzionati
INSERT INTO Strutture (CodAsl, CAP, AnnoR, TipoStruttura, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.ambulatori_laboratori_convenzionati
FROM RawCSVData AS R
JOIN TipoStruttura AS TS ON TS.nome = 'Ambulatori e Laboratori convenzionati'
WHERE R.ambulatori_laboratori_convenzionati IS NOT NULL AND R.ambulatori_laboratori_convenzionati != '' AND R.ambulatori_laboratori_convenzionati REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);

-- Popolazione personale
-- Inserimento per medici (Medici)
INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TM.id, R.`medici`
FROM RawCSVData AS R
JOIN TipoMedico AS TM ON TM.nome = 'Medici'
WHERE R.`medici` IS NOT NULL AND R.`medici` != '' AND R.`medici` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per pedici_indennità_associativa (Medici con indennità per attività in forma associativa)
INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TM.id, R.`pedici_indennità_associativa`
FROM RawCSVData AS R
JOIN TipoMedico AS TM ON TM.nome = 'Medici con indennità per attività in forma associativa'
WHERE R.`pedici_indennità_associativa` IS NOT NULL AND R.`pedici_indennità_associativa` != '' AND R.`pedici_indennità_associativa` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per totale_scelte (Totale scelte per classe di scelte)
INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TM.id, R.`totale_scelte`
FROM RawCSVData AS R
JOIN TipoMedico AS TM ON TM.nome = 'Totale scelte per classe di scelte'
WHERE R.`totale_scelte` IS NOT NULL AND R.`totale_scelte` != '' AND R.`totale_scelte` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per pediatri (Pediatri)
INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TM.id, R.`pediatri`
FROM RawCSVData AS R
JOIN TipoMedico AS TM ON TM.nome = 'Pediatri'
WHERE R.`pediatri` IS NOT NULL AND R.`pediatri` != '' AND R.`pediatri` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per pediatri_indennità_associativa (Pediatri con indennità per attività in forma associativa)
INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TM.id, R.`pediatri_indennità_associativa`
FROM RawCSVData AS R
JOIN TipoMedico AS TM ON TM.nome = 'Pediatri con indennità per attività in forma associativa'
WHERE R.`pediatri_indennità_associativa` IS NOT NULL AND R.`pediatri_indennità_associativa` != '' AND R.`pediatri_indennità_associativa` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per totale_scelte_dei pediatri (Totale scelte per classe di scelte dei pediatri)
INSERT INTO Personale (CodAsl, CAP, AnnoR, TipoMedico, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TM.id, R.`totale_scelte_dei pediatri`
FROM RawCSVData AS R
JOIN TipoMedico AS TM ON TM.nome = 'Totale scelte per classe di scelte dei pediatri'
WHERE R.`totale_scelte_dei pediatri` IS NOT NULL AND R.`totale_scelte_dei pediatri` != '' AND R.`totale_scelte_dei pediatri` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);

-- Popolazione servizi
-- Inserimento per servizio_trasporto_dialisi (Servizio Trasporto per Centro Dialisi)
INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.`servizio_trasporto_dialisi`
FROM RawCSVData AS R
JOIN TipoServizio AS TS ON TS.nome = 'Servizio Trasporto per Centro Dialisi'
WHERE R.`servizio_trasporto_dialisi` IS NOT NULL AND R.`servizio_trasporto_dialisi` != '' AND R.`servizio_trasporto_dialisi` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per servizio_adi (Servizio di Assistenza Domiciliare Integrata)
INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.`servizio_adi`
FROM RawCSVData AS R
JOIN TipoServizio AS TS ON TS.nome = 'Servizio di Assistenza Domiciliare Integrata'
WHERE R.`servizio_adi` IS NOT NULL AND R.`servizio_adi` != '' AND R.`servizio_adi` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per unità_mobile_rianimazione (Unità Mobile di Rianimazione)
INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.`unità_mobile_rianimazione`
FROM RawCSVData AS R
JOIN TipoServizio AS TS ON TS.nome = 'Unità Mobile di Rianimazione'
WHERE R.`unità_mobile_rianimazione` IS NOT NULL AND R.`unità_mobile_rianimazione` != '' AND R.`unità_mobile_rianimazione` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per ambulanze_emergenza_neonato (Ambulanze Trasporto Emergenza Neonato)
INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.`ambulanze_emergenza_neonato`
FROM RawCSVData AS R
JOIN TipoServizio AS TS ON TS.nome = 'Ambulanze Trasporto Emergenza Neonato'
WHERE R.`ambulanze_emergenza_neonato` IS NOT NULL AND R.`ambulanze_emergenza_neonato` != '' AND R.`ambulanze_emergenza_neonato` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per ADI_casi_trattati (Assistenza Domiciliare Integrata Casi Trattati)
INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.`ADI_casi_trattati`
FROM RawCSVData AS R
JOIN TipoServizio AS TS ON TS.nome = 'Assistenza Domiciliare Integrata Casi Trattati'
WHERE R.`ADI_casi_trattati` IS NOT NULL AND R.`ADI_casi_trattati` != '' AND R.`ADI_casi_trattati` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per ADI_casi_trattati_Anziani (Assistenza Domiciliare Integrata Casi Trattati Anziani)
INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.`ADI_casi_trattati_Anziani`
FROM RawCSVData AS R
JOIN TipoServizio AS TS ON TS.nome = 'Assistenza Domiciliare Integrata Casi Trattati Anziani'
WHERE R.`ADI_casi_trattati_Anziani` IS NOT NULL AND R.`ADI_casi_trattati_Anziani` != '' AND R.`ADI_casi_trattati_Anziani` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);


-- Inserimento per ADI_casi_trattati_Pazienti_Terminali (Assistenza Domiciliare Integrata Casi Trattati Pazienti Terminali)
INSERT INTO Servizi (CodAsl, CAP, AnnoR, TipoServizio, Quantita)
SELECT R.codice_asl, R.cap_asl, R.anno_riferimento, TS.id, R.`ADI_casi_trattati_Pazienti_Terminali`
FROM RawCSVData AS R
JOIN TipoServizio AS TS ON TS.nome = 'Assistenza Domiciliare Integrata Casi Trattati Pazienti Terminali'
WHERE R.`ADI_casi_trattati_Pazienti_Terminali` IS NOT NULL AND R.`ADI_casi_trattati_Pazienti_Terminali` != '' AND R.`ADI_casi_trattati_Pazienti_Terminali` REGEXP '^[0-9]+$'
ON DUPLICATE KEY UPDATE Quantita = VALUES(Quantita);

-- DROP TEMPORARY TABLE RawCSVData;