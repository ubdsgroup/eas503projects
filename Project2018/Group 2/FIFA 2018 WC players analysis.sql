drop table player_class1;
create table player_class1 as(
select `player.name` as player,`position.name` as position,count(*) as times from events group by 1,2);

drop table player_class2 ;
create table player_class2 as(
select player,position,rank() over(partition by player order by times desc) as ranks from player_class1);
delete from player_class2 where player='';

Create table player_class3 as(
select player,position from player_class2 where ranks=1 group by 1,2);


drop table player_1_value;
Create table player_1_value as(
select player as team,sum(Overall) value from sofifa group by 1);

select * from sofifa1 limit 10;

########Attackers###########
drop table player_1_attack1 ;
Create table player_1_attack1 as(
select match_id,`team.name` as team_name,`player.name` as player,count(*) as goals
from events where `shot.outcome.name`='Goal' and `shot.type.name`='Open Play' and `player.name` in 
(select player from player_class3 where position in 
('Center Forward',
'Center Attacking Midfield',
'Left Center Forward',
'Right Center Forward',
'Right Wing',
'Left Wing',
'Secondary Striker',
'Left Attacking Midfield',
'Right Attacking Midfield')) group by 1,2,3);



drop table player_1_attack11 ;
create table player_1_attack11 as(
select a.team_name,a.player,round(sum(a.goals),2) as goals from player_1_attack1 a group by a.team_name,a.player);

select * from player_1_attack12 where player like '%Cahil%';

drop table player_1_attack12 ;
Create table player_1_attack12 as(
select `team.name` as team_name,`player.name` as player,count(distinct match_id) as matches 
from events where 
 `player.name` in 
(select player from player_class3) group by 1,2);



drop table player_1_attack13 ;
create table player_1_attack13 as(
select a.team_name,a.player,a.goals,b.matches,round((goals/matches),2) as goalspm from player_1_attack11 a left join 
player_1_attack12 b on a.team_name=b.team_name and a.player=b.player);

select * from player_1_attack13;



#######Shots

drop table player_1_attack2 ;
create table player_1_attack2 as(
select match_id,`team.name` as team_name,`player.name` as player,count(*) as shots,
avg(round((`shot.statsbomb_xg`),2)) as diff from events where `type.name`='Shot'
and `player.name` in 
(select player from player_class3 where position in 
('Center Forward',
'Center Attacking Midfield',
'Left Center Forward',
'Right Center Forward',
'Right Wing',
'Left Wing',
'Secondary Striker',
'Left Attacking Midfield',
'Right Attacking Midfield')) group by 1,2,3);

drop table player_1_attack22;
create table player_1_attack22 as(
select a.team_name,a.player,round(sum(a.shots),2) as shots,round(sum(a.diff),2) as diff
 from player_1_attack2 a group by a.team_name,a.player);


drop table player_1_attack24 ;
create table player_1_attack24 as(
select a.team_name,a.player,a.shots,a.diff,b.matches,round((shots/matches),2) as shotspm 
,round((diff/matches),2) as diffpm from player_1_attack22 a left join 
player_1_attack12 b on a.team_name=b.team_name and a.player=b.player);

select * from player_1_attack24;

select CAST(`shot.end_location.2` as unsigned) from events group by 1;
select * from player_1_attack3;
###shots on target
drop table player_1_attack3 ;
create table player_1_attack3 as(
select  match_id,`team.name` as team_name,`player.name` as player,count(*) as sot
from events where 
`shot.end_location.0`!='' and `shot.end_location.1`!='' and CAST(`shot.end_location.1` as unsigned)>=36 
and  CAST(`shot.end_location.1` as unsigned)<=43 and CAST(`shot.end_location.0` as unsigned)>=114 and
CAST(`shot.end_location.2` as unsigned)<3
and `type.name`='Shot'
and `player.name` in 
(select player from player_class3 where position in 
('Center Forward',
'Center Attacking Midfield',
'Left Center Forward',
'Right Center Forward',
'Right Wing',
'Left Wing',
'Secondary Striker',
'Left Attacking Midfield',
'Right Attacking Midfield')) group by 1,2,3);

select * from player_1_attack3;

drop table player_1_attack33 ;
create table player_1_attack33 as(
select a.team_name,a.player,round(sum(a.sot),2) as sot
 from player_1_attack3 a group by a.team_name,a.player);

