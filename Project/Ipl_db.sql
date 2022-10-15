/*Create database schema to load the tablesa and set it default one*/
CREATE DATABASE ipl_db;

use ipl_db;

/*Create tables to store data*/
CREATE TABLE ipl_db.matches(
id integer, season integer, city varchar(30), date date,
team1 varchar(40), team2 varchar(40), toss_winner varchar(40), toss_decision 
varchar(30), 
result varchar(50), dl_applied integer, winner varchar(40), win_by_runs 
integer, win_by_wickets integer, 
player_of_the_match varchar(30), venue varchar(50), umpire1 varchar(40), 
umpire2 varchar(40), umpire3 integer
);

CREATE TABLE ipl_db.deliveries (
 matchid integer, inning integer, batting_team varchar(40), bowling_team 
varchar(40), 
 overs integer, ball integer, batsman varchar(30), non_striker varchar(30), bowler 
varchar(30), 
 is_super_over integer, wide_runs integer, bye_runs integer, legbye_runs integer, 
noball_runs integer, 
 penalty_runs integer, batsman_runs integer, extra_runs integer, total_runs integer, 
 player_dismissed varchar(30), dismissal_kind varchar(40), fielder varchar(40)
);

SHOW GLOBAL VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile=1;
load data local infile 'C:/Users/LEN 8AIN/OneDrive/Documents/Hithesh DA/Project 1/matches'
into table ipl_db.matches
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;

load data local infile 'C:/Users/LEN 8AIN/OneDrive/Documents/Hithesh DA/Project 1/deliveries'
into table ipl_db.deliveries
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;

select * from matches;

alter table matches
add column Date_of_match date;

update matches
set date_of_match = str_to_date(date, "%d/%m/%Y");

/*Basic queries*/
select season, city, date, team1, team2, winner, win_by_runs from 
matches
where season='2017'
limit 5;

Select distinct(team1)
from matches;

/*Season with most number of matches*/
select season, count(*)
from matches
group by season
order by count(*) desc;

/*Team with the most number of wins*/
select winner, count(*)
from matches
group by winner
order by count(*) desc;

/*Player with most number of player_of_match awards*/
select player_of_match, count(*)
from matches
group by player_of_match
order by count(*) desc
limit 1;

select * from matches;

/*Number of matches in each venue*/
select venue, count(*)
from matches
group by venue
order by count(*) desc
limit 1,40;

/*Champions of each season*/
select id, season, winner
from matches 
where id in
(select max(id) as id
from matches
group by season)
order by season;

select * from matches;

/*Toss decision percentage*/
select count(*)/756*100 as toss_dec_per, toss_decision
from matches 
group by toss_decision;

/*Toss decision varied over time*/
select season, toss_decision, count(*) as toss_dec_per
from matches 
group by toss_decision, season
order by season;

select * from deliveries;

/*Top run scorers in ipl*/
select batsman, sum(total_runs)
from deliveries
group by batsman
order by sum(total_runs) desc;

/*Highest number of boundaries by a batsman*/
select batsman, count(batsman_runs)
from deliveries
where batsman_runs = '4'
group by batsman
order by count(batsman_runs) desc;

/*Highest number of sixes by a batsman*/
select batsman, count(batsman_runs)
from deliveries
where batsman_runs = '6'
group by batsman
order by count(batsman_runs) desc;

/*Most dot balls faced by a batsman*/
select batsman, count(total_runs)
from deliveries
where total_runs = '0'
group by batsman
order by count(total_runs) desc;

/*Numbers of balls bowled by a bowler*/
select bowler, count(*)
from deliveries
group by bowler
order by count(*) desc;

/*Numbers of dot balls bowled by a bowler*/
select bowler, count(*)
from deliveries
where batsman_runs = '0'
group by bowler
order by count(*) desc;

/*Most common dismissal type's*/
select dismissal_kind, count(*)
from deliveries
where dismissal_kind is not null
group by dismissal_kind
order by count(*) desc
limit 1,20;

/*Find venue of 10 most recently played matches*/
select DISTINCT venue, date_of_match
from matches
order by date_of_match desc
limit 10;

/*Case when for (4,6, single,0)*/
select distinct batsman, bowler, ball, 
case 
when total_runs=1 then 'Single'
when total_runs=4 then 'Boundry'
when total_runs=6 then 'Six'
else 'Duck'
end as 'Run in words' from deliveries;

/*How many extra runs have been conceded in ipl*/
select distinct bowler, sum(extra_runs) 
from deliveries
group by bowler
having sum(extra_runs)>0;
 
/*How many boundaries (4s or 6s) have been hit in ipl*/
select m.winner, d.total_runs, count(d.total_runs) 
from deliveries d inner join matches m on m.id=d.matchid
where d.total_runs in (4,6)
group by m.winner, d.total_runs;

/*How many matches were played in the month of April*/
select count(*) 
from matches
where month(date_of_match)='4';

/*How many matches were played in the March and June*/
select count(*) 
from matches
where month(date_of_match) in ('3','6');

/*Total number of wickets taken in ipl (count not null values)*/
select count(player_dismissed) as 'Wicket' 
from deliveries
where player_dismissed <>"";

/*Top 10 players with max boundaries (4 or 6)*/
select DISTINCT batsman, count(total_runs) 
from deliveries
where total_runs in (4,6)
group by batsman 
order by 2 desc
limit 10;

/*Top 10 wicket takers*/
select bowler, count(player_dismissed) as NoWicket_Taken
from deliveries
where dismissal_kind <>""
group by bowler
order by NoWicket_Taken desc
limit 10;

/*Name and number of wickets by bowlers who have taken more than or equal to 100 wickets in ipl*/
select bowler, count(player_dismissed) as NoWicket_Taken
from deliveries
where dismissal_kind <>"" 
group by bowler
having count(player_dismissed) >=100
order by NoWicket_Taken desc
limit 10;