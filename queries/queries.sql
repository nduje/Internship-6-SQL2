-- 1. Prikaži popis svih turnira
SELECT t.Name, t.Year, t.Location, tm.Name AS Winner
FROM Tournaments t
LEFT JOIN Teams tm ON tm.TeamId = t.WinnerTeamId;

-- 2. Prikaži sve timove koji sudjeluju na određenom turniru
SELECT te.Name, (p.FirstName || ' ' || p.LastName) AS Captain
FROM Standings s
JOIN Teams te ON te.TeamId = s.TeamId
LEFT JOIN Players p ON p.PlayerId = te.CaptainId
WHERE s.TournamentId = 1;

-- 3. Prikaži sve igrače iz određenog tima
SELECT (FirstName || ' ' || LastName) AS Name, DateOfBirth, JerseyNumber
FROM Players
WHERE TeamId = 1;

-- 4. Prikaži sve utakmice određenog turnira
SELECT m.MatchDate, m.MatchTime,
       t1.Name AS Team1, t2.Name AS Team2,
       mt.MatchType AS Phase,
       (m.Team1Score || ':' || m.Team2Score) AS Score
FROM Matches m
JOIN Teams t1 ON t1.TeamId = m.Team1Id
JOIN Teams t2 ON t2.TeamId = m.Team2Id
JOIN MatchTypes mt ON mt.MatchTypeId = m.MatchTypeId
WHERE m.TournamentId = 1
ORDER BY m.MatchDate;

-- 5. Prikaži sve utakmice određenog tima kroz sve turnire
SELECT
    m.MatchDate,
	m.MatchTime,
    t.Name AS Tournament,
    t1.Name AS Team1,
    t2.Name AS Team2,
    (m.Team1Score ||':' || m.Team2Score) AS Score,
    mt.MatchType AS Phase
FROM Matches m
JOIN MatchTypes mt ON mt.MatchTypeId = m.MatchTypeId
JOIN Tournaments t ON t.TournamentId = m.TournamentId
JOIN Teams t1 ON t1.TeamId = m.Team1Id
JOIN Teams t2 ON t2.TeamId = m.Team2Id
WHERE 1 IN (m.Team1Id, m.Team2Id)
ORDER BY m.MatchDate;

-- 6. Izlistati sve događaje (golovi, kartoni) za određenu utakmicu
SELECT e.Type, e.Minute, (p.FirstName || ' ' || p.LastName) AS Name
FROM Events e
JOIN Players p ON p.PlayerId = e.PlayerId
WHERE e.MatchId = 1
ORDER BY Minute;

-- 7. Prikaži sve igrače koji su dobili žuti ili crveni karton na cijelom turniru
SELECT
    (p.FirstName || ' ' || p.LastName) AS Name,
    te.Name AS Team,
    COUNT(*) AS Cards
FROM Events e
JOIN Players p ON p.PlayerId = e.PlayerId
JOIN Teams te ON te.TeamId = p.TeamId
JOIN Matches m ON m.MatchId = e.MatchId
JOIN Tournaments t ON t.TournamentId = m.TournamentId
WHERE e.Type IN ('Yellow', 'Red') AND t.TournamentId = 1
GROUP BY p.PlayerId, p.FirstName, p.LastName, te.TeamId, te.Name
ORDER BY Cards DESC;

-- 8. Prikaži sve strijelce turnira
SELECT (p.FirstName || ' ' || p.LastName) AS Name,  te.Name AS Team, COUNT(*) AS Goals
FROM Events e
JOIN Players p ON p.PlayerId = e.PlayerId
JOIN Teams te ON te.TeamId = p.TeamId
JOIN Matches m ON m.MatchId = e.MatchId
WHERE e.Type = 'Goal'
  AND m.TournamentId = 1
GROUP BY p.PlayerId, te.Name
ORDER BY Goals DESC;

-- 9. Prikaži tablicu bodova za određeni turnir
SELECT te.Name, s.Points, s.GoalDifference
FROM Standings s
JOIN Teams te ON te.TeamId = s.TeamId
WHERE s.TournamentId = 1
ORDER BY s.Points DESC;


-- 10. Prikaži sve finalne utakmice u povijesti
SELECT m.MatchDate, m.MatchTime, t1.Name AS Team1, t2.Name AS Team2, (m.Team1Score || ':' || m.Team2Score) AS Score
FROM Matches m
JOIN MatchTypes mt ON mt.MatchTypeId = m.MatchTypeId
JOIN Teams t1 ON t1.TeamId = m.Team1Id
JOIN Teams t2 ON t2.TeamId = m.Team2Id
WHERE mt.MatchType = 'Final';

