-- NOTES:
-- 1) all input files in TSV format need to be located in a directory that is accessible by Postgres (e.g. /tmp)
-- 2) the first header line (with the column names) needs to be removed for the COPY commands to work properly

-- NOTE: The code to import the data into Persons, Titles,... is commented to avoid having to run
-- intensive code multiple times, DONT FORGET TO UNCOMMENT FOR SUBMISSION

--Exercise 1 a) ----------------------------------------------------------------------

/*DROP TABLE IF EXISTS Persons;
CREATE TABLE Persons (
 nid char(10),
 primaryName varchar(128),
 birthYear int,
 deathYear int,
 primaryProfession varchar(128),
 knownForTitles varchar(128));
COPY Persons FROM '/tmp/name.basics.tsv' NULL '\N' ENCODING 'UTF8';
SELECT * FROM Persons LIMIT 100;

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
SELECT * FROM Titles LIMIT 100;
     
DROP TABLE IF EXISTS Principals;
CREATE TABLE Principals (
 tid char(10),
 ordering int,
 nid char(10),
 category varchar(32),
 job varchar(512),
 characters varchar(2048));
COPY Principals FROM '/tmp/title.principals.tsv' NULL '\N' ENCODING 'UTF8';
SELECT * FROM Principals LIMIT 100;
    
DROP TABLE IF EXISTS Ratings;
CREATE TABLE Ratings (
        tid char(10),
        avg_rating numeric,
        num_votes numeric);
COPY Ratings FROM '/tmp/title.ratings.tsv' NULL '\N' ENCODING 'UTF8';
SELECT * FROM Ratings LIMIT 100; */

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
 tid char(10),
 title varchar(1024),
 year int,
 length int,
 rating numeric
);

DROP Table IF EXISTS Director;
CREATE TABLE Director(
 nid char(10),
 name varchar(128),
 birthYear int,
 deathYear int
);

DROP Table IF EXISTS Actor;
CREATE TABLE Actor(
 nid char(10),
 name varchar(128),
 birthYear int,
 deathYear int
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
SELECT * FROM Director WHERE name = 'Steven Spielberg';
--the nid is "nm0000229 "

-- To update the nid of Steven Spielberg
UPDATE Director
SET nid = '123456789'
WHERE name = 'Steven Spielberg';

--Have a look at nid of Steven Spielberg after the operation
SELECT * FROM Director WHERE name = 'Steven Spielberg';
--the nid is "123456789"



-- EXERCISE 2 c) ----------------------------------------------------------------------
-- To delete the actor and director Robert De Niro
DELETE FROM Actor
WHERE name = 'Robert De Niro';

DELETE FROM Director
WHERE name = 'Robert De Niro';