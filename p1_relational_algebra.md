## Problem 1(c) – Relational Algebra for Queries (iii)–(vi)

Notation (basically just acronyms lol):
- `P` = `Participant`
- `T` = `Team`
- `TM` = `TeamMember`
- `C` = `Challenge`
- `R` = `Round`
- `S` = `Submission`
- `J` = `Judge`
- `E` = `Evaluates`
- `L` = `Leaderboard`

We use standard operators (consistent with lec 2 slides):
- Selection: `σ`
- Projection: `π`
- Natural join (on the attributes indicated in the subscript): `⋈`
- Cartesian product: `×`
- Union: `∪`
- Rename: `ρ`
- Grouping/aggregation: `γ`
- Set difference: `−`
- Set division: `÷` (only where it keeps the expression simpler; many of these can equivalently be written using joins, products, and difference which I kinda prefer)

---

### (iii) Participants who submitted to every round of at least one challenge

Idea: For each participant and challenge, compare the set of rounds where they have submissions to the full set of rounds for that challenge.

1. Participant–round participation:

```text
PR(pid, challenge_id, round_id) :=
    π pid, S.challenge_id, S.round_id
    ( TM ⋈_{TM.team_id = S.team_id ∧ TM.challenge_id = S.challenge_id} S )
```

2. Required rounds per challenge:

```text
ReqRounds(challenge_id, round_id) := π challenge_id, round_id (R)
```

3. For each `(pid, challenge_id)`, we need that the set of `round_id` values in `PR` matches all `round_id` in `ReqRounds` for that `challenge_id`. This is a per-challenge division:

```text
PR_per_challenge(pid, challenge_id, round_id) := PR

ParticipantsAllRounds(pid, challenge_id) :=
    π pid, challenge_id
    ( PR_per_challenge ÷ ReqRounds )
```

4. Final result with names:

```text
Result_iii(pid, participant_name) :=
    π P.pid, P.participant_name
    ( P ⋈_{P.pid = ParticipantsAllRounds.pid} ParticipantsAllRounds )
```

---

### (iv) For each challenge and round, judge(s) with the lowest score

1. Minimum score per `(challenge_id, round_id)`:

```text
MinScore(challenge_id, round_id, min_score) :=
    γ challenge_id, round_id; min(score)→min_score (E)
```

2. Join back to evaluations and judges to find those with that minimum:

```text
LowJudges :=
    E ⋈_{E.challenge_id = MinScore.challenge_id
         ∧ E.round_id = MinScore.round_id
         ∧ E.score = MinScore.min_score} MinScore

Result_iv(challenge_id, round_id, jid, judge_name, score) :=
    π LowJudges.challenge_id,
      LowJudges.round_id,
      J.jid,
      J.judge_name,
      LowJudges.score
    ( LowJudges ⋈_{LowJudges.jid = J.jid} J )
```

---

### (v) Pairs of participants sharing ≥3 same challenge–rounds, but never on same team there

1. Participant participation including team:

```text
PRT(pid, challenge_id, round_id, team_id) :=
    π TM.pid, S.challenge_id, S.round_id, S.team_id
    ( TM ⋈_{TM.team_id = S.team_id ∧ TM.challenge_id = S.challenge_id} S )
```

2. All pairs of participants on the same `(challenge_id, round_id)` (ordered so `pid1 < pid2`):

```text
Pairs(pid1, pid2, challenge_id, round_id, team1, team2) :=
    ρ PR1(PRT) ⋈_{PR1.challenge_id = PR2.challenge_id
                 ∧ PR1.round_id = PR2.round_id
                 ∧ PR1.pid < PR2.pid}
    ρ PR2(PRT)
```

3. Keep only pairs where they are on different teams in that round:

```text
PairsDiffTeam :=
    σ team1 ≠ team2 (Pairs)
```

4. Group by pair `(pid1, pid2)` and count how many distinct `(challenge_id, round_id)` they share:

```text
PairCounts(pid1, pid2, shared_rounds) :=
    γ pid1, pid2; count(challenge_id, round_id)→shared_rounds (PairsDiffTeam)
```

5. Final result: those with `shared_rounds ≥ 3`:

```text
Result_v(pid1, pid2, shared_rounds) :=
    σ shared_rounds ≥ 3 (PairCounts)
```

---

### (vi) For each ML domain, number of unique participants who have competed in that domain

1. Participants linked to challenges via membership:

```text
DomPart(domain, pid) :=
    π C.domain, TM.pid
    ( TM ⋈_{TM.challenge_id = C.challenge_id} C )
```

2. Count distinct participants per domain:

```text
Result_vi(domain, num_participants) :=
    γ domain; count_distinct(pid)→num_participants (DomPart)
```

