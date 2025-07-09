SELECT
    A.NomeASL,
    SUM(Pop.RAdulti + Pop.RInfanzia + Pop.RAnziani) AS TotalePopolazione
FROM
    Popolazione AS Pop
JOIN
    ASL AS A ON Pop.CodAsl = A.CodAsl AND Pop.CAP = A.CAP
WHERE
    Pop.AnnoR = 2022
GROUP BY
    A.NomeASL
ORDER BY
    A.NomeASL;