drop table player_1_attack34 ;
create table player_1_attack34 as(
select a.team_name,a.player,a.sot,b.matches,round((sot/matches),2) as sotpm 
 from player_1_attack33 a left join 
player_1_attack12 b on a.team_name=b.team_name and a.player=b.player);


select * from player_1_attack34;


drop table player_1_attack4 ;
create table player_1_attack4 as(
select a.*,b.goalspm as goals,b.sotpm as sot from player_1_attack24 a left join 
(select a.*,b.sotpm from player_1_attack13 a left join
player_1_attack34 b on a.team_name=b.team_name and a.player=b.player) b on 
a.team_name=b.team_name and a.player=b.player);

select * from player_1_attack4;

drop table player_1_attack5 ;
create table player_1_attack5 as(
select team_name,player,shotspm as shots,diffpm as diff,goals,sot,round(goals/shots,2) as scoring_ratio from player_1_attack4);



##############################Final attack table#########################################
select * from player_1_attack5;
#########################################################################################


use soccer;
#############Midfield##############
drop table player_3_mid1;

create table player_3_mid1 as(
select match_id,`team.name` as team_name,`player.name` as player,count(*) as passes from events
where `type.name`='Pass' 
and `player.name` in 
(select player from player_class3 where position in 
('Center Defensive Midfield',
'Left Center Midfield',
'Left Midfield',
'Right Midfield',
'Right Center Midfield',
'Left Defensive Midfield',
'Right Defensive Midfield',
'Center Midfield')) group by 1,2,3);
select * from player_3_mid1;

drop table player_3_mid2 ;
create table player_3_mid2 as(
 select match_id,`team.name` as team_name,`player.name` as player,count(*) as disp from events where 
`type.name`='Dispossessed' 
and `player.name` in 
(select player from player_class3 where position in 
('Center Defensive Midfield',
'Left Center Midfield',
'Left Midfield',
'Right Midfield',
'Right Center Midfield',
'Left Defensive Midfield',
'Right Defensive Midfield',
'Center Midfield')) group by 1,2,3);

select count(*) from player_3_mid1;

drop table player_3_mid4;
create table player_3_mid4 as(
select a.*,b.disp from player_3_mid1 a left join player_3_mid2 b on a.match_id=b.match_id
and a.team_name=b.team_name and a.player=b.player);

select * from player_3_mid4 where player like '%Luka %';
drop table player_3_mid5;
create table player_3_mid5 as(
select team_name,player,round(avg(passes)) as passes,round(avg(disp),2) as disp from player_3_mid4 group by match_id);

Update player_3_mid4 set disp=0 where disp is null;

##############Final mid table##############
select * from player_3_mid5;
###########################################


drop table player_3_mid6 ;
create table player_3_mid6 as(
select match_id,`team.name` as team_name,`player.name` as player,`location.0` as location0,`location.1` as location1,
rank() over(partition by match_id,`player.name` order by timestamp) ranks from events where
`player.name`!='' and `location.0`!=0 and `player.name` in (select `player.name` from player_class3 where position in 
('Center Defensive Midfield',
'Left Center Midfield',
'Left Midfield',
'Right Midfield',
'Right Center Midfield',
'Left Defensive Midfield',
'Right Defensive Midfield',
'Center Midfield')));

select * from player_3_mid7 where player like '%Luka Mo%' ;

create table player_3_mid7 as(
select a.*,b.matches from player_3_mid6 a left join
(select `team.name` as team_name,count(distinct match_id) as matches from events group by 1)
b on a.team_name=b.team_name);

select * from player_3_mid8 limit 11;

#create table player_3_mid8 as(
#select * from player_3_mid7 where matches>3);

drop table player_3_mid9 ;
create table player_3_mid9 as(
select a.*,b.location0 as location2,b.location1 as location3 from player_3_mid7 a left join player_3_mid8 b 
on a.match_id=b.match_id and a.player=b.player where a.ranks =b.ranks+1);

select team_name from player_3_mid9 group by 1;

drop table player_3_mid11 ;
create table player_3_mid11 as(
select player,location0,location1,count(*) as events from player_3_mid8 group by 1,2,3);

drop table player_3_mid12 ;
create table player_3_mid12 as(
select match_id,team_name,player,sum(sqrt(POWER((location0 - location2),2) + POWER((location1 - location3),2 )))*0.00091 as dist
from player_3_mid9 group by 1,2,3);

