-- NOTES:
-- -On Windows all the files we worked on were added to a folder called tmp in the root folder (for example C:)
--    a similar solution was employed on mac
-- -In exercise 2 d) we give examples of operations that are not allowed, so if the whole code is run at once
--    an exception will be thrown
-- GITHUB REPO: https://github.com/doubavitch/ex1-sql
-- Exercise 1 a) Lines 23-65	(code)
-- Exercise 1 b) Lines 69-104	(code)
-- Exercise 1 c) Lines 108-133	(code)
-- Exercise 1 d) Lines 137-159	(text)
-- Exercise 2 a) Lines 165-198	(code)
-- Exercise 2 b) Lines 202-238 	(code + commented code)
-- Exercise 2 c) Lines 243-248	(code)
-- Exercise 2 d) Lines 267-274	(code that throws exception intentionally)
-- Exercise 3 a) Lines 279-286	(code)
-- Exercise 3 b) Lines 289-296	(code)
-- Exercise 3 c) Lines 300-340	(code)
-- Exercise 3 d) Lines 345-372	(code)


--Exercise 1 a) ----------------------------------------------------------------------

DROP TABLE IF EXISTS Persons;
CREATE TABLE Persons (
	nid char(10),
	primaryName varchar(128),
	birthYear int,
	deathYear int,
	primaryProfession varchar(128),
	knownForTitles varchar(128));
COPY Persons FROM '/tmp/name.basics.tsv' NULL '\N' ENCODING 'UTF8';
SELECT * FROM Persons LIMIT 100;  --Selection is made to check our results

DROP TABLE IF EXISTS Titles;
CREATE TABLE Titles (
	tid char(10),
	ttype varchar(12),
	primaryTitle varchar(1024),
	originalTitle varchar(1024),
	isAdult int,
	startYear int,
	endYear int,
	runtimeMinutes int,
	genres varchar(256));
COPY Titles FROM '/tmp/title.basics.tsv' NULL '\N' ENCODING 'UTF8';
SELECT * FROM Titles LIMIT 100;  --Selection is made to check our results
			  
DROP TABLE IF EXISTS Principals;
CREATE TABLE Principals (
	tid char(10),
	ordering int,
	nid char(10),
	category varchar(32),
	job varchar(512),
	characters varchar(2048));
COPY Principals FROM '/tmp/title.principals.tsv' NULL '\N' ENCODING 'UTF8';
SELECT * FROM Principals LIMIT 100;  --Selection is made to check our results
		  
DROP TABLE IF EXISTS Ratings;
CREATE TABLE Ratings (
        tid char(10),
        avg_rating numeric,
        num_votes numeric);
COPY Ratings FROM '/tmp/title.ratings.tsv' NULL '\N' ENCODING 'UTF8';
SELECT * FROM Ratings LIMIT 100;  --Selection is made to check our results

-- Exercise 1 b) ----------------------------------------------------------------------

DROP Table IF EXISTS Directs;
CREATE TABLE Directs(
	nid char(10),
	tid char(10)
);

DROP Table IF EXISTS Starsin;
CREATE TABLE Starsin(
	nid char(10),
	tid char(10)
);

DROP Table IF EXISTS Movie;
CREATE TABLE Movie(
	tid 	char(10),
	title 	varchar(1024),
	year	int,
	length	int,
	rating	numeric
);

DROP Table IF EXISTS Director;
CREATE TABLE Director(
	nid 		char(10),
	name		varchar(128),
	birthYear	int,
	deathYear	int
);

DROP Table IF EXISTS Actor;
CREATE TABLE Actor(
	nid			char(10),
	name		varchar(128),
	birthYear	int,
	deathYear	int
);

-- Exercise 1 c) ----------------------------------------------------------------------

DELETE FROM Movie WHERE TRUE;
INSERT INTO Movie (SELECT DISTINCT Titles.tid AS tid, Titles.originaltitle AS Title,Titles.runtimeMinutes AS length, Titles.startYear AS year, Ratings.avg_rating AS rating
				  FROM Titles,Ratings
				  WHERE Titles.tid = Ratings.tid AND Titles.ttype='movie' AND Ratings.num_votes >= 10000
				  ORDER BY Ratings.avg_rating DESC
				  LIMIT 5000);

DELETE FROM Directs WHERE TRUE;
INSERT INTO Directs(SELECT DISTINCT Principals.nid as nid, Principals.tid as tid
				   FROM Principals,Movie
				   WHERE Principals.category = 'director' AND Movie.tid = Principals.tid);
				   
