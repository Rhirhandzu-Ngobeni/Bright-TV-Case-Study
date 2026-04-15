--Checking the subscribers User profile columns
select *
from subscribers
limit 5;

--Total number of subscribers
select count(userid)
from subscribers;
--Outcome: 5375

--Checking for nulls, blanks, spaces and nones
select gender, count(*)
from subscribers
group by gender;
--Outcome: 702 Nones and 218 Blanks

select race, count(*)
from subscribers
group by race;
--Outcome: 1078 Nones and 231 Blanks

select age, count(*)
from subscribers
group by age
order by age asc;
--Outcome No blanks

select province, count(*)
from subscribers
group by province;
--Outcome: 702 Nones and 218 Blanks

--Create a new clean table that groups nones and blanks to 'Unknown' in categorical column (Gender, Race and Province) and segment Age
create table Subscribers1 as
select
UserID,
case
when gender is null or trim(lower(gender)) in ('') or gender = 'None' then 'Unknown'
else trim(gender)
end as Gender1,
case
when Race is null or trim(lower(Race)) in ('') or Race = 'None' then 'Unknown'
else trim(Race)
end as Race1,
case
when Province is null or trim(lower(Province)) in ('') or Province = 'None' then 'Unknown'
else trim(Province)
end as Province1,
case
when age between 0 and 19 then 'Children'
when age between 20 and 39 then 'Young Adult'
when age between 40 and 64 then 'Middle-Aged Adult'
else 'Senior Citizen'
end as Age_segment
from subscribers;

--Checking the new table
select *
from subscribers1;

--Checking the count of age segments
select age_segment, count(*)
from subscribers1
group by age_segment;

-------------------------------------------------------------------------------------------------------------------
--Checking the viewership columns
select *
from viewers
limit 5;

--Having tow user ids is a problem.
--Checking for mismatches
select 
Userid0,
Userid4
from viewers
where userid0 <> userid4;
--Outcome: 485 mismatches

--To solve this I will merge both UserIDs on a new table, convert the UTC to SA Time, create a day name and hours
create table Viewers1 as
select 
Userid0 as UserID,
Channel2 as Channel,
Dateadd(hour,2,Recorddate2) as SA_Time,
Dayname(SA_Time) as Day_Name,
hour(SA_Time) as Hour_Of_Day,
`Duration 2` as Duration
from viewers
where userid0 is not null
union
select 
Userid4 as UserID,
Channel2 as Channel,
Dateadd(hour,2,Recorddate2) as SA_Time,
Dayname(SA_Time) as Day_Name,
hour(SA_Time) as Hour_Of_Day,
`Duration 2` as Duration
from viewers
where userid0 is not null;

--Checking new table
select *
from viewers1;

--Checking the total records on the new table
select count(*)
from viewers1;
--Total 10480

----------------------------------------------------------------------------------------------------------------------------------------
--Joining the two tables (Subscribers1 and Viewers1) to form BrightTV1

create table BrightTV1 as
select
s.UserID,
s.gender1,
s.race1,
s.province1,
s.age_segment,
v.channel,
v.Day_name,
v.Hour_of_day,
case
when hour_of_day between 6 and 11 then 'Morning'
when hour_of_day between 12 and 17 then 'Afternoon'
when hour_of_day between 18 and 22 then 'Evening'
when hour_of_day between 0 and 5 then 'Late Night'
else 'Late Night'
end as Time_of_Day,
v.Duration,
(hour(v.duration) * 60) + minute(v.duration) as duration_minutes,
case
when v.channel is null then 'Inactive'
else 'Active'
end as Activity_status
from subscribers1 s
left join viewers1 v
on s.UserID=v.UserID;
 
--Checking the new table 
select *
from BrightTv1;

--Checking Active vs Inactive
select 
Count(distinct(userid)) , Activity_Status
from brighttv1
group by Activity_status;