drop table player_3_mid_final ;
create table player_3_mid_final as(
select a.*,b.dist from player_3_mid5 a left join
(select team_name,player,round(sum(dist)*2.8,2) as dist from player_3_mid12 group by 1,2) b 
on a.team_name=b.team_name and a.player=b.player group by 1,2);


#######################Final final mid table###############
select * from player_3_mid_final;
#############################################################

#create table team_4_run1 as(
#select team_name,sum(dist) as dist from player_3_mid_final fr


select team_name,player,round(sum(dist)*2.8,2) as dist from player_3_mid12 group by 1,2;
##############Defense
drop table player_2_def1 ;
create table player_2_def1 as(
select match_id,`team.name` as team_name,`player.name` as player,count(*) as duels_won from events where `duel.type.name`='Tackle' and
(`duel.outcome.name`='Won' or `duel.outcome.name` like '%Success%') and `position.name` like '%Back%' group by 1,2,3);

select * from player_2_def1;

drop table player_2_def2 ;
create table player_2_def2 as(
select match_id,`team.name` as team_name,`player.name` as player,count(*) as duels_lost from events where `duel.type.name`='Tackle' and
`duel.outcome.name` like '%Lost%' and `position.name` like '%Back%' group by 1,2,3);
select * from player_2_def2;

drop table player_2_def3 ;
create table player_2_def3 as(
select a.*,b.duels_lost from player_2_def1 a left join player_2_def2 b on a.match_id=b.match_id
and a.team_name=b.team_name and a.player=b.player);

drop table player_2_def32;
create table player_2_def32 as(
select team_name,player,sum(duels_won) duels_won,sum(duels_lost) duels_lost from player_2_def3 group by team_name,player);

#create table player_2_def33 as(
#select a.*,b.matches from player_2_def3 a left join player_1_attack12 b on a.player=b.player);

#use soccer;
#Update player_2_def4 set duels_lost=0 where duels_lost is null;
select * from player_2_def32;

drop table player_2_def5 ;
create table player_2_def5 as(
select match_id,`team.name` as team_name,`player.name` as player,count(*) as clearances from events where `type.name`='Clearance'
 and `position.name` like '%Back%' group by 1,2,3);
 
 select * from player_2_def5;
 
drop table player_2_def6 ;
create table player_2_def6 as(
select team_name,player,round(sum(clearances),2) as clearances from player_2_def5
group by team_name,player); 
 
 
drop table player_2_def7 ;
 create table player_2_def7 as(
 select a.*,b.clearances from player_2_def32 a left join player_2_def6 b on a.team_name=b.team_name
 and a.player=b.player);
 
 select * from player_2_def7;
 
 
drop table player_2_def8 ;
create table player_2_def8 as(
select match_id,`team.name` as team_name,`player.name` as player,count(*) as blocks from events where `type.name`='Block'
 and `position.name` like '%Back%' group by 1,2,3);
 select * from player_2_def8;
 
drop table player_2_def9 ;
create table player_2_def9 as(
select team_name,player,round(sum(blocks),2) as blocks from player_2_def8
group by team_name,player);


drop table player_2_def10 ;
 create table player_2_def10 as(
 select a.*,b.blocks from player_2_def7 a left join player_2_def9 b on a.team_name=b.team_name
 and a.player=b.player);

drop table player_2_def11;
create table player_2_def11 as(
select match_id,`team.name` as team_name,`player.name` as player,count(*) as cards from events where `foul_committed.card.id`!=''
 and `position.name` like '%Back%' group by 1,2,3);

drop table player_2_def12 ;
create table player_2_def12 as(
select team_name,player,round(sum(cards),2) as cards from player_2_def11
group by team_name,player);

drop table player_2_def13 ;
 create table player_2_def13 as(
 select a.*,b.cards from player_2_def10 a left join player_2_def12 b on a.team_name=b.team_name
 and a.player=b.player);

drop table player_2_def14 ;
create table player_2_def14 as(
select a.*,b.matches from player_2_def13 a left join player_1_attack12 b on a.team_name=b.team_name
and a.player=b.player);

select * from player_2_def14;

create table player_2_def15 as(
select team_name,player,round(duels_won/matches,2) duels_won,round(duels_lost/matches,2) duels_lost,
round(clearances/matches,2) clearances,round(blocks/matches,2) blocks,
round(cards/matches,2) as cards from player_2_def14);

use soccer;
select * from player_2_def15;

show databases;

update player_2_def15 set blocks=0 where blocks is null;

