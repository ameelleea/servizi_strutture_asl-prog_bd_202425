SELECT
    A.NomeASL,
    A.Indirizzo,
    C.Nome AS NomeComune
FROM
    ASL AS A
JOIN
    Comune AS C ON A.CAP = C.CAP
JOIN
    Provincia AS P ON C.SiglaP = P.SiglaP
WHERE
    P.SiglaP = @provincia;

