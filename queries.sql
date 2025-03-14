-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

INSERT INTO players (username, email)
VALUES
('player_one', 'playerone@example.com'),
('player_two', 'playertwo@example.com'),
('player_three', 'playerthree@example.com');

INSERT INTO game_sessions (player_id, session_start, session_end)
VALUES
(1, '2023-12-28 10:00:00', '2023-12-28 10:20:00'),
(2, '2023-12-28 11:00:00', '2023-12-28 11:30:00'),
(3, '2023-12-28 12:00:00', '2023-12-28 12:25:00');


INSERT INTO scores (session_id, player_id, score, pipes_passed)
VALUES
(1, 1, 150, 35),
(2, 2, 200, 40),
(3, 3, 175, 38);

INSERT INTO leaderboard (player_id, high_score)
VALUES
(1, 150),
(2, 200),
(3, 175);

INSERT INTO game_metrics (session_id, player_id, taps_per_second, average_pipe_gap, collision_type)
VALUES
(1, 1, 3.25, 120, 'Pipe'),
(2, 2, 4.10, 110, 'Ground'),
(3, 3, 3.75, 115, 'Pipe');

INSERT INTO events (session_id, player_id, event_type, event_time)
VALUES
(1, 1, 'Collision', '2023-12-28 10:15:00'),
(2, 2, 'Pause', '2023-12-28 11:10:00'),
(3, 3, 'Power-Up', '2023-12-28 12:20:00');


-- Retrieve all players and their details
SELECT *
FROM players;

-- Get the total number of game sessions for each player
SELECT p.username, COUNT(gs.id) AS total_sessions
FROM players p
LEFT JOIN game_sessions gs ON p.id = gs.player_id
GROUP BY p.username;

-- Get the highest score for each player
SELECT p.username, MAX(s.score) AS highest_score
FROM players p
JOIN scores s ON p.id = s.player_id
GROUP BY p.username;

-- Retrieve the top 5 players on the leaderboard
SELECT p.username, l.high_score
FROM leaderboard l
JOIN players p ON l.player_id = p.id
ORDER BY l.high_score DESC
LIMIT 5;

-- Retrieve all events for a specific game session
SELECT e.event_type, e.event_time
FROM events e
WHERE e.session_id = 1;

-- Analyze gameplay metrics for a specific session
SELECT gm.taps_per_second, gm.average_pipe_gap, gm.collision_type
FROM game_metrics gm
WHERE gm.session_id = 1;

UPDATE players
SET email = 'newemail@example.com'
WHERE username = 'player_one';

-- Update the session end time for a specific game session
UPDATE game_sessions
SET session_end = '2023-12-28 10:30:00'
WHERE id = 1;

-- Update a player’s high score on the leaderboard
UPDATE leaderboard
SET high_score = 180
WHERE player_id = 1;

-- Update collision type in game metrics for a specific session
UPDATE game_metrics
SET collision_type = 'Ground'
WHERE session_id = 2;