-- 11. Prikaži sve vrste utakmica
SELECT mt.MatchType, COUNT(*) AS Total
FROM Matches m
JOIN MatchTypes mt ON mt.MatchTypeId = m.MatchTypeId
GROUP BY mt.MatchType;

-- 12. Prikaži sve utakmice odigrane na određeni datum
SELECT t1.Name AS Team1, t2.Name AS Team2, mt.MatchType, (m.Team1Score || ':' || m.Team2Score) AS Score
FROM Matches m
JOIN Teams t1 ON t1.TeamId = m.Team1Id
JOIN Teams t2 ON t2.TeamId = m.Team2Id
JOIN MatchTypes mt ON mt.MatchTypeId = m.MatchTypeId
WHERE m.MatchDate = '2022-12-10';

-- 13. Prikaži igrače koji su postigli najviše golova na određenom turniru
SELECT (p.FirstName || ' ' || p.LastName) AS Name, COUNT(*) AS Goals
FROM Events e
JOIN Players p ON p.PlayerId = e.PlayerId
JOIN Matches m ON m.MatchId = e.MatchId
WHERE e.Type = 'Goal'
  AND m.TournamentId = 1
GROUP BY p.PlayerId, p.FirstName, p.LastName
HAVING COUNT(*) = (
    SELECT MAX(Goals)
    FROM (
        SELECT COUNT(*) AS Goals
        FROM Events e2
        JOIN Matches m2 ON m2.MatchId = e2.MatchId
        WHERE e2.Type = 'Goal'
          AND m2.TournamentId = 1
        GROUP BY e2.PlayerId
    )
)
ORDER BY Name;


SELECT te.Name AS Team, (p.FirstName || ' ' || p.LastName) AS Name, COUNT(*) AS Goals
FROM Events e
JOIN Players p ON p.PlayerId = e.PlayerId
JOIN Teams te ON te.TeamId = p.TeamId
WHERE e.Type = 'Goal'
GROUP BY te.TeamId, te.Name, p.PlayerId, p.FirstName, p.LastName
ORDER BY te.TeamId, COUNT(*) DESC;

-- 14. Prikaži sve turnire na kojima je određeni tim sudjelovao
SELECT t.Name, t.Year, s.Points
FROM Standings s
JOIN Tournaments t ON t.TournamentId = s.TournamentId
WHERE s.TeamId = 5;

-- 15. Pronađi pobjednika turnira na temelju odigranih utakmica
SELECT t.Name
FROM Matches m
JOIN MatchTypes mt ON mt.MatchTypeId = m.MatchTypeId
JOIN Teams t ON
     (m.Team1Score > m.Team2Score AND t.TeamId = m.Team1Id)
  OR (m.Team2Score > m.Team1Score AND t.TeamId = m.Team2Id)
WHERE mt.MatchType = 'Final'
  AND m.TournamentId = 1;

-- 16. Za svaki turnir ispiši broj timova i igrača
SELECT t.Name,
       COUNT(DISTINCT s.TeamId) AS Teams,
       COUNT(p.PlayerId) AS Players
FROM Tournaments t
JOIN Standings s ON s.TournamentId = t.TournamentId
JOIN Players p ON p.TeamId = s.TeamId
GROUP BY t.Name;

-- 17. Najbolji strijelci po timu
SELECT Team, Name, Goals
FROM (
    SELECT DISTINCT ON (te.TeamId)
        te.Name AS Team,
        (p.FirstName || ' ' || p.LastName) AS Name,
        COUNT(*) AS Goals
    FROM Events e
    JOIN Players p ON p.PlayerId = e.PlayerId
    JOIN Teams te ON te.TeamId = p.TeamId
    WHERE e.Type = 'Goal'
    GROUP BY te.TeamId, te.Name, p.PlayerId, p.FirstName, p.LastName
    ORDER BY te.TeamId, COUNT(*) DESC
)
ORDER BY Goals DESC;

-- 18. Utakmice nekog suca
SELECT m.MatchDate, m.MatchTime, t1.Name AS Team1, t2.Name AS Team2, (Team1Score || ':' || Team2Score) AS Score
FROM Matches m
JOIN Teams t1 ON t1.TeamId = m.Team1Id
JOIN Teams t2 ON t2.TeamId = m.Team2Id
WHERE m.RefereeId = 57;
