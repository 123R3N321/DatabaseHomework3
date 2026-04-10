-- CS 6083 Spring 2026 - Problem Set 2
-- Problem 1: Machine Learning Hackathon Database
-- PostgreSQL schema (DDL)

DROP TABLE IF EXISTS EliteParticipant CASCADE;
DROP TABLE IF EXISTS Leaderboard CASCADE;
DROP TABLE IF EXISTS Evaluates CASCADE;
DROP TABLE IF EXISTS Submission CASCADE;
DROP TABLE IF EXISTS Round CASCADE;
DROP TABLE IF EXISTS TeamMember CASCADE;
DROP TABLE IF EXISTS Challenge CASCADE;
DROP TABLE IF EXISTS Judge CASCADE;
DROP TABLE IF EXISTS Team CASCADE;
DROP TABLE IF EXISTS Participant CASCADE;

CREATE TABLE Participant (
    pid              INT PRIMARY KEY,
    participant_name VARCHAR(100) NOT NULL,
    skill_level      VARCHAR(20)  NOT NULL,
    registration_year INT         NOT NULL,
    CONSTRAINT participant_skill_level_chk CHECK (
        skill_level IN ('Beginner','Intermediate','Advanced','Expert')
    )
);

CREATE TABLE Team (
    team_id   INT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL
);

CREATE TABLE Challenge (
    challenge_id INT PRIMARY KEY,
    title        VARCHAR(200) NOT NULL,
    domain       VARCHAR(50)  NOT NULL,
    difficulty   VARCHAR(20)  NOT NULL
);

CREATE TABLE Round (
    challenge_id INT         NOT NULL,
    round_id     INT         NOT NULL,
    round_name   VARCHAR(50) NOT NULL,
    start_date   DATE        NOT NULL,
    end_date     DATE        NOT NULL,
    PRIMARY KEY (challenge_id, round_id),
    CONSTRAINT round_challenge_fk
        FOREIGN KEY (challenge_id)
        REFERENCES Challenge (challenge_id)
        ON DELETE RESTRICT
);

CREATE TABLE TeamMember (
    pid          INT NOT NULL,
    team_id      INT NOT NULL,
    role         VARCHAR(50) NOT NULL,
    challenge_id INT NOT NULL,
    PRIMARY KEY (pid, team_id, challenge_id),
    CONSTRAINT teammember_participant_fk
        FOREIGN KEY (pid)
        REFERENCES Participant (pid)
        ON DELETE RESTRICT,
    CONSTRAINT teammember_team_fk
        FOREIGN KEY (team_id)
        REFERENCES Team (team_id)
        ON DELETE RESTRICT,
    CONSTRAINT teammember_challenge_fk
        FOREIGN KEY (challenge_id)
        REFERENCES Challenge (challenge_id)
        ON DELETE RESTRICT
);

CREATE TABLE Submission (
    team_id        INT  NOT NULL,
    challenge_id   INT  NOT NULL,
    round_id       INT  NOT NULL,
    submission_date DATE NOT NULL,
    model_type     VARCHAR(50) NOT NULL,
    PRIMARY KEY (team_id, challenge_id, round_id),
    CONSTRAINT submission_team_fk
        FOREIGN KEY (team_id)
        REFERENCES Team (team_id)
        ON DELETE RESTRICT,
    CONSTRAINT submission_round_fk
        FOREIGN KEY (challenge_id, round_id)
        REFERENCES Round (challenge_id, round_id)
        ON DELETE RESTRICT
);

CREATE TABLE Judge (
    jid        INT PRIMARY KEY,
    judge_name VARCHAR(100) NOT NULL
);

CREATE TABLE Evaluates (
    jid          INT NOT NULL,
    challenge_id INT NOT NULL,
    round_id     INT NOT NULL,
    team_id      INT NOT NULL,
    score        NUMERIC(5,2) NOT NULL,
    PRIMARY KEY (jid, challenge_id, round_id, team_id),
    CONSTRAINT evaluates_judge_fk
        FOREIGN KEY (jid)
        REFERENCES Judge (jid)
        ON DELETE RESTRICT,
    CONSTRAINT evaluates_submission_fk
        FOREIGN KEY (team_id, challenge_id, round_id)
        REFERENCES Submission (team_id, challenge_id, round_id)
        ON DELETE RESTRICT
);

CREATE TABLE Leaderboard (
    challenge_id INT NOT NULL,
    team_id      INT NOT NULL,
    rank         INT NOT NULL,
    c_score      NUMERIC(6,2) NOT NULL,
    PRIMARY KEY (challenge_id, team_id),
    CONSTRAINT leaderboard_challenge_fk
        FOREIGN KEY (challenge_id)
        REFERENCES Challenge (challenge_id)
        ON DELETE RESTRICT,
    CONSTRAINT leaderboard_team_fk
        FOREIGN KEY (team_id)
        REFERENCES Team (team_id)
        ON DELETE RESTRICT
);

CREATE TABLE EliteParticipant (
    pid INT PRIMARY KEY,
    CONSTRAINT elite_participant_fk
        FOREIGN KEY (pid)
        REFERENCES Participant (pid)
        ON DELETE CASCADE
);

