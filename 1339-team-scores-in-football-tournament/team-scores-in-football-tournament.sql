# Write your MySQL query statement below
With point_cte as
(
select
    match_id,
    host_team,
    guest_team,
    case when host_goals > guest_goals then 3
         when host_goals < guest_goals then 0
         else 1 
    end as host_points,
    case when host_goals < guest_goals then 3
         when host_goals > guest_goals then 0
         else 1
    end as guest_points,
    host_goals,
    guest_goals
from
    matches
),
team_pts_cte as 
(
select 
    team_id,t.team_name, sum(host_points) as num_points
from
    teams t
left join
    point_cte
on
    t.team_id = host_team
group by host_team,t.team_name
union all
select 
   team_id,t.team_name, sum(guest_points) as num_points
from
    teams t
left join
    point_cte
on
    t.team_id = guest_team
group by guest_team,t.team_name
)
select 
    team_id, team_name, coalesce(sum(num_points),0) as num_points
from
    team_pts_cte
group by 1,2
order by 3 desc,1 asc