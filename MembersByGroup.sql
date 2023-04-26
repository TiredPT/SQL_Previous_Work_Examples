-- Finds the number of members in 1, 2, and 3 groups per wk

WITH ActiveMembers AS ( -- gives us members that are actively placed in groups

SELECT
    gm.userId as userId,
    gm.id as groupMemberId,
    g.id as groupId,
    #GROUP_CONCAT(g.name,' ') as groupName,
    CONCAT(u.firstName, ' ',u.lastName) as memberName,
    DATE(gm.startDate) as groupStartDate,
    DATE(gm.endDate) as groupEndDate, 
    COUNT(DISTINCT gm.id) as currentActiveGroups
    
    
FROM 
    paceprod.Users u 
join paceprod.GroupMembers gm on gm.userId = u.id 
join paceprod.Memberships m on m.userId = u.id 
join paceprod.Groups g on g.id = gm.groupId

where
    gm.startDate IS NOT NULL and -- were placed in a group at some point
    gm.endDate IS NULL and -- still active in the groups
    gm.isFacilitator IS NOT TRUE and -- only members 
    gm.isTempMember IS NOT TRUE and 

    -- removes all internal groups
    g.isInternal is not true and 
    g.skipInMetrics != 1 and 
    g.groupTypeId != 'a54e3abf-69be-4115-bfe5-dd04fdc7d049' and 
    g.groupTypeId != 'd8ef8e02-e666-47b1-ba5b-55b2d02b66d5' and
    g.groupTypeId != '59d5603c-f112-4687-8cb9-516467c91ae5' and 
    g.id != 'd67de29b-1dad-4a44-971b-2831ea49f47b' and
    g.id != 'b8e98060-85ad-46bc-b546-4369351db09b' and
    g.id != '6f711176-4ff1-4100-a3e3-14271a229b31' and 
    g.id != '8a184429-eb42-48b4-a3ea-1c7658524aa5' and 
    g.id != '22531d56-d5f7-4a27-8fae-cf79e07941b7'

group by 
    gm.userId    

),

ActiveSessions AS ( -- want the sessionWeek

    SELECT s.id AS sessionId,
           s.groupId AS groupId,
           s.date AS sessionDate,
           s.isPopUp,
           DATE_SUB(DATE(s.date), INTERVAL DAYOFWEEK(s.date)-1 DAY) as sessionWeek
      FROM paceprod.Sessions s
)

SELECT
    ass.sessionWeek as "Week Cohort",
    SUM(case when am.currentActiveGroups = 1 then 1 else 0 end) as 'Members in 1 Group',
    SUM(case when am.currentActiveGroups = 2 then 1 else 0 end) as 'Members in 2 Groups',
    SUM(case when am.currentActiveGroups = 3 then 1 else 0 end) as 'Members in 3 Groups',
    SUM((case when am.currentActiveGroups = 1 then 1 else 0 end) +
        (case when am.currentActiveGroups = 2 then 1 else 0 end) +
        (case when am.currentActiveGroups = 3 then 1 else 0 end)) as 'Total'

FROM
    ActiveMembers am 

join ActiveSessions ass on ass.groupId = am.groupId

where
    ass.sessionWeek <= NOW()

group by    
    ass.sessionWeek 

order by   
    ass.sessionWeek desc 

LIMIT 12