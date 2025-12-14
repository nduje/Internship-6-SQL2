CREATE FUNCTION SetUpdatedAt()
RETURNS TRIGGER AS $$
BEGIN
	NEW.UpdatedAt = CURRENT_TIMESTAMP;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION CalculateMatchScore()
RETURNS TRIGGER AS $$
DECLARE
	Team1Goals INT;
	Team2Goals INT;
BEGIN
	SELECT COUNT(*) INTO Team1Goals
    FROM Events e
    JOIN Players p ON e.PlayerId = p.PlayerId
    WHERE e.MatchId = NEW.MatchId
      AND e.Type = 'Goal'
      AND p.TeamId = NEW.Team1Id;

    SELECT COUNT(*) INTO Team2Goals
    FROM Events e
    JOIN Players p ON e.PlayerId = p.PlayerId
    WHERE e.MatchId = NEW.MatchId
      AND e.Type = 'Goal'
      AND p.TeamId = NEW.Team2Id;

	NEW.Team1Score := Team1Goals;
    NEW.Team2Score := Team2Goals;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION UpdateStandings()
RETURNS TRIGGER AS $$
DECLARE
    Team1Points INT := 0;
    Team2Points INT := 0;
	Team1GoalDifference INT;
	Team2GoalDifference
BEGIN
    IF NEW.Team1Score > NEW.Team2Score THEN
        Team1Points := 3;
    ELSIF NEW.Team2Score > NEW.Team1Score THEN
        Team2Points := 3;
    ELSE
        Team2Points := 1;
        Team2Points := 1;
    END IF;

	Team1GoalDifference := NEW.Team1Score - NEW.Team2Score;
	Team2GoalDifference := NEW.Team2Score - NEW.Team1Score;

    INSERT INTO Standings (TournamentId, TeamId, Points, GoalDifference)
    VALUES (NEW.TournamentId, NEW.Team1Id, Team1Points, Team1GoalDifference)
    ON CONFLICT (TournamentId, TeamId)
    DO UPDATE SET
        Points = Standings.Points + EXCLUDED.Points,
        GoalDifference = Standings.GoalDifference + EXCLUDED.GoalDifference;

		
    INSERT INTO Standings (TournamentId, TeamId, Points, GoalDifference)
    VALUES (NEW.TournamentId, NEW.Team2Id, Team2Points, Team2GoalDifference)
    ON CONFLICT (TournamentId, TeamId)
    DO UPDATE SET
        Points = Standings.Points + EXCLUDED.Points,
        GoalDifference = Standings.GoalDifference + EXCLUDED.GoalDifference;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION SetTournamentWinner()
RETURNS TRIGGER AS $$
DECLARE
    WinnerId INT;
BEGIN
    IF NEW.MatchTypeId = (
        SELECT MatchTypeId FROM MatchTypes WHERE MatchType = 'Final'
    ) THEN
        IF NEW.Team1Score > NEW.Team2Score THEN
            WinnerId := NEW.Team1Id;
        ELSIF NEW.Team2Score > NEW.Team1Score THEN
            WinnerId := NEW.Team2Id;
        ELSE
            RETURN NEW;
        END IF;

        UPDATE Tournaments
        SET WinnerTeamId = WinnerId
        WHERE TournamentId = NEW.TournamentId;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CheckCaptainTeam()
RETURNS TRIGGER AS $$
DECLARE
    CaptainTeam INT;
BEGIN
    SELECT TeamId INTO CaptainTeam
    FROM Players
    WHERE PlayerId = NEW.CaptainId;

    IF CaptainTeam IS NULL OR CaptainTeam != NEW.TeamId THEN
        RAISE EXCEPTION 'Captain must belong to the same team!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;