--Compare the final_assignments_qa table to the assignment events we captured for user_level_testing. 
--Write an answer to the following question: 
--Does this table have everything you need to compute metrics like 30-day view-binary?
--No, there are no information about the date and time to compute metrics like 30-day view-binary.


SELECT * 
FROM dsv1069.final_assignments_qa;

--Write a query and table creation statement to make final_assignments_qa look like 
--the final_assignments table. If you discovered something missing in part 1, 
--you may fill in the value with a place holder of the appropriate data type.

SELECT item_id,
       test_a AS test_assignment,
       (CASE WHEN test_a is NOT NULL THEN 'test_1' ELSE NULL END)                     AS test_number,
       (CASE WHEN test_a is NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END)        AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT item_id,
       test_b AS test_assignment,
       (CASE WHEN test_b is NOT NULL THEN 'test_2' ELSE NULL END)                     AS test_number,
       (CASE WHEN test_b is NOT NULL THEN '2016-01-07 00:00:00' ELSE NULL END)        AS test_start_date
FROM dsv1069.final_assignments_qa 

UNION

SELECT item_id,
       test_c AS test_assignment,
       (CASE WHEN test_c is NOT NULL THEN 'test_3' ELSE NULL END)                     AS test_number,
       (CASE WHEN test_c is NOT NULL THEN '2015-03-14 00:00:00' ELSE NULL END)        AS test_start_date
FROM dsv1069.final_assignments_qa                    

UNION

SELECT item_id,
       test_d AS test_assignment,
       (CASE WHEN test_d is NOT NULL THEN 'test_4' ELSE NULL END)                     AS test_number,
       (CASE WHEN test_d is NOT NULL THEN '2013-01-06 00:00:00' ELSE NULL END)        AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT item_id,
       test_e AS test_assignment,
       (CASE WHEN test_e is NOT NULL THEN 'test_5' ELSE NULL END)                      AS test_number, 
       (CASE WHEN test_e is NOT NULL THEN '2016-01-08 00:00:00' ELSE NULL END)         AS test_start_date
FROM dsv1069.final_assignments_qa

UNION

SELECT item_id,
       test_f AS test_assignment,
       (CASE WHEN test_f is NOT NULL THEN 'test_6' ELSE NULL END)                       AS test_number, 
       (CASE WHEN test_f is NOT NULL THEN '2015-03-15 00:00:00' ELSE NULL END)          AS test_start_date
FROM dsv1069.final_assignments_qa;

--calculate the order binary for the 30 day window after the test assignment for item_test_2 
--(You may include the day the test started)


SELECT  test_number, 
        test_assignment, 
        COUNT(distinct item_id) AS item_assignment, 
        SUM(order_binary)       AS order_binary_30_day
    
FROM
  ( 
    SELECT 
        test_events.item_id,
        test_events.test_number,
        test_events.test_assignment,
        test_events.created_at,
        test_events.test_start_date,
        (CASE WHEN  (created_at >  test_start_date AND 
             DATE_PART('day', created_at - test_start_date) <= 30) 
             THEN 1 
             ELSE 0 
         END) AS order_binary
     FROM
         (SELECT
              final_assignments.item_id, 
              final_assignments.test_number, 
              final_assignments.test_assignment, 
              DATE(orders.created_at) as created_at, 
              final_assignments.test_start_date
          FROM
              dsv1069.final_assignments 
          LEFT JOIN 
              dsv1069.orders 
          ON  final_assignments.item_id = orders.item_id
          WHERE 
              final_assignments.test_number = 'item_test_2'
         ) as test_events
         
     GROUP BY
          test_events.item_id,
          test_events.test_number,
          test_events.test_assignment,
          test_events.created_at,
          test_events.test_start_date
  ) order_binary_table
GROUP BY test_number, test_assignment;


--Use the final_assignments table to calculate the view binary, and average views for the 30 day window 
--after the test assignment for item_test_2. (You may include the day the test started)


SELECT
   test_assignment,
   SUM(binary_view) AS viewed_items,
   COUNT(item_id) AS items_assignment,
   SUM(views) AS total_views,
   SUM(views)/COUNT(item_id) AS average_views
FROM
(
   SELECT 
       final_assignments.test_assignment,
       final_assignments.item_id, 
       MAX(CASE WHEN views.event_time > final_assignments.test_start_date THEN 1 
       ELSE 0 
    END)  AS binary_view,
       COUNT(views.event_id) AS views
   FROM 
      dsv1069.final_assignments
   LEFT JOIN 
      (
         SELECT 
             event_time,
             event_id,
             CAST(parameter_value AS INT) AS item_id
         FROM 
             dsv1069.events 
         WHERE 
             event_name = 'view_item'
         AND 
             parameter_name = 'item_id'
      ) views
   ON       
        final_assignments.item_id = views.item_id
   AND      
        views.event_time >= final_assignments.test_start_date
   AND      
        DATE_PART('day', views.event_time - final_assignments.test_start_date ) <= 30 
   WHERE    
        final_assignments.test_number = 'item_test_2'
   GROUP BY
        final_assignments.item_id,
        final_assignments.test_assignment
)view_metrics
  
GROUP BY view_metrics.test_assignment;

