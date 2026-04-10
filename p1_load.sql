-- Load initial CSV data for Problem 1 into PostgreSQL.
-- Assumes tables from p1_schema.sql already exist.
-- Uses psql's \copy so no superuser privileges are required.
-- Run from the project root so relative paths resolve correctly.

-- Participants
\copy Participant (pid, participant_name, skill_level, registration_year) FROM 'p1/participants.csv' DELIMITER ',' CSV HEADER QUOTE '''';

-- Teams
\copy Team (team_id, team_name) FROM 'p1/team.csv' DELIMITER ',' CSV HEADER QUOTE '''';

-- Challenges
\copy Challenge (challenge_id, title, domain, difficulty) FROM 'p1/challenge.csv' DELIMITER ',' CSV HEADER QUOTE '''';

-- Rounds
\copy Round (challenge_id, round_id, round_name, start_date, end_date) FROM 'p1/round.csv' DELIMITER ',' CSV HEADER QUOTE '''';

-- Team members
\copy TeamMember (pid, team_id, role, challenge_id) FROM 'p1/team_member.csv' DELIMITER ',' CSV HEADER QUOTE '''';

-- Submissions
\copy Submission (team_id, challenge_id, round_id, submission_date, model_type) FROM 'p1/submission.csv' DELIMITER ',' CSV HEADER QUOTE '''';

-- Judges
\copy Judge (jid, judge_name) FROM 'p1/judge.csv' DELIMITER ',' CSV HEADER QUOTE '''';

-- Evaluations
\copy Evaluates (jid, challenge_id, round_id, team_id, score) FROM 'p1/evaluates.csv' DELIMITER ',' CSV HEADER QUOTE '''';

-- Leaderboard
\copy Leaderboard (challenge_id, team_id, rank, c_score) FROM 'p1/leaderboard.csv' DELIMITER ',' CSV HEADER QUOTE '''';

