--Ex1
SELECT 
 parameter_value as Test_id,
COUNT(*)         AS event_rows
--COUNT(distinct parameter_value) as Test
FROM dsv1069.events
where 
event_name = 'test_assignment'
AND
parameter_name = 'test_id'

GROUP BY  parameter_value;


--Ex2
--Check for potential problems with test assignments. For example Make sure there
--is no data obviously missing (This is an open ended questio


SELECT 
    parameter_value  AS Test_id,
    DATE(event_time) AS Day,
    COUNT(*)         AS event_rows
FROM 
    dsv1069.events
where 
    event_name = 'test_assignment'
AND
    parameter_name = 'test_id'
GROUP BY 
    Test_id
    ,day
ORDER BY Day;

--Ex3: Write a query that returns a table of assignment events.Please include all of the
-- relevant parameters as columns (Hint: A previous exercise as a template)

SELECT 
    event_id,
    event_time,
    user_id,
    platform,
    MAX(CASE WHEN parameter_name = 'test_id' 
          THEN CAST(parameter_value AS INT)
          ELSE NULL
        END) as Test_id,
    MAX(CASE WHEN parameter_value ='test_assignment'
          THEN parameter_value
          ELSE NULL
        END) AS test_assignment
FROM 
    dsv1069.events
where 
    event_name = 'test_assignment'
AND
    parameter_name = 'test_id'
GROUP BY 
    event_id,
    event_time,
    user_id,
    platform
ORDER BY 
    event_id;
    
--Ex4
-- Check for potential assignment problems with test_id 5. Specifically, make sure
-- users are assigned only one treatment group.he
SELECT
  test_id,
  user_id,
  COUNT(DISTINCT test_assignment) AS assignments
FROM
      (SELECT 
          event_id,
          event_time,
          user_id,
          platform,
          MAX(CASE WHEN parameter_name = 'test_id' 
                THEN CAST(parameter_value AS INT)
                 ELSE NULL
              END) as test_id,
          MAX(CASE WHEN parameter_name ='test_assignment'
                THEN parameter_value
                ELSE NULL
              END) AS test_assignment
      FROM 
          dsv1069.events
      where 
          event_name = 'test_assignment'
      GROUP BY 
          event_id,
          event_time,
          user_id,
          platform
      ORDER BY 
          event_id) test_events
GROUP BY test_id, user_id
ORDER by assignments DESC;


--Ex5
SELECT test_id,
       user_id,
       COUNT(DISTINCT test_assignment) AS assignments
FROM
  (SELECT event_id,
          event_time,
          user_id,
          platform,
          MAX(CASE
                  WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT)
                  ELSE NULL
              END) AS test_id,
          MAX(CASE
                  WHEN parameter_name = 'test_assignment' THEN parameter_value
                  ELSE NULL
              END) AS test_assignment
   FROM dsv1069.events
   WHERE event_name = 'test_assignment'
   GROUP BY event_id,
            event_time,
            user_id,
            platform
   ORDER BY event_id) test_events
GROUP BY test_id,
         user_id
ORDER BY assignments DESC;

