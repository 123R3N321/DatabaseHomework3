-- Problem 1(d): Database updates using *_upd.csv files
-- Assumes initial data already loaded.

-- 1) Insert new participants, teams, team members, submissions and evaluations
-- Use \copy so no superuser privileges are required (run from project root).

\copy Participant (pid, participant_name, skill_level, registration_year) FROM 'p1/participant_upd.csv' DELIMITER ',' CSV HEADER QUOTE '''';
\copy Team (team_id, team_name) FROM 'p1/team_upd.csv' DELIMITER ',' CSV HEADER QUOTE '''';
\copy TeamMember (pid, team_id, role, challenge_id) FROM 'p1/team_member_upd.csv' DELIMITER ',' CSV HEADER QUOTE '''';
\copy Submission (team_id, challenge_id, round_id, submission_date, model_type) FROM 'p1/submission_upd.csv' DELIMITER ',' CSV HEADER QUOTE '''';
\copy Evaluates (jid, challenge_id, round_id, team_id, score) FROM 'p1/evaluates_upd.csv' DELIMITER ',' CSV HEADER QUOTE '''';


-- 2) Recalculate and update Leaderboard for affected challenges

WITH team_challenge_scores AS (
    SELECT
        e.challenge_id,
        e.team_id,
        AVG(e.score) AS c_score
    FROM Evaluates AS e
    GROUP BY e.challenge_id, e.team_id
),
ranked AS (
    SELECT
        tcs.challenge_id,
        tcs.team_id,
        tcs.c_score,
        RANK() OVER (
            PARTITION BY tcs.challenge_id
            ORDER BY tcs.c_score DESC
        ) AS rank
    FROM team_challenge_scores AS tcs
)
INSERT INTO Leaderboard AS lb (challenge_id, team_id, rank, c_score)
SELECT
    r.challenge_id,
    r.team_id,
    r.rank,
    r.c_score
FROM ranked AS r
ON CONFLICT (challenge_id, team_id) DO UPDATE
SET rank   = EXCLUDED.rank,
    c_score = EXCLUDED.c_score;


-- 3) Populate EliteParticipant(pid)
--    (1) competed in at least 3 different challenges, and
--    (2) achieved rank 1 in at least one Final round.

TRUNCATE EliteParticipant;

WITH participant_challenges AS (
    SELECT DISTINCT
        tm.pid,
        tm.challenge_id
    FROM TeamMember AS tm
),
participants_3plus AS (
    SELECT
        pc.pid
    FROM participant_challenges AS pc
    GROUP BY pc.pid
    HAVING COUNT(DISTINCT pc.challenge_id) >= 3
),
rank1_final_teams AS (
    SELECT DISTINCT
        lb.challenge_id,
        lb.team_id
    FROM Leaderboard AS lb
    JOIN Submission AS s
      ON s.challenge_id = lb.challenge_id
     AND s.team_id      = lb.team_id
    JOIN Round AS r
      ON r.challenge_id = s.challenge_id
     AND r.round_id     = s.round_id
    WHERE lb.rank = 1
      AND r.round_name = 'Final'
),
rank1_final_participants AS (
    SELECT DISTINCT
        tm.pid
    FROM rank1_final_teams AS rft
    JOIN TeamMember AS tm
      ON tm.team_id      = rft.team_id
     AND tm.challenge_id = rft.challenge_id
)
INSERT INTO EliteParticipant(pid)
SELECT DISTINCT
    p3.pid
FROM participants_3plus AS p3
JOIN rank1_final_participants AS rfp
  ON rfp.pid = p3.pid;