DELETE FROM Starsin WHERE TRUE;
INSERT INTO Starsin(SELECT DISTINCT Principals.nid as nid, Principals.tid as tid 
				   FROM Principals,Movie
				   WHERE Movie.tid = Principals.tid AND (Principals.category = 'actor' OR Principals.category = 'actress'));

DELETE FROM Actor WHERE TRUE;
INSERT INTO Actor (SELECT DISTINCT Persons.nid AS nid, primaryName AS name, Persons.birthYear AS birthYear, Persons.deathYear AS deathYear 
				   FROM Persons,Starsin
				   WHERE Persons.nid = Starsin.nid);
				   
DELETE FROM Director WHERE TRUE;
INSERT INTO Director (SELECT DISTINCT Persons.nid AS nid, primaryName AS name, birthYear AS birthYear, deathYear AS deathYear 
				   FROM Persons,Directs
				   WHERE Directs.nid = Persons.nid);

				   
-- EXERCISE 1 d) ----------------------------------------------------------------------
/*NOTE: We suppose that no two movies have the same name in the same year
We could assume that no two persons in the persons table have the same name 
and birthyear, but this assumption seems much more unlikely to hold
The following are non trivial functional dependencies
Movie:
- title,year -> length,rating
- tid -> title,year,length,rating
Actor:
- nid -> name, birthyear, deathyear
Director:
- nid -> name, birthyear, deathyear

Thus the key of Movie is tid or (title,year), the key of Director and Actor is nid

Normal forms:
Movie:
-BCNF as the only non trivial FD's are determined by a key of Movie

Actor and Director:
(these two tables have the same structure and will have the same NF
-BCNF as the only non trivial FD's are determined by the key of the table

*/

-- EXERCISE 2 a) ----------------------------------------------------------------------
-- for details see E/R schema for problem 1
-- Define the PRIMARY KEY constraints

ALTER TABLE Movie
ADD CONSTRAINT PK_Movie PRIMARY KEY (tid);

ALTER TABLE Director
ADD CONSTRAINT PK_Director PRIMARY KEY (nid);

ALTER TABLE Actor
ADD CONSTRAINT PK_Actor PRIMARY KEY (nid);

-- Define the FOREIGN KEY constraints with CASCADE options

ALTER TABLE Directs
ADD CONSTRAINT FK_Directs_nid
FOREIGN KEY (nid) REFERENCES Director(nid)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Starsin
ADD CONSTRAINT FK_Starsin_nid
FOREIGN KEY (nid) REFERENCES Actor(nid)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Directs
ADD CONSTRAINT FK_Directs_tid
FOREIGN KEY (tid) REFERENCES Movie(tid)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE Starsin
ADD CONSTRAINT FK_Starsin_tid
FOREIGN KEY (tid) REFERENCES Movie(tid)
ON DELETE CASCADE
ON UPDATE CASCADE;


-- EXERCISE 2 b) ----------------------------------------------------------------------
--Have a look at nid of Steven Spielberg before the operation
--SELECT * FROM Director WHERE name = 'Steven Spielberg';
--the nid is "nm0000229 "

--SELECT * FROM directs
--WHERE nid='nm0000229'
--get back 26 entries (director/movie)

CREATE VIEW old_direct AS
SELECT * FROM directs
WHERE nid='nm0000229';

-- To update the nid of Steven Spielberg
UPDATE Director
SET nid = '123456789'
WHERE name = 'Steven Spielberg';

--Have a look at nid of Steven Spielberg after the operation
--SELECT * FROM Director WHERE name = 'Steven Spielberg';
--the nid is "123456789"

--SELECT * FROM directs
--WHERE nid='123456789';
--get back the same 26 entries (director/movie)

CREATE VIEW new_direct AS
SELECT * FROM directs
WHERE nid='123456789';

--Now we verify that they are indeed the same
    SELECT * FROM old_direct
EXCEPT
    SELECT * FROM new_direct;
--check that this is empty so they are indeed the same set

DROP VIEW old_direct;
DROP VIEW new_direct;


-- EXERCISE 2 c) ----------------------------------------------------------------------
--Get the nid of Actor and Director Robert De Niro
SELECT * FROM Actor WHERE name = 'Robert De Niro';
--the nid is "nm0000134 "
SELECT * FROM Director WHERE name = 'Robert De Niro';
--He does not exist. Why does he not exists before ? 

SELECT * FROM Starsin WHERE nid = 'nm0000134';
--get back 33 entries (director/Movie)



--To delete the actor and director Robert De Niro

DELETE FROM Actor
WHERE name = 'Robert De Niro';

DELETE FROM Director
WHERE name = 'Robert De Niro';

