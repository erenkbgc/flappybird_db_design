-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- Schema for the Flappy Bird-style game database

-- This table stores information about the players, including their unique username and email.
CREATE TABLE players (
    id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique ID for each player
    username TEXT UNIQUE NOT NULL, -- Unique username for the player
    email TEXT UNIQUE NOT NULL, -- Unique email address
    join_date DATE NOT NULL DEFAULT CURRENT_DATE, -- Date the player joined
    last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Last login timestamp for activity tracking
);

-- A quick lookup of players by username
CREATE INDEX idx_username ON players(username);

-- This table tracks each session a player plays, including the start and end times.
CREATE TABLE game_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    session_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_end TIMESTAMP DEFAULT NULL,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_game_sessions_player_id ON game_sessions(player_id);
--This view dynamically measures the duration seconds by using session_start and session_end
CREATE VIEW game_sessions_with_duration AS
SELECT
    id,
    player_id,
    session_start,
    session_end,
    (JULIANDAY(session_end) - JULIANDAY(session_start)) * 86400 AS duration_seconds
FROM game_sessions;

-- This table stores scores achieved during specific game sessions.
CREATE TABLE scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    score INTEGER NOT NULL,
    pipes_passed INTEGER NOT NULL,
    FOREIGN KEY (session_id) REFERENCES game_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

-- Create a view to display top scores for each player
CREATE VIEW top_scores AS
SELECT
    s.player_id,
    p.username,
    MAX(s.score) AS high_score
FROM
    scores s
JOIN
    players p ON s.player_id = p.id
GROUP BY
    s.player_id, p.username;

-- This table stores high scores for leaderboard rankings.
CREATE TABLE leaderboard (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    high_score INTEGER NOT NULL,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

-- This table stores gameplay metrics for analysis, such as taps per second and collision types.
CREATE TABLE game_metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    taps_per_second REAL NOT NULL,
    average_pipe_gap INTEGER NOT NULL,
    collision_type TEXT NOT NULL CHECK (collision_type IN ('Ground', 'Pipe')),
    FOREIGN KEY (session_id) REFERENCES game_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

-- This table tracks in-game events like power-ups or pauses.
CREATE TABLE events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    event_type TEXT NOT NULL CHECK (event_type IN ('Power-Up', 'Collision', 'Pause', 'Resume')),
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES game_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_event_type ON events(event_type);

-- This view combines player details with their total sessions and top scores.
CREATE VIEW player_statistics AS
SELECT
    p.id AS player_id,
    p.username,
    p.email,
    COUNT(gs.id) AS total_sessions,
    MAX(s.score) AS highest_score
FROM
    players p
LEFT JOIN
    game_sessions gs ON p.id = gs.player_id
LEFT JOIN
    scores s ON p.id = s.player_id
GROUP BY
    p.id, p.username, p.email;
