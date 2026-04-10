-- CS 6083 Spring 2026 - Problem Set 2
-- Problem 1(b): SQL queries
-- Assumes schema and data from p1_schema.sql and p1_load.sql

------------------------------------------------------------
-- (i) Number of distinct participants involved in at least
--     one submission in the Final round for every challenge.
------------------------------------------------------------

-- For each challenge, count participants who belong to a team
-- that has a submission in a Final round of that challenge.
SELECT
    s.challenge_id,
    COUNT(DISTINCT tm.pid) AS num_participants_final
FROM Submission AS s
JOIN Round AS r
  ON r.challenge_id = s.challenge_id
 AND r.round_id     = s.round_id
JOIN TeamMember AS tm
  ON tm.team_id      = s.team_id
 AND tm.challenge_id = s.challenge_id
WHERE r.round_name = 'Final'
GROUP BY s.challenge_id
ORDER BY s.challenge_id;


------------------------------------------------------------
-- (ii) Challenge and round with the highest average
--      submission score, considering only rounds that
--      received more than 3 submissions.
------------------------------------------------------------

WITH round_team_scores AS (
    SELECT
        e.challenge_id,
        e.round_id,
        e.team_id,
        AVG(e.score) AS avg_score_team
    FROM Evaluates AS e
    GROUP BY e.challenge_id, e.round_id, e.team_id
),
round_summary AS (
    SELECT
        rts.challenge_id,
        rts.round_id,
        AVG(rts.avg_score_team) AS avg_score_round,
        COUNT(*)                AS num_submissions
    FROM round_team_scores AS rts
    GROUP BY rts.challenge_id, rts.round_id
    HAVING COUNT(*) > 3
),
ranked AS (
    SELECT
        rs.*,
        ROW_NUMBER() OVER (ORDER BY rs.avg_score_round DESC) AS rn
    FROM round_summary AS rs
)
SELECT
    r.challenge_id,
    r.round_id,
    r.round_name,
    ranked.avg_score_round
FROM ranked
JOIN Round AS r
  ON r.challenge_id = ranked.challenge_id
 AND r.round_id     = ranked.round_id
WHERE ranked.rn = 1;


------------------------------------------------------------
-- (iii) Names and IDs of participants who submitted to
--       every round of at least one challenge.
------------------------------------------------------------

-- A participant is considered to have \"submitted\" to a round
-- if they are on any team that has a submission for that
-- (challenge, round).
WITH participant_rounds AS (
    SELECT DISTINCT
        tm.pid,
        s.challenge_id,
        s.round_id
    FROM Submission AS s
    JOIN TeamMember AS tm
      ON tm.team_id      = s.team_id
     AND tm.challenge_id = s.challenge_id
),
required_rounds AS (
    SELECT
        r.challenge_id,
        COUNT(*) AS total_rounds
    FROM Round AS r
    GROUP BY r.challenge_id
),
participant_coverage AS (
    SELECT
        pr.pid,
        pr.challenge_id,
        COUNT(DISTINCT pr.round_id) AS covered_rounds
    FROM participant_rounds AS pr
    GROUP BY pr.pid, pr.challenge_id
)
SELECT DISTINCT
    p.pid,
    p.participant_name
FROM participant_coverage AS pc
JOIN required_rounds AS rr
  ON rr.challenge_id = pc.challenge_id
JOIN Participant AS p
  ON p.pid = pc.pid
WHERE pc.covered_rounds = rr.total_rounds
ORDER BY p.pid;


------------------------------------------------------------
-- (iv) For each challenge and each round, name and id of
--      the judge(s) who give the lowest score.
------------------------------------------------------------

WITH round_min_score AS (
    SELECT
        e.challenge_id,
        e.round_id,
        MIN(e.score) AS min_score
    FROM Evaluates AS e
    GROUP BY e.challenge_id, e.round_id
)
SELECT
    e.challenge_id,
    e.round_id,
    j.jid,
    j.judge_name,
    e.score AS lowest_score
FROM Evaluates AS e
JOIN round_min_score AS rms
  ON rms.challenge_id = e.challenge_id
 AND rms.round_id     = e.round_id
 AND rms.min_score    = e.score
JOIN Judge AS j
  ON j.jid = e.jid
ORDER BY e.challenge_id, e.round_id, j.jid;


------------------------------------------------------------
-- (v) Pairs of participants who submitted to at least three
--     of the same challenge-round combinations, but without
--     being on the same team.
------------------------------------------------------------

WITH participant_round_team AS (
    SELECT DISTINCT
        tm.pid,
        s.challenge_id,
        s.round_id,
        s.team_id
    FROM Submission AS s
    JOIN TeamMember AS tm
      ON tm.team_id      = s.team_id
     AND tm.challenge_id = s.challenge_id
),
participant_pairs AS (
    SELECT
        pr1.pid        AS pid1,
        pr2.pid        AS pid2,
        pr1.challenge_id,
        pr1.round_id,
        pr1.team_id    AS team1,
        pr2.team_id    AS team2
    FROM participant_round_team AS pr1
    JOIN participant_round_team AS pr2
      ON pr1.challenge_id = pr2.challenge_id
     AND pr1.round_id     = pr2.round_id
     AND pr1.pid          < pr2.pid
)
SELECT
    pp.pid1,
    pp.pid2,
    COUNT(*) AS shared_rounds
FROM participant_pairs AS pp
WHERE pp.team1 <> pp.team2
GROUP BY pp.pid1, pp.pid2
HAVING COUNT(*) >= 3
ORDER BY pp.pid1, pp.pid2;


------------------------------------------------------------
-- (vi) For each ML domain, number of unique participants
--      who have competed in a challenge in that domain.
------------------------------------------------------------

SELECT
    c.domain,
    COUNT(DISTINCT tm.pid) AS num_participants
FROM Challenge AS c
JOIN TeamMember AS tm
  ON tm.challenge_id = c.challenge_id
GROUP BY c.domain
ORDER BY c.domain;


------------------------------------------------------------
-- (vii) All participants who were in teams ranked in the
--       top 3 on the leaderboard in any challenge and who
--       have skill level Beginner or Intermediate.
------------------------------------------------------------

SELECT DISTINCT
    p.pid,
    p.participant_name,
    p.skill_level
FROM Leaderboard AS lb
JOIN TeamMember AS tm
  ON tm.team_id      = lb.team_id
 AND tm.challenge_id = lb.challenge_id
JOIN Participant AS p
  ON p.pid = tm.pid
WHERE lb.rank <= 3
  AND p.skill_level IN ('Beginner','Intermediate')
ORDER BY p.pid;

