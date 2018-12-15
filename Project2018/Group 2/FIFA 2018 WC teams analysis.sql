Use sys;

drop table team_1_value;
Create table team_1_value as(
select Nationality as team,sum(Overall) value from sofifa group by 1);

#chart 1 team ranking intermediate
drop table team_1_results;
Create table team_1_results as(
select a.*,home_score-away_score as home_gd,away_score-home_score as away_gd,
case when home_score>away_score then 3
when home_score<away_score then 0
when home_score=away_score then 1 end as home_points,
case when away_score>home_score then 3
when away_Score<home_score then 0
when away_Score=home_score then 1 end as away_points from matches a);

drop table team_1_home;
Create table team_1_home as(
(select match_id,match_date,`home_team.home_team_name` as team,home_points points,home_gd gd from team_1_results) union 
(select match_id,match_date,`away_team.away_team_name` as team,away_points points,away_gd gd from team_1_results) );

#rank table
drop table team_1_rank_notopas ;
create table team_1_rank_notopas as(
select team,pnts,gds,rank() over(order by pnts DESC,gds DESC)+2 ranks from
(select team,sum(points) as pnts,sum(gd) gds from team_1_home group by 1) a
where team!='Croatia' and team!='France') ;

insert into team_1_rank_notopas values
('Croatia',14,5,2);
insert into team_1_rank_notopas values
('France',19,8,1);

#chart 1 rank table final
select * from team_1_rank_notopas;
select team,value,prev_rank,ranks from team_1_rank_value_prev;

create table team_1_rank_value as(
select a.*,b.value from team_1_rank_notopas a left join team_1_value b on a.team=b.team);

#prev rank
#create table sys.prev_ranks as(select * from database.prev_ranks);

Create table team_1_rank_value_prev as(
select a.*,b.rank as prev_rank from team_1_rank_value a left join prev_ranks b on a.team=b.team);

#Chart 1 final table
select * from team_1_rank_value_prev;
delete from team_1_rank_value_prev where value is null;
#team chart 2
drop table team_2_points ;
create table team_2_points as(
select team,match_id,RANK( ) OVER (PARTITION BY team ORDER by match_id) as rnk,points as points,gd as gd
 from team_1_home);
 
#team char 2 final table
select* from team_2_points;



##chart 3- attack#####

create table team_3_attack1 as(
((select match_id,`home_team.home_team_name` as team_name,home_score as score from matches) union
(select match_id,`away_team.away_team_name` as team_name,away_score as score from matches)));

create table team_3_attack3 as(
select team_name,avg(score) as avg_score from team_3_attack1 group by team_name);

select * from team_3_attack3;

###xg
create table team_3_attack4 as(
select `team.name` as team_name,avg(round(`shot.statsbomb_xg`,2)) avg_xg from events 
where `type.name`='shot' group by 1);

select * from team_3_attack4;

###shots
drop table team_3_attack5 ;
create table team_3_attack5 as(
select match_id,`possession_team.name` as team_name,count(*) as shots
 from events where `type.name`='shot' group by 1,2);

select *from team_3_attack5;

create table team_3_attack8 as(
select team_name,avg(shots) shots from team_3_attack5 group by 1);

select * from team_3_attack8;
##successful dribbles
create table team_3_attack6 as(
select match_id,`possession_team.name` as team_name,count(*) as dribbles from events where `dribble.outcome.id`=8
group by 1,2);

create table team_3_attack7 as(
select team_name,avg(dribbles) dribbles from team_3_attack6 group by 1);

select * from team_3_attack7;


drop table team_3_attack9 ;
Create table team_3_attack9 as(
select a.*,b.avg_xg,b.shots from team_3_attack3 a left join 
(select a.*,b.shots from team_3_attack4 a left join team_3_attack8 b on a.team_name=b.team_name) b on
a.team_name=b.team_name group by 1,2,3,4);

drop table team_3_attack10 ;
create table team_3_attack10 as(
select a.*,b.dribbles from team_3_attack9 a left join team_3_attack7 b on a.team_name=b.team_name);

#####Final attack#################
select * from team_3_attack10;
##################################







##chart 3- defense

####goals conceded
create table team_3_defense1 as(
((select match_id,`home_team.home_team_name` as team_name,away_score as conceded from matches) union
(select match_id,`away_team.away_team_name` as team_name,home_score as conceded from matches)));

