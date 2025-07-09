SELECT
    S.Quantita,
    TS.Nome AS TipoStruttura,
    A.NomeASL,
    C.Nome AS ComuneASL,
    P.Nome AS ProvinciaASL,
    R.Nome AS RegioneASL
FROM
    Strutture AS S
JOIN
    TipoStruttura AS TS ON S.TipoStruttura = TS.Id
JOIN
    ASL AS A ON S.CodAsl = A.CodAsl AND S.CAP = A.CAP
JOIN
    Comune AS C ON A.CAP = C.CAP
JOIN
    Provincia AS P ON C.SiglaP = P.SiglaP
JOIN
    Regione AS R ON P.CodR = R.CodR
WHERE
    TS.Nome = 'Dipartimento di Salute Mentale' AND R.Nome LIKE '%lombardia%' AND S.AnnoR = 2022;

