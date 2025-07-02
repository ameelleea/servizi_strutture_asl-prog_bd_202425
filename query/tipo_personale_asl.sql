SELECT
    COUNT(DISTINCT P.CodAsl, P.CAP) AS NumeroASLConMediciBase
FROM
    Personale AS P
JOIN
    TipoMedico AS TM ON P.TipoMedico = TM.Id
WHERE
    TM.Nome = 'Medico di base' AND P.AnnoR = 2024;