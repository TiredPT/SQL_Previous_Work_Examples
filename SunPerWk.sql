## Finds how many groups have ended per wk

WITH SunsettingGroups AS (

select    
    g.id as groupId,
    g.name as groupName,
    DATE(g.startDate) as startDate,
    DATE(g.endDate) as endDate,
    DATE_SUB(DATE(g.endDate), INTERVAL DAYOFWEEK(g.endDate)-1 DAY) as endDateWeek
from 
    paceprod.Groups g 
where 
    g.startDate IS NOT NULL and 
    g.endDate IS NOT NULL

    # We need to get Groups to exclude internal and other random groups.
        AND g.isInternal is not true 
        AND g.skipInMetrics != 1 
        AND g.groupTypeId != 'a54e3abf-69be-4115-bfe5-dd04fdc7d049'
        AND g.groupTypeId != 'd8ef8e02-e666-47b1-ba5b-55b2d02b66d5'
        AND g.groupTypeId != '59d5603c-f112-4687-8cb9-516467c91ae5'
        AND g.id != 'd67de29b-1dad-4a44-971b-2831ea49f47b'
        AND g.id != 'b8e98060-85ad-46bc-b546-4369351db09b'
        AND g.id != '6f711176-4ff1-4100-a3e3-14271a229b31' 

order by
    g.startDate desc
)

select

    sg.endDateWeek as 'Week Cohort',
    COUNT(sg.groupName) as "Sunsetting by EOW"

from 
    SunsettingGroups sg 

where
    sg.endDateWeek <= NOW()

group by 
    sg.endDateWeek 

order by 
    sg.endDateWeek desc  

LIMIT 12