create table team_3_defense2 as(
select team_name,avg(conceded) as conceded from team_3_defense1 group by 1);

select * from team_3_defense2;

#####Saves
drop table team_3_defense3 ;
create table team_3_defense3 as(
select match_id,`team.name` as team_name, count(*) as saves from events where `related_events.0` in (select id from events where
`type.name` = 'Shot' and `shot.outcome.name`='Saved' group by 1) group by 1,2);

select * from team_3_defense3;

create table team_3_defense33 as(
select team_name,avg(saves) as saves from team_3_defense3 group by 1);

#####Blocks
drop table team_3_defense4 ;
create table team_3_defense4 as(
select match_id,`team.name` as team_name, count(*) as blocks from events where `type.name`='Block' group by 1,2);


create table team_3_defense44 as(
select team_name,avg(blocks) as blocks from team_3_defense4 group by 1);

select * from team_3_defense4;

drop table team_3_defense5 ;
Create table team_3_defense5 as(
select a.*,b.saves,b.blocks from team_3_defense2 a left join 
(select a.*,b.blocks from team_3_defense33 a left join team_3_defense44 b on a.team_name=b.team_name) b on
a.team_name=b.team_name group by 1,2,3,4);


######Final table Defense######################
select * from team_3_defense5;
################################################




######Chart 3 - Midfield

##possession
drop table team_3_mids1 ;
create table team_3_mids1 as(
select match_id,`possession_team.name` as team_name,sum(duration) dur from events group by 1,2);
select *,sum(dur) from team_3_mids1 group by 1 limit 10;
#drop table team_3_mid1 ;
#create table team_3_mid1 as(
#select match_id,timestamp,possession,`possession_team.name` as tn, rank() over(partition by match_id,
#`possession_team.name`,possession order by timestamp) ranks 
#from events group by 1,2,3,4);

#select * from team_3_mid1 where match_id=7525;

#create table team_3_mid2 as(
#select a.match_id,a.possession,a.tn as team_name,a.timestamp-b.timestamp as diff from team_3_mid1 a left join 
#team_3_mid1 b on a.ranks=b.ranks+1 and a.match_id=b.match_id and a.tn=b.tn);

#select count(*) from team_3_mid2 limit 20;
drop table team_3_mids2 ;
create table team_3_mids2 as(
select a.*, b.total,round((a.dur/b.total)*100) as possession 
from team_3_mids1 a left join (select *,sum(dur) total from team_3_mids1 group by 1)
b on a.match_id=b.match_id);

create table team_3_mids3 as(
select team_name,avg(possession) as poss from team_3_mids2 group by team_name);

####pass
drop table team_3_mids4;
create table team_3_mids4 as(
select match_id,`possession_team.name` as team_name,count(*) as passes
from events where `type.name` ='Pass' group by 1,2);

create table team_3_mids5 as(
select team_name,avg(passes) as passes from team_3_mids4  group by 1);

select * from team_3_mids5;
create table sys.team_3_mids6 as (select * from root.passacc);

select * from team_3_mids6 ;
Update `team_3_mids6` set `team_name`='Colombia' where `team_name`='Columbia';
##final table
drop table team_3_mids7 ;
Create table team_3_mids7 as(
select a.*,b.pass_acc,b.passes from team_3_mids3 a left join (select a.*,b.pass_acc from team_3_mids5 a
left join team_3_mids6 b on a.team_name=b.team_name) b on a.team_name=b.team_name);

##Final mid#########################
select * from team_3_mids7;
#######################################




###########run#############
drop table team_4_run1 ;
create table team_4_run1 as(
select team_name,sum(dist) as dist from player_3_mid12 group by 1);

select * from team_4_run1;

drop table team_4_run2 ;
create table team_4_run2 as(
select a.team_name,a.dist*4,b.goals,round(a.dist*4/b.goals) as km_goal from team_4_run1 a join (select team_name,sum(score) as goals from 
team_3_attack1 group by 1) b
on a.team_name=b.team_name);

select * from team_4_run2 ;

drop table team_4_run3;
create table team_4_run3 as(
select a.*,b.passes,round(b.passes/a.goals) as passes_goal from team_4_run2 a left join (select team_name,
sum(passes) passes from team_3_mids4 group by 1) b
on a.team_name=b.team_name);