SELECT * FROM Starsin WHERE nid = 'nm0000134';
--as expected it's empty, since the cascading works

-- Exercise 2 d) ----------------------------------------------------------------------
--Show an insertion that is not allowed according to your foreign keys

INSERT INTO directs(nid,tid)
VALUES('123456789','tt0012345');

--Show an update that is not allowed according to your foreign keys

UPDATE directs 
SET nid='nm0000134'
WHERE tid='tt0046345';

-- Exercise 3 a) ----------------------------------------------------------------------
--NOTE: THE CHUNKS OF CODE MUST BE RUN INDIVIDUALLY, AS OTHERWHISE THE RUNTIME GOES FROM A FEW
--		SECONDS TO NOT EVEN FINISHING IN 30 MIN
SELECT Director.name, COUNT(*) AS Directed_Movies
FROM Director
LEFT JOIN Directs ON Director.nid = Directs.nid
LEFT JOIN Actor ON Director.nid = Actor.nid
WHERE Actor.nid IS NULL
GROUP BY Director.name
ORDER BY Directed_Movies DESC
LIMIT 25;

-- Exercise 3 b) ----------------------------------------------------------------------
SELECT Actor1.name AS Actor1, Actor2.name AS Actor2, COUNT(*) AS Co_occurrences
FROM Starsin AS S1
JOIN Starsin AS S2 ON S1.tid = S2.tid AND S1.nid < S2.nid
JOIN Actor AS Actor1 ON S1.nid = Actor1.nid
JOIN Actor AS Actor2 ON S2.nid = Actor2.nid
GROUP BY Actor1.name, Actor2.name
ORDER BY Co_occurrences DESC
LIMIT 25;

-- Exercise 3 c) ----------------------------------------------------------------------

DROP Table IF EXISTS UnionActorDirector;
CREATE TABLE UnionActorDirector AS
SELECT *
FROM Actor
UNION
SELECT *
FROM Director;

DROP Table IF EXISTS WorksOn;
CREATE TABLE WorksOn AS
SELECT *
FROM Starsin
UNION
SELECT *
FROM Directs;

-- A-Priori Step 1: Materialize the frequent 1-itemsets into a new table Co_Occurences_Duo

DROP TABLE IF EXISTS Co_Occurrences_Duo;
CREATE TABLE Co_Occurrences_Duo(
	nid1 char(10),
	nid2 char(10),
	name1 varchar(128),
	name2 varchar(128),
	count_duo int
);

DELETE FROM Co_Occurrences_Duo;
INSERT INTO Co_Occurrences_Duo (
	SELECT DISTINCT person1.nid as nid1, person2.nid as nid2, person1.name as name1, person2.name as name2, COUNT(person1.nid)
	FROM UnionActorDirector as person1, UnionActorDirector as person2, WorksOn as w1, WorksOn as w2
	WHERE person1.nid = w1.nid 
	  and person2.nid = w2.nid
	  and w1.tid = w2.tid
	  and person1.nid < person2.nid
	GROUP BY person1.nid, person2.nid, person1.name, person2.name
	HAVING COUNT(person1.nid) >= 4
	ORDER BY COUNT(person1.nid) DESC
);

SELECT * FROM Co_Occurrences_Duo;  --Selection is made to check our results


-- Exercise 3 d) ----------------------------------------------------------------------

DROP TABLE IF EXISTS Co_Occurrences_Trio;
CREATE TABLE Co_Occurrences_Trio(
	nid1 char(10),
	nid2 char(10),
	nid3 char(10),
	name1 varchar(128),
	name2 varchar(128),
	name3 varchar(128),
	count_trio int
);

DELETE FROM Co_Occurrences_Trio;
INSERT INTO Co_Occurrences_Trio(
	SELECT DISTINCT person1.nid as nid1, person2.nid as nid2, person3.nid as nid3, person1.name as name1, person2.name as name2, person3.name as name3, COUNT(person1.nid)
	FROM UnionActorDirector as person1, UnionActorDirector as person2, UnionActorDirector as person3, WorksOn as w1, WorksOn as w2, WorksOn as w3
	WHERE person1.nid = w1.nid 
	  and person2.nid = w2.nid
	  and person3.nid = w3.nid
	  and w1.tid = w2.tid
	  and w2.tid = w3.tid
	  and person1.nid < person2.nid
	  and person2.nid < person3.nid
	GROUP BY person1.nid, person2.nid, person3.nid, person1.name, person2.name, person3.name
	HAVING COUNT(person1.nid) >= 4
	ORDER BY COUNT(person1.nid) DESC
);

SELECT * FROM Co_Occurrences_Trio;  --Selection is made to check our results

