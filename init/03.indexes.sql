CREATE INDEX idx_strutture_anno ON Strutture(AnnoR);
CREATE INDEX idx_strutture_tipo ON Strutture(TipoStruttura);

CREATE INDEX idx_personale_anno ON Personale(AnnoR);
CREATE INDEX idx_personale_tipomedico ON Personale(TipoMedico);

CREATE INDEX idx_servizi_anno ON Servizi(AnnoR);
CREATE INDEX idx_servizi_tiposervizio ON Servizi(TipoServizio);

CREATE INDEX idx_prescrizioni_anno ON Prescrizioni(AnnoR);

CREATE INDEX idx_popolazione_anno ON Popolazione(AnnoR);

CREATE INDEX idx_asl_nome ON ASL(NomeASL);

CREATE INDEX idx_comune_siglap ON Comune(siglaP);
CREATE INDEX idx_provincia_codr ON Provincia(codR);
