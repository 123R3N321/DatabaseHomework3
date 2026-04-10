## pdf rendering problem with IDE; md conversion applied

## CS 6083 db, Spring 2026 sem, prof Suel

# Problem Set #2 (due March 13, extended due March 16 1159)

## 1. Machine Learning Hackathon Database

In this question, you will create and query a Machine Learning Hackathon database. The schema tracks
participants, their teams, the ML challenges they compete in, their model submissions, and the judging
outcomes. The schema is as follows:
**_Participant_** (pid, participant_name, skill_level, registration_year)
**_Team_** (team_id, team_name)
**_TeamMember_** (pid, team_id, role, challenge_id)
**_Challenge_** (challenge_id, title, domain, difficulty)
**_Round_** (challenge_id, round_id, round_name, start_date, end_date)
**_Submission_** (team_id, challenge_id, round_id, submission_date, model_type)
**_Judge_** (jid, judge_name)
**_Evaluates_** (jid, challenge_id, round_id, team_id, score)
**_Leaderboard_** (challenge_id, team_id, rank, c_score)
**Participant** stores individual hackers including their self-reported skill level (Beginner/ Intermediate/ Advanced/
Expert). A **Team** represents a group of people taking part in the competition, and all submissions are made by
teams and not individual participants. A participant may belong to at most one team per challenge.
**TeamMember** models the many-to-many relationship between participants and teams, along with each
member's role (e.g., Lead, Contributor, Advisor). A participant can be in different teams for different challenges.
A single **Challenge** has a domain (e.g., image recognition, disease prediction, text retrieval) and can have
multiple Rounds (e.g., Qualifying, Semi-Final, Final). Each **Round** can receive many **Submissions** from teams
but only the latest one counts. Three **Judges** are assigned to evaluate each round via the **Evaluates** table.
The final standings per challenge are recorded in **Leaderboard** , where the score is the average across all
rounds for each team, and tied teams may share the same rank (No need to skip ranks to account for ties. i.e.
there can be 1 team at #1, 2 teams at #2, 1 team at #3...)
**(a) Schema Creation**
Create the above schema in a relational database system. Choose appropriate attribute types and define all
primary keys, foreign keys, and constraints. Choose appropriate foreign key relationships! Data for this schema
will be made available on the course portal. Load the data into the database using either INSERT statements
or the bulk load facility provided by your DBMS.
**(b) SQL Queries**
CSV files for the data will be available on the course portal. Write the following SQL queries and execute them
on your database. Add tables you consider necessary to execute queries. Show both the queries and the
results.


i) Output the number of distinct participants who were involved in at least one submission in the Final round
for every challenge.
ii) Output the challenge and round with the highest average submission score, considering only rounds that
received more than 3 submissions.
iii) Output the names and IDs of participants who submitted to every round of at least one challenge.
iv) For each challenge and each round, output the name and id of the judge(s) who gives the lowest score.
v) Output any pairs of participants who submitted to at least three of the same challenge-round
combinations, but without being on the same team.
vi) Output for each ML domain (e.g., NLP, Computer Vision), the number of unique participants who have
competed in a challenge belonging to that domain.
vii) Output all participants who were in teams ranked in the top 3 on the leaderboard in any challenge and
who have a skill level of Beginner or Intermediate.
**(c) Relational Algebra**
Write expressions in Relational Algebra for queries (iii) to (vi).
**(d) Database Updates**
You are given files with additional participant and submission information (files ending with *_upd.csv). Write
SQL statements to perform the following updates:
i) New Submissions: Insert the new participants, teams, team member, submissions and evaluations into
the database. Ensure referential integrity is maintained (i.e., the challenge and round must already
exist).
ii) Leaderboard Refresh: After the new evaluations are loaded, recalculate and update the Leaderboard
table for any affected challenges. Ranks should be reassigned based on the updated c_score values,
with rank 1 being the highest score.
iii) Elite Registry: Create a table called EliteParticipant(pid). A participant qualifies as elite if they have (1)
competed in at least 3 different challenges, and (2) achieved a rank of 1 in at least one Final round.
Populate this table from the current Leaderboard and Submission data.
**(e) Triggers**
Consider updates (ii) and (iii) from part (d) again. Can you implement these tasks via database triggers?
Specifically:
Leaderboard Auto-Update Trigger: Whenever a new row is inserted into the Evaluates table, a trigger should
automatically recompute the rankings for the relevant attributes and update the Leaderboard table accordingly.
Elite Registry Maintenance Trigger: Whenever the Leaderboard table is updated, a trigger should check
whether any participant now qualifies for or no longer qualifies for EliteParticipant status, and insert or remove
their record accordingly. A participant loses elite status if their rank-1 Final round result is overridden by a
recomputed leaderboard entry.
Implement both triggers in your DBMS and demonstrate them by replaying the *_upd.csv insertions. Show the
state of the Leaderboard and EliteParticipant tables before and after the trigger fires.


## 2. Airline Flights and Booking

