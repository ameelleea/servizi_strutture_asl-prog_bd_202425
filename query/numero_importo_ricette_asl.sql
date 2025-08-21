SELECT
    A.NomeASL,
    SUM(Pres.NumeroRicette) AS RicetteTotali,
    SUM(Pres.ImportoR) AS ImportoTotalePrescrizioni
FROM
    Prescrizioni AS Pres
JOIN
    ASL AS A ON Pres.CodAsl = A.CodAsl AND Pres.CAP = A.CAP
WHERE
    Pres.AnnoR = 2022
GROUP BY
    A.NomeASL
ORDER BY
    ImportoTotalePrescrizioni DESC;
