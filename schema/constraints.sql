ALTER TABLE Tournaments
ADD CONSTRAINT FK_Tournament_Winner
FOREIGN KEY (WinnerTeamId) REFERENCES Teams(TeamId);

ALTER TABLE Teams
ADD CONSTRAINT FK_Team_Captain
FOREIGN KEY (CaptainId) REFERENCES Players(PlayerId);

ALTER TABLE Players
ADD CONSTRAINT FK_Player_Team
FOREIGN KEY (TeamId) REFERENCES Teams(TeamId);

ALTER TABLE Standings
ADD CONSTRAINT FK_Standing_Tournament
FOREIGN KEY (TournamentId) REFERENCES Tournaments(TournamentId);

ALTER TABLE Standings
ADD CONSTRAINT FK_Standing_Team
FOREIGN KEY (TeamId) REFERENCES Teams(TeamId);

ALTER TABLE Standings
ADD CONSTRAINT UQ_Standing
UNIQUE (TournamentId, TeamId);

ALTER TABLE Matches
ADD CONSTRAINT FK_Match_Team1_In_Tournament
FOREIGN KEY (TournamentId, Team1Id)
REFERENCES Standings(TournamentId, TeamId);

ALTER TABLE Matches
ADD CONSTRAINT FK_Match_Team2_In_Tournament
FOREIGN KEY (TournamentId, Team2Id)
REFERENCES Standings(TournamentId, TeamId);

ALTER TABLE Matches
ADD CONSTRAINT FK_Match_Referee
FOREIGN KEY (RefereeId) REFERENCES Referees(RefereeId);

ALTER TABLE Matches
ADD CONSTRAINT FK_Match_MatchType
FOREIGN KEY (MatchTypeId) REFERENCES MatchTypes(MatchTypeId);

ALTER TABLE Events
ADD CONSTRAINT FK_Event_Match
FOREIGN KEY (MatchId) REFERENCES Matches(MatchId);

ALTER TABLE Events
ADD CONSTRAINT FK_Event_Player
FOREIGN KEY (PlayerId) REFERENCES Players(PlayerId);

ALTER TABLE Matches
ADD CONSTRAINT Different_Teams
CHECK (Team1Id <> Team2Id);

ALTER TABLE Events
ADD CONSTRAINT Event_Minute
CHECK (Minute BETWEEN 0 AND 120);