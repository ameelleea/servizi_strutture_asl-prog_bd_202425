SELECT
    C.Nome AS NomeComune,
    C.CAP,
    P.Nome AS NomeProvincia,
    P.SiglaP,
    R.Nome AS NomeRegione
FROM
    Comune AS C
JOIN
    Provincia AS P ON C.SiglaP = P.SiglaP
JOIN
    Regione AS R ON P.CodR = R.CodR
WHERE
    C.CAP = 40123; --Esempio, CAP di Bologna 