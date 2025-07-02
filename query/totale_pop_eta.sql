SELECT
    A.NomeASL,
    SUM(Pop.RAdulti) AS TotaleAdulti,
    SUM(Pop.RInfanzia) AS TotaleInfanzia,
    SUM(Pop.RAnziani) AS TotaleAnziani,
    SUM(Pop.RTotali) AS TotalePopolazione
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