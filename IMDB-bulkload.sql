-- NOTES:
-- 1) all input files in TSV format need to be located in a directory that is accessible by Postgres (e.g. /tmp)
-- 2) the first header line (with the column names) needs to be removed for the COPY commands to work properly

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

DROP Table IF EXISTS Movie;
CREATE TABLE Movie(
	tid 	char(100),
	title 	char(10),
	year	numeric,
	length	numeric,
	rating	numeric
);

DROP Table IF EXISTS Director;
CREATE TABLE Director(
	nid 		char(100),
	name		char(10),
	birthYear	numeric,
	deathYear	numeric
);

DROP Table IF EXISTS Actor;
CREATE TABLE Actor(
	nid			char(100),
	name		char(10),
	birthYear	numeric,
	deathYear	numeric
);

INSERT INTO Actor (SELECT DISTINCT primaryName AS name, birthYear AS birthYear, deathYear AS deathYear 
				   FROM Persons WHERE persons.primaryProfession = 'actor' OR persons.primaryProfession = 'actress');