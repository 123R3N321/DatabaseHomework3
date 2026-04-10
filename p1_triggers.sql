-- Problem 1(e): Triggers for automatic leaderboard and elite registry maintenance

------------------------------------------------------------
-- Helper functions
------------------------------------------------------------

-- Recompute leaderboard entries for a single challenge.
CREATE OR REPLACE FUNCTION recompute_leaderboard_for_challenge(p_challenge_id INT)
RETURNS VOID AS $$
BEGIN
    WITH team_challenge_scores AS (
        SELECT
            e.challenge_id,
            e.team_id,
            AVG(e.score) AS c_score
        FROM Evaluates AS e
        WHERE e.challenge_id = p_challenge_id
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
END;
$$ LANGUAGE plpgsql;


-- Recompute EliteParticipant table for all participants.
CREATE OR REPLACE FUNCTION recompute_elite_participants()
RETURNS VOID AS $$
BEGIN
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
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------
-- Trigger 1: Leaderboard auto-update on Evaluates insert
------------------------------------------------------------

CREATE OR REPLACE FUNCTION trg_evaluates_after_insert()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM recompute_leaderboard_for_challenge(NEW.challenge_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS evaluates_after_insert_leaderboard ON Evaluates;

CREATE TRIGGER evaluates_after_insert_leaderboard
AFTER INSERT ON Evaluates
FOR EACH ROW
EXECUTE FUNCTION trg_evaluates_after_insert();


------------------------------------------------------------
-- Trigger 2: Elite registry maintenance on Leaderboard change
------------------------------------------------------------

CREATE OR REPLACE FUNCTION trg_leaderboard_after_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Recompute elite participants globally.
    PERFORM recompute_elite_participants();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS leaderboard_after_insupd_elite ON Leaderboard;

CREATE TRIGGER leaderboard_after_insupd_elite
AFTER INSERT OR UPDATE ON Leaderboard
FOR EACH STATEMENT
EXECUTE FUNCTION trg_leaderboard_after_change();


------------------------------------------------------------
-- Suggested demo sequence (run manually):
--
-- 1. Load base schema and data:
--    \i p1_schema.sql
--    \i p1_load.sql
--
-- 2. Create functions and triggers:
--    \i p1_triggers.sql
--
-- 3. Replay *_upd inserts and observe automatic updates:
--    \i p1_updates.sql
--
-- 4. Inspect results:
--    SELECT * FROM Leaderboard ORDER BY challenge_id, rank;
--    SELECT * FROM EliteParticipant ORDER BY pid;
------------------------------------------------------------