In this problem, you need to create views and write queries for an Airline Flight & Booking database. The
tables will be made available on NYU Brightspace (named flights.sql), and you need to execute your queries
on this data. The system tracks airports, flight services, specific flight instances, passengers, and their
bookings. Note that a "Flight Service" represents a recurring scheduled service (e.g., AA101, American Airline
morning flight from JFK to LAX), whereas a "Flight" represents a specific instance of that service taking place
on a specific date. The database consists of the following relational schema (primary keys are underlined)
**Airport** (airport_code, name, city, country)
**Aircraft** (plane_type, capacity)
**FlightService** (flight_number, airline_name, origin_code, dest_code, departure_time, duration)
**Flight** (flight_number, departure_date, plane_type)
**Passenger** (pid, passenger_name)
**Booking** (pid, flight_number, departure_date, seat_number)
**(a)** Identify suitable foreign keys for this schema.
**(b)** ER Diagram: Create an ER diagram that shows all the entities and relationships for the schema above. Be
sure to mark which attributes are the primary keys, choose suitable relationships, clearly identify any weak
entities, label the cardinalities of all relationships, and indicate whether each entity has total or partial
participation in each relationship.
**(c)** Define a view **FlightOccupancy** that calculates occupancy of each flight. For every flight, the view should
contain the flight_number, departure_date, arrival_date, origin_code, dest_code, capacity, and
total_passengers (the total number of passengers booked on that specific flight)
Using only this view, answer the following queries:

1. Output the flight_number, departure_date and total_passengers of the single flight that has the highest
    number of passenger bookings.
2. For each airport, output the total number of passengers that were scheduled to arrive on ‘2025-12-31’
3. List all flights that are more than 90% full.
**(d)** Define a view on the Airport table that contains only airport_code, name and city, but explicitly excludes the
country attribute. Then, write queries using only this view to perform the following operations, or explain if it
would fail and why:
1. Add a record to the underlying Airport table with the code ‘DXB’, the name ‘Dubai International’, and the
city ‘Dubai’ (Assume the country column has a NOT NULL constraint).
2. Delete all the airports located in the city of ‘Chicago’ from the database.
3. Delete all the airports located in the country of ‘France’ from the database.
4. For each city, list the number of distinct airports available in that city.


## 3. Warehouse Inventory and Membership

In this problem, you have to design a database for Costco that models warehouse inventory batches and
member purchases. Here is the scenario you need to model:

- Costco operates multiple warehouses to store product inventory and serve its members.
- Each warehouse has a unique ID, an address, and a phone number.
- Costco’s catalog consists of many products. Each product has a unique SKU, a name, a product
    category (e.g., ‘Electronics’, ‘Groceries’) and a current unit price.
- Because stock arrives at different times, product inventory within a warehouse is tracked using distinct
    inventory batches. Each batch has a unique batch ID, an arrival date, an expiration date (if applicable),
    and the quantity remaining in that batch. Note that each batch belongs to exactly one warehouse and
    represents exactly one SKU product, and that a warehouse may have multiple batches of the same
    product at a given point in time, each tracked independently.
- Registered members can purchase products. Each member has a unique member ID, a name, phone
    number, and a membership tier (e.g., ‘Executive’, or ‘Basic’). Memberships have a yearly cost (say, $
    for basic and $120 for executive tier, but this could change over time), and the executive tier comes
    with a 2% discount on all products.
- When a member makes a purchase, the system records a transaction. The database must record the
    transaction’s unique ID, the date and time, the member making the purchase, and the warehouse
    where the transaction took place.
- A transaction can include multiple products. For each item purchased, the system must record the
    specific inventory batch the item was deducted from, the quantity purchased, and probably the price
    that was paid. (Note: base prices for products may change over time — you may or may not want to
    store the complete history of prices, but you need to be able to find out what the actual price was that
    was paid by a customer when they made a purchase – so justify your design choice.)
**(a)** Design a database for the above scenario using the ER model. Draw the ER model, show the cardinalities
of all relationships, indicate whether each entity has total or partial participation in each relationship, and
identify the primary keys, foreign keys, and all the weak entities.
**(b)** Convert your ER diagram into a relational schema. Identify all tables, attributes, primary keys, and foreign
keys.
**(c)** Write SQL queries for the following questions. If you cannot answer the query using your schema, then you
have to modify your solutions (a) and (b) appropriately.
1. List the names of current members in the Basic tier who would have saved money if they had instead
purchased an Executive tier membership (meaning, the 2% extra savings would have already more
than made up for the difference in membership fee).
2. List the ID and address of every warehouse that has had batches of the product named 'Kirkland Paper
Towels' but is currently completely out of stock (i.e., the quantity remaining in all its batches is zero).
3. For the 'Grocery' category, output any product that was fully sold out in a store during the entire week
before Christmas (December 18–24, 2025). (By this we mean that the product was not available at all
during that week in that store.) Output the SKU, product name, and store.
4. Find members who have made purchases at more than one warehouse and have spent more than
$500 in total across all warehouses during 2024. List their names and total spending.
**(d)** Create tables in the database system, and insert sample data (10-15 tuples per table, but choose an
interesting data set, so that queries do not output empty results). Execute the queries in (c) and submit a log,
please also attach your .sql file in the submission.


