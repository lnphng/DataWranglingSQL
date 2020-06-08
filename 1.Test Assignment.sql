--Ex1: Use the order_binary metric from the previous exercise, count the number of users
--per treatment group for test_id = 7, and count the number of users with orders (for test_id 7)

     SELECT
     test_assignment,
     COUNT(user_id)         AS users,
     SUM(checked_if_orders) AS orders_completed
    FROM 
       (SELECT
         test_events.user_id,
         test_id,
         test_assignment,
         MAX(CASE WHEN orders.created_at > test_events.event_time 
             THEN 1 
             ELSE 0
         END  ) AS checked_if_orders
       FROM
             (SELECT 
                 event_id,
                 event_time,
                 user_id,
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
             GROUP BY 
                 event_id,
                 event_time,
                 user_id,
                 platform
             ORDER BY 
                 event_id) test_events
       LEFT JOIN 
           dsv1069.orders
       ON 
           orders.user_id=test_events.user_id
       GROUP BY 
           test_id, 
           test_assignment,
           test_events.user_id
      )checked_orders
  WHERE 
    test_id=7
  GROUP BY
  test_assignment;
  
--Ex2: --Create a new tem view binary metric. Count the number of users per treatment
--group, and count the number of users with views (for test_id 7)


     SELECT
     test_assignment,
     COUNT(user_id)         AS users,
     SUM(checked_if_view) AS view_or_not
    FROM 
       (SELECT
         test_events.user_id,
         test_id,
         test_assignment,
        MAX(CASE WHEN views.event_time > test_events.event_time 
            THEN 1 
            ELSE 0
        END  ) AS checked_if_view
       FROM
             (SELECT 
                 event_id,
                 event_time,
                 user_id,
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
             GROUP BY 
                 event_id,
                 event_time,
                 user_id,
                 platform
             ORDER BY 
                 event_id) test_events
       LEFT JOIN 
           (
           SELECT 
                *
           FROM 
                dsv1069.events
           WHERE 
              event_name= 'view_item'
           )views
       ON 
           views.user_id=test_events.user_id
       GROUP BY 
           test_id, 
           test_assignment,
           test_events.user_id
      )checked_orders
  WHERE 
    test_id=7
  GROUP BY
  test_assignment;
  
-- compute the users who viewed an item WITHIN 30
--days of their treatment event


--Create a new tem view binary metric. Count the number of users per treatment
--group, and count the number of users with views (for test_id 7)


     SELECT
     test_assignment,
     COUNT(user_id)       AS users,
     SUM(checked_if_view) AS view_or_not,
     SUM(views_30_days)   AS view_30days_not
    FROM 
       (SELECT
         test_events.user_id,
         test_id,
         test_assignment,
        MAX(CASE WHEN views.event_time > test_events.event_time 
            THEN 1 
            ELSE 0
        END  ) AS checked_if_view,
        MAX(CASE WHEN (views.event_time > test_events.event_time
            AND DATE_PART('day', views.event_time - test_events.event_time) <= 30)
            THEN 1 
            ELSE 0
        END  ) AS views_30_days
        
       FROM
             (SELECT 
                 event_id,
                 event_time,
                 user_id,
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
             GROUP BY 
                 event_id,
                 event_time,
                 user_id,
                 platform
             ORDER BY 
                 event_id) test_events
       LEFT JOIN 
           (
           SELECT 
                *
           FROM 
                dsv1069.events
           WHERE 
              event_name= 'view_item'
           )views
       ON 
           views.user_id=test_events.user_id
       GROUP BY 
           test_id, 
           test_assignment,
           test_events.user_id
      )checked_orders
  WHERE 
    test_id=7
  GROUP BY
  test_assignment; 
